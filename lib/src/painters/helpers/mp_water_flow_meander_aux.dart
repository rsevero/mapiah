// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';

/// Builds the meandering curve shared by `l_waterflow_permanent_UIS` and
/// the SKBB `l_waterflow_intermittent_SKBB`/`l_waterflow_conjectural_SKBB`
/// variants (which just redraw that same curve with a dashed/dotted
/// stroke): bends alternate side every [step] with a randomized angle
/// (`50 ± 15` degrees).
abstract final class MPWaterFlowMeanderAux {
  /// The triangular arrowhead both variants stamp at the meander's end,
  /// in unit-symbol coordinates (apex at the origin, base at [length]
  /// along +y, half as wide as [halfWidth]) — sized larger than a literal
  /// port of Therion's own proportions per feedback that the default read
  /// too small on screen.
  static Path arrowPath({double halfWidth = 0.22, double length = 0.7}) =>
      Path()
        ..moveTo(0, 0)
        ..lineTo(-halfWidth, length)
        ..lineTo(halfWidth, length)
        ..close();

  static Path buildMeander({
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
