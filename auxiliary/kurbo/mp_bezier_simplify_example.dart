// Adapter: a source curve made of consecutive cubic Beziers
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';

/// How to use the example
/// Build a list of connected cubics and call:
/// final result = simplifyCubicChain(myCubics, accuracy: 0.5);
/// Or, if you prefer the near-optimal approach, swap the call inside the function to fitToBezPathOpt.
class CubicChainSource implements MPSimplificationParamCurveFit {
  final List<MPSimplificationCubicBez> curves;
  CubicChainSource(this.curves) {
    if (curves.isEmpty) {
      throw ArgumentError('curves must not be empty');
    }
  }

  int get _n => curves.length;

  // Map global t∈[0,1] to segment index and local u∈[0,1]
  (int, double) _segForT(double t) {
    final tt = t.clamp(0.0, 1.0);
    var i = (tt * _n).floor();
    if (i >= _n) i = _n - 1;
    final u = tt * _n - i;
    return (i, u);
  }

  @override
  (MPSimplificationPoint, MPSimplificationVec2) samplePtDeriv(double t) {
    final (i, u) = _segForT(t);
    final c = curves[i];
    final p = c.eval(u);
    // Chain rule: dt over concatenated segments (equal share per segment)
    final d = c.deriv(u) * _n.toDouble();
    return (p, d);
  }

  @override
  MPSimplificationCurveFitSample samplePtTangent(double t, double sign) {
    final (p, d0) = samplePtDeriv(t);
    var d = d0;
    // If near a cusp or join, peek slightly to the chosen side
    if (d.x * d.x + d.y * d.y < 1e-18) {
      final eps = (sign >= 0 ? 1 : -1) * (1e-5 / _n);
      final tp = (t + eps).clamp(0.0, 1.0);
      d = samplePtDeriv(tp).$2;
    }
    return MPSimplificationCurveFitSample(p, d);
  }

  @override
  double? breakCusp(MPSimplificationRange range) {
    // Treat joins between segments as “cusps” so we don’t fit across them.
    for (var i = 1; i < _n; i++) {
      final b = i / _n;
      if (b > range.start && b < range.end) return b;
    }
    return null;
  }

  // Provide moment integrals (area and first moments) using quadrature,
  // matching the default in ParamCurveFit.
  @override
  (double, double, double) momentIntegrals(MPSimplificationRange range) {
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
}

// Helper: turn a BezPath back into a list of CubicBez
List<MPSimplificationCubicBez> bezPathToCubics(BezPath path) => path.toCubics();

// Example usage: returns the simplified chain as cubics
List<MPSimplificationCubicBez> mpSimplifyCubicChain(
  List<MPSimplificationCubicBez> chain, {
  double accuracy = 0.5, // tolerance in your coordinate units
}) {
  final source = CubicChainSource(chain);
  // Fast recursive fitter
  final simplified = fitToBezPath(source, accuracy);
  // Or, near-optimal (slower)
  // final simplified = fitToBezPathOpt(source, accuracy);
  return bezPathToCubics(simplified);
}
