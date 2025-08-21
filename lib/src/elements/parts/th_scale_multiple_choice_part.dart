import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';

class THScaleMultipleChoicePart extends THPart {
  late final String choice;

  static final _choices = {
    'hasDefault': true,
    'default': 'normal',
    'choices': <String>{'xs', 's', 'm', 'l', 'xl'},
    'alternateChoices': {
      'tiny': 'xs',
      'small': 's',
      'normal': 'm',
      'large': 'l',
      'huge': 'xl',
    },
  };

  THScaleMultipleChoicePart({required String choice}) : super() {
    this.choice = isAlternateChoice(choice)
        ? (_choices['alternateChoices'] as Map<String, String>)[choice]!
        : choice;
  }

  @override
  THPartType get type => THPartType.scaleChoices;

  @override
  Map<String, dynamic> toMap() {
    return {'partType': type.name, 'choice': choice};
  }

  factory THScaleMultipleChoicePart.fromMap(Map<String, dynamic> map) {
    return THScaleMultipleChoicePart(choice: map['choice']);
  }

  factory THScaleMultipleChoicePart.fromJson(String jsonString) {
    return THScaleMultipleChoicePart.fromMap(jsonDecode(jsonString));
  }

  @override
  THScaleMultipleChoicePart copyWith({
    String? multipleChoiceName,
    String? choice,
  }) {
    return THScaleMultipleChoicePart(choice: choice ?? this.choice);
  }

  @override
  bool operator ==(covariant THScaleMultipleChoicePart other) {
    if (identical(this, other)) return true;

    return other.choice == choice;
  }

  @override
  int get hashCode => choice.hashCode;

  static bool isChoice(String choice) {
    return (_choices['choices'] as Set<String>).contains(choice) ||
        isAlternateChoice(choice);
  }

  static bool isAlternateChoice(String choice) {
    return (_choices['alternateChoices'] as Map<String, String>).containsKey(
      choice,
    );
  }

  static List<String> get choices {
    return (_choices['choices'] as Set<String>).toList();
  }

  @override
  String toString() {
    return choice;
  }
}
