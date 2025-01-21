import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// dist <distance> . valid for extra points, specifies the distance to the nearest station
// (or station specified using -from option. If not specified, appropriate value from LRUD
// data is used.
class THDistCommandOption extends THCommandOption with THHasLength {
  THDistCommandOption({
    required super.parentMapiahID,
    required THDoublePart length,
    required THLengthUnitPart unit,
  }) : super() {
    this.length = length;
    this.unit = unit;
  }

  THDistCommandOption.fromString({
    required super.optionParent,
    required String distance,
    required String? unit,
  }) : super.addToOptionParent() {
    length = THDoublePart.fromString(valueString: distance);
    if (unit != null) {
      unitFromString(unit);
    }
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.dist;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'length': length.toMap(),
      'unit': unit,
    };
  }

  factory THDistCommandOption.fromMap(Map<String, dynamic> map) {
    return THDistCommandOption(
      parentMapiahID: map['parentMapiahID'],
      length: THDoublePart.fromMap(map['length']),
      unit: map['unit'],
    );
  }

  factory THDistCommandOption.fromJson(String jsonString) {
    return THDistCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDistCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? length,
    THLengthUnitPart? unit,
  }) {
    return THDistCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THDistCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.length == length &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        length,
        unit,
      );
}
