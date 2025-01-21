import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// l-size <number> . Size of the line (to the left). Only valid on and required for slope
// type.
//
// size <number> . synonym of l-size
class THLSizeCommandOption extends THCommandOption {
  late final THDoublePart number;

  THLSizeCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.number,
  }) : super();

  THLSizeCommandOption.fromString({
    required super.optionParent,
    required String number,
  }) : super.addToOptionParent(optionType: THCommandOptionType.lSize) {
    this.number = THDoublePart.fromString(valueString: number);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'number': number.toMap(),
    };
  }

  factory THLSizeCommandOption.fromMap(Map<String, dynamic> map) {
    return THLSizeCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      number: THDoublePart.fromMap(map['number']),
    );
  }

  factory THLSizeCommandOption.fromJson(String jsonString) {
    return THLSizeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLSizeCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    THDoublePart? number,
  }) {
    return THLSizeCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      number: number ?? this.number,
    );
  }

  @override
  bool operator ==(covariant THLSizeCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.number == number;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        number,
      );

  @override
  String specToFile() {
    return number.toString();
  }
}
