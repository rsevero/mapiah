import 'dart:collection';

import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THMultipleChoiceCommandOption extends THCommandOption {
  late final String _optionType;
  late String _choice;
  static final _supportedOptions = {
    'point': {
//       align . alignment of the symbol or text. The following values are accepted: center, c,
// top, t, bottom, b, left, l, right, r, top-left, tl, top-right, tr, bottom-left, bl, bottom-right,
// br.
      'align': {
        'hasDefault': false,
        'choices': <String>{
          'center',
          'top',
          'bottom',
          'left',
          'right',
          'top-left',
          'top-right',
          'bottom-left',
          'bottom-right',
        },
        'alternateChoices': {
          'c': 'center',
          't': 'top',
          'b': 'bottom',
          'l': 'left',
          'r': 'right',
          'tl': 'top-left',
          'tr': 'top-right',
          'bl': 'bottom-left',
          'br': 'bottom-right',
        },
      },

//       clip <on/off> . specify whether a symbol is clipped by the scrap border. You cannot
// specify this option for the following symbols: station, station-name, label, remark,
// date, altitude, height, passage-height.
      'clip': {
        'hasDefault': true,
        'default': 'default',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
      },

      // place <bottom/default/top> . changes displaying order in the map.
      'place': {
        'hasDefault': true,
        'default': 'default',
        'choices': <String>{
          'bottom',
          'default',
          'top',
        },
        'alternateChoices': <String, String>{},
      },

      // visibility <on/off> . displays/hides the symbol.
      'visibility': {
        'hasDefault': true,
        'default': 'default',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
      },
    },
    'scrap': {
      // flip (none)/horizontal/vertical . flips the scrap after scale transformation
      'flip': {
        'hasDefault': true,
        'default': 'none',
        'choices': <String>{
          'none',
          'horizontal',
          'vertical',
        },
        'alternateChoices': <String, String>{},
      },

      // walls <on/off/auto> . specify if the scrap should be used in 3D model reconstruction
      'walls': {
        'hasDefault': false,
        'choices': <String>{
          'on',
          'off',
          'auto',
        },
        'alternateChoices': <String, String>{},
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
  THMultipleChoiceCommandOption(
      THHasOptions aOptionParent, String aOptionType, String aChoice)
      : _optionType = aOptionType,
        super(aOptionParent) {
    if (!hasOptionType(parentOption.type, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$optionType' for a '${parentOption.type}'");
    }

    choice = aChoice;
  }

  set choice(String aChoice) {
    aChoice = _mainChoice(parentOption.type, optionType, aChoice);

    if (!hasOptionChoice(parentOption.type, optionType, aChoice)) {
      throw THCustomException(
          "Unsupported choice '$aChoice' in a '$optionType' option for a '${parentOption.type}' element.");
    }

    _choice = aChoice;
  }

  String get choice {
    return _choice;
  }

  static bool hasDefaultChoice(String aParentType, String aOptionType) {
    if (!hasOptionType(aParentType, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$aOptionType' for a '$aParentType' in 'hasDefaultChoice'");
    }

    return (_supportedOptions[aParentType]![aOptionType]!['hasDefault']
        as bool);
  }

  static String defaultChoice(String aParentType, String aOptionType) {
    if (!hasDefaultChoice(aParentType, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$aOptionType' for a '$aParentType' in 'defaultChoice'");
    }

    return (_supportedOptions[aParentType]![aOptionType]!['defaultChoice']
        as String);
  }

  static bool hasOptionChoice(
      String aParentType, String aOptionType, String aChoice) {
    if (!hasOptionType(aParentType, aOptionType)) {
      return false;
    }

    aChoice = _mainChoice(aParentType, aOptionType, aChoice);

    return (_supportedOptions[aParentType]![aOptionType]!['choices']
            as LinkedHashSet)
        .contains(aChoice);
  }

  static String _mainChoice(
      String aParentType, String aOptionType, String aChoice) {
    final alternateChoiceMap =
        _supportedOptions[aParentType]![aOptionType]!['alternateChoices']
            as Map<String, String>;
    if (alternateChoiceMap.containsKey(aChoice)) {
      aChoice = alternateChoiceMap[aChoice]!;
    }

    return aChoice;
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