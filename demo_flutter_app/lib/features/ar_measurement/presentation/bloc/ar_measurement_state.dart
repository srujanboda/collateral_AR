import 'package:flutter/foundation.dart' show immutable;
import '../../domain/entities/measurement_point.dart';
import '../../domain/entities/surface_type.dart';

@immutable
class ArMeasurementState {
  /// All measurement paths. Each path is an ordered list of placed points.
  final List<List<MeasurementPoint>> paths;

  /// Index of the path currently being built. -1 means no active path.
  final int currentPathIndex;

  /// Status message shown in the top pill.
  final String statusText;

  /// The surface the camera is currently aimed at (auto-detected).
  final SurfaceType detectedSurface;

  /// Whether the next tap should start a brand-new path.
  final bool startNewPathOnNextTap;

  /// Whether screen recording is active.
  final bool isRecording;

  /// Floor-plan image URL, null while loading or unavailable.
  final String? floorPlanUrl;

  /// True while the floor-plan is being fetched or uploaded.
  final bool isLoadingFloorPlan;

  const ArMeasurementState({
    this.paths = const [],
    this.currentPathIndex = -1,
    this.statusText = 'Scan the surface, then tap to place a point.',
    this.detectedSurface = SurfaceType.floor,
    this.startNewPathOnNextTap = false,
    this.isRecording = false,
    this.floorPlanUrl,
    this.isLoadingFloorPlan = false,
  });

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  bool get hasPaths => paths.isNotEmpty;

  int get totalPointCount =>
      paths.fold(0, (sum, path) => sum + path.length);

  double get totalDistanceMeters {
    double sum = 0;
    for (final path in paths) {
      for (var i = 1; i < path.length; i++) {
        sum += (path[i].worldPos - path[i - 1].worldPos).length;
      }
    }
    return sum;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  ArMeasurementState copyWith({
    List<List<MeasurementPoint>>? paths,
    int? currentPathIndex,
    String? statusText,
    SurfaceType? detectedSurface,
    bool? startNewPathOnNextTap,
    bool? isRecording,
    String? floorPlanUrl,
    bool? isLoadingFloorPlan,
    bool clearFloorPlanUrl = false,
  }) {
    return ArMeasurementState(
      paths: paths ?? this.paths,
      currentPathIndex: currentPathIndex ?? this.currentPathIndex,
      statusText: statusText ?? this.statusText,
      detectedSurface: detectedSurface ?? this.detectedSurface,
      startNewPathOnNextTap:
          startNewPathOnNextTap ?? this.startNewPathOnNextTap,
      isRecording: isRecording ?? this.isRecording,
      floorPlanUrl: clearFloorPlanUrl ? null : (floorPlanUrl ?? this.floorPlanUrl),
      isLoadingFloorPlan: isLoadingFloorPlan ?? this.isLoadingFloorPlan,
    );
  }
}
