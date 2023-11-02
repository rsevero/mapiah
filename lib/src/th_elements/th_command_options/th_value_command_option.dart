import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';

abstract class THValueCommandOption extends THCommandOption {
  THValueCommandOption(super.parentOption);

  @override
  String get optionType => 'value';
}
