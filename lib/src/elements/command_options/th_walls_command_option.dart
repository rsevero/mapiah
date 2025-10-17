part of 'th_command_option.dart';

class THWallsCommandOption extends THOnOffAutoCommandOption {
  THWallsCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THWallsCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THWallsCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffAutoType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.walls;

  factory THWallsCommandOption.fromMap(Map<String, dynamic> map) {
    return THWallsCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesOnOffAutoType.values.byName(map['choice']),
    );
  }

  factory THWallsCommandOption.fromJson(String jsonString) {
    return THWallsCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THWallsCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesOnOffAutoType? choice,
  }) {
    return THWallsCommandOption.forCWJM(
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
    if (other is! THWallsCommandOption) return false;

    return super.equalsBase(other);
  }
}
