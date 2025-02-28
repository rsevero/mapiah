part of 'th_command_option.dart';

/// direction <begin/end/both/none/point> . can be used only with the section
/// type. It indicates where to put a direction arrow on the section line.
/// Default is |none|. The point option must be used inside [LINE DATA]. The
/// others can (and should) be used as a line option.
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
  THCommandOptionType get optionType => THCommandOptionType.head;

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

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant THHeadCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }
}
