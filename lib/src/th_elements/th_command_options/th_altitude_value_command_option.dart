import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
class THAltitudeValueCommandOption extends THValueCommandOption
    with THHasLength {
  var isNan = false;
  late bool isFix;

  THAltitudeValueCommandOption(
      super.optionParent, THDoublePart aHeight, this.isFix,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'altitude')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'altitude'.");
    }
    length = aHeight;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeValueCommandOption.fromString(
      super.optionParent, String aHeight, this.isFix,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'altitude')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'altitude'.");
    }
    length = THDoublePart.fromString(aHeight);
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeValueCommandOption.fromNan(super.optionParent) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'altitude')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'altitude'.");
    }
    length = THDoublePart.fromString('0');
    isNan = true;
  }

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
