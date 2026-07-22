// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

/// Approximates MetaPost's `{dir A}..{dir B}` directional curve
/// interpolation between successive path samples, used by `l_flowstone_UIS`
/// and `l_moonmilk_UIS` to draw curls that leave/arrive at a fixed angle
/// offset from the underlying path's tangent.
abstract final class MPDirectionalCurveAux {
  static Path buildCurlPath({
    required Path sourcePath,
    required double step,
    required double angleOffsetDegrees,
  }) {
    assert(step > 0);

    final Path result = Path();
    final double angleOffset = angleOffsetDegrees * math.pi / 180;

    for (final PathMetric metric in sourcePath.computeMetrics()) {
      final double length = metric.length;

      if (length <= 0) {
        continue;
      }

      final int segments = math.max(1, (length / step).round());
      final double adjustedStep = length / segments;
      Offset? previousPoint;
      double previousAngle = 0;

      for (int index = 0; index <= segments; index++) {
        final double distance = (adjustedStep * index).clamp(0, length);
        final Tangent? tangent = metric.getTangentForOffset(distance);

        if (tangent == null) {
          continue;
        }

        final double angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

        if (previousPoint == null) {
          result.moveTo(tangent.position.dx, tangent.position.dy);
        } else {
          final double startAngle = previousAngle + angleOffset;
          final double endAngle = angle - angleOffset;
          final double handleLength =
              (tangent.position - previousPoint).distance / 3;
          final Offset controlPoint1 =
              previousPoint +
              Offset(math.cos(startAngle), math.sin(startAngle)) *
                  handleLength;
          final Offset controlPoint2 =
              tangent.position -
              Offset(math.cos(endAngle), math.sin(endAngle)) * handleLength;

          result.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            tangent.position.dx,
            tangent.position.dy,
          );
        }

        previousPoint = tangent.position;
        previousAngle = angle;
      }
    }

    return result;
  }
}
