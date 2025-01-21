import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// title <string> . description of the object
class THTitleCommandOption extends THCommandOption {
  final String title;

  THTitleCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.title,
  }) : super();

  THTitleCommandOption.addToOptionParent({
    required super.optionParent,
    required this.title,
  }) : super.addToOptionParent(optionType: THCommandOptionType.title);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'title': title,
    };
  }

  factory THTitleCommandOption.fromMap(Map<String, dynamic> map) {
    return THTitleCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      title: map['title'],
    );
  }

  factory THTitleCommandOption.fromJson(String jsonString) {
    return THTitleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THTitleCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    String? title,
  }) {
    return THTitleCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(covariant THTitleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        title,
      );

  @override
  String specToFile() {
    return title;
  }
}
