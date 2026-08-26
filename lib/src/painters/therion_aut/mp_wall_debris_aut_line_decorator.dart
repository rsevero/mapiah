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

/// Ports `l_wall_debris_AUT`: a chain of randomly sized/rotated pentagon
/// "block" outlines placed along the wall path, each fit so it doesn't
/// overlap the previous one. Mapiah approximates this collision-avoiding
/// placement with a fixed-spacing "bracket" — an outward leg, a segment of
/// the wall path itself, and another outward leg — the same simplification
/// [MPWallBlocksSKBBLineDecorator] already makes for the equivalent SKBB
/// macro. `PenC`, no separate full-length base stroke (the brackets'
/// middle segments already trace the wall).
class MPWallDebrisAUTLineDecorator extends MPLineDecorator {
  const MPWallDebrisAUTLineDecorator();

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
    MPWallDebrisAUTLineDecorator.drawBracketChain(
      canvas: canvas,
      path: path,
      color: color,
      u: symbolUnit.canvasValue,
      mpID: mpID,
      step: 0.5,
      leg: 0.2,
    );
  }

  /// Shared with [MPWallBlocksAUTLineDecorator], which calls this with a
  /// larger [step]/[leg] pair.
  static void drawBracketChain({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required double u,
    required int mpID,
    required double step,
    required double leg,
  }) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double stepPixels = step * u;
    final int segments = math.max(1, (length / stepPixels).round());
    final double adjustedStep = length / segments;
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

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
          (outward1 * (leg * u)) +
          random.randomizedOffset(u / 10);
      final Offset end2 =
          tangent2.position +
          (outward2 * (leg * u)) +
          random.randomizedOffset(u / 10);
      final Path bracket = Path()
        ..moveTo(end1.dx, end1.dy)
        ..lineTo(tangent1.position.dx, tangent1.position.dy);

      bracket.addPath(metric.extractPath(d1, d2), Offset.zero);
      bracket.lineTo(end2.dx, end2.dy);

      canvas.drawPath(bracket, strokePaint);
    }
  }
}
