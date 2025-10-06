import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

void main() {
  test('nearlyEqual basic behaviours', () {
    // exact equality
    expect(MPNumericAux.nearlyEqual(1.0, 1.0), isTrue);

    // small relative difference within epsilon
    final double a = 1.0;
    final double b = 1.0 + mpDoubleNextEpsilon * 10;
    expect(MPNumericAux.nearlyEqual(a, b), isTrue);

    // larger relative difference should fail
    final double c = 1.0 + mpDoubleNextEpsilon * 1000000;
    expect(MPNumericAux.nearlyEqual(a, c), isFalse);

    // NaN
    expect(MPNumericAux.nearlyEqual(double.nan, 1.0), isFalse);

    // infinities
    expect(MPNumericAux.nearlyEqual(double.infinity, double.infinity), isTrue);
    expect(
      MPNumericAux.nearlyEqual(double.infinity, -double.infinity),
      isFalse,
    );
  });
}
