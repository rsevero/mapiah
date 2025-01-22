import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

enum THAngleUnit {
  degree,
  grad,
  mil,
  minute,
}

class THAngleUnitPart extends THPart {
  late THAngleUnit unit;

  static const stringToUnit = {
    'deg': THAngleUnit.degree,
    'degree': THAngleUnit.degree,
    'degrees': THAngleUnit.degree,
    'grad': THAngleUnit.grad,
    'grads': THAngleUnit.grad,
    'mil': THAngleUnit.mil,
    'mils': THAngleUnit.mil,
    'min': THAngleUnit.minute,
    'minute': THAngleUnit.minute,
    'minutes': THAngleUnit.minute,
  };

  static const unitToString = {
    THAngleUnit.degree: 'deg',
    THAngleUnit.grad: 'grad',
    THAngleUnit.mil: 'mil',
    THAngleUnit.minute: 'min',
  };

  THAngleUnitPart({required this.unit});

  THAngleUnitPart.fromString({required String unitString}) {
    fromString(unitString);
  }

  @override
  THPartType get type => THPartType.angleUnit;

  @override
  Map<String, dynamic> toMap() {
    return {
      'partType': type.name,
      'unit': unitToString[unit],
    };
  }

  factory THAngleUnitPart.fromMap(Map<String, dynamic> map) {
    return THAngleUnitPart(
      unit: stringToUnit[map['unit']]!,
    );
  }

  factory THAngleUnitPart.fromJson(String jsonString) {
    return THAngleUnitPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THAngleUnitPart copyWith({
    THAngleUnit? unit,
  }) {
    return THAngleUnitPart(
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THAngleUnitPart other) {
    if (identical(this, other)) return true;

    return other.unit == unit;
  }

  @override
  int get hashCode => unit.hashCode;

  void fromString(String unitString) {
    if (!isUnit(unitString)) {
      throw THConvertFromStringException('THAngleUnitPart', unitString);
    }

    unit = stringToUnit[unitString]!;
  }

  @override
  String toString() {
    return unitToString[unit]!;
  }

  static bool isUnit(String unitString) {
    return stringToUnit.containsKey(unitString);
  }
}
