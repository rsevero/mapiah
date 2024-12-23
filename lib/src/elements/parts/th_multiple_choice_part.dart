import 'dart:collection';

import 'package:mapiah/src/exceptions/th_custom_exception.dart';

class THMultipleChoicePart {
  late String _choice;
  late String _multipleChoiceName;

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

  THMultipleChoicePart(String aMultipleChoiceName, String aChoice) {
    if (!_choices.containsKey(aMultipleChoiceName)) {
      throw THCustomException(
          "Unknown multiple choice part '$aMultipleChoiceName'.");
    }

    _multipleChoiceName = aMultipleChoiceName;
    choice = aChoice;
  }

  String _mainChoice(String aChoice) {
    final alternateChoicesMap =
        _choices[_multipleChoiceName]!['alternateChoices']
            as Map<String, String>;

    if (alternateChoicesMap.containsKey(aChoice)) {
      aChoice = alternateChoicesMap[aChoice]!;
    }

    return aChoice;
  }

  bool hasChoice(String aChoice) {
    aChoice = _mainChoice(aChoice);
    return (_choices[_multipleChoiceName]!['choices'] as LinkedHashSet)
        .contains(aChoice);
  }

  String get choice {
    return _choice;
  }

  set choice(String aChoice) {
    if (!hasChoice(aChoice)) {
      throw THCustomException(
          "Unknwon choice '$aChoice' for '$_multipleChoiceName'.");
    }

    _choice = _mainChoice(aChoice);
  }

  @override
  String toString() {
    return _choice;
  }
}
