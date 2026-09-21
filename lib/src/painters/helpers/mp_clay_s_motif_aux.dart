// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';

/// Builds the small "S" mark used by `a_clay_SKBB` (an area fill motif,
/// see `MPTherionAreaPatternTilesSKBB.buildClayTile`), `l_wall_clay_SKBB`
/// (a wall-decoration motif, see `MPWallClaySKBBLineDecorator`), and
/// `p_clay_SKBB` (the `clay` point symbol, see
/// `MPTherionPointSymbolsSKBB`): two mirrored humps (the first bulging one
/// way, the second the other) forming an S, centered on the origin.
///
/// [mirrored] flips which half bulges which way. The wall/area motif's own
/// source (`(-halfWidth,0){up}..{down}origin..{up}(halfWidth,0)`) and the
/// point's (`(-halfWidth,0){up}..origin{down}..{up}(halfWidth,0)`) place
/// their direction specifiers differently around the shared midpoint, so
/// they aren't the same curve — `mirrored: true` (used by the point) gives
/// the point's own reading: a hump on the left, then a dip on the right,
/// confirmed against `therion_skbb_showcase.pdf`.
abstract final class MPClaySMotifAux {
  static Path buildPath({
    required double halfWidth,
    double handleLengthFactor = 1.1,
    bool mirrored = false,
  }) {
    final double sign = mirrored ? -1 : 1;
    final Path curve = MPDirectionalCurveAux.buildCurvePath(
      start: Offset(-halfWidth, 0),
      end: Offset.zero,
      startDirectionDegrees: 90 * sign,
      endDirectionDegrees: -90 * sign,
      handleLengthFactor: handleLengthFactor,
    );

    curve.addPath(
      MPDirectionalCurveAux.buildCurvePath(
        start: Offset.zero,
        end: Offset(halfWidth, 0),
        startDirectionDegrees: -90 * sign,
        endDirectionDegrees: 90 * sign,
        handleLengthFactor: handleLengthFactor,
      ),
      Offset.zero,
    );

    return curve;
  }
}
