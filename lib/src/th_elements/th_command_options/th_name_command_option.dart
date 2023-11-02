import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
class THNameCommandOption extends THCommandOption {
  late String reference;

  THNameCommandOption(super.parentOption, this.reference) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'station')) {
      throw THCustomException(
          "Unsupported point type '${parentOption.type}' for option 'name'.");
    }
  }

  @override
  String get optionType => 'name';

  @override
  String specToFile() {
    return reference;
  }
}
