import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_bezier_curve.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_straight_segment.dart';

const double maxDelta = 1e-12;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('nextUp() and nextDown() for a positive number', () {
    double original = 1734.12;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);

      expect(result, greaterThan(original));
      expect(result, closeTo(original, maxDelta));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);

      expect(result, lessThan(original));
      expect(result, closeTo(original, maxDelta));
    });
  });
  group('nextUp() and nextDown() for a negative number', () {
    double original = -32.122;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);

      expect(result, greaterThan(original));
      expect(result, closeTo(original, maxDelta));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);

      expect(result, lessThan(original));
      expect(result, closeTo(original, maxDelta));
    });
  });
  group('nextUp() and nextDown() for 0.0', () {
    double original = 0.0;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);

      expect(result, double.minPositive);
      expect(result, greaterThan(original));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);

      expect(result, -double.minPositive);
      expect(result, lessThan(original));
    });
  });

  group('nextUp() and nextDown() for double.minPositive', () {
    double original = double.minPositive;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);

      expect(result, greaterThan(original));
      expect(result, closeTo(original, maxDelta));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);

      expect(result, 0.0);
      expect(result, lessThan(original));
    });
  });

  group('nextUp() and nextDown() for -double.minPositive', () {
    double original = -double.minPositive;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);

      expect(result, 0.0);
      expect(result, greaterThan(original));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);

      expect(result, lessThan(original));
      expect(result, closeTo(original, maxDelta));
    });
  });

  group('MPNumericAux.nextUp', () {
    test('NaN stays NaN', () {
      final double nan = math.sqrt(-1);

      expect(MPNumericAux.nextUp(nan).isNaN, isTrue);
    });

    test('positive infinity stays infinity', () {
      expect(MPNumericAux.nextUp(double.infinity), double.infinity);
    });

    test('negative infinity steps to -maxFinite', () {
      expect(MPNumericAux.nextUp(double.negativeInfinity), -double.maxFinite);
    });

    test('zero steps to smallest positive subnormal', () {
      expect(MPNumericAux.nextUp(0.0), double.minPositive);
      expect(MPNumericAux.nextUp(-0.0), double.minPositive);
    });

    test('just below zero steps to zero', () {
      expect(MPNumericAux.nextUp(-double.minPositive), 0.0);
    });

    test('normal positives advance by 1 ULP', () {
      expect(MPNumericAux.nextUp(1.0), isNot(equals(1.0)));
      expect(MPNumericAux.nextUp(1.0) > 1.0, isTrue);
      expect(MPNumericAux.nextUp(2.0), closeTo(2.0, maxDelta));
    });

    test('normal negatives advance toward zero by 1 ULP', () {
      expect(MPNumericAux.nextUp(-1.0), closeTo(-1.0, maxDelta));
      expect(MPNumericAux.nextUp(-2.0) > -2.0, isTrue); // less negative
    });

    test('maxFinite steps to infinity', () {
      expect(MPNumericAux.nextUp(double.maxFinite), double.infinity);
    });
  });

  group('MPNumericAux.nextDown', () {
    test('NaN stays NaN', () {
      final double nan = math.sqrt(-1);

      expect(MPNumericAux.nextDown(nan).isNaN, isTrue);
    });

    test('negative infinity stays negative infinity', () {
      expect(
        MPNumericAux.nextDown(double.negativeInfinity),
        double.negativeInfinity,
      );
    });

    test('positive infinity steps to maxFinite', () {
      expect(MPNumericAux.nextDown(double.infinity), double.maxFinite);
    });

    test('zero steps to -smallest positive subnormal', () {
      expect(MPNumericAux.nextDown(0.0), -double.minPositive);
      expect(MPNumericAux.nextDown(-0.0), -double.minPositive);
    });

    test('just above zero steps to zero', () {
      expect(MPNumericAux.nextDown(double.minPositive), 0.0);
    });

    test('normal positives decrease by 1 ULP', () {
      final double nd = MPNumericAux.nextDown(2.0);

      expect(nd, closeTo(2.0, maxDelta));
      expect(nd < 2.0, isTrue);
    });

    test('normal negatives decrease away from zero by 1 ULP', () {
      expect(MPNumericAux.nextDown(-1.0) < -1.0, isTrue);
      expect(MPNumericAux.nextDown(-2.0), closeTo(-2.0, maxDelta));
    });

    test('minPositive stays finite', () {
      expect(MPNumericAux.nextDown(double.minPositive), 0.0);
    });
  });

  group('MPNumericAux.directionOffsetToDegrees', () {
    test('cardinal directions use azimuth convention', () {
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(0, -1)),
        closeTo(0.0, maxDelta),
      );
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(1, 0)),
        closeTo(90.0, maxDelta),
      );
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(0, 1)),
        closeTo(180.0, maxDelta),
      );
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(-1, 0)),
        closeTo(270.0, maxDelta),
      );
    });

    test('diagonal directions map as expected', () {
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(1, -1)),
        closeTo(45.0, maxDelta),
      );
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(-1, -1)),
        closeTo(315.0, maxDelta),
      );
    });

    test('zero direction returns 0.0', () {
      expect(
        MPNumericAux.directionOffsetToDegrees(Offset.zero),
        closeTo(0.0, maxDelta),
      );
    });

    test('magnitude does not matter', () {
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(0, -10)),
        closeTo(0.0, maxDelta),
      );
      expect(
        MPNumericAux.directionOffsetToDegrees(const Offset(10, 0)),
        closeTo(90.0, maxDelta),
      );
    });
  });

  group('MPNumericAux.bezierCurveTangent', () {
    test('returns a unit tangent at start', () {
      const MPBezierCurve curve = MPCubicBezierCurve(
        start: Offset(0, 0),
        c1: Offset(2, 0),
        c2: Offset(2, 2),
        end: Offset(0, 2),
      );

      final Offset t = MPNumericAux.bezierCurveTangent(
        curve,
        MPExtremityType.start,
      );

      expect(t.dx, closeTo(1.0, maxDelta));
      expect(t.dy, closeTo(0.0, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('returns a unit tangent at end', () {
      const MPBezierCurve curve = MPCubicBezierCurve(
        start: Offset(0, 0),
        c1: Offset(2, 0),
        c2: Offset(2, 2),
        end: Offset(0, 2),
      );

      final Offset t = MPNumericAux.bezierCurveTangent(
        curve,
        MPExtremityType.end,
      );

      expect(t.dx, closeTo(-1.0, maxDelta));
      expect(t.dy, closeTo(0.0, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('degenerate start tangent returns zero', () {
      const MPBezierCurve curve = MPCubicBezierCurve(
        start: Offset(1, 1),
        c1: Offset(1, 1),
        c2: Offset(2, 2),
        end: Offset(3, 3),
      );

      expect(
        MPNumericAux.bezierCurveTangent(curve, MPExtremityType.start),
        Offset.zero,
      );
    });

    test('degenerate end tangent returns zero', () {
      const MPBezierCurve curve = MPCubicBezierCurve(
        start: Offset(1, 1),
        c1: Offset(2, 2),
        c2: Offset(3, 3),
        end: Offset(3, 3),
      );

      expect(
        MPNumericAux.bezierCurveTangent(curve, MPExtremityType.end),
        Offset.zero,
      );
    });
  });

  group('MPNumericAux.straightTangent', () {
    test('returns a unit tangent from start to end', () {
      const MPStraightSegment s = MPStraightSegment(
        start: Offset(0, 0),
        end: Offset(3, 4),
      );

      final Offset t = MPNumericAux.straightTangent(s);

      expect(t.dx, closeTo(0.6, maxDelta));
      expect(t.dy, closeTo(0.8, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('degenerate segment returns zero', () {
      const MPStraightSegment s = MPStraightSegment(
        start: Offset(1, 1),
        end: Offset(1, 1),
      );

      expect(MPNumericAux.straightTangent(s), Offset.zero);
    });
  });

  group('MPNumericAux.averageTangent', () {
    test('averages end of first and start of second (straight segments)', () {
      const MPStraightSegment s1 = MPStraightSegment(
        start: Offset(0, 0),
        end: Offset(1, 0),
      );
      const MPStraightSegment s2 = MPStraightSegment(
        start: Offset(1, 0),
        end: Offset(1, 1),
      );

      final Offset t = MPNumericAux.averageTangent(s1, s2);

      final double expected = math.sqrt(2) / 2;
      expect(t.dx, closeTo(expected, maxDelta));
      expect(t.dy, closeTo(expected, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('uses bezier end tangent when first is a cubic curve', () {
      const MPCubicBezierCurve c1 = MPCubicBezierCurve(
        start: Offset(0, 0),
        c1: Offset(1, 0),
        c2: Offset(2, 0),
        end: Offset(3, 0),
      );
      const MPStraightSegment s2 = MPStraightSegment(
        start: Offset(3, 0),
        end: Offset(3, 1),
      );

      final Offset t = MPNumericAux.averageTangent(c1, s2);

      final double expected = math.sqrt(2) / 2;
      expect(t.dx, closeTo(expected, maxDelta));
      expect(t.dy, closeTo(expected, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('degenerate first returns second start tangent', () {
      const MPStraightSegment s1 = MPStraightSegment(
        start: Offset(1, 1),
        end: Offset(1, 1),
      );
      const MPStraightSegment s2 = MPStraightSegment(
        start: Offset(1, 1),
        end: Offset(1, 2),
      );

      final Offset t = MPNumericAux.averageTangent(s1, s2);
      expect(t.dx, closeTo(0.0, maxDelta));
      expect(t.dy, closeTo(1.0, maxDelta));
      expect(t.distance, closeTo(1.0, maxDelta));
    });

    test('both degenerate returns zero', () {
      const MPStraightSegment s1 = MPStraightSegment(
        start: Offset(1, 1),
        end: Offset(1, 1),
      );
      const MPStraightSegment s2 = MPStraightSegment(
        start: Offset(2, 2),
        end: Offset(2, 2),
      );

      expect(MPNumericAux.averageTangent(s1, s2), Offset.zero);
    });
  });

  group('MPNumericAux.normalFromTangent', () {
    test('returns a unit normal (counterclockwise) from a unit tangent', () {
      final Offset n = MPNumericAux.normalFromTangent(const Offset(1, 0));

      expect(n.dx, closeTo(0.0, maxDelta));
      expect(n.dy, closeTo(-1.0, maxDelta));
      expect(n.distance, closeTo(1.0, maxDelta));
    });

    test('returns a unit normal (clockwise) from a unit tangent', () {
      final Offset n = MPNumericAux.normalFromTangent(
        const Offset(1, 0),
        clockwise: true,
      );

      expect(n.dx, closeTo(0.0, maxDelta));
      expect(n.dy, closeTo(1.0, maxDelta));
      expect(n.distance, closeTo(1.0, maxDelta));
    });

    test('normalizes non-unit tangents', () {
      final Offset n = MPNumericAux.normalFromTangent(const Offset(3, 4));

      expect(n.dx, closeTo(-0.8, maxDelta));
      expect(n.dy, closeTo(-0.6, maxDelta));
      expect(n.distance, closeTo(1.0, maxDelta));
    });

    test('zero tangent returns zero', () {
      expect(MPNumericAux.normalFromTangent(Offset.zero), Offset.zero);
    });
  });
}
