import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THAltitudeValueCommandOption extends THValueCommandOption
    with THHasLength {
  var isNan = false;
  late bool isFix;

  THAltitudeValueCommandOption(
      super.parentOption, THDoublePart aHeight, this.isFix,
      [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'altitude')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'altitude'.");
    }
    length = aHeight;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeValueCommandOption.fromString(
      super.parentOption, String aHeight, this.isFix,
      [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'altitude')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'altitude'.");
    }
    length = THDoublePart.fromString(aHeight);
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeValueCommandOption.fromNan(super.parentOption) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'altitude')) {
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
