import 'package:mapiah/src/constants/mp_constants.dart';

double nextUpReal(double x) {
  // Web-safe implementation (no bitwise ops)
  if (x.isNaN || x == double.infinity) {
    return x;
  }
  if (x == double.negativeInfinity) {
    return -double.maxFinite;
  }
  if (x == 0.0 || x == -0.0) {
    return double.minPositive;
  }
  if (x == -double.minPositive) {
    return 0.0;
  }

  final double next =
      x * (x > 0 ? mpDoubleUpEpsilonFactor : mpDoubleDownEpsilonFactor);

  return next;
}

double nextDownReal(double x) {
  // Web-safe implementation (no bitwise ops)
  if (x.isNaN || x == double.negativeInfinity) {
    return x;
  }
  if (x == double.infinity) {
    return double.maxFinite;
  }
  if (x == 0.0 || x == -0.0) {
    return -double.minPositive;
  }
  if (x == double.minPositive) {
    return 0.0;
  }

  final double next =
      x * (x > 0 ? mpDoubleDownEpsilonFactor : mpDoubleUpEpsilonFactor);

  return next;
}
