import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';

import 'package:image_picker/image_picker.dart';


import '../../data/repositories/ar_repository_impl.dart';
import '../../domain/usecases/get_floor_plan.dart';
import '../bloc/ar_measurement_cubit.dart';
import '../bloc/ar_measurement_state.dart';
import '../widgets/measurement_painter.dart';
import '../widgets/ar_action_buttons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point widget — provides the Cubit
// ─────────────────────────────────────────────────────────────────────────────

class ArMeasurementScreen extends StatelessWidget {
  final String? perfiosId;

  const ArMeasurementScreen({super.key, this.perfiosId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ArMeasurementCubit(
          getFloorPlan: GetFloorPlanUseCase(const ArRepositoryImpl()),
          perfiosId: perfiosId,
        );
        if (perfiosId != null) cubit.fetchFloorPlan();
        return cubit;
      },
      child: const _ArMeasurementPage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner stateful page — owns the Ticker and AR managers
// ─────────────────────────────────────────────────────────────────────────────

class _ArMeasurementPage extends StatefulWidget {
  const _ArMeasurementPage();

  @override
  State<_ArMeasurementPage> createState() => _ArMeasurementPageState();
}

class _ArMeasurementPageState extends State<_ArMeasurementPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // AR session references
  ARSessionManager? _sessionManager;

  // Performance-optimised overlay trigger: repaint only the CustomPaint layer
  final ValueNotifier<int> _overlayTrigger = ValueNotifier(0);

  // Throttle projection updates to ~30 FPS
  static const Duration _kUpdateInterval = Duration(milliseconds: 33);
  Duration _lastTickTime = Duration.zero;
  bool _isProcessingTick = false;
  late Ticker _ticker;

  // Last raw tap position captured via Listener (before ARView consumes it)
  Offset? _lastTapPosition;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_ticker.isActive) _ticker.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_sessionManager != null && !_ticker.isActive) _ticker.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _overlayTrigger.dispose();
    _sessionManager?.dispose();
    super.dispose();
  }

  // ── Projection ticker ──────────────────────────────────────────────────────

  void _onTick(Duration elapsed) async {
    if (_sessionManager == null || _isProcessingTick) return;
    if (elapsed - _lastTickTime < _kUpdateInterval) return;
    _lastTickTime = elapsed;
    _isProcessingTick = true;

    try {
      final frameData = await _sessionManager!.getFrameData();
      if (frameData == null || !mounted) return;

      final cameraPose = frameData['cameraPose']!;
      final projectionMatrix = frameData['projectionMatrix']!;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final size = renderBox.size;

      final cubit = context.read<ArMeasurementCubit>();
      final changed = await cubit.updateProjections(
        projectionMatrix,
        cameraPose,
        size.width,
        size.height,
      );

      if (changed && mounted) _overlayTrigger.value++;
    } catch (e) {
      debugPrint('Tick error: $e');
    } finally {
      _isProcessingTick = false;
    }
  }

  // ── AR view ready ─────────────────────────────────────────────────────────

  Future<void> _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) async {
    _sessionManager = arSessionManager;

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      hitTestFromCenter: true,
    );
    arObjectManager.onInitialize();

    arSessionManager.onPlaneOrPointTap = (hitResults) {
      final renderBox = context.findRenderObject() as RenderBox?;
      final fallback = renderBox?.size.center(Offset.zero) ?? Offset.zero;
      context.read<ArMeasurementCubit>().onPlaneOrPointTapped(
            hitResults,
            _lastTapPosition ?? fallback,
          );
    };

    context.read<ArMeasurementCubit>().onArSessionReady(
          sessionManager: arSessionManager,
          anchorManager: arAnchorManager,
        );

    if (!_ticker.isActive) _ticker.start();
  }

  // ── Floor plan overlay ────────────────────────────────────────────────────

  Future<void> _pickAndUploadFloorPlan() async {
    final perfiosId = context.read<ArMeasurementCubit>().perfiosId;
    if (perfiosId == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final repo = const ArRepositoryImpl();
    final success = await repo.uploadFloorPlan(perfiosId, image.path);

    if (!mounted) return;
    if (success) {
      await context.read<ArMeasurementCubit>().fetchFloorPlan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Floor plan uploaded successfully!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload floor plan.')),
      );
    }
  }

  void _showFloorPlanOverlay() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ArMeasurementCubit>(),
        child: _FloorPlanDialog(onUpload: _pickAndUploadFloorPlan),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. AR camera view + raw tap capture
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) => _lastTapPosition = e.localPosition,
                child: ARView(
                  onARViewCreated: _onARViewCreated,
                  planeDetectionConfig:
                      PlaneDetectionConfig.horizontalAndVertical,
                ),
              ),

              // 2. Measurement overlay (dots, lines, labels)
              IgnorePointer(
                child: ValueListenableBuilder<int>(
                  valueListenable: _overlayTrigger,
                  builder: (context, value, child) {
                    return BlocBuilder<ArMeasurementCubit, ArMeasurementState>(
                      buildWhen: (prev, curr) => prev.paths != curr.paths,
                      builder: (context, state) => CustomPaint(
                        painter: MeasurementPainter(
                          state.paths,
                          activePathIndex: state.currentPathIndex >= 0
                              ? state.currentPathIndex
                              : null,
                        ),
                        size: Size(
                            constraints.maxWidth, constraints.maxHeight),
                      ),
                    );
                  },
                ),
              ),

              // 3. Centre reticle
              _buildCenterReticle(),

              // 4. Top status pill
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: BlocBuilder<ArMeasurementCubit, ArMeasurementState>(
                      buildWhen: (prev, curr) =>
                          prev.statusText != curr.statusText,
                      builder: (_, state) =>
                          _buildStatusPill(state.statusText),
                    ),
                  ),
                ),
              ),

              // 5. Bottom distance banner + controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<ArMeasurementCubit, ArMeasurementState>(
                      builder: (_, state) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDistanceBanner(state),
                          const SizedBox(height: 12),
                          ArControlBar(
                            hasPaths: state.hasPaths,
                            isRecording: state.isRecording,
                            onUndo: () =>
                                context.read<ArMeasurementCubit>().undoLastPoint(),
                            onNewLine: () =>
                                context.read<ArMeasurementCubit>().startNewPath(),
                            onClear: () =>
                                context.read<ArMeasurementCubit>().clearAll(),
                            onToggleRecord: () =>
                                context.read<ArMeasurementCubit>().toggleRecording(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 6. Floor plan button (left-middle)
              Positioned(
                left: 16,
                top: MediaQuery.of(context).size.height / 2 - 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'floor_plan_btn',
                      mini: true,
                      onPressed: _showFloorPlanOverlay,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      child: const Icon(Icons.map_outlined),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Floor Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Private UI helpers ────────────────────────────────────────────────────

  Widget _buildStatusPill(String text) {
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
            text,
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

  Widget _buildDistanceBanner(ArMeasurementState state) {
    if (!state.paths.any((p) => p.length > 1)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF32BA7C),
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
            '${state.totalDistanceMeters.toStringAsFixed(2)} m',
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

  Widget _buildCenterReticle() {
    return IgnorePointer(
      child: Stack(
        children: [
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
              child:
                  const Center(child: Icon(Icons.add, size: 20, color: Colors.white)),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, 60),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'POINT AND TAP',
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Floor plan dialog (extracted for readability)
// ─────────────────────────────────────────────────────────────────────────────

class _FloorPlanDialog extends StatelessWidget {
  final VoidCallback onUpload;
  const _FloorPlanDialog({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title:
                const Text('Interactive Floor Plan', style: TextStyle(fontSize: 18)),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 2.0,
                child: Container(
                  width: 550,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: BlocBuilder<ArMeasurementCubit, ArMeasurementState>(
                    buildWhen: (prev, curr) =>
                        prev.floorPlanUrl != curr.floorPlanUrl ||
                        prev.isLoadingFloorPlan != curr.isLoadingFloorPlan,
                    builder: (_, state) {
                      if (state.isLoadingFloorPlan) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.floorPlanUrl != null) {
                        return Image.network(
                          state.floorPlanUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red, size: 48),
                                SizedBox(height: 8),
                                Text('Failed to load image'),
                              ],
                            ),
                          ),
                        );
                      }
                      // No floor plan — show upload CTA
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onUpload();
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 80,
                                  color: Colors.blue.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                'No valid floor plan image found.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Please upload an image (JPG/PNG) in the app or web app.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.upload,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Upload Image',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
