import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/th_has_altitude.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
class THAltitudeValueCommandOption extends THCommandOption
    with THHasLength, THHasAltitude {
  static const String _thisOptionType = 'value';

  THAltitudeValueCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required THDoublePart length,
    required bool isFix,
    required THLengthUnitPart unit,
  }) : super() {
    this.length = length;
    this.isFix = isFix;
    this.unit = unit;
  }

  THAltitudeValueCommandOption.addToOptionParent({
    required super.optionParent,
    required THDoublePart length,
    required bool isFix,
    required String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.length = length;
    this.isFix = isFix;
    unitFromString(unit);
  }

  THAltitudeValueCommandOption.fromString({
    required super.optionParent,
    required String height,
    required bool isFix,
    required String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    length = THDoublePart.fromString(valueString: height);
    isFix = isFix;
    unitFromString(unit);
  }

  THAltitudeValueCommandOption.fromNan({required super.optionParent})
      : super.addToOptionParent(optionType: _thisOptionType) {
    length = THDoublePart.fromString(valueString: '0');
    isNan = true;
    unitFromString('');
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'length': length.toMap(),
      'isFix': isFix,
      'unit': unit,
    };
  }

  factory THAltitudeValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THAltitudeValueCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      length: THDoublePart.fromMap(map['length']),
      isFix: map['isFix'],
      unit: map['unit'],
    );
  }

  factory THAltitudeValueCommandOption.fromJson(String jsonString) {
    return THAltitudeValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAltitudeValueCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? length,
    bool? isFix,
    THLengthUnitPart? unit,
  }) {
    return THAltitudeValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      length: length ?? this.length,
      isFix: isFix ?? this.isFix,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THAltitudeValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.length == length &&
        other.isFix == isFix &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        length,
        isFix,
        unit,
      );
}
