// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_gradient_UIS`: an arrowhead stamped at the line's end, pointing
/// along the path's terminal tangent.
class MPGradientLineDecorator extends MPLineDecorator {
  const MPGradientLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
  }) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final Tangent? tangent = metric.getTangentForOffset(metric.length);

    if (tangent == null) {
      return;
    }

    final Paint? basePaint = linePaint.primaryPaint ?? linePaint.secondaryPaint;

    if (basePaint == null) {
      return;
    }

    final double tangentAngle = math.atan2(
      tangent.vector.dy,
      tangent.vector.dx,
    );
    final double rotation = tangentAngle + (math.pi / 2);
    final Paint fillPaint = Paint()
      ..color = basePaint.color
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint.from(basePaint)
      ..strokeWidth = mpTherionPenC;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: tangent.position,
      rotation: rotation,
      scale: symbolUnit.canvasValue,
      drawUnitSymbol: () {
        final Path arrow = Path()
          ..moveTo(0, 0)
          ..lineTo(-0.15, 0.4)
          ..lineTo(0.15, 0.4)
          ..close();

        canvas.drawPath(arrow, fillPaint);
        canvas.drawPath(arrow, strokePaint);
      },
    );
  }
}
