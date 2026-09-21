// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Shared by every SKBB macro shaped like `draw Path dashed evenly scaled
/// (factor * optical_zoom)` — a plain, evenly-dashed `PenC` stroke with no
/// other marks: `l_chimney_SKBB` (`MPChimneySKBBLineDecorator`,
/// `factor = 1`), `l_border_temporary_SKBB`
/// (`MPBorderTemporarySKBBLineDecorator`, `factor = 1`, byte-for-byte the
/// same macro body as chimney's), and `l_border_presumed_SKBB`
/// (`MPBorderPresumedSKBBLineDecorator`, `factor = 0.25`, a denser dash).
/// `dashScaleFactor` scales the dash length, while `dashGapScaleFactor`
/// scales only the following gap. The default equal dash/gap behavior
/// keeps chimney and border-temporary unchanged; border-presumed can use
/// a larger gap to read as a spaced row of dots without altering the
/// other two decorators.
abstract class MPEvenlyDashedSKBBLineDecorator extends MPLineDecorator {
  final double dashScaleFactor;
  final double dashGapScaleFactor;

  const MPEvenlyDashedSKBBLineDecorator({
    this.dashScaleFactor = 1.0,
    this.dashGapScaleFactor = 1.0,
  });

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
    final double dashLength = 0.15 * dashScaleFactor * u;
    final double dashGapLength = dashLength * dashGapScaleFactor;
    final MPDashedPathProperties dashedPathProperties = MPDashedPathProperties(
      dashLengths: <double>[dashLength, -dashGapLength],
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
