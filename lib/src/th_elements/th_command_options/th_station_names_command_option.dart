import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THStationNamesCommandOption extends THCommandOption {
  late String _prefix;
  late String _suffix;

  THStationNamesCommandOption(super.parent, aPreffix, aSuffix) {
    preffix = aPreffix;
    suffix = aSuffix;
  }

  set preffix(String aPreffix) {
    if (aPreffix.contains(' ')) {
      throw THCustomException(
          "Preffix can't contain spaces in THStationNamesCommandOption: '$aPreffix'");
    }

    _prefix = aPreffix;
  }

  set suffix(String aSuffix) {
    if (aSuffix.contains(' ')) {
      throw THCustomException(
          "Suffix can't contain spaces in THStationNamesCommandOption: '$aSuffix'");
    }

    _suffix = aSuffix;
  }

  String get preffix {
    return _prefix;
  }

  String get suffix {
    return _suffix;
  }

  @override
  String get optionType {
    return 'station-names';
  }

  @override
  String specToFile() {
    return '$_prefix $_suffix';
  }
}
