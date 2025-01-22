// date: -value <date> sets the date for the date point.
import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

class THDateValueCommandOption extends THCommandOption {
  late final THDatetimePart date;

  THDateValueCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.date,
  }) : super.forCWJM();

  THDateValueCommandOption.fromString({
    required super.optionParent,
    required String date,
  }) : super() {
    this.date = THDatetimePart.fromString(datetime: date);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.dateValue;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'date': date.toMap(),
      'optionType': optionType.name,
    };
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDateValueCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      date: THDatetimePart.fromMap(map['date']),
    );
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return THDateValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMapiahID,
    THDatetimePart? date,
  }) {
    return THDateValueCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(covariant THDateValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.date == date;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        date,
      );

  @override
  String specToFile() {
    return date.toString();
  }
}
