// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_floormeander_SKBB`: a radial tick on both sides of the line
/// every `0.25u`, with each tick's outer end connected to the previous
/// one's, forming two continuous zigzag rails straddling the line.
class MPFloorMeanderSKBBLineDecorator extends MPLineDecorator {
  const MPFloorMeanderSKBBLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final double u = symbolUnit.canvasValue;
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double step = 0.25 * u;
    final int segments = math.max(1, (length / step).round());
    final double adjustedStep = length / segments;
    final Path lines = Path();
    Offset? previousOuter;
    Offset? previousInner;

    for (int index = 0; index <= segments; index++) {
      final double distance = (adjustedStep * index).clamp(0, length);
      final Tangent? tangent = metric.getTangentForOffset(distance);

      if (tangent == null) {
        continue;
      }

      final Offset position = tangent.position;
      final double tangentLength = tangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = tangent.vector / tangentLength;
      final Offset perpendicular = Offset(-unit.dy, unit.dx);
      final Offset outer = position + (perpendicular * (0.2 * u));
      final Offset inner = position - (perpendicular * (0.2 * u));

      lines
        ..moveTo(
          (position + (perpendicular * (0.1 * u))).dx,
          (position + (perpendicular * (0.1 * u))).dy,
        )
        ..lineTo(outer.dx, outer.dy)
        ..moveTo(
          (position - (perpendicular * (0.1 * u))).dx,
          (position - (perpendicular * (0.1 * u))).dy,
        )
        ..lineTo(inner.dx, inner.dy);

      if (previousOuter != null) {
        lines
          ..moveTo(previousOuter.dx, previousOuter.dy)
          ..lineTo(outer.dx, outer.dy)
          ..moveTo(previousInner!.dx, previousInner.dy)
          ..lineTo(inner.dx, inner.dy);
      }

      previousOuter = outer;
      previousInner = inner;
    }

    canvas.drawPath(
      lines,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
