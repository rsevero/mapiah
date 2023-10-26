import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:meta/meta.dart';

mixin THHasOptions on THElement {
  final List<String> _optionsList = [];
  final Map<String, THCommandOption> _optionsMap = {};

  bool addOption(THCommandOption aOption) {
    final type = aOption.type;
    if (_optionsList.contains(type) | _optionsMap.containsKey(type)) {
      return false;
    }
    _optionsList.add(aOption.type());
    _optionsMap[aOption.type()] = aOption;

    return true;
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
  bool updateOption(THCommandOption aOption) {
    final type = aOption.type();
    if (hasOption(type)) {
      assert(_optionsList.contains(type));
      _optionsMap[type] = aOption;
      return true;
    } else {
      return addOption(aOption);
    }
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

  @override
  String toString() {
    var asString = '';

    for (var aType in _optionsList) {
      asString += " ${optionByType(aType).toString()}";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    return asString;
  }
}
