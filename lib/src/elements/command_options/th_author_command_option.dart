import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';

// author <date> <person> . author of the data and its creation date
@serializable
class THAuthorCommandOption extends THCommandOption
    with Dataclass<THAuthorCommandOption> {
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
  Map<String, dynamic> toMap() {
    return dogs.toNative<THAuthorCommandOption>(this);
  }

  factory THAuthorCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THAuthorCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THAuthorCommandOption>(this);
  }

  factory THAuthorCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THAuthorCommandOption>(jsonString);
  }

  @override
  THAuthorCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
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
  String specToFile() {
    return '$datetime $person';
  }
}
