import 'package:dart_mappable/dart_mappable.dart';
import 'package:dart_numerics/dart_numerics.dart' as numerics;

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

part 'th_double_part.mapper.dart';

@MappableClass()
class THDoublePart with THDoublePartMappable {
  late double value;
  late int _decimalPositions;

  THDoublePart(this.value, int decimalPositions) {
    this.decimalPositions = decimalPositions;
  }

  THDoublePart.fromString(String aValueString) {
    fromString(aValueString);
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

  void fromString(String aValueString) {
    aValueString = aValueString.trim();

    final aDouble = double.tryParse(aValueString);
    if (aDouble == null) {
      throw THConvertFromStringException('THDoublePart', aValueString);
    }
    value = aDouble;

    final dotPosition = aValueString.indexOf(thDecimalSeparator);
    decimalPositions =
        (dotPosition > 0) ? aValueString.length - (dotPosition + 1) : 0;
  }

  void fromValue(double aValue, int aDecimalPositions) {
    value = aValue;
    decimalPositions = aDecimalPositions;
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
