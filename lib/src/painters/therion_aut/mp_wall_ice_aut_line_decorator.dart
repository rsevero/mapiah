// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_ice_AUT`: a small "L"-shaped mark — a `.3u` segment at
/// the sample point, plus a perpendicular `.3u` segment shifted `.25u`
/// along it (Therion's own `p`/`q` symbol, always axis-aligned to the
/// symbol frame rather than rotated to the path) — offset outward `.25u`,
/// every `.6u`, followed by the wall itself as a plain `PenC` stroke.
class MPWallIceAUTLineDecorator extends MPLineDecorator {
  const MPWallIceAUTLineDecorator();

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
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.6 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset outward = Offset(unit.dy, -unit.dx);
        final Offset along = unit;
        final Offset center = position + (outward * (0.25 * u));

        canvas.drawLine(
          center - (unit * (0.15 * u)),
          center + (unit * (0.15 * u)),
          strokePaint,
        );

        final Offset perpCenter = center + (along * (0.25 * u));

        canvas.drawLine(
          perpCenter - (outward * (0.15 * u)),
          perpCenter + (outward * (0.15 * u)),
          strokePaint,
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
