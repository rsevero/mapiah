import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_cs_command_option.mapper.dart';

// cs <coordinate system> assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
@MappableClass()
class THCSCommandOption extends THCommandOption with THCSCommandOptionMappable {
  static const String _thisOptionType = 'cs';
  late THCSPart cs;

  /// Constructor necessary for dart_mappable support.
  THCSCommandOption.withExplicitParameters(
      super.thFile, super.parentMapiahID, super.optionType, this.cs)
      : super.withExplicitParameters();

  THCSCommandOption.fromString(
      THHasOptions optionParent, String aCSString, bool forOutputOnly)
      : super(optionParent, _thisOptionType) {
    cs = THCSPart(aCSString, forOutputOnly);
  }

  @override
  String specToFile() {
    return cs.toString();
  }
}
