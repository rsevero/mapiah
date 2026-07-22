// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_ceilingmeander_UIS`: a "ladder rung" of two radial ticks plus two
/// crossbars straddling the line, stamped at the center of each `0.8u`
/// segment.
class MPCeilingMeanderLineDecorator extends MPLineDecorator {
  const MPCeilingMeanderLineDecorator();

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
    final Path rungs = Path();

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.8 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset direction = tangent / tangentLength;
        final Offset perpendicular = Offset(-direction.dy, direction.dx);
        // Radial ticks span 0.2u..0.3u from the line; crossbars are 0.4u
        // long, centered on the 0.2u radial point.
        final Offset near = perpendicular * (0.2 * u);
        final Offset radialSpan = perpendicular * (0.1 * u);
        final Offset along = direction * (0.2 * u);

        void addRung(double sign) {
          final Offset radial = near * sign;
          final Offset span = radialSpan * sign;

          rungs
            ..moveTo((position + radial).dx, (position + radial).dy)
            ..lineTo(
              (position + radial + span).dx,
              (position + radial + span).dy,
            )
            ..moveTo(
              (position + radial + along).dx,
              (position + radial + along).dy,
            )
            ..lineTo(
              (position + radial - along).dx,
              (position + radial - along).dy,
            );
        }

        addRung(1);
        addRung(-1);
      },
    );

    canvas.drawPath(
      rungs,
      Paint.from(basePaint)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
