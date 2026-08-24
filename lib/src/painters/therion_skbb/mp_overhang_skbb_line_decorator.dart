// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_overhang_SKBB`: a strip of `0.3u`-wide filled triangles, each
/// based on a chord of the path with its apex offset `0.3u` perpendicular
/// at the chord's midpoint, followed by a plain stroke of the whole path.
class MPOverhangSKBBLineDecorator extends MPLineDecorator {
  const MPOverhangSKBBLineDecorator();

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
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double step = 0.3 * u;
    final int segments = math.max(1, (length / step).round());
    final double adjustedStep = length / segments;
    final Paint fill = Paint.from(color)..style = PaintingStyle.fill;

    for (int index = 0; index < segments; index++) {
      final double d1 = (adjustedStep * index).clamp(0, length);
      final double d2 = (adjustedStep * (index + 1)).clamp(0, length);
      final double dm = ((d1 + d2) / 2).clamp(0, length);
      final Tangent? midTangent = metric.getTangentForOffset(dm);

      if (midTangent == null || d2 <= d1) {
        continue;
      }

      final double tangentLength = midTangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = midTangent.vector / tangentLength;
      final Offset perpendicular = Offset(-unit.dy, unit.dx);
      final Offset apex = midTangent.position + (perpendicular * (0.3 * u));
      final Path triangle = metric.extractPath(d1, d2);

      triangle
        ..lineTo(apex.dx, apex.dy)
        ..close();

      canvas.drawPath(triangle, fill);
    }

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
