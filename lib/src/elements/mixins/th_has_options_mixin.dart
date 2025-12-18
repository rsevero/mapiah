part of '../th_element.dart';

mixin THHasOptionsMixin on THElement, MPTHFileReferenceMixin {
  final SplayTreeMap<THCommandOptionType, THCommandOption> _optionsMap =
      SplayTreeMap<THCommandOptionType, THCommandOption>();
  final SplayTreeMap<String, THAttrCommandOption> _attrOptionsMap =
      SplayTreeMap<String, THAttrCommandOption>();

  /// The return value is true if:
  /// 1. the were no option with the same name and it was added; or
  /// 2. there was an option with the same name but with a different value.
  bool addUpdateOption(THCommandOption option) {
    if (thFile != null) {
      option.setTHFile(thFile!);
    }

    bool changedValue = false;

    if (option is THAttrCommandOption) {
      final String attrName = option.name.content;

      if (!_attrOptionsMap.containsKey(attrName) ||
          (_attrOptionsMap[attrName] != option)) {
        changedValue = true;
        _attrOptionsMap[attrName] = option;
      }
    } else {
      if (!_optionsMap.containsKey(option.type) ||
          (_optionsMap[option.type] != option)) {
        changedValue = true;
        _optionsMap[option.type] = option;
      }
    }

    return changedValue;
  }

  void setTHFileToOptions(THFile thFile) {
    for (final THCommandOption option in _optionsMap.values) {
      option.setTHFile(thFile);
    }

    for (final THAttrCommandOption attrOption in _attrOptionsMap.values) {
      attrOption.setTHFile(thFile);
    }
  }

  bool hasOption(THCommandOptionType type) {
    return (type == THCommandOptionType.attr)
        ? _attrOptionsMap.isNotEmpty
        : _optionsMap.containsKey(type);
  }

  THCommandOption? getOption(THCommandOptionType type) {
    return (type == THCommandOptionType.attr) ? null : _optionsMap[type];
  }

  THAttrCommandOption? attrOptionByName(String name) {
    return (_attrOptionsMap.containsKey(name)) ? _attrOptionsMap[name] : null;
  }

  bool removeOption(THCommandOptionType type) {
    if (!hasOption(type) || (type == THCommandOptionType.attr)) {
      return false;
    }

    return (_optionsMap.remove(type) != null);
  }

  bool removeAttrOption(String name) {
    if (!hasAttrOption(name)) {
      return false;
    }

    return (_attrOptionsMap.remove(name) != null);
  }

  bool hasAttrOption(String name) {
    return _attrOptionsMap.containsKey(name);
  }

  String? getAttrOptionValue(String name) {
    return _attrOptionsMap[name]?.value.content;
  }

  THAttrCommandOption? getAttrOption(String name) {
    return _attrOptionsMap[name];
  }

  Iterable<String> getSetAttrOptionNames() {
    return _attrOptionsMap.keys;
  }

  String optionsAsString() {
    final Iterable<THCommandOptionType> optionTypeList = _optionsMap.keys;
    final List<String> optionsList = [];
    final THCommandOption? idOption = hasOption(THCommandOptionType.id)
        ? getOption(THCommandOptionType.id)
        : null;

    for (THCommandOptionType type in optionTypeList) {
      /// subtype option is serialized in the ':subtype' format, not in the
      /// -subtype <subtype> format.
      if ((type == THCommandOptionType.subtype) ||
          (type == THCommandOptionType.id)) {
        continue;
      }

      final THCommandOption option = getOption(type)!;
      final String typeToFile = option.typeToFile();
      final String spec = option.specToFile();

      optionsList.add("-$typeToFile $spec");
    }

    for (THAttrCommandOption attrOption in _attrOptionsMap.values) {
      final String name = attrOption.name.content;
      final String value = attrOption.value.content;

      optionsList.add("-attr $name \"$value\"");
    }

    optionsList.sort();

    if (idOption != null) {
      final String idTypeToFile = idOption.typeToFile();
      final String idSpec = idOption.specToFile();

      optionsList.insert(0, "-$idTypeToFile $idSpec");
    }

    final String asString = optionsList.join(' ').trim();

    return asString;
  }

  static Map<String, dynamic> optionsMapToMap(
    SplayTreeMap<THCommandOptionType, THCommandOption> optionsMap,
  ) => optionsMap.map((key, value) => MapEntry(key.name, value.toMap()));

  static SplayTreeMap<THCommandOptionType, THCommandOption> optionsMapFromMap(
    Map<String, dynamic> map,
  ) => SplayTreeMap<THCommandOptionType, THCommandOption>.from(
    map.map(
      (key, value) => MapEntry(
        THCommandOptionType.values.byName(key),
        THCommandOption.fromMap(value),
      ),
    ),
  );

  SplayTreeMap<THCommandOptionType, THCommandOption> get optionsMap =>
      _optionsMap;

  void addOptionsMap(Map<THCommandOptionType, THCommandOption> optionsMap) {
    for (final THCommandOptionType type in optionsMap.keys) {
      addUpdateOption(optionsMap[type]!);
    }
  }

  static Map<String, dynamic> attrOptionsMapToMap(
    SplayTreeMap<String, THAttrCommandOption> attrOptionsMap,
  ) => attrOptionsMap.map((key, value) => MapEntry(key, value.toMap()));

  static SplayTreeMap<String, THAttrCommandOption> attrOptionsMapFromMap(
    Map<String, dynamic> map,
  ) => SplayTreeMap<String, THAttrCommandOption>.from(
    map.map((key, value) => MapEntry(key, THAttrCommandOption.fromMap(value))),
  );

  SplayTreeMap<String, THAttrCommandOption> get attrOptionsMap =>
      _attrOptionsMap;

  void addUpdateAttrOptionsMap(
    Map<String, THAttrCommandOption> attrOptionsMap,
  ) {
    for (final String name in attrOptionsMap.keys) {
      addUpdateOption(attrOptionsMap[name]!);
    }
  }
}
