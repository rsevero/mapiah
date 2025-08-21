import 'dart:convert';

import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

class THDoublePart extends THPart {
  late final double _value;
  late final int _decimalPositions;

  THDoublePart({required double value, int? decimalPositions})
    : _value = value {
    this.decimalPositions =
        decimalPositions ?? MPNumericAux.getMinimumNumberOfDecimals(value);
  }

  THDoublePart.fromString({required String valueString}) {
    fromString(valueString);
  }

  @override
  THPartType get type => THPartType.double;

  @override
  Map<String, dynamic> toMap() {
    return {
      'partType': type.name,
      'value': _value,
      'decimalPositions': _decimalPositions,
    };
  }

  factory THDoublePart.fromMap(Map<String, dynamic> map) {
    return THDoublePart(
      value: map['value'],
      decimalPositions: map['decimalPositions'],
    );
  }

  factory THDoublePart.fromJson(String jsonString) {
    return THDoublePart.fromMap(jsonDecode(jsonString));
  }

  @override
  THDoublePart copyWith({double? value, int? decimalPositions}) {
    return THDoublePart(
      value: value ?? _value,
      decimalPositions: decimalPositions ?? _decimalPositions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THDoublePart &&
        other._value == _value &&
        other._decimalPositions == _decimalPositions;
  }

  @override
  int get hashCode => Object.hash(_value, _decimalPositions);

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

    decimalPositions = (dotPosition > 0)
        ? valueString.length - (dotPosition + 1)
        : 0;
  }

  void fromValue(double value, int decimalPositions) {
    _value = value;
    _decimalPositions = decimalPositions;
  }

  @override
  String toString() {
    return MPNumericAux.doubleToString(_value, _decimalPositions);
  }
}
