// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_chimney_SKBB`: `thdraw P dashed evenly scaled optical_zoom` —
/// a plain, evenly-dashed `PenC` stroke of the path, with **no** tick
/// marks at all. This is a distinct macro from `l_chimney_UIS` (which
/// delegates to `l_ceilingstep_SKBB`'s tick-marked rendering, still used
/// by [MPChimneyLineDecorator]); confirmed against the SKBB showcase's
/// own legend, whose `chimney` sample is a plain dashed oval with no
/// ticks. `optical_zoom`'s exact default dash pitch isn't derivable
/// without running MetaPost itself, so the dash length here is an
/// approximation using this set's own established dash-length
/// conventions rather than a literal port of that constant.
class MPChimneySKBBLineDecorator extends MPLineDecorator {
  const MPChimneySKBBLineDecorator();

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
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
