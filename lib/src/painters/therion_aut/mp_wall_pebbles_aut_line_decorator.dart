// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_pebbles_AUT`: a `.2u`x`.1u` pebble lens (Therion's own
/// shape is a superellipse, approximated as an oval, same as
/// `MPWallPebblesSKBBLineDecorator`), stamped directly on the wall path,
/// rotated to the path's own tangent plus jitter, every `.18u`. `PenC`, no
/// separate base-line stroke.
class MPWallPebblesAUTLineDecorator extends MPLineDecorator {
  const MPWallPebblesAUTLineDecorator();

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
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;
    final Rect ovalRect = Rect.fromCenter(
      center: Offset.zero,
      width: 0.2 * u,
      height: 0.1 * u,
    );

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.18 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final double tangentAngle = math.atan2(tangent.dy, tangent.dx);
        final double rotation =
            tangentAngle + (random.nextGaussian() * 40 * math.pi / 180);

        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(rotation);
        canvas.drawOval(ovalRect, strokePaint);
        canvas.restore();
      },
    );
  }
}
