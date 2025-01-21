import 'dart:collection';
import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';

class THMultipleChoicePart extends THPart {
  late final String choice;
  late final String multipleChoiceName;

  static final _choices = {
    'point|scale': {
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
    },
  };

  THMultipleChoicePart({
    required this.multipleChoiceName,
    required this.choice,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'multipleChoiceName': multipleChoiceName,
      'choice': choice,
    };
  }

  factory THMultipleChoicePart.fromMap(Map<String, dynamic> map) {
    return THMultipleChoicePart(
      multipleChoiceName: map['multipleChoiceName'],
      choice: map['choice'],
    );
  }

  factory THMultipleChoicePart.fromJson(String jsonString) {
    return THMultipleChoicePart.fromMap(jsonDecode(jsonString));
  }

  @override
  THMultipleChoicePart copyWith({
    String? multipleChoiceName,
    String? choice,
  }) {
    return THMultipleChoicePart(
      multipleChoiceName: multipleChoiceName ?? this.multipleChoiceName,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THMultipleChoicePart other) {
    if (identical(this, other)) return true;

    return other.multipleChoiceName == multipleChoiceName &&
        other.choice == choice;
  }

  @override
  int get hashCode => Object.hash(multipleChoiceName, choice);

  String _mainChoice(String choice) {
    final alternateChoicesMap =
        _choices[multipleChoiceName]!['alternateChoices']
            as Map<String, String>;

    if (alternateChoicesMap.containsKey(choice)) {
      choice = alternateChoicesMap[choice]!;
    }

    return choice;
  }

  bool hasChoice(String choice) {
    choice = _mainChoice(choice);
    return (_choices[multipleChoiceName]!['choices'] as LinkedHashSet)
        .contains(choice);
  }

  // String get choice {
  //   return _choice;
  // }

  // set choice(String aChoice) {
  //   if (!hasChoice(aChoice)) {
  //     throw THCustomException(
  //         "Unknwon choice '$aChoice' for '$_multipleChoiceName'.");
  //   }

  //   _choice = _mainChoice(aChoice);
  // }

  @override
  String toString() {
    return choice;
  }
}
