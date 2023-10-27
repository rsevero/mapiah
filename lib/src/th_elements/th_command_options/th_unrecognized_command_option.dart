import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  THUnrecognizedCommandOption(super.parent, super.value);

  @override
  String type() {
    return 'UnrecognizedCommandOption';
  }
}
