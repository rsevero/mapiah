import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// scrap <reference> . if the point type is section, this is a reference to a cross-section
// scrap.
class THScrapCommandOption extends THCommandOption {
  late final String reference;

  THScrapCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.reference,
  }) : super();

  THScrapCommandOption.addToOptionParent({
    required super.optionParent,
    required this.reference,
  }) : super.addToOptionParent(optionType: THCommandOptionType.scrap);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'reference': reference,
    };
  }

  factory THScrapCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      reference: map['reference'],
    );
  }

  factory THScrapCommandOption.fromJson(String jsonString) {
    return THScrapCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    String? reference,
  }) {
    return THScrapCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(covariant THScrapCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        reference,
      );

  @override
  String specToFile() {
    return reference;
  }
}
