import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('nextUp() and nextDown() for a positive number', () {
    double original = 1734.12;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);
      expect(result, greaterThan(original));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);
      expect(result, lessThan(original));
    });
  });
  group('nextUp() and nextDown() for a negative number', () {
    double original = -32.122;

    test('nextUp() should return a bigger number than the original', () {
      final double result = MPNumericAux.nextUp(original);
      expect(result, greaterThan(original));
    });

    test('nextDown() should return a smaller number than the original', () {
      final double result = MPNumericAux.nextDown(original);
      expect(result, lessThan(original));
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
    });
  });
}
