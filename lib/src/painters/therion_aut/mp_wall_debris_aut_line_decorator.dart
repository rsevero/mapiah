// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_aut/mp_aut_wall_block_chain_aux.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_debris_AUT`: a chain of small, fully randomly rotated
/// pentagon "block" outlines placed edge to edge along the wall path, each
/// erased from the background before it is stroked. See
/// [MPAUTWallBlockChainAux] for the placement simplification. `PenC`, no
/// separate base-line stroke (the block chain traces the wall itself).
class MPWallDebrisAUTLineDecorator extends MPLineDecorator {
  const MPWallDebrisAUTLineDecorator();

  /// `((-.25u,-.25u)--(.25u,-.25u)--(.45u,.01u)--(.2u,.25u)--(.05u,.15u))`,
  /// the shape Therion uses for the first/last debris block; the inner
  /// loop's `punked` pentagon is close enough that Mapiah reuses this one
  /// everywhere.
  static const List<Offset> _shape = <Offset>[
    Offset(-0.25, -0.25),
    Offset(0.25, -0.25),
    Offset(0.45, 0.01),
    Offset(0.2, 0.25),
    Offset(0.05, 0.15),
  ];

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
    MPAUTWallBlockChainAux.drawBlockChain(
      canvas: canvas,
      path: path,
      color: color,
      u: symbolUnit.canvasValue,
      mpID: mpID,
      baseShape: _shape,
      randomizeFactor: 0.16,
      scaleMin: 0.4,
      scaleSpan: 0.3,
      rotationMinDegrees: 0,
      rotationSpanDegrees: 360,
    );
  }
}
