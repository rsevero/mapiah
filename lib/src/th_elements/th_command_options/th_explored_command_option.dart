import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
class THExploredCommandOption extends THCommandOption with THHasLength {
  THExploredCommandOption(super.optionParent, THDoublePart aDistance,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'continuation')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'continuation'.");
    }
    length = aDistance;
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  THExploredCommandOption.fromString(super.optionParent, String aDistance,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'continuation')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'continuation'.");
    }
    length = THDoublePart.fromString(aDistance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  @override
  String get optionType => 'explored';
}
