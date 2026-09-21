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

/// Ports `l_wall_debris_SKBB`: a small triangle, stamped directly on the
/// wall path (not offset outward), fully randomly rotated (unlike
/// `pebbles`, which only jitters around the path's tangent), every
/// `0.4u`. `PenC`, no separate base-line stroke.
class MPWallDebrisSKBBLineDecorator extends MPLineDecorator {
  const MPWallDebrisSKBBLineDecorator();

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
    // `((-.2u,-.1u)--(.2u,-.1u)--(0,.2u)--cycle) scaled 1.1`.
    final double scale = 1.1 * u;
    final Path triangle = Path()
      ..moveTo(-0.2 * scale, -0.1 * scale)
      ..lineTo(0.2 * scale, -0.1 * scale)
      ..lineTo(0, 0.2 * scale)
      ..close();

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.4 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final Offset jitter = random.randomizedOffset(u / 10);
        final double rotation = random.nextDouble() * 2 * math.pi;

        canvas.save();
        canvas.translate(position.dx + jitter.dx, position.dy + jitter.dy);
        canvas.rotate(rotation);
        canvas.drawPath(triangle, strokePaint);
        canvas.restore();
      },
    );
  }
}
