import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:meta/meta.dart';

mixin THHasOptions on THElement {
  final LinkedHashMap<THCommandOptionType, THCommandOption> _optionsMap =
      LinkedHashMap<THCommandOptionType, THCommandOption>();

  void addUpdateOption(THCommandOption option) {
    _optionsMap[option.optionType] = option;
  }

  @useResult
  bool hasOption(THCommandOptionType optionType) {
    return _optionsMap.containsKey(optionType);
  }

  @useResult
  bool optionIsSet(THCommandOptionType optionType) {
    return _optionsMap.containsKey(optionType);
  }

  @useResult
  THCommandOption? optionByType(THCommandOptionType optionType) {
    return _optionsMap[optionType];
  }

  @useResult
  bool deleteOption(THCommandOptionType optionType) {
    if (!hasOption(optionType)) {
      return false;
    }

    if (kDebugMode) assert(_optionsMap.containsKey(optionType));
    return (_optionsMap.remove(optionType) != null);
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
