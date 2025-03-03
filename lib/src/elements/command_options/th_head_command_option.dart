part of 'th_command_option.dart';

/// head <begin/end/both/none> . can be used only with the arrow type and
/// indicates where to put an arrow head. Default is |end|.
class THHeadCommandOption extends THArrowPositionCommandOption {
  THHeadCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THHeadCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THHeadCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesArrowPositionType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.head;

  @override
  THOptionChoicesArrowPositionType get defaultChoice =>
      THOptionChoicesArrowPositionType.end;

  factory THHeadCommandOption.fromMap(Map<String, dynamic> map) {
    return THHeadCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesArrowPositionType.values.byName(map['choice']),
    );
  }

  factory THHeadCommandOption.fromJson(String jsonString) {
    return THHeadCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THHeadCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesArrowPositionType? choice,
  }) {
    return THHeadCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
