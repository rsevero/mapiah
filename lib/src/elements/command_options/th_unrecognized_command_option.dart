import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_unrecognized_command_option.mapper.dart';

@MappableClass()
class THUnrecognizedCommandOption extends THCommandOption
    with THUnrecognizedCommandOptionMappable {
  static const String _thisOptionType = 'UnrecognizedCommandOption';
  String? value;

  /// Constructor necessary for dart_mappable support.
  THUnrecognizedCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.value,
  ) : super.withExplicitParameters();

  THUnrecognizedCommandOption(THHasOptions optionParent, this.value)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    return value ?? thNullValueAsString;
  }
}
