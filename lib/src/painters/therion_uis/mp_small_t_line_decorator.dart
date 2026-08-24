// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Draws path-aligned small Ts from either end of a Therion line.
abstract class MPSmallTLineDecorator extends MPLineDecorator {
  final bool reverseOrigin;

  /// Flips which side of the path the T's stem points to. `1.0` (the
  /// default, used by every UIS subclass) reproduces the pre-Phase-4B
  /// behavior exactly; `-1.0` mirrors it, matching `l_ceilingstep_SKBB`'s
  /// opposite-signed `mark_` offset relative to `l_ceilingstep_UIS`.
  final double sideSign;

  const MPSmallTLineDecorator({
    required this.reverseOrigin,
    this.sideSign = 1.0,
  });

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final double u = symbolUnit.canvasValue;
    final Path smallTs = Path();

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: mpTherionUISSmallTStepUnits * u,
      reverseOrigin: reverseOrigin,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        _addSmallT(
          path: smallTs,
          position: position,
          tangent: tangent,
          adjustedStep: adjustedStep,
          u: u,
          sideSign: sideSign,
        );
      },
    );

    canvas.drawPath(
      smallTs,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }

  void _addSmallT({
    required Path path,
    required Offset position,
    required Offset tangent,
    required double adjustedStep,
    required double u,
    required double sideSign,
  }) {
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
        (perpendicular * (sideSign * mpTherionUISSmallTStemLengthUnits * u));

    path
      ..moveTo(capStart.dx, capStart.dy)
      ..lineTo(capEnd.dx, capEnd.dy)
      ..moveTo(position.dx, position.dy)
      ..lineTo(stemEnd.dx, stemEnd.dy);
  }
}
