part of 'th_command_option.dart';

class THClipCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesOnOffType choice;
  // static final HashSet<String> _unsupportedPointTypes = HashSet<String>.from({
  //   'altitude',
  //   'date',
  //   'height',
  //   'label',
  //   'passage-height',
  //   'remark',
  //   'station-name',
  //   'station',
  // });

  THClipCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THClipCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THClipCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesOnOffType.values.byName(choice),
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.clip;

  @override
  String get defaultChoice => '';

  @override
  String specToFile() {
    return choice.name;
  }

  factory THClipCommandOption.fromMap(Map<String, dynamic> map) {
    return THClipCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THClipCommandOption.fromJson(String jsonString) {
    return THClipCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THClipCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffType? choice,
  }) {
    return THClipCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THClipCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        parentElementType,
        choice,
      );
}
