// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_ceilingmeander_UIS`: a "ladder rung" of two radial ticks plus two
/// crossbars straddling the line, stamped at the center of each `0.8u`
/// segment.
class MPCeilingMeanderLineDecorator extends MPLineDecorator {
  /// Distance (in `u`) from the line to the crossbar/inner tick end. `0.2`
  /// (the default) reproduces `l_ceilingmeander_UIS`'s `0.2u..0.3u` radial
  /// ticks exactly; `l_ceilingmeander_SKBB` uses `0.1u..0.2u` instead.
  final double nearUnits;

  const MPCeilingMeanderLineDecorator({this.nearUnits = 0.2});

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
  }) {
    final double u = symbolUnit.canvasValue;
    final Path rungs = Path();

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.8 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double _) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset direction = tangent / tangentLength;
        final Offset perpendicular = Offset(-direction.dy, direction.dx);
        // Radial ticks span nearUnits..(nearUnits+0.1)u from the line;
        // crossbars are 0.4u long, centered on the nearUnits radial point.
        final Offset near = perpendicular * (nearUnits * u);
        final Offset radialSpan = perpendicular * (0.1 * u);
        final Offset along = direction * (0.2 * u);

        void addRung(double sign) {
          final Offset radial = near * sign;
          final Offset span = radialSpan * sign;

          rungs
            ..moveTo((position + radial).dx, (position + radial).dy)
            ..lineTo(
              (position + radial + span).dx,
              (position + radial + span).dy,
            )
            ..moveTo(
              (position + radial + along).dx,
              (position + radial + along).dy,
            )
            ..lineTo(
              (position + radial - along).dx,
              (position + radial - along).dy,
            );
        }

        addRung(1);
        addRung(-1);
      },
    );

    canvas.drawPath(
      rungs,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
