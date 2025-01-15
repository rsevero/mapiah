import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:meta/meta.dart';

mixin THHasOptions on THElement {
  final LinkedHashMap<String, THCommandOption> _optionsMap =
      LinkedHashMap<String, THCommandOption>();

  void addUpdateOption(THCommandOption option) {
    _optionsMap[option.optionType] = option;
  }

  @useResult
  bool hasOption(String optionType) {
    return _optionsMap.containsKey(optionType);
  }

  @useResult
  bool optionIsSet(String optionType) {
    return _optionsMap.containsKey(optionType);
  }

  @useResult
  THCommandOption? optionByType(String optionType) {
    return _optionsMap[optionType];
  }

  @useResult
  bool deleteOption(String optionType) {
    if (!hasOption(optionType)) {
      return false;
    }

    if (kDebugMode) assert(_optionsMap.containsKey(optionType));
    return (_optionsMap.remove(optionType) != null);
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
      final String spec = optionByType(type)!.specToFile();
      asString += " -$type $spec";
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
