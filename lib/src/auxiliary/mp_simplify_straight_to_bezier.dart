// Example: end-to-end conversion from a polyline (list of Points)
// to fitted cubic Beziers, and back to a polyline by simple resampling.
//
// This is a self-contained usage snippet that depends only on
// lib/src/auxiliary/mp_bezier_fit_aux.dart.

import 'dart:math' as math;
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';
import 'package:mapiah/src/auxiliary/mp_fit_cubic_schneider.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_bezier_to_bezier.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Minimal ParamCurveFit adapter for a polyline (piecewise linear curve).
/// Each segment shares the global parameter uniformly.
class _PolylineSource implements ParamCurveFit {
  _PolylineSource(List<Point> points, {this.breakAtJoints = true})
    : _pts = _dedup(points) {
    if (_pts.length < 2) {
      throw ArgumentError('Polyline must have at least 2 distinct points');
    }
    for (var i = 0; i < _pts.length - 1; i++) {
      _segments.add(_pts[i + 1] - _pts[i]);
    }
  }

  final List<Point> _pts;
  final List<Vec2> _segments = [];
  final bool breakAtJoints;

  int get _n => math.max(1, _segments.length);

  (int, double) _segForT(double t) {
    final tt = t.clamp(0.0, 1.0);
    var i = (tt * _n).floor();
    if (i >= _n) i = _n - 1;
    final u = tt * _n - i;
    return (i, u);
  }

  @override
  (Point, Vec2) samplePtDeriv(double t) {
    final (i, u) = _segForT(t);
    final p0 = _pts[i];
    final p1 = _pts[i + 1];
    final p = p0.lerp(p1, u);
    final d = _segments[i] * _n.toDouble();
    return (p, d);
  }

  @override
  CurveFitSample samplePtTangent(double t, double sign) {
    final (p, d0) = samplePtDeriv(t);
    var d = d0;
    // If derivative is (near) zero, sample slightly forward/backward.
    if (d.hypot2() < 1e-18) {
      final eps = (sign >= 0 ? 1 : -1) * (1e-5 / _n);
      final tp = (t + eps).clamp(0.0, 1.0);
      d = samplePtDeriv(tp).$2;
    }
    return CurveFitSample(p, d);
  }

  @override
  double? breakCusp(Range range) {
    if (!breakAtJoints) return null;
    for (var i = 1; i < _pts.length - 1; i++) {
      final b = i / _n; // uniform parameter per segment
      if (b > range.start && b < range.end) return b;
    }
    return null;
  }

  @override
  (double, double, double) momentIntegrals(Range range) {
    final t0 = 0.5 * (range.start + range.end);
    final dt = 0.5 * (range.end - range.start);
    double a = 0, x = 0, y = 0;
    for (final (w, xi) in gaussLegendre16) {
      final t = t0 + xi * dt;
      final (p, d) = samplePtDeriv(t);
      final ai = w * d.x * p.y;
      a += ai;
      x += p.x * ai;
      y += p.y * ai;
    }
    return (a * dt, x * dt, y * dt);
  }

  static List<Point> _dedup(List<Point> pts) {
    if (pts.isEmpty) return pts;
    final out = <Point>[];
    Point? last;
    for (final p in pts) {
      if (last == null || (p - last).hypot2() > 1e-24) {
        out.add(p);
        last = p;
      }
    }
    return out;
  }
}

/// Fit a polyline to cubic Bezier segments and return the fitted cubics.
List<CubicBez> mpFitPolylineToCubics(
  List<Point> points, {
  double accuracy = 0.5,
  bool breakAtJoints = true,
  bool nearOptimal = false,
}) {
  final source = _PolylineSource(points, breakAtJoints: breakAtJoints);
  final path = nearOptimal
      ? fitToBezPathOpt(source, accuracy)
      : fitToBezPath(source, accuracy);
  return path.toCubics();
}

/// Resample a list of cubic Beziers back to a polyline by uniform sampling.
List<Point> resampleCubics(
  List<CubicBez> cubics, {
  int samplesPerSegment = 12,
}) {
  final out = <Point>[];
  for (final c in cubics) {
    for (var i = 0; i <= samplesPerSegment; i++) {
      final t = i / samplesPerSegment;
      out.add(c.eval(t));
    }
  }
  return out;
}

/// Quick demo function: build a simple polyline, fit it, and resample back.
/// Returns both the fitted cubics and a polyline approximation from resampling.
(List<CubicBez>, List<Point>) demoPolylineFit() {
  // A simple polyline (a rough arc)
  final points = <Point>[
    Point(0, 0),
    Point(1, 0.2),
    Point(2, 0.8),
    Point(3, 2.0),
    Point(4, 4.0),
  ];

  final cubics = mpFitPolylineToCubics(points, accuracy: 0.25);
  final backToPolyline = resampleCubics(cubics, samplesPerSegment: 10);

  // Use `cubics` for rendering smooth curves.
  // `backToPolyline` shows a simple way to get a polyline approximation back.
  // This function intentionally has no prints to keep example quiet.
  return (cubics, backToPolyline);
}

List<THLineSegment> convertTHStraightLinesToTHBezierCurveLineSegments({
  required List<THLineSegment> originalStraightLineSegmentsList,
}) {
  final List<Point> points = originalStraightLineSegmentsList
      .map(
        (seg) =>
            Point(seg.endPoint.coordinates.dx, seg.endPoint.coordinates.dy),
      )
      .toList();

  if (points.isEmpty) {
    return [];
  }

  // final List<CubicBez> cubicBezs = mpFitPolylineToCubics(
  //   points,
  //   accuracy: 0.5,
  //   breakAtJoints: false,
  //   nearOptimal: false,
  // );
  final List<CubicBez> cubicBezs = fitCubicSchneider(points, errorSquared: 0.5);
  final List<THLineSegment> lineSegmentsList =
      mpConvertCubicBezsToTHBezierCurveLineSegments(
        cubicBezs: cubicBezs,
        originalLineSegmentsList: originalStraightLineSegmentsList,
      );

  return lineSegmentsList;
}
