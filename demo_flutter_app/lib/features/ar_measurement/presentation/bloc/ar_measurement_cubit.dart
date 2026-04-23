import 'dart:math' as math;
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:flutter/painting.dart' show Offset;
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/measurement_point.dart';
import '../../domain/entities/surface_type.dart';
import '../../domain/usecases/get_floor_plan.dart';
import 'ar_measurement_state.dart';

/// Maximum number of points across all paths.
const int _kMaxTotalPoints = 60;

/// Minimum time between two consecutive placements.
const Duration _kMinTapInterval = Duration(milliseconds: 250);

/// Deadband: screen-position change smaller than this skips a repaint.
const double _kScreenDeadbandPx = 1.5;

/// Camera pitch threshold (radians) for floor/ceiling auto-detection.
/// ~25 degrees
const double _kPitchThreshold = 0.44;

class ArMeasurementCubit extends Cubit<ArMeasurementState> {
  // -------------------------------------------------------------------------
  // Dependencies
  // -------------------------------------------------------------------------
  final GetFloorPlanUseCase _getFloorPlan;
  final String? perfiosId;

  // -------------------------------------------------------------------------
  // AR plugin references (set when the AR view is ready)
  // -------------------------------------------------------------------------
  ARSessionManager? _sessionManager;
  ARAnchorManager? _anchorManager;

  /// Anchor lookup so we can remove individual anchors on undo.
  final Map<String, ARAnchor> _anchorsByName = {};

  /// Timestamp of the last successfully placed point.
  DateTime? _lastPlacementAt;

  // -------------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------------
  ArMeasurementCubit({
    required GetFloorPlanUseCase getFloorPlan,
    this.perfiosId,
  })  : _getFloorPlan = getFloorPlan,
        super(const ArMeasurementState());

  // =========================================================================
  // AR session lifecycle
  // =========================================================================

  void onArSessionReady({
    required ARSessionManager sessionManager,
    required ARAnchorManager anchorManager,
  }) {
    _sessionManager = sessionManager;
    _anchorManager = anchorManager;
    emit(state.copyWith(statusText: 'Scan the surface for planes.'));
  }

  // =========================================================================
  // Continuous frame update — called by the Ticker in the page widget.
  // Returns true if any screen position changed (triggers overlay repaint).
  // =========================================================================

  Future<bool> updateProjections(
    vm.Matrix4 projectionMatrix,
    vm.Matrix4 cameraPose,
    double viewportWidth,
    double viewportHeight,
  ) async {
    if (state.paths.isEmpty) return false;

    // ── Auto-detect surface from camera pitch ──────────────────────────────
    final detected = _detectSurfaceFromPose(cameraPose);
    if (detected != state.detectedSurface) {
      emit(state.copyWith(
        detectedSurface: detected,
        statusText: detected.scanHint,
      ));
    }

    // ── Project every world-point to screen coords ─────────────────────────
    final viewMatrix = vm.Matrix4.inverted(cameraPose);
    final vpMatrix = projectionMatrix * viewMatrix;

    bool changed = false;
    final updatedPaths = state.paths.map((path) {
      return path.map((pt) {
        final worldVec = vm.Vector4(
          pt.worldPos.x,
          pt.worldPos.y,
          pt.worldPos.z,
          1.0,
        );
        final ndcVec = vpMatrix * worldVec;
        if (ndcVec.w <= 0) return pt; // behind camera

        final screenX = (ndcVec.x / ndcVec.w + 1.0) * 0.5 * viewportWidth;
        final screenY = (1.0 - ndcVec.y / ndcVec.w) * 0.5 * viewportHeight;
        final newPos = Offset(screenX, screenY);

        if ((pt.screenPos - newPos).distance > _kScreenDeadbandPx) {
          changed = true;
          return pt.copyWithScreenPos(newPos);
        }
        return pt;
      }).toList();
    }).toList();

    if (changed) {
      // Only update the paths — don't emit a full state to avoid rebuilding
      // the whole widget tree.  The overlay uses a ValueNotifier instead.
      emit(state.copyWith(paths: updatedPaths));
    }

    return changed;
  }

  // =========================================================================
  // Tap handler — the most critical method
  // =========================================================================

  Future<void> onPlaneOrPointTapped(
    List<ARHitTestResult> hitResults,
    Offset tapPosition,
  ) async {
    if (_sessionManager == null) return;

    // Debounce
    final now = DateTime.now();
    if (_lastPlacementAt != null &&
        now.difference(_lastPlacementAt!) < _kMinTapInterval) {
      return;
    }

    // Point limit
    if (state.totalPointCount >= _kMaxTotalPoints) {
      emit(state.copyWith(
        statusText:
            'Point limit reached ($_kMaxTotalPoints). Clear or undo to continue.',
      ));
      return;
    }

    // ── 1. Determine intended surface from camera pose ─────────────────────
    final cameraPose = await _sessionManager!.getCameraPose();
    final intendedSurface = cameraPose != null
        ? _detectSurfaceFromPose(cameraPose)
        : SurfaceType.floor;

    // ── 2. Surface-aware hit selection ─────────────────────────────────────
    ARHitTestResult? hit = _selectBestHit(hitResults, intendedSurface);

    // ── 3. Fallback: estimate from camera direction ─────────────────────────
    vm.Vector3? worldPos;
    if (hit != null) {
      final t = hit.worldTransform.getTranslation();
      worldPos = vm.Vector3(t.x, t.y, t.z);
    } else if (cameraPose != null) {
      worldPos = _estimateFallbackPoint(cameraPose, intendedSurface);
    }

    if (worldPos == null) {
      emit(state.copyWith(
        statusText: 'No stable surface detected. Move slowly and try again.',
      ));
      return;
    }

    // ── 4. Create anchor ───────────────────────────────────────────────────
    String? anchorName;
    if (hit != null) {
      final anchor = ARPlaneAnchor(transformation: hit.worldTransform);
      _anchorManager?.addAnchor(anchor);
      anchorName = anchor.name;
      _anchorsByName[anchorName] = anchor;
    }

    final point = MeasurementPoint(
      screenPos: tapPosition,
      worldPos: worldPos,
      anchorName: anchorName,
    );

    // ── 5. Commit to state ─────────────────────────────────────────────────
    final paths = state.paths.map((p) => List<MeasurementPoint>.from(p)).toList();
    int newPathIndex = state.currentPathIndex;

    if (paths.isEmpty ||
        state.currentPathIndex == -1 ||
        state.startNewPathOnNextTap) {
      paths.add([point]);
      newPathIndex = paths.length - 1;
    } else {
      paths[state.currentPathIndex].add(point);
    }

    final isFallback = hit == null;
    final distStr = _computeTotalDistance(paths).toStringAsFixed(2);

    emit(state.copyWith(
      paths: paths,
      currentPathIndex: newPathIndex,
      startNewPathOnNextTap: false,
      statusText: isFallback
          ? 'Point added (estimated). Total: ${distStr}m'
          : 'Point added. Total: ${distStr}m',
    ));

    _lastPlacementAt = now;
  }

  // =========================================================================
  // User actions
  // =========================================================================

  void undoLastPoint() {
    if (!state.hasPaths || state.currentPathIndex == -1) return;

    final paths = state.paths.map((p) => List<MeasurementPoint>.from(p)).toList();
    final currentPath = paths[state.currentPathIndex];

    if (currentPath.isNotEmpty) {
      final removed = currentPath.removeLast();
      _removeAnchor(removed);
    }

    String statusText;
    int newPathIndex = state.currentPathIndex;

    if (currentPath.isEmpty) {
      paths.removeAt(state.currentPathIndex);
      newPathIndex = paths.isEmpty ? -1 : paths.length - 1;
      statusText = 'Line removed.';
    } else {
      statusText = 'Point removed.';
    }

    emit(state.copyWith(
      paths: paths,
      currentPathIndex: newPathIndex,
      statusText: statusText,
    ));
  }

  void startNewPath() {
    if (!state.hasPaths) return;
    emit(state.copyWith(
      startNewPathOnNextTap: true,
      statusText: 'Next tap starts a new line.',
    ));
  }

  void clearAll() {
    _removeAllAnchors();
    emit(state.copyWith(
      paths: [],
      currentPathIndex: -1,
      startNewPathOnNextTap: false,
      statusText: 'Cleared. Tap to start new.',
    ));
  }

  // =========================================================================
  // Recording
  // =========================================================================

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // 1. Request necessary permissions
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        emit(state.copyWith(statusText: 'Microphone permission denied.'));
        return;
      }

      // Notification permission (Android 13+)
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      // Storage permission is trickier on Android 11+
      // For Gal.putVideo, we usually don't need it on modern Android,
      // but for manual file copying we might.
      // We'll skip explicit storage check here as Gal handles it,
      // and use temp directory for the recording itself.

      final String fileName =
          'measurement_${DateTime.now().millisecondsSinceEpoch}';

      emit(state.copyWith(statusText: 'Requesting screen capture...'));

      final bool started = await FlutterScreenRecording.startRecordScreenAndAudio(
        fileName,
        titleNotification: 'Screen Recording',
        messageNotification: 'Recording AR measurement session',
      );

      if (started) {
        emit(state.copyWith(
          isRecording: true,
          statusText: 'Recording started...',
        ));
      } else {
        emit(state.copyWith(statusText: 'Recording failed to start.'));
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      emit(state.copyWith(statusText: 'Error starting recording: $e'));
    }
  }

  Future<void> _stopRecording() async {
    try {
      emit(state.copyWith(statusText: 'Saving recording...'));
      final String path = await FlutterScreenRecording.stopRecordScreen;

      if (path.isNotEmpty) {
        final File recordedFile = File(path);
        if (await recordedFile.exists() && await recordedFile.length() > 0) {
          // Save to gallery
          await Gal.putVideo(path);

          // Optional: Backup to app-specific external storage
          final Directory? appDir = await getExternalStorageDirectory();
          if (appDir != null) {
            final String videoDir = '${appDir.path}/Recordings';
            await Directory(videoDir).create(recursive: true);
            final String backupPath =
                '$videoDir/${recordedFile.uri.pathSegments.last}';
            await recordedFile.copy(backupPath);
          }

          emit(state.copyWith(
            isRecording: false,
            statusText: 'Video saved to gallery!',
          ));
        } else {
          emit(state.copyWith(
            isRecording: false,
            statusText: 'Recording failed: file was empty.',
          ));
        }
      } else {
        emit(state.copyWith(
          isRecording: false,
          statusText: 'Recording stopped (no path).',
        ));
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      emit(state.copyWith(
        isRecording: false,
        statusText: 'Error stopping recording: $e',
      ));
    }
  }

  // =========================================================================
  // Floor plan
  // =========================================================================

  Future<void> fetchFloorPlan() async {
    if (perfiosId == null) return;
    emit(state.copyWith(isLoadingFloorPlan: true));
    final url = await _getFloorPlan(perfiosId!);
    if (url != null) {
      emit(state.copyWith(floorPlanUrl: url, isLoadingFloorPlan: false));
    } else {
      emit(state.copyWith(isLoadingFloorPlan: false));
    }
  }

  // =========================================================================
  // Cleanup
  // =========================================================================

  @override
  Future<void> close() {
    _removeAllAnchors();
    return super.close();
  }

  // =========================================================================
  // Private helpers
  // =========================================================================

  /// Classifies hits and picks the one that best matches [intended].
  ///
  /// Priority order:
  ///   1. Plane hit matching the intended surface (nearest first)
  ///   2. Any plane hit (nearest)
  ///   3. Point cloud hit (nearest)
  ARHitTestResult? _selectBestHit(
    List<ARHitTestResult> results,
    SurfaceType intended,
  ) {
    // Separate planes and points
    final planes = results
        .where((h) => h.type == ARHitTestResultType.plane)
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));

    final points = results
        .where((h) => h.type == ARHitTestResultType.point)
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));

    // Filter planes by intended surface (using normal Y component)
    final matchingPlanes = planes.where((h) {
      final surface = _surfaceFromHitNormal(h);
      return surface == intended;
    }).toList();

    if (matchingPlanes.isNotEmpty) return matchingPlanes.first;
    if (planes.isNotEmpty) return planes.first; // fallback to any plane
    if (points.isNotEmpty) return points.first;
    return null;
  }

  /// Infers surface type from a hit result's world-transform normal (Y column).
  SurfaceType _surfaceFromHitNormal(ARHitTestResult hit) {
    // The Y column of the plane transform is the surface normal.
    final normalY = hit.worldTransform.entry(1, 1);
    return _classifyNormalY(normalY);
  }

  /// Infers surface type from the camera's forward direction and pitch.
  SurfaceType _detectSurfaceFromPose(vm.Matrix4 pose) {
    // Camera forward in world space: -Z column
    final forwardY = -pose.entry(1, 2);
    // forwardY > 0 → camera tilted upward (looking at ceiling)
    // forwardY < 0 → camera tilted downward (looking at floor)
    if (forwardY > math.sin(_kPitchThreshold)) return SurfaceType.ceiling;
    if (forwardY < -math.sin(_kPitchThreshold)) return SurfaceType.floor;
    return SurfaceType.wall;
  }

  SurfaceType _classifyNormalY(double normalY) {
    if (normalY > 0.7) return SurfaceType.floor;
    if (normalY < -0.7) return SurfaceType.ceiling;
    return SurfaceType.wall;
  }

  /// Estimates a world point along the camera's look direction.
  /// Adapts the direction and distance based on [surface].
  vm.Vector3 _estimateFallbackPoint(
    vm.Matrix4 cameraPose,
    SurfaceType surface,
  ) {
    final camPos = cameraPose.getTranslation();

    // Camera forward vector: -Z column of pose matrix
    final fx = -cameraPose.entry(0, 2);
    final fy = -cameraPose.entry(1, 2);
    final fz = -cameraPose.entry(2, 2);
    final forward = vm.Vector3(fx, fy, fz)..normalize();

    // Adaptive distance: use actual camera pitch to refine ceiling height.
    double dist = surface.fallbackDistance;
    if (surface == SurfaceType.ceiling) {
      // If camera is pitched more steeply upward, user is likely closer to ceiling.
      final pitch = math.asin(forward.y.clamp(-1.0, 1.0)); // radians
      // Map pitch 25°→90° to distance 3.5→2.5 m
      final t = ((pitch - _kPitchThreshold) /
              (math.pi / 2 - _kPitchThreshold))
          .clamp(0.0, 1.0);
      dist = 3.5 - t * 1.0; // 3.5 m at low pitch, 2.5 m straight up
    }

    return vm.Vector3(
      camPos.x + forward.x * dist,
      camPos.y + forward.y * dist,
      camPos.z + forward.z * dist,
    );
  }

  double _computeTotalDistance(List<List<MeasurementPoint>> paths) {
    double sum = 0;
    for (final path in paths) {
      for (var i = 1; i < path.length; i++) {
        sum += (path[i].worldPos - path[i - 1].worldPos).length;
      }
    }
    return sum;
  }

  void _removeAnchor(MeasurementPoint point) {
    final name = point.anchorName;
    if (name == null) return;
    final anchor = _anchorsByName.remove(name);
    if (anchor != null) _anchorManager?.removeAnchor(anchor);
  }

  void _removeAllAnchors() {
    for (final anchor in _anchorsByName.values) {
      _anchorManager?.removeAnchor(anchor);
    }
    _anchorsByName.clear();
  }
}
