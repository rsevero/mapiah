import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

enum THLengthUnit {
  centimeter,
  feet,
  inch,
  meter,
  yard,
}

class THLengthUnitPart extends THPart {
  late final THLengthUnit unit;

  static const stringToUnit = {
    'centimeter': THLengthUnit.centimeter,
    'centimeters': THLengthUnit.centimeter,
    'cm': THLengthUnit.centimeter,
    'feet': THLengthUnit.feet,
    'feets': THLengthUnit.feet,
    'ft': THLengthUnit.feet,
    'in': THLengthUnit.inch,
    'inch': THLengthUnit.inch,
    'inches': THLengthUnit.inch,
    'm': THLengthUnit.meter,
    'meter': THLengthUnit.meter,
    'meters': THLengthUnit.meter,
    'yard': THLengthUnit.yard,
    'yards': THLengthUnit.yard,
    'yd': THLengthUnit.yard,
  };

  static const unitToString = {
    THLengthUnit.centimeter: 'centimeter',
    THLengthUnit.feet: 'feet',
    THLengthUnit.inch: 'inch',
    THLengthUnit.meter: 'meter',
    THLengthUnit.yard: 'yard',
  };

  THLengthUnitPart({required this.unit});

  THLengthUnitPart.fromString({required String unitString}) {
    fromString(unitString);
  }

  @override
  THPartType get type => THPartType.lengthUnit;

  @override
  Map<String, dynamic> toMap() {
    return {
      'unit': unitToString[unit],
      'partType': type.name,
    };
  }

  factory THLengthUnitPart.fromMap(Map<String, dynamic> map) {
    return THLengthUnitPart(
      unit: stringToUnit[map['unit']]!,
    );
  }

  factory THLengthUnitPart.fromJson(String jsonString) {
    return THLengthUnitPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THLengthUnitPart copyWith({
    THLengthUnit? unit,
  }) {
    return THLengthUnitPart(
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THLengthUnitPart other) {
    if (identical(this, other)) return true;

    return other.unit == unit;
  }

  @override
  int get hashCode => unit.hashCode;

  void fromString(String unitString) {
    if (!isUnit(unitString)) {
      throw THConvertFromStringException('THLengthUnitPart', unitString);
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
