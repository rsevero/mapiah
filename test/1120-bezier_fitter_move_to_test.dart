import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_bezier_fit_aux.dart';

class _LineSource extends ParamCurveFit {
  // Parametric straight line from (0,0) to (1,0)
  @override
  CurveFitSample samplePtTangent(double t, double sign) {
    final Point p = Point(t.clamp(0.0, 1.0), 0.0);
    final Vec2 tan = const Vec2(1.0, 0.0);
    return CurveFitSample(p, tan);
  }

  @override
  (Point, Vec2) samplePtDeriv(double t) {
    final double tc = t.clamp(0.0, 1.0);
    return (Point(tc, 0.0), const Vec2(1.0, 0.0));
  }

  @override
  double? breakCusp(Range range) => null;
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
