import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THExtendCommandOption extends THCommandOption {
  late String station;

  THExtendCommandOption(super.parentOption, this.station);

  @override
  String get optionType => 'extend';

  @override
  String specToFile() {
    if (station.isNotEmpty) {
      return "previous $station";
    } else {
      return '';
    }
  }
}
