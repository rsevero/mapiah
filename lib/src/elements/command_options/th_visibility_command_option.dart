part of 'th_command_option.dart';

/// point, line and area:
/// visibility <on/off> . displays/hides the symbol.
class THVisibilityCommandOption extends THOnOffCommandOption {
  THVisibilityCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THVisibilityCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THVisibilityCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.visibility;

  factory THVisibilityCommandOption.fromMap(Map<String, dynamic> map) {
    return THVisibilityCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THVisibilityCommandOption.fromJson(String jsonString) {
    return THVisibilityCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THVisibilityCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesOnOffType? choice,
  }) {
    return THVisibilityCommandOption.forCWJM(
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
    if (other is! THVisibilityCommandOption) return false;

    return super.equalsBase(other);
  }
}
