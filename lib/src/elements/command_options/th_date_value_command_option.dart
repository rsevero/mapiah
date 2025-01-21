// date: -value <date> sets the date for the date point.
import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

class THDateValueCommandOption extends THCommandOption {
  static const String _thisOptionType = 'datevalue';
  late final THDatetimePart date;

  THDateValueCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.date,
  }) : super();

  THDateValueCommandOption.fromString({
    required super.optionParent,
    required String date,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.date = THDatetimePart.fromString(datetime: date);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'date': date.toMap(),
    };
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDateValueCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      date: THDatetimePart.fromMap(map['date']),
    );
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return THDateValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDatetimePart? date,
  }) {
    return THDateValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(covariant THDateValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        date,
      );

  @override
  String specToFile() {
    return date.toString();
  }
}
