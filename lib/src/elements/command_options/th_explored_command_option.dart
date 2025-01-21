import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
class THExploredCommandOption extends THCommandOption with THHasLength {
  THExploredCommandOption.forCWJM({
    required super.parentMapiahID,
    required THDoublePart length,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
  }

  THExploredCommandOption.fromString({
    required super.optionParent,
    required String distance,
    required String? unit,
  }) : super() {
    length = THDoublePart.fromString(valueString: distance);
    if (unit != null) {
      unitFromString(unit);
    }
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.explored;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'length': length.toMap(),
      'unit': unit.toMap(),
    };
  }

  factory THExploredCommandOption.fromMap(Map<String, dynamic> map) {
    return THExploredCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
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
    THDoublePart? length,
    THLengthUnitPart? unit,
  }) {
    return THExploredCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      length: length ?? this.length,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THExploredCommandOption other) {
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
