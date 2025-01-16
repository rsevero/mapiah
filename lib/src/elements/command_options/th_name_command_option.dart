import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_name_command_option.mapper.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
@MappableClass()
class THNameCommandOption extends THCommandOption
    with THNameCommandOptionMappable {
  static const String _thisOptionType = 'name';
  late String reference;

  /// Constructor necessary for dart_mappable support.
  THNameCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.reference,
  ) : super.withExplicitParameters();

  THNameCommandOption(THHasOptions optionParent, this.reference)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    return reference;
  }
}
