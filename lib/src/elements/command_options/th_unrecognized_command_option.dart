import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  static const String _thisOptionType = 'UnrecognizedCommandOption';
  String? value;

  THUnrecognizedCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.value,
  }) : super();

  THUnrecognizedCommandOption.addToOptionParent({
    required super.optionParent,
    required this.value,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'value': value,
    };
  }

  factory THUnrecognizedCommandOption.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      value: map['value'],
    );
  }

  factory THUnrecognizedCommandOption.fromJson(String jsonString) {
    return THUnrecognizedCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THUnrecognizedCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? value,
  }) {
    return THUnrecognizedCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        value,
      );

  @override
  String specToFile() {
    return value ?? thNullValueAsString;
  }
}
