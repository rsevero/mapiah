import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

class THLengthUnitPart extends THPart {
  late final THLengthUnitType unit;

  /// Enable length unit part hash debug output when true.
  static bool enableLengthUnitPartHashDebug = false;

  static const stringToLengthUnit = {
    'centimeter': THLengthUnitType.centimeter,
    'centimeters': THLengthUnitType.centimeter,
    'cm': THLengthUnitType.centimeter,
    'feet': THLengthUnitType.feet,
    'feets': THLengthUnitType.feet,
    'ft': THLengthUnitType.feet,
    'in': THLengthUnitType.inch,
    'inch': THLengthUnitType.inch,
    'inches': THLengthUnitType.inch,
    'm': THLengthUnitType.meter,
    'meter': THLengthUnitType.meter,
    'meters': THLengthUnitType.meter,
    'yard': THLengthUnitType.yard,
    'yards': THLengthUnitType.yard,
    'yd': THLengthUnitType.yard,
  };

  static const lengthUnitToString = {
    THLengthUnitType.centimeter: 'cm',
    THLengthUnitType.feet: 'ft',
    THLengthUnitType.inch: 'in',
    THLengthUnitType.meter: 'm',
    THLengthUnitType.yard: 'yd',
  };

  THLengthUnitPart({required this.unit});

  THLengthUnitPart.fromString({required String unitString}) {
    fromString(unitString);
  }

  @override
  THPartType get type => THPartType.lengthUnit;

  @override
  Map<String, dynamic> toMap() {
    return {'partType': type.name, 'unit': lengthUnitToString[unit]};
  }

  factory THLengthUnitPart.fromMap(Map<String, dynamic> map) {
    return THLengthUnitPart(unit: stringToLengthUnit[map['unit']]!);
  }

  factory THLengthUnitPart.fromJson(String jsonString) {
    return THLengthUnitPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THLengthUnitPart copyWith({THLengthUnitType? unit}) {
    return THLengthUnitPart(unit: unit ?? this.unit);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THLengthUnitPart && other.unit == unit;
  }

  @override
  int get hashCode {
    final int h = unit.hashCode;

    if (kDebugMode && THLengthUnitPart.enableLengthUnitPartHashDebug) {
      debugPrint(
        '[LENGTH UNIT PART HASH] hash=$h details=${debugHashString()}',
      );
    }

    return h;
  }

  /// Return a map of the fields used to compute `hashCode` so tests and
  /// debugging helpers can inspect and compare them.
  Map<String, dynamic> debugHashDetails() {
    return {'unit': unit.name};
  }

  /// Human-friendly debug string describing the hash inputs.
  String debugHashString() =>
      debugHashDetails().entries.map((e) => '${e.key}=${e.value}').join(', ');

  void fromString(String unitString) {
    if (!isUnit(unitString)) {
      throw THConvertFromStringException('THLengthUnitPart', unitString);
    }

    unit = stringToLengthUnit[unitString]!;
  }

  @override
  String toString() {
    return lengthUnitToString[unit]!;
  }

  static bool isUnit(String unitString) {
    return stringToLengthUnit.containsKey(unitString);
  }
}
