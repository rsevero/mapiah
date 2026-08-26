// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_blocks_SKBB`: every `1.5u`, a "bracket" made of an
/// outward `0.4u` leg, the wall path's own middle 80% of that step, and
/// another outward `0.4u` leg — so unlike the other wall marks, part of
/// the actual wall boundary shows through as the bracket's middle
/// segment. `PenA`, no separate full-length base-line stroke (the
/// brackets' own middle segments already trace the wall).
class MPWallBlocksSKBBLineDecorator extends MPLineDecorator {
  const MPWallBlocksSKBBLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
    List<THLinePainterLineSegment>? lineSegments,
    bool showBorder = false,
    THOptionChoicesArrowPositionType arrowHead =
        THOptionChoicesArrowPositionType.end,
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

    final double step = 1.5 * u;
    final int segments = math.max(1, (length / step).round());
    final double adjustedStep = length / segments;
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenA * u;

    for (int index = 0; index < segments; index++) {
      final double segmentStart = adjustedStep * index;
      final double d1 = (segmentStart + (adjustedStep * 0.1)).clamp(
        0,
        length,
      );
      final double d2 = (segmentStart + (adjustedStep * 0.9)).clamp(
        0,
        length,
      );

      if (d2 <= d1) {
        continue;
      }

      final Tangent? tangent1 = metric.getTangentForOffset(d1);
      final Tangent? tangent2 = metric.getTangentForOffset(d2);

      if ((tangent1 == null) || (tangent2 == null)) {
        continue;
      }

      final double tangentLength1 = tangent1.vector.distance;
      final double tangentLength2 = tangent2.vector.distance;

      if ((tangentLength1 == 0) || (tangentLength2 == 0)) {
        continue;
      }

      final Offset unit1 = tangent1.vector / tangentLength1;
      final Offset unit2 = tangent2.vector / tangentLength2;
      final Offset outward1 = Offset(unit1.dy, -unit1.dx);
      final Offset outward2 = Offset(unit2.dy, -unit2.dx);
      final Offset end1 =
          tangent1.position +
          (outward1 * (0.4 * u)) +
          random.randomizedOffset(u / 6);
      final Offset end2 =
          tangent2.position +
          (outward2 * (0.4 * u)) +
          random.randomizedOffset(u / 6);
      final Path bracket = Path()
        ..moveTo(end1.dx, end1.dy)
        ..lineTo(tangent1.position.dx, tangent1.position.dy);

      bracket.addPath(metric.extractPath(d1, d2), Offset.zero);
      bracket.lineTo(end2.dx, end2.dy);

      canvas.drawPath(bracket, strokePaint);
    }
  }
}
