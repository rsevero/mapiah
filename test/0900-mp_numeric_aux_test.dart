import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';

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
}
