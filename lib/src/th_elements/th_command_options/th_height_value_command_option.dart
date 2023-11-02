import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THHeightValueCommandOption extends THValueCommandOption with THHasLength {
  late bool hasFix;

  THHeightValueCommandOption(
      super.parentOption, THDoublePart aHeight, this.hasFix,
      [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'height')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'height'.");
    }
    length = aHeight;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THHeightValueCommandOption.fromString(
      super.parentOption, String aHeight, this.hasFix,
      [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'height')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'height'.");
    }
    length = THDoublePart.fromString(aHeight);
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  @override
  String specToFile() {
    var asString = length.toString();

    if (unitSet || hasFix) {
      if (hasFix) {
        asString += '?';
      }

      if (unitSet) {
        asString += " $unit";
      }
      return "[ $asString ]";
    }

    return asString;
  }
}
