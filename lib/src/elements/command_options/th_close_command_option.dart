part of 'th_command_option.dart';

/// close <on/off/auto> . determines whether a line is closed or not. Default is
/// auto.
class THCloseCommandOption extends THOnOffAutoCommandOption {
  THCloseCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THCloseCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THCloseCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffAutoType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.close;

  THOptionChoicesOnOffAutoType get defaultOption =>
      THOptionChoicesOnOffAutoType.auto;

  factory THCloseCommandOption.fromMap(Map<String, dynamic> map) {
    return THCloseCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffAutoType.values.byName(map['choice']),
    );
  }

  factory THCloseCommandOption.fromJson(String jsonString) {
    return THCloseCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCloseCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffAutoType? choice,
  }) {
    return THCloseCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
