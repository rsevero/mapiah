part of 'th_command_option.dart';

/// outline <in/out/none> . determines whether the line serves as a border line
/// for a scrap. Default value is ‘out’ for walls, ‘none’ for all other lines.
/// Use -outline in for large pillars etc.
class THOutlineCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesOutlineType choice;

  THOutlineCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THOutlineCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THOutlineCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : choice = _setChoiceFromString(choice),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.outline;

  @override
  String specToFile() {
    return (choice == THOptionChoicesOutlineType.inChoice) ? 'in' : choice.name;
  }

  static THOptionChoicesOutlineType _setChoiceFromString(String choice) {
    return (choice == 'in')
        ? THOptionChoicesOutlineType.inChoice
        : THOptionChoicesOutlineType.values.byName(choice);
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'choice': specToFile()});

    return map;
  }

  factory THOutlineCommandOption.fromMap(Map<String, dynamic> map) {
    return THOutlineCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: _setChoiceFromString(map['choice']),
    );
  }

  factory THOutlineCommandOption.fromJson(String jsonString) {
    return THOutlineCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THOutlineCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOutlineType? choice,
  }) {
    return THOutlineCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THOutlineCommandOption) return false;

    return super.equalsBase(other);
  }
}
