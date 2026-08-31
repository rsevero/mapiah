// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_overlying_AUT`: the path's middle section (insetting
/// `.25u` from each end) is first "erased" with a thick (`.35u`) stroke in
/// the scrap background color, then redrawn with a dash-dot pattern (`on
/// 2bp off 2bp on .5bp off 2bp on 2bp`, `1bp ≈ .05u`); the two end
/// sections outside the inset are drawn as a plain `PenA` stroke.
class MPWallOverlyingAUTLineDecorator extends MPLineDecorator {
  const MPWallOverlyingAUTLineDecorator();

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
    final double inset = 0.25 * u;

    if (length <= (2 * inset)) {
      canvas.drawPath(
        path,
        Paint.from(color)
          ..style = PaintingStyle.stroke
          ..strokeWidth = mpTherionPenA * u,
      );

      return;
    }

    final Path middle = metric.extractPath(inset, length - inset);

    canvas.drawPath(
      middle,
      Paint()
        ..color = THPaint.thPaintWhiteBackground.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.35 * u
        ..strokeCap = StrokeCap.square,
    );

    final Paint endsPaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenA * u;

    canvas.drawPath(metric.extractPath(0, inset), endsPaint);
    canvas.drawPath(metric.extractPath(length - inset, length), endsPaint);

    // Therion's `bp` is an absolute PostScript big point; Mapiah has no
    // absolute-to-`u` mapping, so `0.1u` is used to keep the dash-dot
    // pattern visually close to Therion's AUT output at the default scale.
    final double bp = 0.1 * u;
    final MPDashedPathProperties dashedPathProperties = MPDashedPathProperties(
      dashLengths: <double>[
        2 * bp,
        -2 * bp,
        0.5 * bp,
        -2 * bp,
        2 * bp,
        -2 * bp,
      ],
    );

    for (final PathMetric middleMetric in middle.computeMetrics()) {
      dashedPathProperties.extractedPathLength = 0.0;

      while (dashedPathProperties.extractedPathLength < middleMetric.length) {
        dashedPathProperties.addNext(middleMetric);
      }
    }

    canvas.drawPath(dashedPathProperties.path, endsPaint);
  }
}
