// Domain entity — pure Dart, no Flutter/plugin dependencies.
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show Offset;
import 'package:vector_math/vector_math_64.dart' show Vector3;

@immutable
class MeasurementPoint {
  final Offset screenPos;
  final Vector3 worldPos;
  final String? anchorName;

  const MeasurementPoint({
    required this.screenPos,
    required this.worldPos,
    this.anchorName,
  });

  /// Returns a copy with an updated [screenPos] (used during projection).
  MeasurementPoint copyWithScreenPos(Offset newPos) => MeasurementPoint(
        screenPos: newPos,
        worldPos: worldPos,
        anchorName: anchorName,
      );
}
