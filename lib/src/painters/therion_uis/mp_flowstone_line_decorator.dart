// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_flowstone_UIS`: wide curls (leaving/arriving at a 60-degree
/// offset from the path's tangent) stamped every `0.7u`.
class MPFlowstoneLineDecorator extends MPLineDecorator {
  const MPFlowstoneLineDecorator();

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
    final Path curls = MPDirectionalCurveAux.buildCurlPath(
      sourcePath: path,
      step: 0.7 * u,
      angleOffsetDegrees: 60,
    );

    canvas.drawPath(
      curls,
      Paint.from(basePaint)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
