double nextUpReal(double x) {
  // Web-safe implementation (no bitwise ops)
  if (x.isNaN || x == double.infinity) return x;
  if (x == 0.0 || x == -0.0) return double.minPositive;
  if (x == double.negativeInfinity) return -double.maxFinite;

  final double absX = x.abs();
  final double next = absX * (1 + 2.220446049250313e-16); // 2^-52

  return x > 0 ? next : -next;
}

double nextDownReal(double x) {
  if (x.isNaN || x == double.negativeInfinity) return x;
  if (x == double.infinity) return double.maxFinite;
  if (x == 0.0 || x == -0.0) return -double.minPositive;

  final double absX = x.abs();
  final double next = absX * (1 - 2.220446049250313e-16); // 2^-52

  return x > 0 ? next : -next;
}
