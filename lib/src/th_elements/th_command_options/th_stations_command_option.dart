import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THStationsCommandOption extends THCommandOption {
  List<String> stations;

  THStationsCommandOption(super.parent, this.stations);

  @override
  String optionType() {
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
