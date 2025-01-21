import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// id <ext_keyword> . ID of the symbol.
class THIDCommandOption extends THCommandOption {
  static const String _thisOptionType = 'id';
  late final String thID;

  THIDCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.thID,
  }) : super();

  THIDCommandOption.addToOptionParent({
    required super.optionParent,
    required this.thID,
  }) : super.addToOptionParent(
          optionType: _thisOptionType,
        ); // TODO: call thFile.addElementWithTHID for the parent of this option. Was done with: optionParent.thFile.addElementWithTHID(optionParent, thID);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'thID': thID,
    };
  }

  factory THIDCommandOption.fromMap(Map<String, dynamic> map) {
    return THIDCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      thID: map['thID'],
    );
  }

  factory THIDCommandOption.fromJson(String jsonString) {
    return THIDCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THIDCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? thID,
  }) {
    return THIDCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      thID: thID ?? this.thID,
    );
  }

  @override
  bool operator ==(covariant THIDCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.thID == thID;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        thID,
      );

  @override
  String specToFile() {
    return thID;
  }
}
