import 'package:dart_numerics/dart_numerics.dart' as numerics;

import "package:mapiah/src/th_definitions.dart";

class THDoublePart {
  late double value;
  late int _decimalPositions;

  THDoublePart(aValue, aDecimalPositions) : value = aValue {
    decimalPositions = aDecimalPositions;
  }

  THDoublePart.fromString(String aValueString) {
    fromString(aValueString);
  }

  void fromString(String aValueString) {
    aValueString = aValueString.trim();

    var dotPosition = aValueString.indexOf(thDecimalSeparator);
    decimalPositions =
        (dotPosition > 0) ? aValueString.length - (dotPosition + 1) : 0;

    value = double.parse(aValueString);
  }

  void fromValue(double aValue, int aDecimalPositions) {
    value = aValue;
    decimalPositions = aDecimalPositions;
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

  @override
  String toString() {
    double incrementValue = numerics.positiveEpsilonOf(value);

    if (value < 0) {
      value -= incrementValue;
    } else {
      value += incrementValue;
    }

    var asString = value.toStringAsFixed(decimalPositions);

    return asString;
  }
}
