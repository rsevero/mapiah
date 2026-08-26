// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_path_metric_walker.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_handrail_SKBB`'s non-`ATTR__elevation` (plan view) branch:
/// `0.12u`-half-size filled squares (`PenD`) stamped every `adjust_step`d
/// `u` along the path, then the path itself stroked with `PenC`.
/// `ATTR__elevation`'s side-view rendering (posts and diagonal braces) is
/// out of scope — Mapiah's painters have no elevation-view concept at
/// all, matching every other SKBB decorator's plan-view-only scope.
class MPHandrailSKBBLineDecorator extends MPLineDecorator {
  const MPHandrailSKBBLineDecorator();

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
  }) {
    final double u = symbolUnit.canvasValue;
    final double halfSize = 0.12 * u;
    final Paint squarePaint = Paint.from(color)..style = PaintingStyle.fill;

    MPPathMetricWalker.walk(
      path: path,
      desiredStep: u,
      reverse: false,
      visit: (sample) {
        final Offset center = sample.tangent.position;

        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: 2 * halfSize,
            height: 2 * halfSize,
          ),
          squarePaint,
        );
      },
    );

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
