import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';

// cs <coordinate system> . assumes that (calibrated) local scrap coordinates are given
// in specified coordinate system. It is useful for absolute placing of imported sketches
// where no survey stations are specified.6
class THCSCommandOption extends THCommandOption {
  late THCSPart cs;

  THCSCommandOption(super.parent, String aCSString, bool forOutputOnly) {
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
