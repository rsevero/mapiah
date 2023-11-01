import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THFromCommandOption extends THCommandOption {
  String station;

  THFromCommandOption(super.parentOption, this.station) {
    if ((parentOption as THPoint).pointType != 'extra') {
      throw THCustomException(
          "Option 'dist' only valid for points of type 'extra'.");
    }
  }

  @override
  String get optionType => 'from';

  @override
  String specToFile() {
    return station;
  }
}
