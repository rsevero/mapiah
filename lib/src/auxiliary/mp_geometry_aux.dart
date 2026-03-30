// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math';
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';

/// Geometric intersection result for two straight segments.
typedef MPSegmentIntersection = ({Offset point, double tA, double tB});

/// Geometric intersection result for a cubic Bézier curve and a straight segment.
typedef BezierStraightIntersection = ({
  double tBezier, // Parameter on Bézier curve (0–1)
  double tLine, // Parameter on line segment (0–1)
  Offset point, // Actual intersection point
});

/// Geometric intersection result for two cubic Bézier curves.
typedef BezierBezierIntersection = ({
  double tA, // Parameter on first Bézier curve (0–1)
  double tB, // Parameter on second Bézier curve (0–1)
  Offset point, // Intersection point
});

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

  /// Finds intersections of a cubic Bézier curve vs. a straight line segment.
  ///
  /// Bézier: B(t) = (1-t)³·p0 + 3(1-t)²t·p1 + 3(1-t)t²·p2 + t³·p3
  /// Line: L(s) = lineStart + s·(lineEnd - lineStart)
  ///
  /// Returns a sorted list of intersections (by t on Bézier), where both
  /// t and s are strictly in the interior: (epsilon, 1-epsilon).
  /// List is empty if no valid intersections exist.
  static List<BezierStraightIntersection>
  bezierSegmentStraightSegmentIntersection(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset lineStart,
    Offset lineEnd, {
    double epsilon = mpDoubleComparisonEpsilon,
  }) {
    final Offset lineDir = lineEnd - lineStart;
    final double lineLenSq = lineDir.distanceSquared;

    if (lineLenSq < epsilon * epsilon) {
      return []; // Degenerate line
    }

    // Convert line to implicit form: (lineEnd - lineStart) × (P - lineStart) = 0
    // Rearranged: `a*x + b*y + c = 0` where (a, b) is perpendicular to line direction.
    final double a = lineDir.dy;
    final double b = -lineDir.dx;
    final double c = -(a * lineStart.dx + b * lineStart.dy);

    // Substitute Bézier into implicit form to get cubic polynomial in t:
    // a*Bx(t) + b*By(t) + c = 0
    // Expanding B(t) = (1-t)³·p0 + 3(1-t)²t·p1 + 3(1-t)t²·p2 + t³·p3
    // Leads to: coeff3*t³ + coeff2*t² + coeff1*t + coeff0 = 0

    final double b0x = p0.dx;
    final double b0y = p0.dy;
    final double b1x = p1.dx;
    final double b1y = p1.dy;
    final double b2x = p2.dx;
    final double b2y = p2.dy;
    final double b3x = p3.dx;
    final double b3y = p3.dy;

    // Compute Bézier coefficients for x and y components
    final double bax = 3.0 * (b1x - b0x);
    final double bbx = 3.0 * (b2x - 2.0 * b1x + b0x);
    final double bcx = b3x - 3.0 * b2x + 3.0 * b1x - b0x;

    final double bay = 3.0 * (b1y - b0y);
    final double bby = 3.0 * (b2y - 2.0 * b1y + b0y);
    final double bcy = b3y - 3.0 * b2y + 3.0 * b1y - b0y;

    // Coefficients for cubic: a*Bx(t) + b*By(t) + c = 0
    final double coeff0 = a * b0x + b * b0y + c;
    final double coeff1 = a * bax + b * bay;
    final double coeff2 = a * bbx + b * bby;
    final double coeff3 = a * bcx + b * bcy;

    // Solve cubic polynomial
    final List<double> roots = _solveCubicPolynomial(
      coeff3,
      coeff2,
      coeff1,
      coeff0,
    );

    final List<BezierStraightIntersection> results = [];

    for (final double t in roots) {
      // Check if t is in interior (epsilon, 1-epsilon)
      if (t <= epsilon || t >= 1.0 - epsilon) {
        continue;
      }

      // Compute Bézier point at t
      final double oneMinusT = 1.0 - t;
      final double oneMinusT2 = oneMinusT * oneMinusT;
      final double t2 = t * t;

      final Offset bezierPoint = Offset(
        oneMinusT2 * oneMinusT * b0x +
            3.0 * oneMinusT2 * t * b1x +
            3.0 * oneMinusT * t2 * b2x +
            t2 * t * b3x,
        oneMinusT2 * oneMinusT * b0y +
            3.0 * oneMinusT2 * t * b1y +
            3.0 * oneMinusT * t2 * b2y +
            t2 * t * b3y,
      );

      // Compute parameter s on line
      // We need to project (bezierPoint - lineStart) onto lineDir
      final Offset toPoint = bezierPoint - lineStart;
      final double s =
          (toPoint.dx * lineDir.dx + toPoint.dy * lineDir.dy) / lineLenSq;

      // Check if s is in interior (epsilon, 1-epsilon)
      if (s <= epsilon || s >= 1.0 - epsilon) {
        continue;
      }

      // Compute actual intersection point on line (for numerical stability)
      final Offset linePoint = lineStart + lineDir * s;

      results.add((tBezier: t, tLine: s, point: linePoint));
    }

    // Sort by t (travel order along Bézier curve)
    results.sort(
      (
        final BezierStraightIntersection a,
        final BezierStraightIntersection b,
      ) => a.tBezier.compareTo(b.tBezier),
    );

    return results;
  }

  /// Finds intersections between two cubic Bézier curves using recursive AABB
  /// subdivision (de Casteljau).
  ///
  /// Returns a list of intersections sorted by tA, where both tA and tB are
  /// strictly in the interior (epsilon, 1-epsilon).
  /// Returns an empty list when the curves do not intersect.
  static List<BezierBezierIntersection> bezierBezierIntersection(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset q0,
    Offset q1,
    Offset q2,
    Offset q3, {
    double epsilon = mpDoubleComparisonEpsilon,
  }) {
    final List<BezierBezierIntersection> raw = [];

    _bezierBezierSubdivide(
      p0,
      p1,
      p2,
      p3,
      0.0,
      1.0,
      q0,
      q1,
      q2,
      q3,
      0.0,
      1.0,
      raw,
      0,
    );

    // Deduplicate results that converged to the same intersection point.
    final List<BezierBezierIntersection> deduped = [];

    for (final BezierBezierIntersection r in raw) {
      final bool isDuplicate = deduped.any(
        (final BezierBezierIntersection e) =>
            ((r.tA - e.tA).abs() < mpBezierBezierDeduplicationEpsilon) &&
            ((r.tB - e.tB).abs() < mpBezierBezierDeduplicationEpsilon),
      );

      if (!isDuplicate) {
        deduped.add(r);
      }
    }

    // Remove endpoint-only touches (both parameters must be interior).
    deduped.removeWhere(
      (final BezierBezierIntersection r) =>
          (r.tA <= epsilon) ||
          (r.tA >= 1.0 - epsilon) ||
          (r.tB <= epsilon) ||
          (r.tB >= 1.0 - epsilon),
    );

    deduped.sort(
      (final BezierBezierIntersection a, final BezierBezierIntersection b) =>
          a.tA.compareTo(b.tA),
    );

    return deduped;
  }

  static void _bezierBezierSubdivide(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double tAMin,
    double tAMax,
    Offset q0,
    Offset q1,
    Offset q2,
    Offset q3,
    double tBMin,
    double tBMax,
    List<BezierBezierIntersection> results,
    int depth,
  ) {
    if (!_bezierAABBsOverlap(p0, p1, p2, p3, q0, q1, q2, q3)) {
      return;
    }

    final double sizeA = _bezierAABBSize(p0, p1, p2, p3);
    final double sizeB = _bezierAABBSize(q0, q1, q2, q3);

    if ((max(sizeA, sizeB) < mpBezierBezierConvergenceThreshold) ||
        (depth >= mpBezierBezierMaxDepth)) {
      final double tA = (tAMin + tAMax) / 2.0;
      final double tB = (tBMin + tBMax) / 2.0;
      final Offset point = _evalBezier(p0, p1, p2, p3, 0.5);

      results.add((tA: tA, tB: tB, point: point));

      return;
    }

    // Split the larger curve first to minimise recursion depth.
    if (sizeA >= sizeB) {
      final double tAMid = (tAMin + tAMax) / 2.0;
      final Offset m01 = Offset.lerp(p0, p1, 0.5)!;
      final Offset m12 = Offset.lerp(p1, p2, 0.5)!;
      final Offset m23 = Offset.lerp(p2, p3, 0.5)!;
      final Offset m012 = Offset.lerp(m01, m12, 0.5)!;
      final Offset m123 = Offset.lerp(m12, m23, 0.5)!;
      final Offset split = Offset.lerp(m012, m123, 0.5)!;

      _bezierBezierSubdivide(
        p0,
        m01,
        m012,
        split,
        tAMin,
        tAMid,
        q0,
        q1,
        q2,
        q3,
        tBMin,
        tBMax,
        results,
        depth + 1,
      );
      _bezierBezierSubdivide(
        split,
        m123,
        m23,
        p3,
        tAMid,
        tAMax,
        q0,
        q1,
        q2,
        q3,
        tBMin,
        tBMax,
        results,
        depth + 1,
      );
    } else {
      final double tBMid = (tBMin + tBMax) / 2.0;
      final Offset m01 = Offset.lerp(q0, q1, 0.5)!;
      final Offset m12 = Offset.lerp(q1, q2, 0.5)!;
      final Offset m23 = Offset.lerp(q2, q3, 0.5)!;
      final Offset m012 = Offset.lerp(m01, m12, 0.5)!;
      final Offset m123 = Offset.lerp(m12, m23, 0.5)!;
      final Offset split = Offset.lerp(m012, m123, 0.5)!;

      _bezierBezierSubdivide(
        p0,
        p1,
        p2,
        p3,
        tAMin,
        tAMax,
        q0,
        m01,
        m012,
        split,
        tBMin,
        tBMid,
        results,
        depth + 1,
      );
      _bezierBezierSubdivide(
        p0,
        p1,
        p2,
        p3,
        tAMin,
        tAMax,
        split,
        m123,
        m23,
        q3,
        tBMid,
        tBMax,
        results,
        depth + 1,
      );
    }
  }

  static bool _bezierAABBsOverlap(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset q0,
    Offset q1,
    Offset q2,
    Offset q3,
  ) {
    final double aMinX = min(min(p0.dx, p1.dx), min(p2.dx, p3.dx));
    final double aMaxX = max(max(p0.dx, p1.dx), max(p2.dx, p3.dx));
    final double aMinY = min(min(p0.dy, p1.dy), min(p2.dy, p3.dy));
    final double aMaxY = max(max(p0.dy, p1.dy), max(p2.dy, p3.dy));

    final double bMinX = min(min(q0.dx, q1.dx), min(q2.dx, q3.dx));
    final double bMaxX = max(max(q0.dx, q1.dx), max(q2.dx, q3.dx));
    final double bMinY = min(min(q0.dy, q1.dy), min(q2.dy, q3.dy));
    final double bMaxY = max(max(q0.dy, q1.dy), max(q2.dy, q3.dy));

    return (aMinX <= bMaxX) &&
        (aMaxX >= bMinX) &&
        (aMinY <= bMaxY) &&
        (aMaxY >= bMinY);
  }

  static double _bezierAABBSize(Offset p0, Offset p1, Offset p2, Offset p3) {
    final double minX = min(min(p0.dx, p1.dx), min(p2.dx, p3.dx));
    final double maxX = max(max(p0.dx, p1.dx), max(p2.dx, p3.dx));
    final double minY = min(min(p0.dy, p1.dy), min(p2.dy, p3.dy));
    final double maxY = max(max(p0.dy, p1.dy), max(p2.dy, p3.dy));

    return max(maxX - minX, maxY - minY);
  }

  static Offset _evalBezier(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final double oneMinusT = 1.0 - t;
    final double oneMinusT2 = oneMinusT * oneMinusT;
    final double t2 = t * t;

    return Offset(
      (oneMinusT2 * oneMinusT * p0.dx) +
          (3.0 * oneMinusT2 * t * p1.dx) +
          (3.0 * oneMinusT * t2 * p2.dx) +
          (t2 * t * p3.dx),
      (oneMinusT2 * oneMinusT * p0.dy) +
          (3.0 * oneMinusT2 * t * p1.dy) +
          (3.0 * oneMinusT * t2 * p2.dy) +
          (t2 * t * p3.dy),
    );
  }

  /// Solves cubic polynomial: a*t³ + b*t² + c*t + d = 0.
  /// Returns a list of real roots in range [0, 1]. Uses numerical sampling + Newton-Raphson.
  static List<double> _solveCubicPolynomial(
    double a,
    double b,
    double c,
    double d,
  ) {
    const double eps = 1e-14;

    // Polynomial and its derivative
    double poly(double t) => a * t * t * t + b * t * t + c * t + d;
    double polyDerivative(double t) => 3.0 * a * t * t + 2.0 * b * t + c;

    // Handle degenerate cases
    if (a.abs() < eps) {
      // Quadratic: b*t² + c*t + d = 0
      if (b.abs() < eps) {
        // Linear: c*t + d = 0
        if (c.abs() < eps) {
          return []; // No solution (constant non-zero)
        }
        final double root = -d / c;
        if ((root >= -eps) && (root <= 1.0 + eps)) {
          return [root];
        }
        return [];
      }

      final double discriminant = c * c - 4.0 * b * d;
      if (discriminant < -eps) {
        return []; // No real roots
      }

      final List<double> roots = [];
      if (discriminant.abs() < eps) {
        final double root = -c / (2.0 * b);
        if ((root >= -eps) && (root <= 1.0 + eps)) {
          roots.add(root);
        }
      } else {
        final double sqrtDisc = sqrt(discriminant);
        final double root1 = (-c + sqrtDisc) / (2.0 * b);
        final double root2 = (-c - sqrtDisc) / (2.0 * b);
        if ((root1 >= -eps) && (root1 <= 1.0 + eps)) {
          roots.add(root1);
        }
        if ((root2 >= -eps) && (root2 <= 1.0 + eps)) {
          roots.add(root2);
        }
      }
      return roots;
    }

    // For cubic: use sampling to bracket roots, then Newton-Raphson to refine
    final List<double> roots = [];
    const int samples = 100;

    for (int i = 0; i < samples; i++) {
      final double t1 = i / samples;
      final double t2 = (i + 1) / samples;
      final double v1 = poly(t1);
      final double v2 = poly(t2);

      // Check for sign change (bracket a root)
      if ((v1 * v2) < 0 || (v1.abs() < eps && i > 0)) {
        // Use Newton-Raphson to refine
        double tRoot = (t1 + t2) / 2.0;
        for (int iter = 0; iter < 20; iter++) {
          final double deriv = polyDerivative(tRoot);
          if (deriv.abs() < eps) {
            break; // Stuck at critical point
          }
          final double nextT = tRoot - poly(tRoot) / deriv;
          if ((nextT - tRoot).abs() < 1e-12) {
            break; // Converged
          }
          tRoot = nextT;
        }

        // Check if already added (avoid duplicates)
        bool isDuplicate = false;
        for (final double existingRoot in roots) {
          if ((tRoot - existingRoot).abs() < 1e-10) {
            isDuplicate = true;
            break;
          }
        }

        if (!isDuplicate && (tRoot >= -eps) && (tRoot <= 1.0 + eps)) {
          roots.add(tRoot);
        }
      }
    }

    roots.sort();
    return roots;
  }
}
