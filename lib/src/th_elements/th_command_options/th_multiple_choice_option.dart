import 'dart:collection';

import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THMultipleChoiceOption extends THCommandOption {
  late final String _optionType;
  late String _choice;
  static final _supportedOptions = {
    'scrap': {
      'walls': {
        'hasDefault': false,
        'choices': <String>{
          'on',
          'off',
          'auto',
        }
      },
    },
  };

  /// Did some shenanigans in this constructor:
  ///
  /// 1. Used a initializer list instead of the regular 'super.' and 'this.' in
  ///    the parameter list to change the order of the initialization as I need
  ///    _optionType set before setting 'optionParent' in [THCommandOption]
  ///    because of the call to 'addUpdateOption' inside THCommandOption
  ///    constructor.
  THMultipleChoiceOption(
      THHasOptions aOptionParent, String aOptionType, String aChoice)
      : _optionType = aOptionType,
        super(aOptionParent) {
    if (!hasOptionType(optionParent.type, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$optionType' for a '${optionParent.type}'");
    }

    choice = aChoice;
  }

  set choice(String aChoice) {
    if (!hasOptionChoice(optionParent.type, optionType, aChoice)) {
      throw THCustomException(
          "Unsupported choice '$aChoice' in a '$optionType' option for a '${optionParent.type}' element.");
    }

    _choice = aChoice;
  }

  String get choice {
    return _choice;
  }

  static bool hasOptionChoice(
      String aParentType, String aOptionType, String aChoice) {
    if (!hasOptionType(aParentType, aOptionType)) {
      return false;
    }

    return (_supportedOptions[aParentType]![aOptionType]!['choices']
            as LinkedHashSet)
        .contains(aChoice);
  }

  static bool hasOptionType(String aParentType, String aOptionType) {
    if (!_supportedOptions.containsKey(aParentType)) {
      return false;
    }

    return _supportedOptions[aParentType]!.containsKey(aOptionType);
  }

  @override
  String get optionType {
    return _optionType;
  }

  @override
  String specToFile() {
    return _choice;
  }
}
