// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_survey_surface_SKBB`: the path drawn as a sparse row of
/// round dots (`thdrawoptions(dashed withdots scaled (0.2 *
/// optical_zoom) withpen PenC)`, denser than the `waterFlow -subtype
/// conjectural` dots' `0.5` scale), and unlike `waterFlow`, no
/// arrowhead. Therion has no separate UIS macro for `survey -subtype
/// surface` at all — `l_survey_surface` aliases straight to this SKBB
/// definition in `thTrans.mp` — so this is the only rendering Therion
/// itself ever produces for it, under any symbol set.
class MPSurveySurfaceSKBBLineDecorator extends MPLineDecorator {
  const MPSurveySurfaceSKBBLineDecorator();

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
    final double dotRadius = 0.5 * mpTherionPenC * u;
    final double spacing = 0.12 * u;
    final Paint dotPaint = Paint.from(color)..style = PaintingStyle.fill;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;

      while (distance <= metric.length) {
        final Tangent? tangent = metric.getTangentForOffset(distance);

        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, dotPaint);
        }

        distance += spacing;
      }
    }
  }
}
