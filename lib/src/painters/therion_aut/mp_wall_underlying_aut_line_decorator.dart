// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_underlying_AUT`: the path's middle section (insetting
/// `.5u` from each end) drawn `PenA`, `dashed evenly` — no full-length
/// base stroke, only the inset dashed run.
class MPWallUnderlyingAUTLineDecorator extends MPLineDecorator {
  const MPWallUnderlyingAUTLineDecorator();

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
    final double inset = 0.5 * u;

    if (length <= (2 * inset)) {
      return;
    }

    final Path middle = metric.extractPath(inset, length - inset);
    final double dashLength = 0.15 * u;
    final MPDashedPathProperties dashedPathProperties = MPDashedPathProperties(
      dashLengths: <double>[dashLength, -dashLength],
    );

    for (final PathMetric middleMetric in middle.computeMetrics()) {
      dashedPathProperties.extractedPathLength = 0.0;

      while (dashedPathProperties.extractedPathLength < middleMetric.length) {
        dashedPathProperties.addNext(middleMetric);
      }
    }

    canvas.drawPath(
      dashedPathProperties.path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );
  }
}
