import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

// from <station> . valid for extra points, specifies reference station.
class THFromCommandOption extends THCommandOption {
  String station;

  THFromCommandOption(super.optionParent, this.station) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'extra')) {
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
