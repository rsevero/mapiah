import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_multiple_choice_command_option.dart';

class THClipCommandOption extends THMultipleChoiceCommandOption {
  static const _thisOptionType = 'clip';
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

  /// Constructor necessary for dart_mappable support.
  THClipCommandOption({
    required super.parentMapiahID,
    required super.parentElementType,
    required super.optionType,
    required super.choice,
  }) : super();

  THClipCommandOption.addToOptionParent({
    required super.optionParent,
    required super.optionType,
    required super.choice,
  }) : super.addToOptionParent();

  THClipCommandOption.fromChoice({
    required super.optionParent,
    required super.choice,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'parentElementType': parentElementType,
      'optionType': optionType,
      'choice': choice,
    };
  }

  factory THClipCommandOption.fromMap(Map<String, dynamic> map) {
    return THClipCommandOption(
      parentMapiahID: map['parentMapiahID'],
      parentElementType: map['parentElementType'],
      optionType: map['optionType'],
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
    String? optionType,
    String? choice,
  }) {
    return THClipCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      parentElementType: parentElementType ?? this.parentElementType,
      optionType: optionType ?? this.optionType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THClipCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.parentElementType == parentElementType &&
        other.optionType == optionType &&
        other.choice == choice;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        parentElementType,
        optionType,
        choice,
      );
}
