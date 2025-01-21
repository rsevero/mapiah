import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_text.dart';

// title <string> . description of the object
class THTitleCommandOption extends THCommandOption with THHasText {
  static const String _thisOptionType = 'title';

  THTitleCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required String text,
  }) : super() {
    this.text = text;
  }

  THTitleCommandOption.addToOptionParent({
    required super.optionParent,
    required String text,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.text = text;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'text': text,
    };
  }

  factory THTitleCommandOption.fromMap(Map<String, dynamic> map) {
    return THTitleCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      text: map['text'],
    );
  }

  factory THTitleCommandOption.fromJson(String jsonString) {
    return THTitleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THTitleCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    String? text,
  }) {
    return THTitleCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(covariant THTitleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.text == text;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        text,
      );

  @override
  String specToFile() {
    return textToFile();
  }
}
