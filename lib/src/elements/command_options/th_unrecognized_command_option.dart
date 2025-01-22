import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  String? value;

  THUnrecognizedCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.value,
  }) : super.forCWJM();

  THUnrecognizedCommandOption({
    required super.optionParent,
    required this.value,
  }) : super();

  @override
  THCommandOptionType get optionType =>
      THCommandOptionType.unrecognizedCommandOption;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'value': value,
      'optionType': optionType.name,
    };
  }

  factory THUnrecognizedCommandOption.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      value: map['value'],
    );
  }

  factory THUnrecognizedCommandOption.fromJson(String jsonString) {
    return THUnrecognizedCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THUnrecognizedCommandOption copyWith({
    int? parentMapiahID,
    String? value,
  }) {
    return THUnrecognizedCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.value == value;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        value,
      );

  @override
  String specToFile() {
    return value ?? thNullValueAsString;
  }
}
