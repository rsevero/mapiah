part of 'th_command_option.dart';

/// close <on/off/auto> . determines whether a line is closed or not. Default is
/// auto.
class THCloseCommandOption extends THOnOffAutoCommandOption {
  THCloseCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THCloseCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THCloseCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffAutoType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.close;

  factory THCloseCommandOption.fromMap(Map<String, dynamic> map) {
    return THCloseCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesOnOffAutoType.values.byName(map['choice']),
    );
  }

  factory THCloseCommandOption.fromJson(String jsonString) {
    return THCloseCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCloseCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesOnOffAutoType? choice,
  }) {
    return THCloseCommandOption.forCWJM(
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
    if (other is! THCloseCommandOption) return false;

    return super.equalsBase(other);
  }
}
