part of 'th_command_option.dart';

/// rebelays <on/off>. this option can be specified only with the ‘rope’ line
/// type. Default is |on|.
class THRebelaysCommandOption extends THOnOffCommandOption {
  THRebelaysCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THRebelaysCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THRebelaysCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.rebelays;

  factory THRebelaysCommandOption.fromMap(Map<String, dynamic> map) {
    return THRebelaysCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THRebelaysCommandOption.fromJson(String jsonString) {
    return THRebelaysCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THRebelaysCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffType? choice,
  }) {
    return THRebelaysCommandOption.forCWJM(
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
    if (other is! THRebelaysCommandOption) return false;

    return super.equalsBase(other);
  }
}
