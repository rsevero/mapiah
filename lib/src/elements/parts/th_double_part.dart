import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/auxiliary/th_numeric_helper.dart';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

part 'th_double_part.mapper.dart';

@MappableClass()
class THDoublePart with THDoublePartMappable {
  late double _value;
  late int _decimalPositions;

  THDoublePart(double value, int decimalPositions) {
    _value = value;
    this.decimalPositions = decimalPositions;
  }

  THDoublePart.fromString(String valueString) {
    fromString(valueString);
  }

  set decimalPositions(int decimalPositions) {
    if (decimalPositions < 0) {
      decimalPositions = 0;
    } else if (decimalPositions > thMaxDecimalPositions) {
      decimalPositions = thMaxDecimalPositions;
    }

    _decimalPositions = decimalPositions;
  }

  double get value {
    return _value;
  }

  int get decimalPositions {
    return _decimalPositions;
  }

  void fromString(String valueString) {
    valueString = valueString.trim();

    final double? doubleValue = double.tryParse(valueString);
    if (doubleValue == null) {
      throw THConvertFromStringException('THDoublePart', valueString);
    }
    _value = doubleValue;

    final int dotPosition = valueString.indexOf(thDecimalSeparator);
    _decimalPositions =
        (dotPosition > 0) ? valueString.length - (dotPosition + 1) : 0;
  }

  void fromValue(double value, int decimalPositions) {
    _value = value;
    _decimalPositions = decimalPositions;
  }

  @override
  String toString() {
    return THNumericHelper.doubleToString(_value, _decimalPositions);
  }
}
