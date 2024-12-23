import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  String? value;

  THUnrecognizedCommandOption(super.parent, this.value);

  @override
  String get optionType {
    return 'UnrecognizedCommandOption';
  }

  @override
  String specToFile() {
    return value ?? thNullValueAsString;
  }
}
