import 'dart:collection';

import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';
import 'package:mapiah/src/th_elements/th_has_platype.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THMultipleChoiceCommandOption extends THCommandOption {
  late final String _optionType;
  late String _choice;
  static final _supportedOptions = {
    'line': {
      // anchors <on/off> . this option can be specified only with the ‘rope’ line type.
      'anchors': {
        'hasDefault': true,
        'default': 'off',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'rope',
        },
      },

      // border <on/off> . this option can be specified only with the ‘slope’ symbol type. It
      // switches on/off the border line of the slope.
      'border': {
        'hasDefault': true,
        'default': 'off',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'slope',
        },
      },

      // close <on/off/auto> . determines whether a line is closed or not
      'close': {
        'hasDefault': true,
        'default': 'off',
        'choices': <String>{
          'on',
          'off',
          'auto',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{},
      },

      // direction <begin/end/both/none/point> . can be used only with the section type.
      // It indicates where to put a direction arrow on the section line. None is default.
      'direction': {
        'hasDefault': true,
        'default': 'none',
        'choices': <String>{
          'begin',
          'end',
          'both',
          'none',
          'point',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'section',
        },
      },

      // gradient <none/center/point> . can be used only with the contour type and indi-
      // cates where to put a gradient mark on the contour line. If there is no gradient speci-
      // fication, behaviour is symbol-set dependent (e.g. no tick in UIS, tick in the middle in
      // SKBB).
      'gradient': {
        'hasDefault': true,
        'default': 'none',
        'choices': <String>{
          'none',
          'center',
          'point',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'contour',
        },
      },

      // head <begin/end/both/none> . can be used only with the arrow type and indicates
      // where to put an arrow head. End is default.
      'head': {
        'hasDefault': true,
        'default': 'end',
        'choices': <String>{
          'begin',
          'end',
          'both',
          'none',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'arrow',
        },
      },

      // rebelays <on/off> . this option can be specified only with the ‘rope’ line type.
      'rebelays': {
        'hasDefault': true,
        'default': 'off',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'rope',
        },
      },
    },
    'point': {
      // align . alignment of the symbol or text. The following values are accepted: center, c,
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
        'plaTypesSupported': <String>{},
      },

      // clip <on/off> . specify whether a symbol is clipped by the scrap border. You cannot
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
        'plaTypesSupported': <String>{},
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
        'plaTypesSupported': <String>{},
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
        'plaTypesSupported': <String>{},
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
    if (!hasOptionType(aOptionParent, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$optionType' for a '${optionParent.elementType}'");
    }

    choice = aChoice;
  }

  set choice(String aChoice) {
    aChoice = _mainChoice(optionParent, optionType, aChoice);

    final aPLAType = (optionParent is THHasPLAType)
        ? (optionParent as THHasPLAType).plaType
        : '';
    if (!hasOptionChoice(optionParent, aPLAType, optionType, aChoice)) {
      throw THCustomException(
          "Unsupported choice '$aChoice' in a '$optionType' option for a '${optionParent.elementType}' element.");
    }

    _choice = aChoice;
  }

  String get choice {
    return _choice;
  }

  static bool hasDefaultChoice(THHasOptions aOptionParent, String aOptionType) {
    if (!hasOptionType(aOptionParent, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$aOptionType' in 'hasDefaultChoice'");
    }

    return (_supportedOptions[aOptionParent.elementType]![aOptionType]![
        'hasDefault'] as bool);
  }

  static String defaultChoice(THHasOptions aOptionParent, String aOptionType) {
    if (!hasDefaultChoice(aOptionParent, aOptionType)) {
      throw THCustomException(
          "Unsupported option type '$aOptionType' in 'defaultChoice'");
    }

    return (_supportedOptions[aOptionParent.elementType]![aOptionType]![
        'defaultChoice'] as String);
  }

  static bool hasOptionChoice(THHasOptions aOptionParent, String aPLAType,
      String aOptionType, String aChoice) {
    if (!hasOptionType(aOptionParent, aOptionType)) {
      return false;
    }

    aChoice = _mainChoice(aOptionParent, aOptionType, aChoice);

    return (_supportedOptions[aOptionParent.elementType]![aOptionType]![
            'choices'] as LinkedHashSet)
        .contains(aChoice);
  }

  static String _mainChoice(
      THHasOptions aOptionParent, String aOptionType, String aChoice) {
    final alternateChoiceMap = _supportedOptions[aOptionParent.elementType]![
        aOptionType]!['alternateChoices'] as Map<String, String>;
    if (alternateChoiceMap.containsKey(aChoice)) {
      aChoice = alternateChoiceMap[aChoice]!;
    }

    return aChoice;
  }

  static bool hasOptionType(THHasOptions aOptionParent, String aOptionType) {
    final aOptionParentElementType = aOptionParent.elementType;
    if (!_supportedOptions.containsKey(aOptionParentElementType)) {
      return false;
    }

    if (!_supportedOptions[aOptionParentElementType]!
        .containsKey(aOptionType)) {
      return false;
    }

    if (aOptionParent is THHasPLAType) {
      final aPLAType = (aOptionParent as THHasPLAType).plaType;

      final plaTypesSupported = _supportedOptions[aOptionParentElementType]![
          aOptionType]!['plaTypesSupported'] as Set<String>;

      if (plaTypesSupported.isEmpty) {
        return true;
      } else {
        return plaTypesSupported.contains(aPLAType);
      }
    }

    return true;
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
