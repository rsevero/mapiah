import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  String? value;

  THUnrecognizedCommandOption(super.parent);

  @override
  String optionType() {
    return 'UnrecognizedCommandOption';
  }

  @override
  String specToString() {
    return value ?? THNullValueAsString;
  }
}
