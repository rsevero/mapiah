// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';

/// Builds the small "S" mark used by both `a_clay_SKBB` (an area fill
/// motif, see `MPTherionAreaPatternTilesSKBB.buildClayTile`) and
/// `l_wall_clay_SKBB` (a wall-decoration motif, see
/// `MPWallClaySKBBLineDecorator`): `(-halfWidth,0){up}..{down}origin..
/// {up}(halfWidth,0)` — two mirrored humps (the first bulging one way,
/// the second the other) forming an S, centered on the origin.
abstract final class MPClaySMotifAux {
  static Path buildPath({
    required double halfWidth,
    double handleLengthFactor = 1.1,
  }) {
    final Path curve = MPDirectionalCurveAux.buildCurvePath(
      start: Offset(-halfWidth, 0),
      end: Offset.zero,
      startDirectionDegrees: 90,
      endDirectionDegrees: -90,
      handleLengthFactor: handleLengthFactor,
    );

    curve.addPath(
      MPDirectionalCurveAux.buildCurvePath(
        start: Offset.zero,
        end: Offset(halfWidth, 0),
        startDirectionDegrees: -90,
        endDirectionDegrees: 90,
        handleLengthFactor: handleLengthFactor,
      ),
      Offset.zero,
    );

    return curve;
  }
}
