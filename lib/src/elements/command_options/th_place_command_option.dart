part of 'th_command_option.dart';

/// point, line and area:
/// place [bottom/default/top] . changes displaying order in the map.
class THPlaceCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesPlaceType choice;

  THPlaceCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.choice,
  }) : super.forCWJM();

  THPlaceCommandOption({
    required super.parentMPID,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THPlaceCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : choice = _setChoiceFromString(choice),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.place;

  @override
  String specToFile() {
    return (choice == THOptionChoicesPlaceType.defaultChoice)
        ? 'default'
        : choice.name;
  }

  static THOptionChoicesPlaceType _setChoiceFromString(String choice) {
    return (choice == 'default')
        ? THOptionChoicesPlaceType.defaultChoice
        : THOptionChoicesPlaceType.values.byName(choice);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'choice': specToFile()});

    return map;
  }

  factory THPlaceCommandOption.fromMap(Map<String, dynamic> map) {
    return THPlaceCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: _setChoiceFromString(map['choice']),
    );
  }

  factory THPlaceCommandOption.fromJson(String jsonString) {
    return THPlaceCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPlaceCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesPlaceType? choice,
  }) {
    return THPlaceCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      choice: choice ?? this.choice,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THPlaceCommandOption) return false;

    return super.equalsBase(other);
  }
}
