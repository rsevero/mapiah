part of 'th_command_option.dart';

/// |reverse <on/off> - whether points are given in reverse order. Default is
/// off.
class THReverseCommandOption extends THOnOffCommandOption {
  THReverseCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THReverseCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THReverseCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.reverse;

  @override
  THOptionChoicesOnOffType get defaultChoice => THOptionChoicesOnOffType.off;

  factory THReverseCommandOption.fromMap(Map<String, dynamic> map) {
    return THReverseCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THReverseCommandOption.fromJson(String jsonString) {
    return THReverseCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THReverseCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffType? choice,
  }) {
    return THReverseCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
