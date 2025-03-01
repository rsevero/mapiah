part of 'th_command_option.dart';

// author <date> <person> . author of the data and its creation date
class THAuthorCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  late final THPersonPart person;

  THAuthorCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.datetime,
    required this.person,
  }) : super.forCWJM();

  THAuthorCommandOption({
    required super.optionParent,
    required this.datetime,
    required this.person,
    super.originalLineInTH2File = '',
  }) : super();

  THAuthorCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String person,
    super.originalLineInTH2File = '',
  }) : super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
    this.person = THPersonPart.fromString(name: person);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.author;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'datetime': datetime.toMap(),
      'person': person.toMap(),
    });

    return map;
  }

  factory THAuthorCommandOption.fromMap(Map<String, dynamic> map) {
    return THAuthorCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
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
    String? originalLineInTH2File,
    THDatetimePart? datetime,
    THPersonPart? person,
  }) {
    return THAuthorCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      datetime: datetime ?? this.datetime,
      person: person ?? this.person,
    );
  }

  @override
  bool operator ==(covariant THAuthorCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.datetime == datetime &&
        other.person == person;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        datetime,
        person,
      );

  @override
  String specToFile() {
    return '$datetime $person';
  }
}
