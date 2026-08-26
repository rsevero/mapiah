// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_sand_AUT`/`l_wall_clay_AUT` (the latter a bare `let`
/// alias): a row of short, randomly rotated `.01u` ticks (drawn here as
/// dots, same simplification as `MPWallSandSKBBLineDecorator`), each
/// offset outward from the wall by a random distance up to `.4u`, spaced
/// every `.1u`, followed by the wall itself as a plain `PenC` stroke.
class MPWallSandAUTLineDecorator extends MPLineDecorator {
  const MPWallSandAUTLineDecorator();

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
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final double dotRadius = 0.5 * mpTherionPenC * u;
    final Paint dotPaint = Paint.from(color)..style = PaintingStyle.fill;

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.1 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset outward = Offset(unit.dy, -unit.dx);
        final Offset dot =
            position + (outward * (random.nextDouble() * 0.4 * u));

        canvas.drawCircle(dot, dotRadius, dotPaint);
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
