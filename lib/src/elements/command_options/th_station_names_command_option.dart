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
  static const String _thisOptionType = 'station-names';
  late String _prefix;
  late String _suffix;

  /// Constructor necessary for dart_mappable support.
  THStationNamesCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    String preffix,
    String suffix,
  ) : super.withExplicitParameters() {
    this.preffix = preffix;
    this.suffix = suffix;
  }

  THStationNamesCommandOption(
      THHasOptions optionParent, String preffix, String suffix)
      : _prefix = preffix,
        _suffix = suffix,
        super(optionParent, _thisOptionType);

  set preffix(String preffix) {
    if (preffix.contains(' ')) {
      throw THCustomException(
          "Preffix can't contain spaces in THStationNamesCommandOption: '$preffix'");
    }

    _prefix = preffix;
  }

  set suffix(String suffix) {
    if (suffix.contains(' ')) {
      throw THCustomException(
          "Suffix can't contain spaces in THStationNamesCommandOption: '$suffix'");
    }

    _suffix = suffix;
  }

  String get preffix {
    return _prefix;
  }

  String get suffix {
    return _suffix;
  }

  @override
  String specToFile() {
    return '$_prefix $_suffix';
  }
}
