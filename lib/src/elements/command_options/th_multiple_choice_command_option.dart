import 'dart:collection';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_has_platype.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_multiple_choice_command_option.mapper.dart';

@MappableClass()
class THMultipleChoiceCommandOption extends THCommandOption
    with THMultipleChoiceCommandOptionMappable {
  late String _choice;

  static const Map<String, Map<String, Map<String, Object>>> _supportedOptions =
      {
    'area': {
      // clip <on/off> . specify whether a symbol is clipped by the scrap border.
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
        'default': 'on',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{},
      },
    },
    'line': {
      // anchors <on/off> . this option can be specified only with the ‘rope’ line type.
      'anchors': {
        'hasDefault': true,
        'default': 'on',
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

      // clip <on/off> . specify whether a symbol is clipped by the scrap border.
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

      // outline <in/out/none> . determines whether the line serves as a border line for a
      // scrap. Default value is ‘out’ for walls, ‘none’ for all other lines. Use -outline in for
      // large pillars etc.
      'outline': {
        'hasDefault': false,
        'choices': <String>{
          'in',
          'out',
          'none',
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

      // rebelays <on/off> . this option can be specified only with the ‘rope’ line type.
      'rebelays': {
        'hasDefault': true,
        'default': 'on',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{
          'rope',
        },
      },

      // reverse <on/off> . whether points are given in reverse order.
      'reverse': {
        'hasDefault': true,
        'default': 'off',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{},
      },

      // visibility <on/off> . displays/hides the symbol.
      'visibility': {
        'hasDefault': true,
        'default': 'on',
        'choices': <String>{
          'on',
          'off',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{},
      },
    },
    'linesegment': {
      // adjust <horizontal/vertical> . shifts the line point to be aligned horizontally/ver-
      // tically with the previous point. It can’t be set on the first point. The result is a
      // horizontal/vertical line segment. This option is not allowed in the plan projection.
      'adjust': {
        'hasDefault': false,
        'choices': <String>{
          'horizontal',
          'vertical',
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

      // smooth <on/off/auto> . whether the line is smooth at the given point. Auto is
      // default.
      'smooth': {
        'hasDefault': true,
        'default': 'auto',
        'choices': <String>{
          'on',
          'off',
          'auto',
        },
        'alternateChoices': <String, String>{},
        'plaTypesSupported': <String>{},
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

  THMultipleChoiceCommandOption.withExplicitParameters(
    super.thFile,
    super.parentMapiahID,
    super.optionType,
    String choice,
  ) : super.withExplicitParameters() {
    _checkOptionParent();
    this.choice = choice;
  }

  THMultipleChoiceCommandOption(
    super.optionParent,
    super.optionType,
    String choice,
  ) {
    _checkOptionParent();
    this.choice = choice;
  }

  void _checkOptionParent() {
    if (!hasOptionType(optionParent, optionType)) {
      throw THCustomException(
          "Unsupported option type '$optionType' for a '${optionParent.elementType}'");
    }
  }

  set choice(String choice) {
    choice = _mainChoice(choice);

    if (!hasOptionChoice(choice)) {
      throw THCustomException(
          "Unsupported choice '$choice' in a '$optionType' option for a '${optionParent.elementType}' element.");
    }

    _choice = choice;
  }

  String get choice => _choice;

  bool hasDefaultChoice() {
    return (_supportedOptions[optionParent.elementType]![optionType]![
        'hasDefault'] as bool);
  }

  String defaultChoice() {
    if (!hasDefaultChoice()) {
      throw THCustomException(
          "Unsupported option type '$optionType' in 'defaultChoice'");
    }

    return (_supportedOptions[optionParent.elementType]![optionType]![
        'defaultChoice'] as String);
  }

  bool hasOptionChoice(String aChoice) {
    aChoice = _mainChoice(aChoice);

    return (_supportedOptions[optionParent.elementType]![optionType]!['choices']
            as LinkedHashSet)
        .contains(aChoice);
  }

  String _mainChoice(String aChoice) {
    final Map<String, String> alternateChoiceMap = _supportedOptions[
            optionParent.elementType]![optionType]!['alternateChoices']
        as Map<String, String>;
    if (alternateChoiceMap.containsKey(aChoice)) {
      aChoice = alternateChoiceMap[aChoice]!;
    }

    return aChoice;
  }

  static bool hasOptionType(THHasOptions aOptionParent, String aOptionType) {
    final String aOptionParentElementType = aOptionParent.elementType;
    if (!_supportedOptions.containsKey(aOptionParentElementType)) {
      return false;
    }

    if (!_supportedOptions[aOptionParentElementType]!
        .containsKey(aOptionType)) {
      return false;
    }

    if (aOptionParent is THHasPLAType) {
      final String aPLAType = (aOptionParent as THHasPLAType).plaType;

      final Set<String> plaTypesSupported = _supportedOptions[
              aOptionParentElementType]![aOptionType]!['plaTypesSupported']
          as Set<String>;

      if (plaTypesSupported.isEmpty) {
        return true;
      } else {
        return plaTypesSupported.contains(aPLAType);
      }
    }

    return true;
  }

  @override
  String specToFile() {
    return _choice;
  }
}
