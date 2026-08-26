// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_clay_s_motif_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_clay_SKBB`: the same small "S" mark as `a_clay_SKBB`
/// (`0.15u` half-width, see [MPClaySMotifAux]), axis-aligned (not rotated
/// to the path, matching Therion's own `shifted` with no `rotated`),
/// offset outward from the wall by `0.25u`, every `0.5u` along the path,
/// followed by the wall itself as a plain (`PenA`) stroke.
class MPWallClaySKBBLineDecorator extends MPLineDecorator {
  const MPWallClaySKBBLineDecorator();

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
    final Path motif = MPClaySMotifAux.buildPath(halfWidth: 0.15 * u);
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05 * u;

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.5 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset outward = Offset(unit.dy, -unit.dx);
        final Offset center = position + (outward * (0.25 * u));

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.drawPath(motif, strokePaint);
        canvas.restore();
      },
    );

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );
  }
}
