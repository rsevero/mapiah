part of 'th_command_option.dart';

class THMultipleChoiceAsStringCommandOption extends THCommandOption {
  late final String _choice;
  late final String multipleChoiceType;
  final THElementType parentElementType;

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

  THMultipleChoiceAsStringCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.multipleChoiceType,
    required this.parentElementType,
    required String choice,
  }) : super.forCWJM() {
    setChoice(choice);
  }

  THMultipleChoiceAsStringCommandOption({
    required super.optionParent,
    required this.multipleChoiceType,
    required String choice,
    super.originalLineInTH2File = '',
  })  : parentElementType = optionParent.elementType,
        super() {
    setChoice(choice);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.multipleChoice;

  @override
  String typeToFile() => multipleChoiceType;

  static String getParentTypeNameForChecking(String parentTypeName) {
    String parentTypeNameForChecking = parentTypeName;

    if ((parentTypeNameForChecking == THElementType.straightLineSegment.name) ||
        (parentTypeNameForChecking ==
            THElementType.bezierCurveLineSegment.name)) {
      parentTypeNameForChecking = 'linesegment';
    } else {
      parentTypeNameForChecking = parentTypeNameForChecking.toLowerCase();
    }

    return parentTypeNameForChecking;
  }

  String get parentTypeNameForChecking =>
      getParentTypeNameForChecking(parentElementType.name);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'multipleChoiceType': multipleChoiceType,
      'parentElementType': parentElementType.name,
      'choice': _choice,
    });

    return map;
  }

  factory THMultipleChoiceAsStringCommandOption.fromMap(
      Map<String, dynamic> map) {
    return THMultipleChoiceAsStringCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      multipleChoiceType: map['multipleChoiceType'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: map['choice'],
    );
  }

  factory THMultipleChoiceAsStringCommandOption.fromJson(String jsonString) {
    return THMultipleChoiceAsStringCommandOption.fromMap(
        jsonDecode(jsonString));
  }

  @override
  THMultipleChoiceAsStringCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? multipleChoiceType,
    THElementType? parentElementType,
    String? choice,
    bool makeChoiceNull = false,
  }) {
    return THMultipleChoiceAsStringCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      multipleChoiceType: multipleChoiceType ?? this.multipleChoiceType,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: makeChoiceNull ? '' : (choice ?? _choice),
    );
  }

  @override
  bool operator ==(covariant THMultipleChoiceAsStringCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.multipleChoiceType == multipleChoiceType &&
        other.parentElementType == parentElementType &&
        other._choice == _choice;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        multipleChoiceType,
        parentElementType,
        _choice,
      );

  void setChoice(String choice) {
    choice = _mainChoice(choice);

    if (!hasOptionChoice(choice)) {
      throw THCustomException(
          "Unsupported choice '$choice' in a '$optionType' option for a '$parentElementType' element.");
    }

    _choice = choice;
  }

  String get choice => _choice;

  bool hasDefaultChoice() {
    return (_supportedOptions[parentTypeNameForChecking]![multipleChoiceType]![
        'hasDefault'] as bool);
  }

  String defaultChoice() {
    if (!hasDefaultChoice()) {
      throw THCustomException(
          "Unsupported option type '$optionType' in 'defaultChoice'");
    }

    return (_supportedOptions[parentTypeNameForChecking]![multipleChoiceType]![
        'defaultChoice'] as String);
  }

  bool hasOptionChoice(String choice) {
    choice = _mainChoice(choice);

    return (_supportedOptions[parentTypeNameForChecking]![multipleChoiceType]![
            'choices'] as LinkedHashSet)
        .contains(choice);
  }

  String _mainChoice(String choice) {
    final Map<String, String> alternateChoiceMap = _supportedOptions[
            parentTypeNameForChecking]![multipleChoiceType]!['alternateChoices']
        as Map<String, String>;
    if (alternateChoiceMap.containsKey(choice)) {
      choice = alternateChoiceMap[choice]!;
    }

    return choice;
  }

  static bool hasOptionType(THHasOptionsMixin optionParent, String optionType) {
    final String optionParentElementType =
        getParentTypeNameForChecking(optionParent.elementType.name);

    if (!_supportedOptions.containsKey(optionParentElementType)) {
      return false;
    }

    if (!_supportedOptions[optionParentElementType]!.containsKey(optionType)) {
      return false;
    }

    if (optionParent is THHasPLATypeMixin) {
      final String plaType = (optionParent as THHasPLATypeMixin).plaType;

      final Set<String> plaTypesSupported = _supportedOptions[
              optionParentElementType]![optionType]!['plaTypesSupported']
          as Set<String>;

      if (plaTypesSupported.isEmpty) {
        return true;
      } else {
        return plaTypesSupported.contains(plaType);
      }
    }

    return true;
  }

  @override
  String specToFile() {
    return _choice;
  }
}
