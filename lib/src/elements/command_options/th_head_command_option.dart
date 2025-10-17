part of 'th_command_option.dart';

/// head <begin/end/both/none> . can be used only with the arrow type and
/// indicates where to put an arrow head. Default is |end|.
class THHeadCommandOption extends THArrowPositionCommandOption {
  THHeadCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THHeadCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THHeadCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesArrowPositionType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.head;

  factory THHeadCommandOption.fromMap(Map<String, dynamic> map) {
    return THHeadCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesArrowPositionType.values.byName(map['choice']),
    );
  }

  factory THHeadCommandOption.fromJson(String jsonString) {
    return THHeadCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THHeadCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesArrowPositionType? choice,
  }) {
    return THHeadCommandOption.forCWJM(
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
    if (other is! THHeadCommandOption) return false;

    return super.equalsBase(other);
  }
}
