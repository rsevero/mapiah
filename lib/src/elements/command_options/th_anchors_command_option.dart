part of 'th_command_option.dart';

/// anchors <on/off> - this option can be specified only with the ‘rope’ line
/// type. Default is on.
class THAnchorsCommandOption extends THOnOffCommandOption {
  THAnchorsCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THAnchorsCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THAnchorsCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.anchors;

  factory THAnchorsCommandOption.fromMap(Map<String, dynamic> map) {
    return THAnchorsCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THAnchorsCommandOption.fromJson(String jsonString) {
    return THAnchorsCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAnchorsCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffType? choice,
  }) {
    return THAnchorsCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
