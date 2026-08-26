// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_survey_cave_SKBB`'s non-`ATTR__scrap_centerline` branch: each
/// straight segment between the line's original knots is drawn only as
/// two `0.8u` stubs leaning in from its endpoints when it's longer than
/// `1.6u` (leaving its middle bare), or drawn whole otherwise — a
/// "broken line" marking that a `survey` line here is background context
/// rather than the scrap's own centreline data.
///
/// Therion's other branch (drawn as a single unbroken line, when the
/// scrap itself is declared `-type centreline`) isn't ported: Mapiah
/// doesn't currently track a scrap's declared type, and a scrap
/// containing an actual centreline-typed `line survey` (as opposed to
/// referencing survey data as background, the common case this branch
/// covers) is rare enough that this is a reasonable simplification for
/// now.
class MPSurveyCaveSKBBLineDecorator extends MPLineDecorator {
  const MPSurveyCaveSKBBLineDecorator();

  @override
  Path buildBasePath({
    required Path path,
    required List<Offset> vertices,
    required MPSymbolUnit symbolUnit,
  }) {
    final Path segmentedPath = Path();

    if (vertices.length < 2) {
      return segmentedPath;
    }

    final double stubLength = 0.8 * symbolUnit.canvasValue;

    for (int index = 0; index < (vertices.length - 1); index++) {
      final Offset start = vertices[index];
      final Offset end = vertices[index + 1];
      final Offset delta = end - start;
      final double segmentLength = delta.distance;

      if (segmentLength == 0) {
        continue;
      }

      final Offset unit = delta / segmentLength;

      if (segmentLength > (2 * stubLength)) {
        final Offset startStubEnd = start + (unit * stubLength);
        final Offset endStubStart = end - (unit * stubLength);

        segmentedPath.moveTo(start.dx, start.dy);
        segmentedPath.lineTo(startStubEnd.dx, startStubEnd.dy);
        segmentedPath.moveTo(endStubStart.dx, endStubStart.dy);
        segmentedPath.lineTo(end.dx, end.dy);
      } else {
        segmentedPath.moveTo(start.dx, start.dy);
        segmentedPath.lineTo(end.dx, end.dy);
      }
    }

    return segmentedPath;
  }

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
    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * symbolUnit.canvasValue,
    );
  }
}
