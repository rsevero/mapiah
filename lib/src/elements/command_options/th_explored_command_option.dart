import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
class THExploredCommandOption extends THCommandOption with THHasLength {
  THExploredCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required THDoublePart length,
    required THLengthUnitPart unit,
  }) : super() {
    this.length = length;
    this.unit = unit;
  }

  THExploredCommandOption.fromString({
    required super.optionParent,
    required String distance,
    required String? unit,
  }) : super.addToOptionParent(optionType: THCommandOptionType.explored) {
    length = THDoublePart.fromString(valueString: distance);
    if (unit != null) {
      unitFromString(unit);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'length': length.toMap(),
      'unit': unit.toMap(),
    };
  }

  factory THExploredCommandOption.fromMap(Map<String, dynamic> map) {
    return THExploredCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      length: THDoublePart.fromMap(map['length']),
      unit: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THExploredCommandOption.fromJson(String jsonString) {
    return THExploredCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THExploredCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    THDoublePart? length,
    THLengthUnitPart? unit,
  }) {
    return THExploredCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THExploredCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.length == length &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        length,
        unit,
      );
}
