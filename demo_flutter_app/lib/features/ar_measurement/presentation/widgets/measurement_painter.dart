import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm hide Colors;
import '../../domain/entities/measurement_point.dart';

/// Paints measurement dots, connector lines, and distance labels on the AR view.
class MeasurementPainter extends CustomPainter {
  final List<List<MeasurementPoint>> paths;
  final int? activePathIndex;

  static const _kLineColor = Color(0xFF2E7D32);
  static final _linePaint = Paint()
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..color = _kLineColor;
  static final _dotFill = Paint()..color = Colors.white;
  static final _dotStroke = Paint()
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke
    ..color = _kLineColor;

  const MeasurementPainter(this.paths, {this.activePathIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    for (var pi = 0; pi < paths.length; pi++) {
      final path = paths[pi];

      // Lines and distance label for the last segment of the active path
      for (var i = 1; i < path.length; i++) {
        final a = path[i - 1].screenPos;
        final b = path[i].screenPos;
        canvas.drawLine(a, b, _linePaint);

        if (activePathIndex == pi && i == path.length - 1) {
          final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
          final dist = _dist3(path[i - 1].worldPos, path[i].worldPos);
          _drawLabel(canvas, '${dist.toStringAsFixed(2)} m', mid);
        }
      }

      // Dots with index numbers
      for (var di = 0; di < path.length; di++) {
        final pt = path[di];
        canvas.drawCircle(pt.screenPos, 9, _dotFill);
        canvas.drawCircle(pt.screenPos, 9, _dotStroke);
        _drawDotIndex(canvas, di + 1, pt.screenPos);
      }
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
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
        width: tp.width + 12,
        height: tp.height + 6,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = _kLineColor);
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

  double _dist3(vm.Vector3 a, vm.Vector3 b) => (b - a).length;

  @override
  bool shouldRepaint(MeasurementPainter oldDelegate) => true;
}
