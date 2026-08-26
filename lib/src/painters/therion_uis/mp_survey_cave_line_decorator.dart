// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_survey_cave_UIS` by joining the original knots with straight
/// segments, irrespective of any Bézier controls stored in the TH2 line.
class MPSurveyCaveLineDecorator extends MPLineDecorator {
  const MPSurveyCaveLineDecorator();

  @override
  Path buildBasePath({
    required Path path,
    required List<Offset> vertices,
    required MPSymbolUnit symbolUnit,
  }) {
    final Path segmentedPath = Path();

    if (vertices.isEmpty) {
      return segmentedPath;
    }

    segmentedPath.moveTo(vertices.first.dx, vertices.first.dy);
    for (final Offset vertex in vertices.skip(1)) {
      segmentedPath.lineTo(vertex.dx, vertex.dy);
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
    final double u = symbolUnit.canvasValue;

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
