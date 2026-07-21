// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_survey_cave_UIS` by joining the original knots with straight
/// segments, irrespective of any Bézier controls stored in the TH2 line.
class MPSurveyCaveLineDecorator extends MPLineDecorator {
  const MPSurveyCaveLineDecorator();

  @override
  Path buildBasePath({required Path path, required List<Offset> vertices}) {
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
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
  }) {}
}
