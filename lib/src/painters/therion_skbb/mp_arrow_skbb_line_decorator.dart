// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_arrow_chevron_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_arrow_SKBB(P, Q)`: a plain solid `PenC` stroke of the path,
/// plus an open two-segment chevron mark at whichever end(s) [arrowHead]
/// (`line arrow -head begin/end/both/none`) selects — `begin`/`both` draw
/// the chevron at the path's start, `end`/`both` at its end, `none` draws
/// neither. Defaults to `end`, matching the option's own default.
class MPArrowSKBBLineDecorator extends MPLineDecorator {
  const MPArrowSKBBLineDecorator();

  static final Path _chevron = Path()
    ..moveTo(-0.1, 0.25)
    ..lineTo(0, 0)
    ..lineTo(0.1, 0.25);

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

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );

    if (arrowHead == THOptionChoicesArrowPositionType.none) {
      return;
    }

    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final Paint chevronPaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC;

    MPArrowChevronAux.drawAtEnds(
      canvas: canvas,
      metric: metric,
      length: length,
      scale: u,
      chevron: _chevron,
      chevronPaint: chevronPaint,
      drawStart:
          (arrowHead == THOptionChoicesArrowPositionType.begin) ||
          (arrowHead == THOptionChoicesArrowPositionType.both),
      drawEnd:
          (arrowHead == THOptionChoicesArrowPositionType.end) ||
          (arrowHead == THOptionChoicesArrowPositionType.both),
    );
  }
}
