part of 'th_command_option.dart';

class THClipCommandOption extends THMultipleChoiceCommandOption {
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
    required super.parentElementType,
    required super.multipleChoiceType,
    required super.choice,
  }) : super.forCWJM();

  THClipCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super(multipleChoiceType: thClipMultipleChoiceType);

  THClipCommandOption.fromChoice({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super(multipleChoiceType: thClipMultipleChoiceType);

  @override
  THCommandOptionType get optionType => THCommandOptionType.clip;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'parentElementType': parentElementType.name,
      'multipleChoiceType': multipleChoiceType,
      'choice': choice,
    };
  }

  factory THClipCommandOption.fromMap(Map<String, dynamic> map) {
    return THClipCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      multipleChoiceType: map['multipleChoiceType'],
      choice: map['choice'],
    );
  }

  factory THClipCommandOption.fromJson(String jsonString) {
    return THClipCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THClipCommandOption copyWith({
    int? parentMapiahID,
    THElementType? parentElementType,
    String? multipleChoiceType,
    String? choice,
    bool makeChoiceNull = false,
  }) {
    return THClipCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      parentElementType: parentElementType ?? this.parentElementType,
      multipleChoiceType: multipleChoiceType ?? this.multipleChoiceType,
      choice: makeChoiceNull ? '' : (choice ?? this.choice),
    );
  }

  @override
  bool operator ==(covariant THClipCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.parentElementType == parentElementType &&
        other.multipleChoiceType == multipleChoiceType &&
        other.choice == choice;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        parentElementType,
        multipleChoiceType,
        choice,
      );
}
