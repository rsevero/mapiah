// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_aut/mp_aut_wall_block_chain_aux.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_blocks_AUT`: the same chain-of-blocks construction as
/// [MPWallDebrisAUTLineDecorator], but with Therion's larger, more angular
/// polygon, a wider scale range and only a small (`-15deg..+30deg`)
/// rotation jitter around the path direction, so the blocks stay roughly
/// upright. Unlike `debris`, Therion strokes this outline open (no
/// `--cycle`) so each block is drawn as an arc that opens toward the
/// outward, non-cave side; only the background erase is closed. See
/// [MPAUTWallBlockChainAux].
class MPWallBlocksAUTLineDecorator extends MPLineDecorator {
  const MPWallBlocksAUTLineDecorator();

  /// `((.8u,-.35u)--(.85u,.01u)--(.6u,.4u)--(.1u,.1u)--(-.0u,-.3u))`,
  /// Therion's `l_wall_blocks_AUT` inner-loop block outline verbatim; the
  /// unclosed edge runs from `(-.0u,-.3u)` back to `(.8u,-.35u)` along the
  /// outward side.
  static const List<Offset> _shape = <Offset>[
    Offset(0.8, -0.35),
    Offset(0.85, 0.01),
    Offset(0.6, 0.4),
    Offset(0.1, 0.1),
    Offset(0.0, -0.3),
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
      randomizeFactor: 0.12,
      scaleMin: 0.8,
      scaleSpan: 0.4,
      rotationMinDegrees: -15,
      rotationSpanDegrees: 45,
      closeOutline: false,
      advanceFactor: 0.95,
    );
  }
}
