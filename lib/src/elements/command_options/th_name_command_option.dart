import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
class THNameCommandOption extends THCommandOption {
  late final String reference;

  THNameCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.reference,
  }) : super();

  THNameCommandOption.addToOptionParent({
    required super.optionParent,
    required this.reference,
  }) : super.addToOptionParent(optionType: THCommandOptionType.name);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'reference': reference,
    };
  }

  factory THNameCommandOption.fromMap(Map<String, dynamic> map) {
    return THNameCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      reference: map['reference'],
    );
  }

  factory THNameCommandOption.fromJson(String jsonString) {
    return THNameCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THNameCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    String? reference,
  }) {
    return THNameCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(covariant THNameCommandOption other) {
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
