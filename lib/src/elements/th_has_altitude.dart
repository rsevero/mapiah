import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';

// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
mixin THHasAltitude on THCommandOption, THHasLength {
  var isNan = false;
  late bool isFix;

  @override
  String specToFile() {
    if (isNan) {
      return 'NaN';
    }

    var asString = length.toString();

    if (unitSet || isFix) {
      if (isFix) {
        asString = "fix $asString";
      }

      if (unitSet) {
        asString += " $unit";
      }
      return "[ $asString ]";
    }

    return asString;
  }
}
