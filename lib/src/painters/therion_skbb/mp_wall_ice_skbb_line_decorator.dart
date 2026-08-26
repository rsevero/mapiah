// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_wall_ice_SKBB`: a small `+`-shaped cross (`PenC`, its two
/// strokes axis-aligned rather than rotated to the path — Therion's own
/// `p`/`q` segments are never rotated), offset outward from the wall by
/// `0.25u`, every `0.5u` along the path, followed by the wall itself as a
/// plain (`PenA`) stroke.
class MPWallIceSKBBLineDecorator extends MPLineDecorator {
  const MPWallIceSKBBLineDecorator();

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
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.5 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset outward = Offset(unit.dy, -unit.dx);
        final Offset center = position + (outward * (0.25 * u));

        canvas.drawLine(
          center - Offset(0.1 * u, 0),
          center + Offset(0.1 * u, 0),
          strokePaint,
        );
        canvas.drawLine(
          center - Offset(0, 0.1 * u),
          center + Offset(0, 0.1 * u),
          strokePaint,
        );
      },
    );

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );
  }
}
