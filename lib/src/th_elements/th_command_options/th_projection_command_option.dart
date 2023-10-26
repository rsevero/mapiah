import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

class THProjectionCommandOption extends THCommandOption {
  THProjectionCommandOption(super.parent, super.value);

  @override
  String type() {
    return 'projection';
  }
}
