import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';

// stations <list of station names> . stations you want to plot to the scrap, but
// which are not used for scrap transformation. You don’t have to specify (draw) them
// with the point station command.
class THStationsCommandOption extends THCommandOption {
  List<String> stations;

  THStationsCommandOption(super.parent, this.stations);

  @override
  String get optionType {
    return 'stations';
  }

  @override
  String specToFile() {
    var asString = '';

    for (final station in stations) {
      asString += ",$station";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    return asString;
  }
}
