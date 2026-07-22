// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_contour_UIS`'s default (`pnt = -2`) case: a single perpendicular
/// tick at the path's midpoint. Therion can also place ticks at specific
/// knot indices supplied by the C++ layer, which Mapiah has no equivalent
/// data for, so only the midpoint tick is reproduced.
class MPContourLineDecorator extends MPLineDecorator {
  const MPContourLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final Paint? basePaint = linePaint.primaryPaint ?? linePaint.secondaryPaint;

    if (basePaint == null) {
      return;
    }

    final double u = symbolUnit.canvasValue;
    final Path tick = Path();

    MPLineTickAux.walkMidpoint(
      path: path,
      visit: (Offset position, Offset tangent) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset perpendicular = Offset(-unit.dy, unit.dx);
        final Offset end = position + (perpendicular * (0.2 * u));

        tick
          ..moveTo(position.dx, position.dy)
          ..lineTo(end.dx, end.dy);
      },
    );

    canvas.drawPath(
      tick,
      Paint.from(basePaint)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenD * u,
    );
  }
}
