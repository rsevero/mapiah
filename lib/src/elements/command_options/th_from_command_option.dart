import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_from_command_option.mapper.dart';

// from <station> . valid for extra points, specifies reference station.
@MappableClass()
class THFromCommandOption extends THCommandOption
    with THFromCommandOptionMappable {
  static const String _thisOptionType = 'from';
  String station;

  /// Constructor necessary for dart_mappable support.
  THFromCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.station,
  ) : super.withExplicitParameters();

  THFromCommandOption(THHasOptions optionParent, this.station)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    return station;
  }
}
