import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';
import 'package:dart_numerics/dart_numerics.dart' as numerics;

class MPNumericHelper {
  static RegExp endingZeroes = RegExp(r'0*$');
  static RegExp endingDot = RegExp(r'\.$');

  static THDoublePart fromString(String valueString) {
    valueString = valueString.trim();

    final double? doubleValue = double.tryParse(valueString);
    if (doubleValue == null) {
      throw THConvertFromStringException(
          'THDoublePart fromString', valueString);
    }
    final double value = doubleValue;

    final int dotPosition = valueString.indexOf(thDecimalSeparator);
    final int decimalPositions =
        (dotPosition > 0) ? valueString.length - (dotPosition + 1) : 0;

    return THDoublePart(value: value, decimalPositions: decimalPositions);
  }

  static String doubleToString(double value, int decimalPositions) {
    /// Adapted from https://stackoverflow.com/a/67497099/11754455
    final double incrementValue = numerics.positiveEpsilonOf(value);

    if (value < 0) {
      value -= incrementValue;
    } else {
      value += incrementValue;
    }

    final String valueString = value.toStringAsFixed(decimalPositions);

    return removeTrailingZeros(valueString);
  }

  static String removeTrailingZeros(String valueString) {
    if (valueString.contains('.')) {
      // Remove trailing zeros
      valueString = valueString.replaceAll(endingZeroes, '');
      // Remove the decimal point if it is the last character
      valueString = valueString.replaceAll(endingDot, '');
    }
    return valueString;
  }

  static bool isRect1InsideRect2({
    required Rect rect1,
    required Rect rect2,
  }) {
    return rect2.contains(rect1.topLeft) && rect2.contains(rect1.bottomRight);
  }
}
