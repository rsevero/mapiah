// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_ceilingstep_UIS`: a small T pointing to the line's left-hand side,
/// stamped at the center of each `0.8u` segment.
class MPCeilingStepLineDecorator extends MPLineDecorator {
  const MPCeilingStepLineDecorator();

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
    final Path ticks = Path();

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: mpTherionUISSmallTStepUnits * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset perpendicular = Offset(-unit.dy, unit.dx);
        final Offset capStart =
            position -
            (unit * (mpTherionUISSmallTCapHalfStepFactor * adjustedStep));
        final Offset capEnd =
            position +
            (unit * (mpTherionUISSmallTCapHalfStepFactor * adjustedStep));
        final Offset stemEnd =
            position -
            (perpendicular * (mpTherionUISSmallTStemLengthUnits * u));

        ticks
          ..moveTo(capStart.dx, capStart.dy)
          ..lineTo(capEnd.dx, capEnd.dy)
          ..moveTo(position.dx, position.dy)
          ..lineTo(stemEnd.dx, stemEnd.dy);
      },
    );

    canvas.drawPath(
      ticks,
      Paint.from(basePaint)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
