// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_moonmilk_aut_line_decorator.dart';

/// Ports `l_wall_flowstone_AUT`: the same `.4u`-wide, `.8u`-spaced bumps as
/// [MPWallMoonmilkAUTLineDecorator], each also filled (closing back to its
/// own start point), followed by a plain `PenA` stroke of the whole path.
class MPWallFlowstoneAUTLineDecorator extends MPLineDecorator {
  const MPWallFlowstoneAUTLineDecorator();

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
    final Paint fillPaint = Paint.from(color)..style = PaintingStyle.fill;

    for (final Path bump in MPWallMoonmilkAUTLineDecorator.buildBumps(
      path: path,
      u: u,
    )) {
      canvas.drawPath(bump, strokePaint);

      final Path closedBump = Path.from(bump)..close();

      canvas.drawPath(closedBump, fillPaint);
    }

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );
  }
}
