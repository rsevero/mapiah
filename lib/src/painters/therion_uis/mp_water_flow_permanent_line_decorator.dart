// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_waterflow_permanent_UIS`: a meandering line whose bends
/// alternate side every `0.5u` with a randomized angle (`50 ± 15` degrees,
/// seeded per element for repaint stability), ending in an arrowhead.
class MPWaterFlowPermanentLineDecorator extends MPLineDecorator {
  const MPWaterFlowPermanentLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final Paint? basePaint = linePaint.primaryPaint ?? linePaint.secondaryPaint;

    if (basePaint == null) {
      return;
    }

    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double u = symbolUnit.canvasValue;
    final double step = 0.5 * u;
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final Path meander = _buildMeander(
      metric: metric,
      length: length,
      step: step,
      random: random,
    );
    final Paint strokePaint = Paint.from(basePaint)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenD * u;

    canvas.drawPath(meander, strokePaint);

    final Tangent? endTangent = metric.getTangentForOffset(length);

    if (endTangent == null) {
      return;
    }

    final double rotation =
        math.atan2(endTangent.vector.dy, endTangent.vector.dx) +
        (math.pi / 2);
    final Paint arrowFillPaint = Paint()
      ..color = basePaint.color
      ..style = PaintingStyle.fill;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: endTangent.position,
      rotation: rotation,
      scale: u,
      drawUnitSymbol: () {
        final Path arrow = Path()
          ..moveTo(0, 0)
          ..lineTo(-0.09, 0.3)
          ..lineTo(0.09, 0.3)
          ..close();

        canvas.drawPath(arrow, arrowFillPaint);
      },
    );
  }

  Path _buildMeander({
    required PathMetric metric,
    required double length,
    required double step,
    required MPSeededRandom random,
  }) {
    final Path meander = Path();
    final Tangent? startTangent = metric.getTangentForOffset(0);

    if (startTangent == null) {
      return meander;
    }

    meander.moveTo(startTangent.position.dx, startTangent.position.dy);

    double distance = 0;
    double azimuth1 = 50 + (15 * random.nextGaussian());
    double sign = 1;

    while (true) {
      final double nextDistance = distance + step;
      final Tangent? startPoint = metric.getTangentForOffset(
        distance.clamp(0, length),
      );
      final Tangent? endPoint = metric.getTangentForOffset(
        nextDistance.clamp(0, length),
      );

      if ((startPoint == null) || (endPoint == null)) {
        break;
      }

      final bool isFinalSegment = (distance + (1.1 * step)) > length;
      final double azimuth2 = isFinalSegment
          ? 0
          : (50 + (15 * random.nextGaussian()));
      final double azimuth1Rad = azimuth1 * math.pi / 180;
      final double azimuth2Rad = azimuth2 * math.pi / 180;
      final double startAngle =
          math.atan2(startPoint.vector.dy, startPoint.vector.dx) +
          (sign * azimuth1Rad);
      final double endAngle =
          math.atan2(endPoint.vector.dy, endPoint.vector.dx) -
          (sign * azimuth2Rad);
      final double handleLength =
          (endPoint.position - startPoint.position).distance / 3;
      final Offset controlPoint1 =
          startPoint.position +
          Offset(math.cos(startAngle), math.sin(startAngle)) * handleLength;
      final Offset controlPoint2 =
          endPoint.position -
          Offset(math.cos(endAngle), math.sin(endAngle)) * handleLength;

      meander.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        endPoint.position.dx,
        endPoint.position.dy,
      );

      azimuth1 = azimuth2;
      sign = -sign;
      distance += step;

      if (distance > (length + (step / 3))) {
        break;
      }
    }

    return meander;
  }
}
