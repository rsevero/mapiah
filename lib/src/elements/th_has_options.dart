import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:meta/meta.dart';

mixin THHasOptions on THElement {
  final LinkedHashMap<String, THCommandOption> _optionsMap =
      LinkedHashMap<String, THCommandOption>();

  void addUpdateOption(THCommandOption option) {
    _optionsMap[option.typeToFile()] = option;
  }

  @useResult
  bool hasOption(String optionStringType) {
    return _optionsMap.containsKey(optionStringType);
  }

  @useResult
  bool optionIsSet(String optionStringType) {
    return _optionsMap.containsKey(optionStringType);
  }

  @useResult
  THCommandOption? optionByType(String optionStringType) {
    return _optionsMap[optionStringType];
  }

  @useResult
  bool deleteOption(String optionStringType) {
    if (!hasOption(optionStringType)) {
      return false;
    }

    if (kDebugMode) assert(_optionsMap.containsKey(optionStringType));
    return (_optionsMap.remove(optionStringType) != null);
  }

  String optionsAsString() {
    String asString = '';

    final Iterable<String> optionTypeList = _optionsMap.keys;

    for (String type in optionTypeList) {
      /// subtype option is serialized in the ':subtype' format, not in the
      /// -subtype <subtype> format.
      if (type == 'subtype') {
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

  LinkedHashMap<String, THCommandOption> get optionsMap => _optionsMap;

  void addOptionsMap(Map<String, THCommandOption> optionsMap) {
    for (final String type in optionsMap.keys) {
      addUpdateOption(optionsMap[type]!);
    }
  }
}
