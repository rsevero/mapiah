// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';

/// Geometric intersection result for two straight segments.
typedef MPSegmentIntersection = ({Offset point, double tA, double tB});

/// Static geometry utilities used by Mapiah.
class MPGeometryAux {
  MPGeometryAux._();

  /// Returns the intersection of finite straight segments (p0,p1) and (p2,p3),
  /// or null if they do not cross strictly within both segments' interiors.
  ///
  /// Uses parametric form: P(t) = p0 + t*(p1-p0), Q(s) = p2 + s*(p3-p2).
  /// Both t and s must be in the open interval (epsilon, 1-epsilon).
  static MPSegmentIntersection? straightSegmentIntersection(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3, {
    double epsilon = mpDoubleComparisonEpsilon,
  }) {
    final double dx1 = p1.dx - p0.dx;
    final double dy1 = p1.dy - p0.dy;
    final double dx2 = p3.dx - p2.dx;
    final double dy2 = p3.dy - p2.dy;

    final double denom = (dx1 * dy2) - (dy1 * dx2);

    if (denom.abs() < epsilon) {
      return null; // parallel or collinear
    }

    final double dx0 = p2.dx - p0.dx;
    final double dy0 = p2.dy - p0.dy;

    final double tA = ((dx0 * dy2) - (dy0 * dx2)) / denom;
    final double tB = ((dx0 * dy1) - (dy0 * dx1)) / denom;

    if ((tA <= epsilon) ||
        (tA >= 1.0 - epsilon) ||
        (tB <= epsilon) ||
        (tB >= 1.0 - epsilon)) {
      return null;
    }

    final Offset point = Offset(p0.dx + (tA * dx1), p0.dy + (tA * dy1));

    return (point: point, tA: tA, tB: tB);
  }
}
