// Copyright 2022 the Kurbo Authors
// SPDX-License-Identifier: Apache-2.0 OR MIT
//
// Dart port of kurbo/kurbo/src/fit.rs. This is a standalone, dependency-free
// implementation that mirrors the Rust logic closely, with some numeric
// differences (notably root finding and arclength inversion).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';

// -----------------------------
// Math/Geometry primitives
// -----------------------------

class MPSimplificationRange {
  double start, end;

  MPSimplificationRange(this.start, this.end);
  MPSimplificationRange copy() => MPSimplificationRange(start, end);
}

class MPSimplificationVec2 {
  final double x, y;
  const MPSimplificationVec2(this.x, this.y);

  MPSimplificationVec2 operator +(MPSimplificationVec2 o) =>
      MPSimplificationVec2(x + o.x, y + o.y);
  MPSimplificationVec2 operator -(MPSimplificationVec2 o) =>
      MPSimplificationVec2(x - o.x, y - o.y);
  MPSimplificationVec2 operator *(double s) =>
      MPSimplificationVec2(x * s, y * s);
  MPSimplificationVec2 operator /(double s) =>
      MPSimplificationVec2(x / s, y / s);

  MPSimplificationVec2 operator -() => MPSimplificationVec2(-x, -y);

  double dot(MPSimplificationVec2 o) => x * o.x + y * o.y;
  double cross(MPSimplificationVec2 o) => x * o.y - y * o.x;
  double hypot() => math.sqrt(x * x + y * y);
  double hypot2() => x * x + y * y;
  double angle() => math.atan2(y, x);
}

class MPSimplificationPoint {
  final double x, y;
  final THLineSegment? lineSegment;

  const MPSimplificationPoint(this.x, this.y, {this.lineSegment});

  MPSimplificationPoint operator +(MPSimplificationVec2 v) =>
      MPSimplificationPoint(x + v.x, y + v.y);
  MPSimplificationVec2 operator -(MPSimplificationPoint p) =>
      MPSimplificationVec2(x - p.x, y - p.y);
  MPSimplificationPoint lerp(MPSimplificationPoint other, double t) =>
      MPSimplificationPoint(x + (other.x - x) * t, y + (other.y - y) * t);
  MPSimplificationVec2 toVec2() => MPSimplificationVec2(x, y);

  double distanceSquared(MPSimplificationPoint p) {
    final double dx = x - p.x, dy = y - p.y;

    return dx * dx + dy * dy;
  }

  Offset toOffset() => Offset(x, y);
}

class MPSimplificationAffine {
  // 2x3 matrix:
  // [ a c e ]
  // [ b d f ]
  final double a, b, c, d, e, f;
  const MPSimplificationAffine(this.a, this.b, this.c, this.d, this.e, this.f);

  static const identity = MPSimplificationAffine(1, 0, 0, 1, 0, 0);

  static MPSimplificationAffine translate(MPSimplificationVec2 v) =>
      MPSimplificationAffine(1, 0, 0, 1, v.x, v.y);
  static MPSimplificationAffine scale(double s) =>
      MPSimplificationAffine(s, 0, 0, s, 0, 0);
  static MPSimplificationAffine rotate(double th) {
    final ct = math.cos(th), st = math.sin(th);
    return MPSimplificationAffine(ct, st, -st, ct, 0, 0);
  }

  MPSimplificationAffine then(MPSimplificationAffine o) {
    // this * o (apply o then this)
    return MPSimplificationAffine(
      a * o.a + c * o.b, // a'
      b * o.a + d * o.b, // b'
      a * o.c + c * o.d, // c'
      b * o.c + d * o.d, // d'
      a * o.e + c * o.f + e, // e'
      b * o.e + d * o.f + f, // f'
    );
  }

  MPSimplificationPoint applyToPoint(MPSimplificationPoint p) =>
      MPSimplificationPoint(a * p.x + c * p.y + e, b * p.x + d * p.y + f);
}

class Line {
  final MPSimplificationPoint p0, p1;

  Line(this.p0, this.p1);

  double nearestDistanceSq(MPSimplificationPoint p) {
    final MPSimplificationVec2 v = p1 - p0;
    final MPSimplificationVec2 w = p - p0;
    final double c1 = w.dot(v);

    if (c1 <= 0) {
      return p.distanceSquared(p0);
    }

    final double c2 = v.dot(v);

    if (c2 <= c1) {
      return p.distanceSquared(p1);
    }

    final double t = c1 / c2;
    final MPSimplificationPoint proj = MPSimplificationPoint(
      p0.x + v.x * t,
      p0.y + v.y * t,
    );

    return p.distanceSquared(proj);
  }
}

/// Cubic Bezier curve representation.
/// p0: start point
/// p1: first control point
/// p2: second control point
/// p3: end point
class MPSimplificationCubicBez {
  final MPSimplificationPoint p0, p1, p2, p3;
  final THLineSegment? lineSegment;
  final bool isCalculated;

  MPSimplificationCubicBez(
    this.p0,
    this.p1,
    this.p2,
    this.p3, {
    this.lineSegment,
    this.isCalculated = true,
  });

  MPSimplificationCubicBez copyWith({
    MPSimplificationPoint? p0,
    MPSimplificationPoint? p1,
    MPSimplificationPoint? p2,
    MPSimplificationPoint? p3,
    THLineSegment? lineSegment,
    bool makeLineSegmentNull = false,
    bool? isCalculated,
  }) {
    return MPSimplificationCubicBez(
      p0 ?? this.p0,
      p1 ?? this.p1,
      p2 ?? this.p2,
      p3 ?? this.p3,
      lineSegment: makeLineSegmentNull
          ? null
          : (lineSegment ?? this.lineSegment),
      isCalculated: isCalculated ?? this.isCalculated,
    );
  }

  MPSimplificationPoint eval(double t) {
    final double u = 1 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;
    final double x =
        uuu * p0.x + 3 * uu * t * p1.x + 3 * u * tt * p2.x + ttt * p3.x;
    final double y =
        uuu * p0.y + 3 * uu * t * p1.y + 3 * u * tt * p2.y + ttt * p3.y;

    return MPSimplificationPoint(x, y);
  }

  MPSimplificationVec2 deriv(double t) {
    // derivative of cubic Bezier
    final double u = 1 - t;
    final double x =
        3 * u * u * (p1.x - p0.x) +
        6 * u * t * (p2.x - p1.x) +
        3 * t * t * (p3.x - p2.x);
    final double y =
        3 * u * u * (p1.y - p0.y) +
        6 * u * t * (p2.y - p1.y) +
        3 * t * t * (p3.y - p2.y);

    return MPSimplificationVec2(x, y);
  }

  double arclen(double eps) {
    // 16-point Gauss-Legendre quadrature of |p'(t)|
    double sum = 0;

    for (final (double, double) wxi in gaussLegendre16) {
      final double w = wxi.$1;
      final double xi = wxi.$2;
      final double t = 0.5 * (xi + 1); // map [-1,1] -> [0,1]

      sum += w * deriv(t).hypot();
    }

    return 0.5 * sum;
  }

  double invArclen(double s, double eps) {
    // Invert arclength numerically via bisection (monotone).
    double lo = 0, hi = 1;

    const maxIter = 40;

    final double total = arclen(eps);

    if (s <= 0) {
      return 0;
    }
    if (s >= total) {
      return 1;
    }
    for (int i = 0; i < maxIter; i++) {
      final double mid = 0.5 * (lo + hi);
      final double mlen = _partialArclen(mid);

      if (mlen < s) {
        lo = mid;
      } else {
        hi = mid;
      }
      if ((hi - lo) < 1e-9) {
        break;
      }
    }

    return 0.5 * (lo + hi);
  }

  double _partialArclen(double tEnd) {
    // Gauss-Legendre on [0, tEnd]
    final double t0 = 0.5 * tEnd;
    final double dt = t0;

    double sum = 0;

    for (final (double, double) wxi in gaussLegendre16) {
      final double w = wxi.$1;
      final double xi = wxi.$2;
      final double t = t0 + xi * dt * 0.5; // careful mapping

      sum += w * deriv(math.max(0.0, math.min(1.0, t))).hypot();
    }

    return dt * sum;
  }

  MPSimplificationCubicBez transform(MPSimplificationAffine a) =>
      MPSimplificationCubicBez(
        a.applyToPoint(p0),
        a.applyToPoint(p1),
        a.applyToPoint(p2),
        a.applyToPoint(p3),
      );
}

class BezPath {
  final List<_Cmd> _elements = [];

  bool isEmpty() => _elements.isEmpty;
  List<Object> elements() => _elements;

  void moveTo(MPSimplificationPoint p) => _elements.add(_MoveTo(p));

  void curveTo(
    MPSimplificationPoint p1,
    MPSimplificationPoint p2,
    MPSimplificationPoint p3,
  ) => _elements.add(_CurveTo(p1, p2, p3));

  void truncate(int n) => _elements.length = math.min(n, _elements.length);

  // Convert the path to a list of cubic Bezier segments.
  // This avoids exposing the private command types to callers.
  List<MPSimplificationCubicBez> toCubics() {
    final List<MPSimplificationCubicBez> out = <MPSimplificationCubicBez>[];

    MPSimplificationPoint? current;

    for (final _Cmd e in _elements) {
      if (e is _MoveTo) {
        current = e.p;
      } else if (e is _CurveTo) {
        if (current == null) {
          throw StateError('Curve before moveTo');
        }

        out.add(MPSimplificationCubicBez(current, e.p1, e.p2, e.p3));
        current = e.p3;
      }
    }

    return out;
  }
}

abstract class _Cmd {}

class _MoveTo extends _Cmd {
  final MPSimplificationPoint p;

  _MoveTo(this.p);
}

class _CurveTo extends _Cmd {
  final MPSimplificationPoint p1, p2, p3;

  _CurveTo(this.p1, this.p2, this.p3);
}

// -----------------------------
// ParamCurveFit API
// -----------------------------

class MPSimplificationCurveFitSample {
  final MPSimplificationPoint p;
  final MPSimplificationVec2 tangent;

  MPSimplificationCurveFitSample(this.p, this.tangent);

  List<double> intersect(MPSimplificationCubicBez c) {
    // Solve dot(c(t) - p, tangent) == 0 for t in [0, 1]
    final MPSimplificationVec2 p1 = (c.p1 - c.p0) * 3.0;
    final MPSimplificationVec2 p2 =
        (c.p2.toVec2() * 3.0) - (c.p1.toVec2() * 6.0) + (c.p0.toVec2() * 3.0);
    final MPSimplificationVec2 p3 = (c.p3 - c.p0) - (c.p2 - c.p1) * 3.0;
    final double c0 = (c.p0 - p).dot(tangent);
    final double c1 = p1.dot(tangent);
    final double c2 = p2.dot(tangent);
    final double c3 = p3.dot(tangent);
    final List<double> roots = solveCubic(c0, c1, c2, c3);

    return roots.where((t) => t >= 0.0 && t <= 1.0).toList();
  }
}

abstract class MPSimplificationParamCurveFit {
  MPSimplificationCurveFitSample samplePtTangent(double t, double sign);
  (MPSimplificationPoint, MPSimplificationVec2) samplePtDeriv(double t);
  double? breakCusp(MPSimplificationRange range);

  // Default moment integrals via quadrature and Green's theorem
  (double, double, double) momentIntegrals(MPSimplificationRange range) {
    final double t0 = 0.5 * (range.start + range.end);
    final double dt = 0.5 * (range.end - range.start);

    double a = 0, x = 0, y = 0;
    for (final (double w, double xi) in gaussLegendre16) {
      final double t = t0 + xi * dt;
      final (MPSimplificationPoint p, MPSimplificationVec2 d) = samplePtDeriv(
        t,
      );
      final double ai = w * d.x * p.y;

      a += ai;
      x += p.x * ai;
      y += p.y * ai;
    }

    return (a * dt, x * dt, y * dt);
  }
}

// -----------------------------
// Core fitting
// -----------------------------

const int nSample = 20;
const double dPenaltyElbow = 0.65;
const double dPenaltySlope = 2.0;

class MPSimplificationCurveDist {
  final List<MPSimplificationCurveFitSample> samples;
  final List<double> arcparams;
  final MPSimplificationRange range;
  final bool spicy;

  MPSimplificationCurveDist._(
    this.samples,
    this.arcparams,
    this.range,
    this.spicy,
  );

  factory MPSimplificationCurveDist.fromCurve(
    MPSimplificationParamCurveFit source,
    MPSimplificationRange range,
  ) {
    final double step = (range.end - range.start) * (1.0 / (nSample + 1));

    MPSimplificationVec2? lastTan;

    bool spicy = false;

    const double spicyThresh = 0.2;

    final List<MPSimplificationCurveFitSample> samples =
        <MPSimplificationCurveFitSample>[];

    for (int i = 0; i < nSample + 2; i++) {
      final MPSimplificationCurveFitSample s = source.samplePtTangent(
        range.start + i * step,
        1.0,
      );

      if (lastTan != null) {
        final double cross = s.tangent.cross(lastTan);
        final double dot = s.tangent.dot(lastTan);

        if (cross.abs() > spicyThresh * dot.abs()) {
          spicy = true;
        }
      }
      lastTan = s.tangent;
      if (i > 0 && i < nSample + 1) {
        samples.add(s);
      }
    }

    return MPSimplificationCurveDist._(samples, <double>[], range, spicy);
  }

  void computeArcParams(MPSimplificationParamCurveFit source) {
    const int nSubsample = 10;
    final double start = range.start, end = range.end;
    final double dt = (end - start) * (1.0 / ((nSample + 1) * nSubsample));

    double arclen = 0.0;

    for (int i = 0; i < nSample + 1; i++) {
      for (int j = 0; j < nSubsample; j++) {
        final double t = start + dt * ((i * nSubsample + j) + 0.5);
        final MPSimplificationVec2 deriv = source.samplePtDeriv(t).$2;

        arclen += deriv.hypot();
      }
      if (i < nSample) {
        arcparams.add(arclen);
      }
    }

    final double inv = 1.0 / arclen;

    for (int i = 0; i < arcparams.length; i++) {
      arcparams[i] *= inv;
    }
  }

  double? evalRay(MPSimplificationCubicBez c, double acc2) {
    double maxErr2 = 0.0;

    for (final MPSimplificationCurveFitSample s in samples) {
      double best = acc2 + 1.0;

      for (final double t in s.intersect(c)) {
        final double err = s.p.distanceSquared(c.eval(t));

        if (err < best) {
          best = err;
        }
      }
      if (best > maxErr2) {
        maxErr2 = best;
      }
      if (maxErr2 > acc2) {
        return null;
      }
    }

    return maxErr2;
  }

  double? evalArc(
    MPSimplificationParamCurveFit source,
    MPSimplificationCubicBez c,
    double acc2,
  ) {
    const double eps = 1e-9;

    final double cLen = c.arclen(eps);

    double maxErr2 = 0.0;

    for (int i = 0; i < samples.length; i++) {
      final MPSimplificationCurveFitSample s = samples[i];
      final double t = c.invArclen(cLen * arcparams[i], eps);
      final double err = s.p.distanceSquared(c.eval(t));

      if (err > maxErr2) {
        maxErr2 = err;
      }
      if (maxErr2 > acc2) {
        return null;
      }
    }

    return maxErr2;
  }

  double? evalDist(
    MPSimplificationParamCurveFit source,
    MPSimplificationCubicBez c,
    double acc2,
  ) {
    final double? ray = evalRay(c, acc2);

    if (ray == null) {
      return null;
    }
    if (!spicy) {
      return ray;
    }
    if (arcparams.isEmpty) {
      computeArcParams(source);
    }

    return evalArc(source, c, acc2);
  }
}

BezPath fitToBezPath(MPSimplificationParamCurveFit source, double accuracy) {
  final BezPath path = BezPath();

  _fitToBezPathRec(source, MPSimplificationRange(0, 1), accuracy, path);

  return path;
}

void _fitToBezPathRec(
  MPSimplificationParamCurveFit source,
  MPSimplificationRange range,
  double accuracy,
  BezPath path,
) {
  final double start = range.start, end = range.end;
  final MPSimplificationPoint startP = source
      .samplePtTangent(range.start, 1.0)
      .p;
  final MPSimplificationPoint endP = source.samplePtTangent(range.end, -1.0).p;

  if (startP.distanceSquared(endP) <= accuracy * accuracy) {
    final (MPSimplificationCubicBez, double)? line =
        _mpSimplificationTryFitLine(source, accuracy, range, startP, endP);

    if (line != null) {
      final (MPSimplificationCubicBez c, _) = line;

      if (path.isEmpty()) {
        path.moveTo(c.p0);
      }
      path.curveTo(c.p1, c.p2, c.p3);

      return;
    }
  }
  final double t = (() {
    final double? cusp = source.breakCusp(MPSimplificationRange(start, end));

    if (cusp != null) {
      return cusp;
    }

    final (MPSimplificationCubicBez, double)? fit = mpSimplificationFitToCubic(
      source,
      MPSimplificationRange(start, end),
      accuracy,
    );

    if (fit != null) {
      final (MPSimplificationCubicBez c, _) = fit;

      if (path.isEmpty()) {
        path.moveTo(c.p0);
      }
      path.curveTo(c.p1, c.p2, c.p3);

      return double.nan; // signal done
    }

    return 0.5 * (start + end);
  })();

  if (t.isNaN) {
    return;
  }

  if (t == start || t == end) {
    final MPSimplificationPoint p1 = startP.lerp(endP, 1.0 / 3.0);
    final MPSimplificationPoint p2 = endP.lerp(startP, 1.0 / 3.0);

    if (path.isEmpty()) {
      path.moveTo(startP);
    }
    path.curveTo(p1, p2, endP);

    return;
  }
  _fitToBezPathRec(source, MPSimplificationRange(start, t), accuracy, path);
  _fitToBezPathRec(source, MPSimplificationRange(t, end), accuracy, path);
}

(MPSimplificationCubicBez, double)? _mpSimplificationTryFitLine(
  MPSimplificationParamCurveFit source,
  double accuracy,
  MPSimplificationRange range,
  MPSimplificationPoint start,
  MPSimplificationPoint end,
) {
  final double acc2 = accuracy * accuracy;
  final Line chordL = Line(start, end);

  const int shortN = 7;

  double maxErr2 = 0.0;

  final double dt = (range.end - range.start) / (shortN + 1);

  for (int i = 0; i < shortN; i++) {
    final double t = range.start + (i + 1) * dt;
    final MPSimplificationPoint p = source.samplePtDeriv(t).$1;
    final double err2 = chordL.nearestDistanceSq(p);

    if (err2 > acc2) {
      return null;
    }
    if (err2 > maxErr2) {
      maxErr2 = err2;
    }
  }
  final MPSimplificationPoint p1 = start.lerp(end, 1.0 / 3.0);
  final MPSimplificationPoint p2 = end.lerp(start, 1.0 / 3.0);
  final MPSimplificationCubicBez c = MPSimplificationCubicBez(
    start,
    p1,
    p2,
    end,
  );

  return (c, maxErr2);
}

(MPSimplificationCubicBez, double)? mpSimplificationFitToCubic(
  MPSimplificationParamCurveFit source,
  MPSimplificationRange range,
  double accuracy,
) {
  final MPSimplificationCurveFitSample start = source.samplePtTangent(
    range.start,
    1.0,
  );
  final MPSimplificationCurveFitSample end = source.samplePtTangent(
    range.end,
    -1.0,
  );
  final MPSimplificationVec2 d = end.p - start.p;
  final double chord2 = d.hypot2();
  final double acc2 = accuracy * accuracy;

  if (chord2 <= acc2) {
    return _mpSimplificationTryFitLine(source, accuracy, range, start.p, end.p);
  }

  double mod2pi(double th) {
    final double thScaled = th * (1 / math.pi) * 0.5;

    return math.pi * 2.0 * (thScaled - thScaled.round());
  }

  final double th = d.angle();
  final double th0 = mod2pi(start.tangent.angle() - th);
  final double th1 = mod2pi(th - end.tangent.angle());

  var (double area, double x, double y) = source.momentIntegrals(range.copy());

  final double x0 = start.p.x;
  final double y0 = start.p.y;
  final double dx = d.x;
  final double dy = d.y;

  area -= dx * (y0 + 0.5 * dy);

  final double dy3 = dy * (1.0 / 3.0);

  x -= dx * (x0 * y0 + 0.5 * (x0 * dy + y0 * dx) + dy3 * dx);
  y -= dx * (y0 * y0 + y0 * dy + dy3 * dy);
  x -= x0 * area;
  y = 0.5 * y - y0 * area;

  final double moment = d.x * x + d.y * y;
  final double chord2Inv = 1.0 / chord2;
  final double unitArea = area * chord2Inv;
  final double mx = moment * math.pow(chord2Inv, 2);

  final double chord = math.sqrt(chord2);
  final MPSimplificationAffine aff =
      MPSimplificationAffine.translate(start.p.toVec2())
          .then(MPSimplificationAffine.rotate(th))
          .then(MPSimplificationAffine.scale(chord));
  final MPSimplificationCurveDist curveDist =
      MPSimplificationCurveDist.fromCurve(source, range.copy());

  MPSimplificationCubicBez? bestC;
  double? bestErr2;

  for (final (MPSimplificationCubicBez cand, double d0, double d1)
      in _mpSimplificationCubicFit(th0, th1, unitArea, mx)) {
    final MPSimplificationCubicBez c = cand.transform(aff);
    final double? err2 = curveDist.evalDist(source, c, acc2);

    if (err2 == null) {
      continue;
    }

    double scaleF(double d) =>
        1.0 + math.max(0.0, d - dPenaltyElbow) * dPenaltySlope;

    final double scale =
        math.pow(math.max(scaleF(d0), scaleF(d1)), 2) as double;
    final double adjErr2 = err2 * scale;

    if ((adjErr2 < acc2) && (bestErr2 == null || adjErr2 < bestErr2)) {
      bestC = c;
      bestErr2 = adjErr2;
    }
  }
  if ((bestC != null) && (bestErr2 != null)) {
    return (bestC, bestErr2);
  }

  return null;
}

Iterable<(MPSimplificationCubicBez, double, double)> _mpSimplificationCubicFit(
  double th0,
  double th1,
  double area,
  double mx,
) sync* {
  final double s0 = math.sin(th0);
  final double c0 = math.cos(th0);
  final double s1 = math.sin(th1);
  final double c1 = math.cos(th1);
  final double a4 =
      -9 *
      c0 *
      ((((2 * s1 * c1 * c0 + s0 * (2 * c1 * c1 - 1)) * c0 - 2 * s1 * c1) * c0) -
          c1 * c1 * s0);
  final double a3 =
      12 *
      (((((c1 * (30 * area * c1 - s1) - 15 * area) * c0 +
                          2 * s0 -
                          c1 * s0 * (c1 + 30 * area * s1)) *
                      c0) +
                  c1 * (s1 - 15 * area * c1)) *
              c0 -
          s0 * c1 * c1);
  final double a2 =
      12 *
      ((((70 * mx + 15 * area) * s1 * s1 +
                          c1 * (9 * s1 - 70 * c1 * mx - 5 * c1 * area)) *
                      c0 -
                  5 * s0 * s1 * (3 * s1 - 4 * c1 * (7 * mx + area))) *
              c0 -
          c1 * (9 * s1 - 70 * c1 * mx - 5 * c1 * area));
  final double a1 =
      16 *
      (((12 * s0 - 5 * c0 * (42 * mx - 17 * area)) * s1 -
                  70 * c1 * (3 * mx - area) * s0 -
                  75 * c0 * c1 * area * area) *
              s1 -
          75 * c1 * c1 * area * area * s0);
  final double a0 = 80 * s1 * (42 * s1 * mx - 25 * area * (s1 - c1 * area));

  const double eps = 1e-12;

  List<double> roots = [];

  if (a4.abs() > eps) {
    roots = solveQuartic(a0, a1, a2, a3, a4);
  } else if (a3.abs() > eps) {
    roots = solveCubic(a0, a1, a2, a3);
  } else if (a2.abs() > eps || a1.abs() > eps || a0.abs() > eps) {
    roots = solveQuadratic(a0, a1, a2);
  } else {
    yield (
      MPSimplificationCubicBez(
        MPSimplificationPoint(0, 0),
        MPSimplificationPoint(1 / 3, 0),
        MPSimplificationPoint(2 / 3, 0),
        MPSimplificationPoint(1, 0),
      ),
      1.0 / 3.0,
      1.0 / 3.0,
    );

    return;
  }

  final double s01 = s0 * c1 + s1 * c0;

  for (final double r in roots) {
    double d0, d1;

    if (r > 0) {
      d0 = r;
      d1 = (d0 * s0 - area * (10.0 / 3.0)) / (0.5 * d0 * s01 - s1);
      if (d1 <= 0) {
        d0 = s1 / s01;
        d1 = 0.0;
      }
    } else {
      d0 = 0.0;
      d1 = s0 / s01;
    }
    if (d0 >= 0 && d1 >= 0) {
      yield (
        MPSimplificationCubicBez(
          MPSimplificationPoint(0, 0),
          MPSimplificationPoint(d0 * c0, d0 * s0),
          MPSimplificationPoint(1.0 - d1 * c1, d1 * s1),
          MPSimplificationPoint(1, 0),
        ),
        d0,
        d1,
      );
    }
  }
}

// -----------------------------
// Optimized multi-segment fitter (optional)
// -----------------------------

BezPath fitToBezPathOpt(MPSimplificationParamCurveFit source, double accuracy) {
  final List<double> cusps = <double>[];
  final BezPath path = BezPath();

  double t0 = 0.0;

  while (true) {
    final double t1 = cusps.isNotEmpty ? cusps.last : 1.0;
    final double? cusp = _fitToBezPathOptInner(
      source,
      accuracy,
      MPSimplificationRange(t0, t1),
      path,
    );
    if (cusp != null) {
      cusps.add(cusp);
    } else {
      if (cusps.isNotEmpty) {
        t0 = cusps.removeLast();
      } else {
        break;
      }
    }
  }

  return path;
}

double? _fitToBezPathOptInner(
  MPSimplificationParamCurveFit source,
  double accuracy,
  MPSimplificationRange range,
  BezPath path,
) {
  final double? cusp = source.breakCusp(range.copy());

  if (cusp != null) {
    return cusp;
  }

  double err;

  final (MPSimplificationCubicBez, double)? fit = mpSimplificationFitToCubic(
    source,
    range.copy(),
    accuracy,
  );

  if (fit != null) {
    final (MPSimplificationCubicBez c, double err2) = fit;

    err = math.sqrt(err2);
    if (err < accuracy) {
      if (path.isEmpty()) {
        path.moveTo(c.p0);
      }
      path.curveTo(c.p1, c.p2, c.p3);

      return null;
    }
  } else {
    err = 2.0 * accuracy;
  }

  double t0 = range.start;
  final double t1 = range.end;

  int n = 0;
  // Initialize with the current fit error so bracketing below is valid even if
  // we don't hit a _SegmentError in the exploratory loop (edge cases).
  double lastErr = err;

  while (true) {
    n += 1;
    final _FitResult r = _fitOptSegment(
      source,
      accuracy,
      MPSimplificationRange(t0, t1),
    );
    if (r is _ParamVal) {
      t0 = r.t;
    } else if (r is _SegmentError) {
      lastErr = r.err;
      break;
    } else if (r is _CuspFound) {
      return r.t;
    } else {
      throw StateError('unknown FitResult');
    }
  }

  t0 = range.start;

  const double eps = 1e-9;

  double f(double x) {
    final _ErrDelta r = _fitOptErrDelta(
      source,
      accuracy,
      x,
      MPSimplificationRange(t0, t1),
      n,
    );

    if (r is _ErrCusp) {
      throw _CuspException(r.t);
    }

    return (r as _Delta).delta;
  }

  final double ya = -err;
  final double yb = accuracy - lastErr;

  // Solve for x in [0, accuracy] where f crosses zero
  double x;

  try {
    x = solveItp((v) => f(v), 0.0, accuracy, eps, ya, yb, maxIter: 64);
  } on _CuspException catch (e) {
    return e.t;
  }

  final int pathLen = path.elements().length;

  t0 = range.start;
  for (int i = 0; i < n; i++) {
    final double tNext = (i < n - 1)
        ? (() {
            final r = _fitOptSegment(
              source,
              x,
              MPSimplificationRange(t0, range.end),
            );
            if (r is _ParamVal) return r.t;
            if (r is _SegmentError) return range.end;
            if (r is _CuspFound) {
              path.truncate(pathLen);
              throw _CuspException(r.t);
            }
            return range.end;
          })()
        : range.end;

    final (MPSimplificationCubicBez, double)? fitSeg =
        mpSimplificationFitToCubic(
          source,
          MPSimplificationRange(t0, tNext),
          accuracy,
        );

    MPSimplificationCubicBez seg;

    if (fitSeg != null) {
      seg = fitSeg.$1;
    } else {
      // Fallback: try a straight-line cubic segment if a precise fit fails.
      final MPSimplificationPoint startP = source.samplePtTangent(t0, 1.0).p;
      final MPSimplificationPoint endP = source.samplePtTangent(tNext, -1.0).p;
      final (MPSimplificationCubicBez, double)? line =
          _mpSimplificationTryFitLine(
            source,
            accuracy,
            MPSimplificationRange(t0, tNext),
            startP,
            endP,
          );

      if (line != null) {
        seg = line.$1;
      } else {
        // Last-resort: degenerate cubic along the chord.
        final MPSimplificationPoint p1 = startP.lerp(endP, 1.0 / 3.0);
        final MPSimplificationPoint p2 = endP.lerp(startP, 1.0 / 3.0);

        seg = MPSimplificationCubicBez(startP, p1, p2, endP);
      }
    }
    if (path.isEmpty()) {
      path.moveTo(seg.p0);
    }
    path.curveTo(seg.p1, seg.p2, seg.p3);
    t0 = tNext;
    if (t0 == range.end) {
      break;
    }
  }

  return null;
}

double? _measureOneSeg(
  MPSimplificationParamCurveFit source,
  MPSimplificationRange range,
  double limit,
) {
  final (MPSimplificationCubicBez, double)? r = mpSimplificationFitToCubic(
    source,
    range,
    limit,
  );

  return r == null ? null : math.sqrt(r.$2);
}

sealed class _FitResult {}

class _ParamVal extends _FitResult {
  final double t;
  _ParamVal(this.t);
}

class _SegmentError extends _FitResult {
  final double err;
  _SegmentError(this.err);
}

class _CuspFound extends _FitResult {
  final double t;
  _CuspFound(this.t);
}

_FitResult _fitOptSegment(
  MPSimplificationParamCurveFit source,
  double accuracy,
  MPSimplificationRange range,
) {
  final double? cusp = source.breakCusp(range.copy());

  if (cusp != null) {
    return _CuspFound(cusp);
  }

  final double missingErr = accuracy * 2.0;
  final double err =
      _measureOneSeg(source, range.copy(), accuracy) ?? missingErr;

  if (err <= accuracy) {
    return _SegmentError(err);
  }

  final double t0 = range.start, t1 = range.end;

  double f(double x) {
    final double? cusp2 = source.breakCusp(range.copy());

    if (cusp2 != null) {
      throw _CuspException(cusp2);
    }

    final double e =
        _measureOneSeg(source, MPSimplificationRange(t0, x), accuracy) ??
        missingErr;

    return e - accuracy;
  }

  try {
    final double t = solveItp(
      f,
      t0,
      t1,
      1e-9,
      -accuracy,
      err - accuracy,
      maxIter: 64,
    );
    return _ParamVal(t);
  } on _CuspException catch (e) {
    return _CuspFound(e.t);
  }
}

sealed class _ErrDelta {}

class _Delta extends _ErrDelta {
  final double delta; // accuracy - err

  _Delta(this.delta);
}

class _ErrCusp extends _ErrDelta {
  final double t;

  _ErrCusp(this.t);
}

class _CuspException implements Exception {
  final double t;

  _CuspException(this.t);
}

_ErrDelta _fitOptErrDelta(
  MPSimplificationParamCurveFit source,
  double accuracy,
  double limit,
  MPSimplificationRange range,
  int n,
) {
  double t0 = range.start;

  final double t1 = range.end;

  for (int i = 0; i < n - 1; i++) {
    final _FitResult r = _fitOptSegment(
      source,
      accuracy,
      MPSimplificationRange(t0, t1),
    );

    if (r is _ParamVal) {
      t0 = r.t;
    } else if (r is _SegmentError) {
      return _Delta(accuracy); // harvest partial solution
    } else if (r is _CuspFound) {
      return _ErrCusp(r.t);
    }
  }
  final double err =
      _measureOneSeg(source, MPSimplificationRange(t0, t1), limit) ??
      accuracy * 2.0;

  return _Delta(accuracy - err);
}

// -----------------------------
// Numeric utils (quadrature, solvers)
// -----------------------------

// 16-point Gauss-Legendre on [-1, 1]
const List<(double, double)> gaussLegendre16 = [
  (0.1894506104550685, -0.9815606342467191),
  (0.1894506104550685, 0.9815606342467191),
  (0.1826034150449236, -0.9041172563704749),
  (0.1826034150449236, 0.9041172563704749),
  (0.1691565193950025, -0.7699026741943047),
  (0.1691565193950025, 0.7699026741943047),
  (0.1495959888165767, -0.5873179542866175),
  (0.1495959888165767, 0.5873179542866175),
  (0.1246289712555339, -0.3678314989981802),
  (0.1246289712555339, 0.3678314989981802),
  (0.0951585116824928, -0.1252334085114689),
  (0.0951585116824928, 0.1252334085114689),
  (0.0622535239386479, -0.0 + 0.0 + 0.0),
  (0.0622535239386479, 0.0),
  (
    0.0951585116824928,
    -0.1252334085114689,
  ), // redundant lines included for symmetry
  (0.0951585116824928, 0.1252334085114689),
];

List<double> solveQuadratic(double c0, double c1, double c2) {
  // c0 + c1*x + c2*x^2 = 0
  if (c2.abs() < 1e-18) {
    if (c1.abs() < 1e-18) {
      return [];
    }

    return [-c0 / c1];
  }
  final double a = c2, b = c1, c = c0;
  final double disc = b * b - 4 * a * c;

  if (disc < 0) {
    return [];
  }
  if (disc == 0) {
    return [-b / (2 * a)];
  }

  final double s = math.sqrt(disc);
  final double q = -0.5 * (b + (b >= 0 ? s : -s)); // more stable
  final double r1 = q / a;
  final double r2 = c / q;
  final List<double> roots = [r1, r2]..sort();

  return roots;
}

List<double> solveCubic(double c0, double c1, double c2, double c3) {
  // c0 + c1*x + c2*x^2 + c3*x^3 = 0
  if (c3.abs() < 1e-18) {
    return solveQuadratic(c0, c1, c2);
  }
  // Normalize
  final double a = c3;
  final double b = c2;
  final double c = c1;
  final double d = c0;
  final double inva = 1.0 / a;
  final double bb = b * inva;
  final double cc = c * inva;
  final double dd = d * inva;
  // Depressed cubic: y^3 + py + q = 0 via x = y - b/3a
  final double b3 = bb / 3.0;
  final double p = cc - bb * bb / 3.0;
  final double q = 2 * bb * bb * bb / 27.0 - bb * cc / 3.0 + dd;
  final double disc = (q * q / 4.0) + (p * p * p / 27.0);
  final List<double> roots = <double>[];

  if (disc > 0) {
    final double s = math.sqrt(disc);
    final double u = _cbrt(-q / 2.0 + s);
    final double v = _cbrt(-q / 2.0 - s);

    roots.add(u + v - b3);
  } else if (disc.abs() < 1e-18) {
    final double u = _cbrt(-q / 2.0);

    roots.add(u + u - b3);
    roots.add(-u - b3);
  } else {
    final double r = math.sqrt(-p * p * p / 27.0);
    final double phi = math.acos(-q / (2.0 * r));
    final double t = 2.0 * math.pow(r, 1 / 3.0);
    final double y1 = t * math.cos(phi / 3.0);
    final double y2 = t * math.cos((phi + 2 * math.pi) / 3.0);
    final double y3 = t * math.cos((phi + 4 * math.pi) / 3.0);

    roots.addAll([y1 - b3, y2 - b3, y3 - b3]);
  }
  roots.sort();

  return roots;
}

List<double> solveQuartic(
  double c0,
  double c1,
  double c2,
  double c3,
  double c4,
) {
  // c0 + c1*x + c2*x^2 + c3*x^3 + c4*x^4 = 0
  if (c4.abs() < 1e-18) {
    return solveCubic(c0, c1, c2, c3);
  }

  // Cauchy bound for roots
  final double a4 = c4.abs();
  final double R =
      1 +
      [
        c0.abs() / a4,
        c1.abs() / a4,
        c2.abs() / a4,
        c3.abs() / a4,
      ].reduce(math.max);

  // Find derivative roots to bracket intervals
  final double d0 = c1,
      d1 = 2 * c2,
      d2 = 3 * c3,
      d3 = 4 * c4; // derivative coeffs reversed order
  final List<double> dRoots = solveCubic(d0, d1, d2, d3)
    ..removeWhere((v) => v.isNaN);

  final List<double> xs = [-R, ...dRoots.where((x) => x.isFinite), R]..sort();

  double f(double x) {
    return (((c4 * x + c3) * x + c2) * x + c1) * x + c0;
  }

  final List<double> roots = <double>[];

  for (int i = 0; i < xs.length - 1; i++) {
    double a = xs[i], b = xs[i + 1];
    double fa = f(a), fb = f(b);

    if (fa.abs() < 1e-14) {
      roots.add(a);
    }
    if (fb.abs() < 1e-14) {
      roots.add(b);
    }
    if (fa == 0 || fb == 0) {
      continue;
    }
    if (fa.sign == fb.sign) {
      continue;
    }
    // Bisection
    for (int it = 0; it < 80; it++) {
      final double m = 0.5 * (a + b);
      final double fm = f(m);

      if ((b - a) < 1e-12 || fm.abs() < 1e-14) {
        roots.add(m);
        break;
      }
      if (fa.sign != fm.sign) {
        b = m;
        fb = fm;
      } else {
        a = m;
        fa = fm;
      }
    }
  }

  // Dedup close roots
  roots.sort();

  final List<double> dedup = <double>[];

  const double tol = 1e-9;

  for (final double r in roots) {
    if (dedup.isEmpty || (r - dedup.last).abs() > tol) {
      dedup.add(r);
    }
  }

  return dedup;
}

double _cbrt(double x) => x >= 0
    ? math.pow(x, 1.0 / 3.0) as double
    : -math.pow(-x, 1.0 / 3.0) as double;

double solveItp(
  double Function(double) f,
  double a,
  double b,
  double eps,
  double fa,
  double fb, {
  int maxIter = 64,
}) {
  // Simple safeguarded bisection/secant hybrid.
  if (fa.isNaN || fb.isNaN) {
    throw StateError('Invalid bracket values');
  }
  if (fa == 0) {
    return a;
  }
  if (fb == 0) {
    return b;
  }
  if (fa.sign == fb.sign) {
    // Try to bracket by sampling
    final double fa0 = f(a);
    final double fb0 = f(b);

    if (fa0.sign == fb0.sign) {
      throw StateError('No sign change in bracket');
    }
    fa = fa0;
    fb = fb0;
  }
  double lo = a, hi = b, flo = fa;
  double x = (a + b) / 2.0;

  for (int i = 0; i < maxIter; i++) {
    x = 0.5 * (lo + hi);

    final double fx = f(x);

    if (fx == 0 || (hi - lo).abs() < eps) {
      break;
    }
    if (fx.sign == flo.sign) {
      lo = x;
      flo = fx;
    } else {
      hi = x;
    }
  }
  return x;
}

List<MPSimplificationCubicBez> mpConvertTHBeziersToCubicsBez(
  List<THLineSegment> segs,
) {
  final List<MPSimplificationCubicBez> cubics = <MPSimplificationCubicBez>[];

  THLineSegment startSegment = segs.first;

  for (final THLineSegment seg in segs.skip(1)) {
    if (seg is! THBezierCurveLineSegment) {
      throw ArgumentError(
        'All segments must be THBezierCurveLineSegment, found ${seg.runtimeType}',
      );
    }

    final Offset endPoint = seg.endPoint.coordinates;
    final Offset controlPoint1 = seg.controlPoint1.coordinates;
    final Offset controlPoint2 = seg.controlPoint2.coordinates;
    final MPSimplificationPoint p0 = MPSimplificationPoint(
      startSegment.endPoint.coordinates.dx,
      startSegment.endPoint.coordinates.dy,
      lineSegment: startSegment,
    );
    // Standard cubic Bezier ordering: (start, control1, control2, end)
    final MPSimplificationPoint p1 = MPSimplificationPoint(
      controlPoint1.dx,
      controlPoint1.dy,
      lineSegment: seg,
    );
    final MPSimplificationPoint p2 = MPSimplificationPoint(
      controlPoint2.dx,
      controlPoint2.dy,
      lineSegment: seg,
    );
    final MPSimplificationPoint p3 = MPSimplificationPoint(
      endPoint.dx,
      endPoint.dy,
      lineSegment: seg,
    );

    startSegment = seg;
    cubics.add(
      MPSimplificationCubicBez(
        p0,
        p1,
        p2,
        p3,
        lineSegment: seg,
        isCalculated: false,
      ),
    );
  }

  return cubics;
}
