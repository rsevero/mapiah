import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_value_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// height: according to the sign of the value (positive, negative or unsigned), this type of
// symbol represents chimney height, pit depth or step height in general. The numeric
// value can be optionally followed by ‘?’, if the value is presumed and units can be added
// (e.g. -value [40? ft]).
class THHeightValueCommandOption extends THValueCommandOption with THHasLength {
  late bool isPresumed;

  THHeightValueCommandOption(
      super.optionParent, THDoublePart aHeight, this.isPresumed,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'height')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'height'.");
    }
    length = aHeight;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THHeightValueCommandOption.fromString(
      super.optionParent, String aHeight, this.isPresumed,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'height')) {
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

    if (unitSet || isPresumed) {
      if (isPresumed) {
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
