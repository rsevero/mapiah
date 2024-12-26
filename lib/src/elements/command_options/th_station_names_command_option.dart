import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_station_names_command_option.mapper.dart';

// station-names <prefix> <suffix> . adds given prefix/suffix to all survey stations
// in the current scrap. Saves some typing.
@MappableClass()
class THStationNamesCommandOption extends THCommandOption
    with THStationNamesCommandOptionMappable {
  late String _prefix;
  late String _suffix;

  THStationNamesCommandOption(super.parent, String preffix, String suffix) {
    this.preffix = preffix;
    this.suffix = suffix;
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
