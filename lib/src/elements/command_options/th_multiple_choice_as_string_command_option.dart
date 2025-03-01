part of 'th_command_option.dart';

class THMultipleChoiceAsStringCommandOption extends THCommandOption {
  late final String _choice;
  late final String multipleChoiceType;
  final THElementType parentElementType;

  static const Map<String, Map<String, Map<String, Object>>> _supportedOptions =
      {
    'line': {
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
