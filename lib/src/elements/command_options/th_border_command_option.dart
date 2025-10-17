part of 'th_command_option.dart';

// border <on/off> . this option can be specified only with the ‘slope’ symbol
// type. It switches on/off the border line of the slope. Default is on.
class THBorderCommandOption extends THOnOffCommandOption {
  THBorderCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THBorderCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THBorderCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.border;

  factory THBorderCommandOption.fromMap(Map<String, dynamic> map) {
    return THBorderCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THBorderCommandOption.fromJson(String jsonString) {
    return THBorderCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THBorderCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesOnOffType? choice,
  }) {
    return THBorderCommandOption.forCWJM(
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
    if (other is! THBorderCommandOption) return false;

    return super.equalsBase(other);
  }
}
