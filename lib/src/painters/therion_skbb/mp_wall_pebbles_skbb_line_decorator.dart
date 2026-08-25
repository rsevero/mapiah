// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_wall_pebbles_SKBB`: a `0.4u`x`0.2u` lens (Therion's own shape
/// is a superellipse; approximated here as an oval, same as
/// `a_pebbles_SKBB`'s area motif), stamped directly on the wall path
/// (unlike `sand`/`clay`/`ice`, not offset outward), rotated to the
/// path's own tangent plus `normaldeviate*40` degrees of jitter, every
/// `0.35u`. `PenC`, no separate base-line stroke (the marks alone convey
/// the wall).
class MPWallPebblesSKBBLineDecorator extends MPLineDecorator {
  const MPWallPebblesSKBBLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final double u = symbolUnit.canvasValue;
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;
    final Rect ovalRect = Rect.fromCenter(
      center: Offset.zero,
      width: 0.4 * u,
      height: 0.2 * u,
    );

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.35 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final double tangentAngle = math.atan2(tangent.dy, tangent.dx);
        final double rotation =
            tangentAngle + (random.nextGaussian() * 40 * math.pi / 180);
        final Offset jitter = random.randomizedOffset(u / 20);

        canvas.save();
        canvas.translate(position.dx + jitter.dx, position.dy + jitter.dy);
        canvas.rotate(rotation);
        canvas.drawOval(ovalRect, strokePaint);
        canvas.restore();
      },
    );
  }
}
