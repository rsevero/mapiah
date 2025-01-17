import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';

// author <date> <person> . author of the data and its creation date
class THAuthorCommandOption extends THCommandOption {
  static const String _thisOptionType = 'author';
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
  }) : super.addToOptionParent(optionType: _thisOptionType);

  THAuthorCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String person,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.datetime = THDatetimePart(datetime);
    this.person = THPersonPart.fromString(person);
  }

  @override
  THAuthorCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THPersonPart? person,
    THDatetimePart? datetime,
  }) {
    return THAuthorCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      person: person ?? this.person,
      datetime: datetime ?? this.datetime,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'person': person.toMap(),
      'datetime': datetime.toMap(),
    });
    return map;
  }

  @override
  bool operator ==(covariant THAuthorCommandOption other) {
    if (identical(this, other)) return true;

    return super == other &&
        other.person == person &&
        other.datetime == datetime;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        person,
        datetime,
      );

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
