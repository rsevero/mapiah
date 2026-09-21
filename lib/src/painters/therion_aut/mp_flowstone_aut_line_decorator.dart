// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_flowstone_AUT` (the standalone `flowstone` line type, distinct
/// from the `wall -subtype flowstone` macro
/// [MPWallFlowstoneAUTLineDecorator] ports): `pickup PenC; thdraw P dashed
/// evenly scaled optical_zoom;` — a plain, evenly-dashed `PenC` stroke with
/// no other marks, the same shape family as
/// `MPEvenlyDashedSKBBLineDecorator`'s macros.
class MPFlowstoneAUTLineDecorator extends MPLineDecorator {
  const MPFlowstoneAUTLineDecorator();

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
    final double dashLength = 0.15 * u;
    final MPDashedPathProperties dashedPathProperties = MPDashedPathProperties(
      dashLengths: <double>[dashLength, -dashLength],
    );

    for (final PathMetric metric in path.computeMetrics()) {
      dashedPathProperties.extractedPathLength = 0.0;

      while (dashedPathProperties.extractedPathLength < metric.length) {
        dashedPathProperties.addNext(metric);
      }
    }

    canvas.drawPath(
      dashedPathProperties.path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u
        ..strokeCap = StrokeCap.round,
    );
  }
}
