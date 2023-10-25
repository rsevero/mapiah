import "dart:math";

import "package:mapiah/src/th_definitions.dart";

class THDoublePart {
  late double value;
  late int _decimalPositions;

  THDoublePart(aValue, aDecimalPositions) : value = aValue {
    decimalPositions = aDecimalPositions;
  }

  THDoublePart.fromString(String aValueString) {
    aValueString = aValueString.trim();

    var dotPosition = aValueString.indexOf(thDecimalSeparator);
    decimalPositions =
        (dotPosition > 0) ? aValueString.length - (dotPosition + 1) : 0;

    value = double.parse(aValueString);
  }

  set decimalPositions(int aDecimalPositions) {
    if (aDecimalPositions < 0) {
      aDecimalPositions = 0;
    } else if (aDecimalPositions > 20) {
      aDecimalPositions = 20;
    }

    _decimalPositions = aDecimalPositions;
  }

  int get decimalPositions {
    return _decimalPositions;
  }

  /// Based on [https://stackoverflow.com/questions/28419255/how-do-you-round-a-double-in-dart-to-a-given-degree-of-precision-after-the-decim/67497099#67497099]
  @override
  String toString() {
    String numbersAfterDecimal = value.toString().split('.')[1];

    if (numbersAfterDecimal != '0') {
      int existingNumberOfDecimal = numbersAfterDecimal.length;
      double incrementValue = 1 / (10 * pow(10, existingNumberOfDecimal));
      if (value < 0) {
        value -= incrementValue;
      } else {
        value += incrementValue;
      }
    }
    var asString = value.toStringAsFixed(decimalPositions);

    return asString;
  }
}
