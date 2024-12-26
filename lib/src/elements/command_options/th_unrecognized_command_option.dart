import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_unrecognized_command_option.mapper.dart';

@MappableClass()
class THUnrecognizedCommandOption extends THCommandOption
    with THUnrecognizedCommandOptionMappable {
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
