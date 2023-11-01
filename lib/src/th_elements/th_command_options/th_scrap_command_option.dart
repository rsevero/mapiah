import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THScrapCommandOption extends THCommandOption {
  late String reference;

  THScrapCommandOption(super.parentOption, this.reference) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'section')) {
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
