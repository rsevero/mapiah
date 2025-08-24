import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

enum THAngleUnitType { degree, grad, mil, minute }

class THAngleUnitPart extends THPart {
  late THAngleUnitType unit;

  static const stringToUnit = {
    'deg': THAngleUnitType.degree,
    'degree': THAngleUnitType.degree,
    'degrees': THAngleUnitType.degree,
    'grad': THAngleUnitType.grad,
    'grads': THAngleUnitType.grad,
    'mil': THAngleUnitType.mil,
    'mils': THAngleUnitType.mil,
    'min': THAngleUnitType.minute,
    'minute': THAngleUnitType.minute,
    'minutes': THAngleUnitType.minute,
  };

  static const unitToString = {
    THAngleUnitType.degree: 'deg',
    THAngleUnitType.grad: 'grad',
    THAngleUnitType.mil: 'mil',
    THAngleUnitType.minute: 'min',
  };

  THAngleUnitPart({required this.unit});

  THAngleUnitPart.fromString({required String unitString}) {
    fromString(unitString);
  }

  @override
  THPartType get type => THPartType.angleUnit;

  @override
  Map<String, dynamic> toMap() {
    return {'partType': type.name, 'unit': unitToString[unit]};
  }

  factory THAngleUnitPart.fromMap(Map<String, dynamic> map) {
    return THAngleUnitPart(unit: stringToUnit[map['unit']]!);
  }

  factory THAngleUnitPart.fromJson(String jsonString) {
    return THAngleUnitPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THAngleUnitPart copyWith({THAngleUnitType? unit}) {
    return THAngleUnitPart(unit: unit ?? this.unit);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THAngleUnitPart && other.unit == unit;
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
