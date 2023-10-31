import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
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
  bool hasOption(String aType) {
    return _optionsMap.containsKey(aType);
  }

  @useResult
  THCommandOption? optionByType(String aType) {
    return _optionsMap[aType];
  }

  @useResult
  bool deleteOption(String aType) {
    if (!hasOption(aType)) {
      return false;
    }

    assert(_optionsList.contains(aType));
    if (!_optionsList.remove(aType)) {
      return false;
    }

    assert(_optionsMap.containsKey(aType));
    return (_optionsMap.remove(aType) != null);
  }

  List<String> optionsList() {
    return _optionsList;
  }

  String optionsAsString() {
    var asString = '';

    for (var aType in optionsList()) {
      final spec = optionByType(aType)!.specToFile();
      asString += " -$aType $spec";
    }

    asString = asString.trim();

    return asString;
  }
}
