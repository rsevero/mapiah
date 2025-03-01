part of '../th_element.dart';

mixin THHasOptionsMixin on THElement {
  final LinkedHashMap<THCommandOptionType, THCommandOption> _optionsMap =
      LinkedHashMap<THCommandOptionType, THCommandOption>();

  void addUpdateOption(THCommandOption option) {
    _optionsMap[option.type] = option;
  }

  bool hasOption(THCommandOptionType type) {
    return _optionsMap.containsKey(type);
  }

  bool optionIsSet(THCommandOptionType type) {
    return _optionsMap.containsKey(type);
  }

  THCommandOption? optionByType(THCommandOptionType type) {
    return _optionsMap[type];
  }

  bool deleteOption(THCommandOptionType type) {
    if (!hasOption(type)) {
      return false;
    }

    if (kDebugMode) assert(_optionsMap.containsKey(type));
    return (_optionsMap.remove(type) != null);
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

    asString = asString.trim();

    return asString;
  }

  LinkedHashMap<THCommandOptionType, THCommandOption> get optionsMap =>
      _optionsMap;

  void addOptionsMap(Map<THCommandOptionType, THCommandOption> optionsMap) {
    for (final THCommandOptionType type in optionsMap.keys) {
      addUpdateOption(optionsMap[type]!);
    }
  }
}
