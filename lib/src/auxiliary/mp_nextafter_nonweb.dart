import 'dart:typed_data';

double nextUpReal(double x) {
  if ((x.isNaN) || (x == double.infinity)) {
    return x;
  }

  if (x == double.negativeInfinity) {
    return -double.maxFinite;
  }

  if ((x == 0.0) || (x == -0.0)) {
    return double.minPositive;
  }

  var (sign, exponent, precision) = doubleToComponents(x);

  if (x > 0.0) {
    precision++;
  } else {
    precision--;
  }

  return componentsToDouble(sign, exponent, precision);
}

double nextDownReal(double x) {
  if ((x.isNaN) || (x == double.negativeInfinity)) {
    return x;
  }

  if (x == double.infinity) {
    return double.maxFinite;
  }

  if ((x == 0.0) || (x == -0.0)) {
    return -double.minPositive;
  }

  var (sign, exponent, precision) = doubleToComponents(x);

  if (x > 0.0) {
    precision--;
  } else {
    precision++;
  }

  return componentsToDouble(sign, exponent, precision);
}

(int, int, int) doubleToComponents(double value) {
  ByteData bytes = ByteData(8);
  bytes.setFloat64(0, value);
  final int sign = bytes.getUint8(0) >> 7;
  final int exponent =
      ((bytes.getUint8(0) & 0x7F) << 4) | ((bytes.getUint8(1) >> 4));
  final int precision = ((bytes.getUint8(1) & 0x0F) << 48) +
      (bytes.getUint32(2) << 16) +
      (bytes.getUint16(6));
  return (sign, exponent, precision);
}

double componentsToDouble(int sign, int exponent, int precision) {
  ByteData bytes = ByteData(8);
  bytes.setUint8(0, (sign << 7) + (exponent >> 4));
  bytes.setUint8(1, ((exponent & 0xF) << 4) + (precision >> 48));
  bytes.setUint32(2, (precision >> 16) & 0xFFFFFFFF);
  bytes.setUint16(6, precision & 0xFFFF);
  return bytes.getFloat64(0);
}
