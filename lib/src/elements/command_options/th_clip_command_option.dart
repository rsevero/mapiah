import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_multiple_choice_command_option.dart';

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

  THClipCommandOption({
    required super.parentMapiahID,
    required super.parentElementType,
    required super.optionType,
    required super.multipleChoiceType,
    required super.choice,
  }) : super();

  THClipCommandOption.addToOptionParent({
    required super.optionParent,
    required super.choice,
  }) : super.addToOptionParent(
          multipleChoiceType: thClipMultipleChoiceType,
          optionType: THCommandOptionType.clip,
        );

  THClipCommandOption.fromChoice({
    required super.optionParent,
    required super.choice,
  }) : super.addToOptionParent(
          multipleChoiceType: thClipMultipleChoiceType,
          optionType: THCommandOptionType.clip,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'parentElementType': parentElementType,
      'optionType': optionType.name,
      'multipleChoiceType': multipleChoiceType,
      'choice': choice,
    };
  }

  factory THClipCommandOption.fromMap(Map<String, dynamic> map) {
    return THClipCommandOption(
      parentMapiahID: map['parentMapiahID'],
      parentElementType: map['parentElementType'],
      optionType: THCommandOptionType.values.byName(map['optionType']),
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
    String? parentElementType,
    THCommandOptionType? optionType,
    String? multipleChoiceType,
    String? choice,
    bool makeChoiceNull = false,
  }) {
    return THClipCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      parentElementType: parentElementType ?? this.parentElementType,
      optionType: optionType ?? this.optionType,
      multipleChoiceType: multipleChoiceType ?? this.multipleChoiceType,
      choice: makeChoiceNull ? '' : (choice ?? this.choice),
    );
  }

  @override
  bool operator ==(covariant THClipCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.parentElementType == parentElementType &&
        other.optionType == optionType &&
        other.multipleChoiceType == multipleChoiceType &&
        other.choice == choice;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        parentElementType,
        optionType,
        multipleChoiceType,
        choice,
      );
}
