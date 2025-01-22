import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// height: according to the sign of the value (positive, negative or unsigned), this type of
// symbol represents chimney height, pit depth or step height in general. The numeric
// value can be optionally followed by ‘?’, if the value is presumed and units can be added
// (e.g. -value [40? ft]).
class THPointHeightValueCommandOption extends THCommandOption with THHasLength {
  late bool isPresumed;

  THPointHeightValueCommandOption.forCWJM({
    required super.parentMapiahID,
    required THDoublePart length,
    required this.isPresumed,
    required THLengthUnitPart unit,
  }) : super.forCWJM() {
    this.length = length;
    this.unit = unit;
  }

  THPointHeightValueCommandOption.fromString({
    required super.optionParent,
    required String height,
    required this.isPresumed,
    String? unit,
  }) : super() {
    length = THDoublePart.fromString(valueString: height);
    unitFromString(unit);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.pointHeightValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'length': length.toMap(),
      'isPresumed': isPresumed,
      'unit': unit.toMap(),
      'optionType': optionType.name,
    };
  }

  factory THPointHeightValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      length: THDoublePart.fromMap(map['length']),
      isPresumed: map['isPresumed'],
      unit: THLengthUnitPart.fromMap(map['unit']),
    );
  }

  factory THPointHeightValueCommandOption.fromJson(String jsonString) {
    return THPointHeightValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPointHeightValueCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? length,
    bool? isPresumed,
    THLengthUnitPart? unit,
  }) {
    return THPointHeightValueCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      length: length ?? this.length,
      isPresumed: isPresumed ?? this.isPresumed,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(covariant THPointHeightValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.length == length &&
        other.isPresumed == isPresumed &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        length,
        isPresumed,
        unit,
      );

  @override
  String specToFile() {
    var asString = length.toString();

    if (unitSet || isPresumed) {
      if (isPresumed) {
        asString += '?';
      }

      if (unitSet) {
        asString += " $unit";
      }
      return "[ $asString ]";
    }

    return asString;
  }
}
