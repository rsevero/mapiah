import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';

class _LineSource extends MPSimplificationParamCurveFit {
  // Parametric straight line from (0,0) to (1,0)
  @override
  MPSimplificationCurveFitSample samplePtTangent(double t, double sign) {
    final MPSimplificationPoint p = MPSimplificationPoint(
      t.clamp(0.0, 1.0),
      0.0,
    );
    final MPSimplificationVec2 tan = const MPSimplificationVec2(1.0, 0.0);
    return MPSimplificationCurveFitSample(p, tan);
  }

  @override
  (MPSimplificationPoint, MPSimplificationVec2) samplePtDeriv(double t) {
    final double tc = t.clamp(0.0, 1.0);
    return (
      MPSimplificationPoint(tc, 0.0),
      const MPSimplificationVec2(1.0, 0.0),
    );
  }

  @override
  double? breakCusp(MPSimplificationRange range) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bezier fitter emits moveTo before any curveTo', () {
    test('fitToBezPath: toCubics does not throw and is non-empty', () {
      final source = _LineSource();
      final BezPath path = fitToBezPath(source, 1e-3);

      expect(() => path.toCubics(), returnsNormally);
      expect(path.toCubics(), isNotEmpty);
    });

    test('fitToBezPathOpt: toCubics does not throw and is non-empty', () {
      final source = _LineSource();
      final BezPath path = fitToBezPathOpt(source, 1e-3);

      expect(() => path.toCubics(), returnsNormally);
      expect(path.toCubics(), isNotEmpty);
    });
  });
}
