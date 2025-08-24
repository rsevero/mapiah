import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';

enum THClinoUnit { degree, grad, mil, minute, percent }

class THClinoUnitPart extends THPart {
  late final THClinoUnit unit;

  static const stringToUnit = {
    'deg': THClinoUnit.degree,
    'degree': THClinoUnit.degree,
    'degrees': THClinoUnit.degree,
    'grad': THClinoUnit.grad,
    'grads': THClinoUnit.grad,
    'mil': THClinoUnit.mil,
    'mils': THClinoUnit.mil,
    'min': THClinoUnit.minute,
    'minute': THClinoUnit.minute,
    'minutes': THClinoUnit.minute,
    'percent': THClinoUnit.percent,
    'percentage': THClinoUnit.percent,
  };

  static const unitToString = {
    THClinoUnit.degree: 'deg',
    THClinoUnit.grad: 'grad',
    THClinoUnit.mil: 'mil',
    THClinoUnit.minute: 'min',
    THClinoUnit.percent: 'percent',
  };

  THClinoUnitPart({required this.unit}) : super();

  THClinoUnitPart.fromString(String unitString) : super() {
    if (!isUnit(unitString)) {
      throw 'Unknown clino unit.';
    }

    fromString(unitString);
  }

  @override
  THPartType get type => THPartType.clinoUnit;

  @override
  Map<String, dynamic> toMap() {
    return {'partType': type.name, 'unit': unitToString[unit]};
  }

  factory THClinoUnitPart.fromMap(Map<String, dynamic> map) {
    return THClinoUnitPart(unit: stringToUnit[map['unit']]!);
  }

  factory THClinoUnitPart.fromJson(String jsonString) {
    return THClinoUnitPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THClinoUnitPart copyWith({THClinoUnit? unit}) {
    return THClinoUnitPart(unit: unit ?? this.unit);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THClinoUnitPart && other.unit == unit;
  }

  @override
  int get hashCode => unit.hashCode;

  bool fromString(String unitString) {
    if (!isUnit(unitString)) {
      return false;
    }

    unit = stringToUnit[unitString]!;

    return true;
  }

  @override
  String toString() {
    return unitToString[unit]!;
  }

  static bool isUnit(String unitString) {
    return stringToUnit.containsKey(unitString);
  }
}
