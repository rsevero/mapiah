// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_rope_SKBB(P, show_anchors, show_rebelays)`'s default
/// `show_anchors`/`show_rebelays` off case (Mapiah has no way to plumb
/// those two extra macro arguments — driven by `-anchors`/`-rebelays`
/// line options in real Therion — through to a line decorator yet, so
/// this port only covers the plain, no-option case): `if not
/// show_rebelays: draw P;`, a single solid `PenC` stroke of the path as
/// drawn, with no rebelay dips or anchor triangle markers.
class MPRopeSKBBLineDecorator extends MPLineDecorator {
  const MPRopeSKBBLineDecorator();

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

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
