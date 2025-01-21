import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';

// author <date> <person> . author of the data and its creation date
class THAuthorCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  late final THPersonPart person;

  THAuthorCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.datetime,
    required this.person,
  }) : super();

  THAuthorCommandOption.addToOptionParent({
    required super.optionParent,
    required this.datetime,
    required this.person,
  }) : super.addToOptionParent(optionType: THCommandOptionType.author);

  THAuthorCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String person,
  }) : super.addToOptionParent(optionType: THCommandOptionType.author) {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
    this.person = THPersonPart.fromString(name: person);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType.name,
      'datetime': datetime.toMap(),
      'person': person.toMap(),
    };
  }

  factory THAuthorCommandOption.fromMap(Map<String, dynamic> map) {
    return THAuthorCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
      datetime: THDatetimePart.fromMap(map['datetime']),
      person: THPersonPart.fromMap(map['person']),
    );
  }

  factory THAuthorCommandOption.fromJson(String jsonString) {
    return THAuthorCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAuthorCommandOption copyWith({
    int? parentMapiahID,
    THCommandOptionType? optionType,
    THDatetimePart? datetime,
    THPersonPart? person,
  }) {
    return THAuthorCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      datetime: datetime ?? this.datetime,
      person: person ?? this.person,
    );
  }

  @override
  bool operator ==(covariant THAuthorCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.datetime == datetime &&
        other.person == person;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        datetime,
        person,
      );

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
