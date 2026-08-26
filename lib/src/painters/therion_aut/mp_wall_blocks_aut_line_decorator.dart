// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_debris_aut_line_decorator.dart';

/// Ports `l_wall_blocks_AUT`: the same bracket-chain approximation as
/// [MPWallDebrisAUTLineDecorator], scaled to the macro's bigger blocks.
class MPWallBlocksAUTLineDecorator extends MPLineDecorator {
  const MPWallBlocksAUTLineDecorator();

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
    MPWallDebrisAUTLineDecorator.drawBracketChain(
      canvas: canvas,
      path: path,
      color: color,
      u: symbolUnit.canvasValue,
      mpID: mpID,
      step: 1.0,
      leg: 0.35,
    );
  }
}
