import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_text.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption with THHasText {
  static const String _thisOptionType = 'copyright';
  late final THDatetimePart datetime;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.datetime,
    required String copyrightMessage,
  }) : super() {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.addToOptionParent({
    required super.optionParent,
    required this.datetime,
    required String copyrightMessage,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String text,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
    this.text = text;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'datetime': datetime.toMap(),
      'text': text,
    };
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      datetime: THDatetimePart.fromMap(map['datetime']),
      copyrightMessage: map['text'],
    );
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return THCopyrightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDatetimePart? datetime,
    String? text,
  }) {
    return THCopyrightCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      datetime: datetime ?? this.datetime,
      copyrightMessage: text ?? this.text,
    );
  }

  @override
  bool operator ==(covariant THCopyrightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.datetime == datetime &&
        other.text == text;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        datetime,
        text,
      );

  @override
  String specToFile() {
    return '$datetime ${textToFile()}';
  }

  String get copyrightMessage => text;
}
