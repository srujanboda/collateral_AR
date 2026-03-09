import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart' as vm hide Colors;
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:gal/gal.dart';

// ---------- Data model -------------------------------------------------
class MeasurementPoint {
  Offset screenPos;
  final vm.Vector3 worldPos;
  final String? anchorName;

  MeasurementPoint({
    required this.screenPos,
    required this.worldPos,
    this.anchorName,
  });
}

// ---------- CustomPainter ----------------------------------------------
class MeasurementPainter extends CustomPainter {
  final List<List<MeasurementPoint>> paths;

  // Optimized styles
  static const _lineColors = [Color(0xFF2E7D32)];
  static final _linePaint = Paint()
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;
  static final _dotFill = Paint()..color = Colors.white;
  static final _dotStroke = Paint()
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  MeasurementPainter(this.paths);

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    for (var pi = 0; pi < paths.length; pi++) {
      final path = paths[pi];
      final color = _lineColors[pi % _lineColors.length];

      _linePaint.color = color;
      _dotStroke.color = color;

      // Draw lines + distance labels
      for (var i = 1; i < path.length; i++) {
        final a = path[i - 1].screenPos;
        final b = path[i].screenPos;

        canvas.drawLine(a, b, _linePaint);

        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        final dist = _dist3(path[i - 1].worldPos, path[i].worldPos);
        _drawLabel(canvas, '${dist.toStringAsFixed(2)} m', mid, color);
      }

      // Draw dots
      for (var di = 0; di < path.length; di++) {
        final pt = path[di];
        canvas.drawCircle(pt.screenPos, 9, _dotFill);
        canvas.drawCircle(pt.screenPos, 9, _dotStroke);
        _drawDotIndex(canvas, di + 1, pt.screenPos);
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center, Color lineColor) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 12.0,
        height: tp.height + 6.0,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, Paint()..color = lineColor);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDotIndex(Canvas canvas, int index, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: '$index',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  double _dist3(vm.Vector3 a, vm.Vector3 b) {
    return (b - a).length;
  }

  @override
  bool shouldRepaint(MeasurementPainter oldDelegate) => true;
}

// ---------- Screen StatefulWidget --------------------------------------
class ArMeasurementScreen extends StatefulWidget {
  const ArMeasurementScreen({super.key});

  @override
  State<ArMeasurementScreen> createState() => _ArMeasurementScreenState();
}

class _ArMeasurementScreenState extends State<ArMeasurementScreen>
    with TickerProviderStateMixin {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;
  late Ticker _ticker;
  Duration _lastTickTime = Duration.zero;

  final List<List<MeasurementPoint>> _paths = [];
  int _currentPathIndex = -1;
  bool _startNewPathOnNextTap = false;
  Offset? _lastTapPosition;
  bool _isRecording = false;

  String _statusText = 'Scan the surface, then tap to place a point.';

  double get _totalDistance {
    double sum = 0;
    for (final path in _paths) {
      if (path.length < 2) continue;
      for (var i = 1; i < path.length; i++) {
        sum += _segmentLength(path[i - 1].worldPos, path[i].worldPos);
      }
    }
    return sum;
  }

  @override
  void initState() {
    super.initState();
    // Enable immersive full-screen mode for better AR alignment
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _arSessionManager?.dispose();
    super.dispose();
  }

  bool _isProcessingTick = false;
  void _onTick(Duration elapsed) async {
    if (_arSessionManager == null || _paths.isEmpty || _isProcessingTick)
      return;

    // Throttle to ~30 FPS (every 33ms) to save CPU for AR engine
    if ((elapsed - _lastTickTime).inMilliseconds < 33) return;
    _lastTickTime = elapsed;

    _isProcessingTick = true;

    try {
      final cameraPose = await _arSessionManager!.getCameraPose();
      if (cameraPose == null) {
        _isProcessingTick = false;
        return;
      }

      final viewMatrix = vm.Matrix4.inverted(cameraPose);

      if (!mounted) {
        _isProcessingTick = false;
        return;
      }

      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        _isProcessingTick = false;
        return;
      }
      final size = renderBox.size;

      // Typical mobile AR camera vertical FOV is around 63.5 degrees for 16:9.
      final projectionMatrix = vm.makePerspectiveMatrix(
        vm.radians(63.5),
        size.aspectRatio,
        0.01,
        1000.0,
      );

      final vpMatrix = projectionMatrix * viewMatrix;
      final pixelWidth = size.width;
      final pixelHeight = size.height;

      bool changed = false;
      for (var path in _paths) {
        for (var pt in path) {
          // Project 3D world position to 2D screen coordinates
          final worldVec = vm.Vector4(
            pt.worldPos.x,
            pt.worldPos.y,
            pt.worldPos.z,
            1.0,
          );
          final ndcVec = vpMatrix * worldVec;

          if (ndcVec.w <= 0) continue; // Behind camera

          final screenX = (ndcVec.x / ndcVec.w + 1.0) * 0.5 * pixelWidth;
          final screenY = (1.0 - ndcVec.y / ndcVec.w) * 0.5 * pixelHeight;

          final newPos = Offset(screenX, screenY);
          // Only trigger a rebuild if the movement is significant (> 0.5 pixel)
          if ((pt.screenPos - newPos).distance > 0.5) {
            pt.screenPos = newPos;
            changed = true;
          }
        }
      }

      if (changed && mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Tick error: $e");
    } finally {
      _isProcessingTick = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. AR camera + tap handler
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  _lastTapPosition = event.localPosition;
                },
                child: ARView(
                  onARViewCreated: _onARViewCreated,
                  planeDetectionConfig:
                      PlaneDetectionConfig.horizontalAndVertical,
                ),
              ),

              // 2. Dots + lines + distance labels overlay
              IgnorePointer(
                child: CustomPaint(
                  painter: MeasurementPainter(_paths),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              ),

              // 3. Centre reticle
              _buildCenterReticle(),

              // 4. Floating Status Pill (Top)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildStatusPill(),
                  ),
                ),
              ),

              // 5. Bottom UI Section (Floating)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBottomDistanceBanner(),
                        const SizedBox(height: 12),
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent, size: 14),
          const SizedBox(width: 8),
          Text(
            _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDistanceBanner() {
    final hasAnyDistance = _paths.any((p) => p.length > 1);
    if (!hasAnyDistance) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF32BA7C), // Vibrant green from screenshot
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Dimensions measured successfully',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_totalDistance.toStringAsFixed(2)} m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final hasPaths = _paths.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: Icons.undo,
            onPressed: hasPaths ? _undoLastPoint : null,
            label: "Undo",
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.add,
            color: const Color(0xFF00E5FF),
            onPressed: hasPaths
                ? () {
                    setState(() {
                      _startNewPathOnNextTap = true;
                      _statusText = 'Next tap starts a new line.';
                    });
                  }
                : null,
            label: "New Line",
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete_outline,
            color: Colors.redAccent,
            onPressed: hasPaths
                ? () {
                    setState(() {
                      _paths.clear();
                      _currentPathIndex = -1;
                      _startNewPathOnNextTap = false;
                      _statusText = 'Cleared. Tap to start new.';
                    });
                  }
                : null,
            label: "Clear",
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: _isRecording ? Icons.stop : Icons.videocam,
            color: _isRecording ? Colors.red : Colors.blue,
            onPressed: _toggleRecording,
            label: _isRecording ? "Stop" : "Record",
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onPressed,
    Color color = Colors.white,
    required String label,
  }) {
    final bool isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isEnabled ? color : Colors.white24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white70 : Colors.white10,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterReticle() {
    return IgnorePointer(
      child: Stack(
        children: [
          // The actual "plus" icon at the dead center
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 20, color: Colors.white),
              ),
            ),
          ),
          // Instruction text offset below the center
          Center(
            child: Transform.translate(
              offset: const Offset(0, 60),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "POINT AND TAP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) async {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    await _arSessionManager?.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      hitTestFromCenter: true,
    );
    await _arObjectManager?.onInitialize();

    _arSessionManager?.onPlaneOrPointTap = _onPlaneOrPointTapped;

    setState(() {
      _statusText = 'Scan the surface for planes.';
    });

    _ticker.start();
  }

  void _onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) {
    if (hitTestResults.isEmpty || _arSessionManager == null) return;

    final hit = hitTestResults.first;
    final rawWorld = hit.worldTransform.getTranslation();
    final worldPos = vm.Vector3(rawWorld.x, rawWorld.y, rawWorld.z);

    // Instead of using Gesture detector position which is tricky with ARView,
    // we capture the actual tap position directly using a Listener.
    // If not available, fallback to the center of the screen.
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final fallbackCenter = renderBox.size.center(Offset.zero);
    final tapPos = _lastTapPosition ?? fallbackCenter;

    // Create an anchor at the hit location
    final newAnchor = ARPlaneAnchor(transformation: hit.worldTransform);
    _arAnchorManager?.addAnchor(newAnchor);

    final point = MeasurementPoint(
      screenPos: tapPos,
      worldPos: worldPos,
      anchorName: newAnchor.name,
    );

    setState(() {
      if (_paths.isEmpty || _currentPathIndex == -1 || _startNewPathOnNextTap) {
        _paths.add([point]);
        _currentPathIndex = _paths.length - 1;
        _startNewPathOnNextTap = false;
        _statusText = 'Point placed! Move and tap again.';
      } else {
        final currentPath = _paths[_currentPathIndex];
        currentPath.add(point);
        _statusText =
            'Point added. Total: ${_totalDistance.toStringAsFixed(2)}m';
      }
    });
  }

  double _segmentLength(vm.Vector3 a, vm.Vector3 b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dz = b.z - a.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  void _undoLastPoint() {
    if (_paths.isEmpty || _currentPathIndex == -1) return;
    setState(() {
      final currentPath = _paths[_currentPathIndex];
      if (currentPath.isNotEmpty) currentPath.removeLast();
      if (currentPath.isEmpty) {
        _paths.removeAt(_currentPathIndex);
        _currentPathIndex = _paths.isEmpty ? -1 : _paths.length - 1;
        _statusText = 'Line removed.';
      } else {
        _statusText = 'Point removed.';
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopScreenRecording();
    } else {
      await _startScreenRecording();
    }
  }

  Future<void> _startScreenRecording() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      setState(() {
        _statusText = 'Permissions denied.';
      });
      return;
    }

    try {
      final Directory? appDirectory = await getExternalStorageDirectory();
      final String videoDirectory = '${appDirectory!.path}/Recordings';
      await Directory(videoDirectory).create(recursive: true);
      final String fileName =
          'measurement_${DateTime.now().millisecondsSinceEpoch}';

      bool started = await FlutterScreenRecording.startRecordScreenAndAudio(
        fileName,
      );

      if (started) {
        setState(() {
          _isRecording = true;
          _statusText = 'Recording started...';
        });
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
      setState(() {
        _statusText = 'Error starting recording.';
      });
    }
  }

  Future<void> _stopScreenRecording() async {
    try {
      String path = await FlutterScreenRecording.stopRecordScreen;
      if (path.isNotEmpty) {
        // 1. Save to system gallery
        await Gal.putVideo(path);

        // 2. Move to persistent recordings directory for app gallery
        final Directory? appDirectory = await getExternalStorageDirectory();
        if (appDirectory != null) {
          final String videoDirectory = '${appDirectory.path}/Recordings';
          final String fileName =
              'measurement_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final String newPath = '$videoDirectory/$fileName';

          final File recordedFile = File(path);
          if (await recordedFile.exists()) {
            await recordedFile.copy(newPath);
            debugPrint("Video copied to persistent storage: $newPath");
          }
        }

        setState(() {
          _isRecording = false;
          _statusText = 'Video saved to gallery!';
        });
      } else {
        setState(() {
          _isRecording = false;
          _statusText = 'Recording stopped.';
        });
      }
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      setState(() {
        _isRecording = false;
        _statusText = 'Error stopping recording.';
      });
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.camera,
    ].request();

    return statuses[Permission.microphone]!.isGranted &&
        (statuses[Permission.storage]!.isGranted ||
            statuses[Permission.manageExternalStorage]!.isGranted);
  }
}
