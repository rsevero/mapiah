/// Dart port of "An Algorithm for Automatically Fitting Digitized Curves"
/// by Philip J. Schneider (Graphics Gems, 1990).
///
/// This implementation follows the original algorithm but uses idiomatic Dart
/// and the project's existing geometry types (Point, Vec2, CubicBez) from
/// `mp_bezier_fit_aux.dart`.
///
/// Given a polyline and an error tolerance (squared distance), it returns a
/// list of cubic Bezier segments that approximate the points.

import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';

/// Fit the given polyline with one or more cubic Bezier segments.
///
/// - points: ordered points to approximate (must be >= 2 and non-degenerate).
/// - errorSquared: maximum allowed squared distance from points to the fitted
///   curve before the segment is split and refit. Typical values are small,
///   e.g. 0.25 (i.e., 0.5 units error).
List<MPSimplificationCubicBez> mpSimplificationFitCubicSchneider(
  List<MPSimplificationPoint> points, {
  double errorSquared = 0.25,
}) {
  if (points.length < 2) {
    return const <MPSimplificationCubicBez>[];
  }

  // Deduplicate exact duplicates to avoid zero-length segments.
  final List<MPSimplificationPoint> d = _mpSimplificationDedup(points);

  if (d.length < 2) {
    return const <MPSimplificationCubicBez>[];
  }

  final MPSimplificationVec2 tHat1 = _mpSimplificationComputeLeftTangent(d, 0);
  final MPSimplificationVec2 tHat2 = _mpSimplificationComputeRightTangent(
    d,
    d.length - 1,
  );
  final List<MPSimplificationCubicBez> out = <MPSimplificationCubicBez>[];

  _mpSimplificationFitCubic(
    d,
    0,
    d.length - 1,
    tHat1,
    tHat2,
    errorSquared,
    out,
  );

  return out;
}

// --- Core algorithm ---------------------------------------------------------

void _mpSimplificationFitCubic(
  List<MPSimplificationPoint> d,
  int first,
  int last,
  MPSimplificationVec2 tHat1,
  MPSimplificationVec2 tHat2,
  double errorSquared,
  List<MPSimplificationCubicBez> out,
) {
  final int nPts = last - first + 1;

  // Heuristic for two points: place inner controls at 1/3 along the tangents.
  if (nPts == 2) {
    final MPSimplificationVec2 seg = d[last] - d[first];
    final double dist = seg.hypot() / 3.0;
    final MPSimplificationPoint p0 = d[first];
    final MPSimplificationPoint p3 = d[last];
    final MPSimplificationPoint p1 = p0 + (tHat1 * dist);
    final MPSimplificationPoint p2 = p3 + (tHat2 * dist);

    out.add(
      MPSimplificationCubicBez(
        p0,
        p1,
        p2,
        p3,
        lineSegment: d[last].lineSegment,
      ),
    );

    return;
  }

  // Initial parameterization using chord-length.
  List<double> u = _chordLengthParameterize(d, first, last);
  MPSimplificationCubicBez bez = _generateBezier(
    d,
    first,
    last,
    u,
    tHat1,
    tHat2,
  );

  // Find max deviation of points to fitted curve.
  int splitPoint = 0;
  double maxError = _computeMaxError(
    d,
    first,
    last,
    bez,
    u,
    (i) => splitPoint = i,
  );
  if (maxError < errorSquared) {
    out.add(bez);

    return;
  }

  // If error not too large, try reparameterization + iteration.
  final double iterationError =
      errorSquared * 4.0; // as in Graphics Gems erratum

  const int maxIterations = 4;

  if (maxError < iterationError) {
    for (int i = 0; i < maxIterations; i++) {
      final List<double> uPrime = _reparameterize(d, first, last, u, bez);

      u = uPrime;
      bez = _generateBezier(d, first, last, u, tHat1, tHat2);
      maxError = _computeMaxError(
        d,
        first,
        last,
        bez,
        u,
        (i) => splitPoint = i,
      );
      if (maxError < errorSquared) {
        out.add(bez);

        return;
      }
    }
  }

  // Split and recurse.
  final MPSimplificationVec2 tCenter = _computeCenterTangent(d, splitPoint);

  _mpSimplificationFitCubic(
    d,
    first,
    splitPoint,
    tHat1,
    tCenter,
    errorSquared,
    out,
  );
  _mpSimplificationFitCubic(
    d,
    splitPoint,
    last,
    -tCenter,
    tHat2,
    errorSquared,
    out,
  );
}

// --- Parameterization -------------------------------------------------------

List<double> _chordLengthParameterize(
  List<MPSimplificationPoint> d,
  int first,
  int last,
) {
  final int n = last - first + 1;
  final List<double> u = List<double>.filled(n, 0);

  for (int i = first + 1; i <= last; i++) {
    u[i - first] = u[i - first - 1] + (d[i] - d[i - 1]).hypot();
  }
  final double total = u.last;

  if (total > 0) {
    for (int i = 1; i < u.length; i++) {
      u[i] /= total;
    }
  }

  return u;
}

List<double> _reparameterize(
  List<MPSimplificationPoint> d,
  int first,
  int last,
  List<double> u,
  MPSimplificationCubicBez bez,
) {
  final int n = last - first + 1;
  final List<double> uPrime = List<double>.filled(n, 0);

  for (int i = first; i <= last; i++) {
    uPrime[i - first] = _newtonRaphson(bez, d[i], u[i - first]);
  }

  return uPrime;
}

double _newtonRaphson(
  MPSimplificationCubicBez c,
  MPSimplificationPoint p,
  double u,
) {
  final MPSimplificationPoint q = c.eval(u); // Q(u)
  final MPSimplificationVec2 q1 = c.deriv(u); // Q'(u)
  final MPSimplificationVec2 q2 = _secondDeriv(c, u); // Q''(u)
  final MPSimplificationVec2 diff =
      q - p; // vector from point on curve to data point
  final double numerator = diff.dot(q1);
  final double denominator = q1.dot(q1) + diff.dot(q2);

  if (denominator == 0) {
    return u;
  }

  final double up = u - numerator / denominator;

  // Keep in [0,1] to be safe.
  return up.isNaN ? u : up.clamp(0.0, 1.0);
}

MPSimplificationVec2 _secondDeriv(MPSimplificationCubicBez c, double t) {
  // d^2/dt^2 of cubic Bezier: 6*((1-t)*(p2 - 2p1 + p0) + t*(p3 - 2p2 + p1))
  final MPSimplificationVec2 a =
      (c.p2 - c.p1) * 2.0 - (c.p1 - c.p0) * 2.0; // (p2 - 2p1 + p0)
  final MPSimplificationVec2 b =
      (c.p3 - c.p2) * 2.0 - (c.p2 - c.p1) * 2.0; // (p3 - 2p2 + p1)

  return (a * (1 - t) + b * t) * 6.0;
}

// --- Bezier generation (least squares for alphas) ---------------------------

MPSimplificationCubicBez _generateBezier(
  List<MPSimplificationPoint> d,
  int first,
  int last,
  List<double> u,
  MPSimplificationVec2 tHat1,
  MPSimplificationVec2 tHat2,
) {
  final int nPts = last - first + 1;

  // Precompute the A vectors: A[i][0] = tHat1 * B1(u[i]), A[i][1] = tHat2 * B2(u[i])
  final List<MPSimplificationVec2> a0 = List<MPSimplificationVec2>.filled(
    nPts,
    const MPSimplificationVec2(0, 0),
  );
  final List<MPSimplificationVec2> a1 = List<MPSimplificationVec2>.filled(
    nPts,
    const MPSimplificationVec2(0, 0),
  );

  for (int i = 0; i < nPts; i++) {
    final double ui = u[i];

    a0[i] = tHat1 * _b1(ui);
    a1[i] = tHat2 * _b2(ui);
  }

  // Build C (2x2) and X (2) for the normal equations.
  double c00 = 0.0, c01 = 0.0, c11 = 0.0;
  double x0 = 0.0, x1 = 0.0;

  final MPSimplificationPoint p0 = d[first];
  final MPSimplificationPoint p3 = d[last];

  for (int i = 0; i < nPts; i++) {
    c00 += a0[i].dot(a0[i]);
    c01 += a0[i].dot(a1[i]);
    c11 += a1[i].dot(a1[i]);

    final double ui = u[i];
    final double s0 = _b0(ui) + _b1(ui);
    final double s1 = _b2(ui) + _b3(ui);
    final double sx = p0.x * s0 + p3.x * s1;
    final double sy = p0.y * s0 + p3.y * s1;
    final MPSimplificationPoint tmp = MPSimplificationPoint(sx, sy);
    final MPSimplificationVec2 r = d[first + i] - tmp; // residual vector

    x0 += a0[i].dot(r);
    x1 += a1[i].dot(r);
  }

  final double det = c00 * c11 - c01 * c01;
  final double detC0X = c00 * x1 - c01 * x0;
  final double detXC1 = x0 * c11 - x1 * c01;
  final double alphaL = (det == 0) ? 0.0 : detXC1 / det;
  final double alphaR = (det == 0) ? 0.0 : detC0X / det;

  // Guard against degenerate alphas.
  final double segLen = (p3 - p0).hypot();
  final double epsilon = 1e-6 * segLen;

  if (alphaL < epsilon || alphaR < epsilon) {
    final double dist = segLen / 3.0;
    final MPSimplificationPoint p1 = p0 + tHat1 * dist;
    final MPSimplificationPoint p2 = p3 + tHat2 * dist;

    return MPSimplificationCubicBez(
      p0,
      p1,
      p2,
      p3,
      lineSegment: d[last].lineSegment,
    );
  }

  final MPSimplificationPoint p1 = p0 + tHat1 * alphaL;
  final MPSimplificationPoint p2 = p3 + tHat2 * alphaR;

  return MPSimplificationCubicBez(
    p0,
    p1,
    p2,
    p3,
    lineSegment: d[last].lineSegment,
  );
}

double _computeMaxError(
  List<MPSimplificationPoint> d,
  int first,
  int last,
  MPSimplificationCubicBez c,
  List<double> u,
  void Function(int) setSplit,
) {
  double maxDist2 = 0.0;
  int split = (last - first + 1) ~/ 2;

  for (int i = first + 1; i < last; i++) {
    final MPSimplificationPoint q = c.eval(u[i - first]);
    final MPSimplificationVec2 v = q - d[i];
    final double dist2 = v.hypot2();

    if (dist2 >= maxDist2) {
      maxDist2 = dist2;
      split = i;
    }
  }
  setSplit(split);

  return maxDist2;
}

// --- Tangents ---------------------------------------------------------------

MPSimplificationVec2 _mpSimplificationComputeLeftTangent(
  List<MPSimplificationPoint> d,
  int end,
) {
  final MPSimplificationVec2 v = d[end + 1] - d[end];

  return _mpSimplificationNormalize(v);
}

MPSimplificationVec2 _mpSimplificationComputeRightTangent(
  List<MPSimplificationPoint> d,
  int end,
) {
  final MPSimplificationVec2 v = d[end - 1] - d[end];

  return _mpSimplificationNormalize(v);
}

MPSimplificationVec2 _computeCenterTangent(
  List<MPSimplificationPoint> d,
  int center,
) {
  final MPSimplificationVec2 v1 = d[center - 1] - d[center];
  final MPSimplificationVec2 v2 = d[center] - d[center + 1];

  return _mpSimplificationNormalize(
    MPSimplificationVec2((v1.x + v2.x) / 2.0, (v1.y + v2.y) / 2.0),
  );
}

MPSimplificationVec2 _mpSimplificationNormalize(MPSimplificationVec2 v) {
  final double h = v.hypot();

  return h == 0 ? const MPSimplificationVec2(0, 0) : (v / h);
}

// --- Basis functions --------------------------------------------------------

double _b0(double u) {
  final double t = 1.0 - u;

  return t * t * t;
}

double _b1(double u) {
  final double t = 1.0 - u;

  return 3 * u * t * t;
}

double _b2(double u) {
  final double t = 1.0 - u;

  return 3 * u * u * t;
}

double _b3(double u) => u * u * u;

// --- Utilities --------------------------------------------------------------

List<MPSimplificationPoint> _mpSimplificationDedup(
  List<MPSimplificationPoint> pts,
) {
  if (pts.isEmpty) {
    return pts;
  }

  final List<MPSimplificationPoint> out = <MPSimplificationPoint>[];

  MPSimplificationPoint? last;

  for (final MPSimplificationPoint p in pts) {
    if (last == null || (p - last).hypot2() > 1e-24) {
      out.add(p);
      last = p;
    }
  }

  return out;
}
