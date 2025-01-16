import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_scrap_command_option.mapper.dart';

// scrap <reference> . if the point type is section, this is a reference to a cross-section
// scrap.
@MappableClass()
class THScrapCommandOption extends THCommandOption
    with THScrapCommandOptionMappable {
  static const String _thisOptionType = 'scrap';
  late String reference;

  /// Constructor necessary for dart_mappable support.
  THScrapCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.reference,
  ) : super.withExplicitParameters();

  THScrapCommandOption(THHasOptions optionParent, this.reference)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    return reference;
  }
}
