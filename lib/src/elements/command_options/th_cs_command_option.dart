import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_cs_command_option.mapper.dart';

// cs <coordinate system> . assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.
@MappableClass()
class THCSCommandOption extends THCommandOption with THCSCommandOptionMappable {
  late THCSPart cs;

  @MappableConstructor()
  THCSCommandOption(super.optionParent, this.cs);

  THCSCommandOption.fromString(
      super.optionParent, String aCSString, bool forOutputOnly) {
    cs = THCSPart(aCSString, forOutputOnly);
  }

  @override
  String get optionType {
    return 'cs';
  }

  @override
  String specToFile() {
    return cs.toString();
  }
}
