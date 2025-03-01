part of 'th_command_option.dart';

class THWallsCommandOption extends THOnOffAutoCommandOption {
  THWallsCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THWallsCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THWallsCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffAutoType.values.byName(choice));

  @override
  THCommandOptionType get optionType => THCommandOptionType.walls;

  factory THWallsCommandOption.fromMap(Map<String, dynamic> map) {
    return THWallsCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffAutoType.values.byName(map['choice']),
    );
  }

  factory THWallsCommandOption.fromJson(String jsonString) {
    return THWallsCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THWallsCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffAutoType? choice,
  }) {
    return THWallsCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
