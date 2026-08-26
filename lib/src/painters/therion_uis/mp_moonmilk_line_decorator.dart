// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_moonmilk_UIS`: tight curls (leaving/arriving at an 80-degree
/// offset from the path's tangent) stamped every `0.3u`.
class MPMoonmilkLineDecorator extends MPLineDecorator {
  const MPMoonmilkLineDecorator();

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
    final Path curls = MPDirectionalCurveAux.buildCurlPath(
      sourcePath: path,
      step: mpTherionUISMoonmilkLineStepUnits * u,
      angleOffsetDegrees: mpTherionUISMoonmilkLineAngleOffsetDegrees,
      handleLengthFactor: mpTherionUISMoonmilkLineHandleLengthFactor,
    );

    canvas.drawPath(
      curls,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
