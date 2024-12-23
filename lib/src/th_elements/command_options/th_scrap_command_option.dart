import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// scrap <reference> . if the point type is section, this is a reference to a cross-section
// scrap.
class THScrapCommandOption extends THCommandOption {
  late String reference;

  THScrapCommandOption(super.optionParent, this.reference) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'section')) {
      throw THCustomException(
          "Option 'scrap' only valid for points of type 'section'.");
    }
  }

  @override
  String get optionType => 'scrap';

  @override
  String specToFile() {
    return reference;
  }
}
