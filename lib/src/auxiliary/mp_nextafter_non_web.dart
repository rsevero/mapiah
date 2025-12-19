import 'dart:math' as math;
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

  if (x == -double.minPositive) {
    return 0.0;
  }

  // final int bits = _doubleToBits(x);
  // final int next = x > 0 ? bits + 1 : bits - 1;

  // return _bitsToDouble(next);

  return x + ulp(x);
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

  if (x == double.minPositive) {
    return 0.0;
  }

  // final int bits = _doubleToBits(x);
  // final int next = x > 0 ? bits - 1 : bits + 1;

  // return _bitsToDouble(next);

  return x - ulp(x);
}

int _doubleToBits(double value) {
  final ByteData b = ByteData(8);

  b.setFloat64(0, value, Endian.big);

  return b.getUint64(0, Endian.big);
}

double _bitsToDouble(int bits) {
  final ByteData b = ByteData(8);

  b.setUint64(0, bits, Endian.big);

  return b.getFloat64(0, Endian.big);
}

// double nextUpReal(double x) {
//   if ((x.isNaN) || (x == double.infinity)) {
//     return x;
//   }

//   if (x == double.negativeInfinity) {
//     return -double.maxFinite;
//   }

//   if ((x == 0.0) || (x == -0.0)) {
//     return double.minPositive;
//   }

//   if (x == -double.minPositive) {
//     return 0.0;
//   }

//   var (int sign, int exponent, int precision) = doubleToComponents(x);

//   if (x > 0.0) {
//     precision++;
//   } else {
//     precision--;
//   }

//   return componentsToDouble(sign, exponent, precision);
// }

// double nextDownReal(double x) {
//   if ((x.isNaN) || (x == double.negativeInfinity)) {
//     return x;
//   }

//   if (x == double.infinity) {
//     return double.maxFinite;
//   }

//   if ((x == 0.0) || (x == -0.0)) {
//     return -double.minPositive;
//   }

//   if (x == double.minPositive) {
//     return 0.0;
//   }

//   var (int sign, int exponent, int precision) = doubleToComponents(x);

//   if (x > 0.0) {
//     precision--;
//   } else {
//     precision++;
//   }

//   return componentsToDouble(sign, exponent, precision);
// }

// (int, int, int) doubleToComponents(double value) {
//   ByteData bytes = ByteData(8);

//   bytes.setFloat64(0, value);

//   final int sign = bytes.getUint8(0) >> 7;
//   final int exponent =
//       ((bytes.getUint8(0) & 0x7F) << 4) | ((bytes.getUint8(1) >> 4));
//   final int precision =
//       ((bytes.getUint8(1) & 0x0F) << 48) +
//       (bytes.getUint32(2) << 16) +
//       (bytes.getUint16(6));

//   return (sign, exponent, precision);
// }

// double componentsToDouble(int sign, int exponent, int precision) {
//   ByteData bytes = ByteData(8);

//   bytes.setUint8(0, (sign << 7) + (exponent >> 4));
//   bytes.setUint8(1, ((exponent & 0xF) << 4) + (precision >> 48));
//   bytes.setUint32(2, (precision >> 16) & 0xFFFFFFFF);
//   bytes.setUint16(6, precision & 0xFFFF);

//   return bytes.getFloat64(0);
// }

double ulp(double d) {
  final int exp = _getExponent(d);

  // NaN or infinity
  if (exp == _doubleMaxExponent + 1) {
    return d.abs();
  }

  // zero or subnormal
  if (exp == _doubleMinExponent - 1) {
    return double.minPositive;
  }

  // normal numbers
  int e = exp - (_doubleSignificandWidth - 1);

  if (e >= _doubleMinExponent) {
    // 2^(e)
    return _powerOfTwo(e);
  } else {
    // subnormal result: shift the min subnormal left
    final int shift = e - (_doubleMinExponent - (_doubleSignificandWidth - 1));

    return _bitsToDouble(1 << shift);
  }
}

const int _doubleSignificandWidth = 53; // includes implicit leading 1
const int _doubleExponentBias = 1023;
const int _doubleMaxExponent = 1023; // unbiased max exponent for normal doubles
const int _doubleMinExponent =
    -1022; // unbiased min exponent for normal doubles

int _getExponent(double d) {
  final int bits = _doubleToBits(d);
  final int rawExp = (bits >> 52) & 0x7ff;

  if (rawExp == 0x7ff) {
    return _doubleMaxExponent + 1;
  } // NaN or infinity
  if (rawExp == 0) {
    return _doubleMinExponent - 1;
  } // zero or subnormal

  return rawExp - _doubleExponentBias; // unbiased exponent
}

double _powerOfTwo(int exp) => math.pow(2.0, exp).toDouble();
