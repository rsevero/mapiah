part of '../th_element.dart';

mixin THHasOptionsMixin on THElement {
  final LinkedHashMap<THCommandOptionType, THCommandOption> _optionsMap =
      LinkedHashMap<THCommandOptionType, THCommandOption>();
  final LinkedHashMap<String, THAttrCommandOption> _attrOptionsMap =
      LinkedHashMap<String, THAttrCommandOption>();

  void addUpdateOption(THCommandOption option) {
    if (option is THAttrCommandOption) {
      _attrOptionsMap[option.name.content] = option;
    } else {
      _optionsMap[option.type] = option;
    }
  }

  bool hasOption(THCommandOptionType type) {
    return (type == THCommandOptionType.attr)
        ? _attrOptionsMap.isNotEmpty
        : _optionsMap.containsKey(type);
  }

  THCommandOption? optionByType(THCommandOptionType type) {
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

  String? getAttrOption(String name) {
    return _attrOptionsMap[name]?.value.content;
  }

  Iterable<String> getSetAttrOptions() {
    return _attrOptionsMap.keys;
  }

  String optionsAsString() {
    String asString = '';

    final Iterable<THCommandOptionType> optionTypeList = _optionsMap.keys;

    for (THCommandOptionType type in optionTypeList) {
      /// subtype option is serialized in the ':subtype' format, not in the
      /// -subtype <subtype> format.
      if (type == THCommandOptionType.subtype) {
        continue;
      }

      final THCommandOption option = optionByType(type)!;
      final String typeToFile = option.typeToFile();
      final String spec = option.specToFile();

      asString += " -$typeToFile $spec";
    }

    for (THAttrCommandOption attrOption in _attrOptionsMap.values) {
      final String name = attrOption.name.content;
      final String value = attrOption.value.content;

      asString += " -attr $name \"$value\"";
    }

    asString = asString.trim();

    return asString;
  }

  static Map<String, dynamic> optionsMapToMap(
    LinkedHashMap<THCommandOptionType, THCommandOption> optionsMap,
  ) =>
      optionsMap.map(
        (key, value) => MapEntry(
          key.name,
          value.toMap(),
        ),
      );

  static LinkedHashMap<THCommandOptionType, THCommandOption> optionsMapFromMap(
    Map<String, dynamic> map,
  ) =>
      LinkedHashMap<THCommandOptionType, THCommandOption>.from(
        map.map(
          (key, value) => MapEntry(
            THCommandOptionType.values.byName(key),
            THCommandOption.fromMap(value),
          ),
        ),
      );

  LinkedHashMap<THCommandOptionType, THCommandOption> get optionsMap =>
      _optionsMap;

  void addOptionsMap(
    Map<THCommandOptionType, THCommandOption> optionsMap,
  ) {
    for (final THCommandOptionType type in optionsMap.keys) {
      addUpdateOption(optionsMap[type]!);
    }
  }
}
