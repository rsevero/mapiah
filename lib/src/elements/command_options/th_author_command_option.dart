part of 'th_command_option.dart';

// author <date> <person> . author of the data and its creation date
class THAuthorCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  late final THPersonPart person;

  THAuthorCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.datetime,
    required this.person,
  }) : super.forCWJM();

  THAuthorCommandOption({
    required super.optionParent,
    required this.datetime,
    required this.person,
  }) : super();

  THAuthorCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String person,
  }) : super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
    this.person = THPersonPart.fromString(name: person);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.author;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'datetime': datetime.toMap(),
      'person': person.toMap(),
    };
  }

  factory THAuthorCommandOption.fromMap(Map<String, dynamic> map) {
    return THAuthorCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
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
    THDatetimePart? datetime,
    THPersonPart? person,
  }) {
    return THAuthorCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      datetime: datetime ?? this.datetime,
      person: person ?? this.person,
    );
  }

  @override
  bool operator ==(covariant THAuthorCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.datetime == datetime &&
        other.person == person;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        datetime,
        person,
      );

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
