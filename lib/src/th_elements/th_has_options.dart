import 'package:flutter/foundation.dart';
import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:meta/meta.dart';

mixin THHasOptions on THElement {
  final List<String> _optionsList = [];
  final Map<String, THCommandOption> _optionsMap = {};

  void addUpdateOption(THCommandOption aOption) {
    final type = aOption.optionType;

    if (!_optionsList.contains(type)) {
      _optionsList.add(type);
    }
    _optionsMap[type] = aOption;
  }

  @useResult
  bool hasOption(String aOptionType) {
    return _optionsMap.containsKey(aOptionType);
  }

  @useResult
  bool optionIsSet(String aOptionType) {
    return _optionsMap.containsKey(aOptionType);
  }

  @useResult
  THCommandOption? optionByType(String aOptionType) {
    return _optionsMap[aOptionType];
  }

  @useResult
  bool deleteOption(String aOptionType) {
    if (!hasOption(aOptionType)) {
      return false;
    }

    if (kDebugMode) assert(_optionsList.contains(aOptionType));
    if (!_optionsList.remove(aOptionType)) {
      return false;
    }

    if (kDebugMode) assert(_optionsMap.containsKey(aOptionType));
    return (_optionsMap.remove(aOptionType) != null);
  }

  List<String> optionsList() {
    return _optionsList;
  }

  String optionsAsString() {
    var asString = '';

    for (var aType in optionsList()) {
      /// subtype option is serialized in the ':subtype' format, not in the
      /// -subtype <subtype> format.
      if (aType == 'subtype') {
        continue;
      }
      final spec = optionByType(aType)!.specToFile();
      asString += " -$aType $spec";
    }

    asString = asString.trim();

    return asString;
  }
}
