import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_stations_command_option.mapper.dart';

// stations <list of station names> . stations you want to plot to the scrap, but
// which are not used for scrap transformation. You don’t have to specify (draw) them
// with the point station command.
@MappableClass()
class THStationsCommandOption extends THCommandOption
    with THStationsCommandOptionMappable {
  static const String _thisOptionType = 'stations';
  List<String> stations;

  /// Constructor necessary for dart_mappable support.
  THStationsCommandOption.withExplicitParameters(
      super.thFile, super.parentMapiahID, super.optionType, this.stations)
      : super.withExplicitParameters();

  THStationsCommandOption(THHasOptions optionParent, this.stations)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    String asString = '';

    for (final String station in stations) {
      asString += ",$station";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    return asString;
  }
}
