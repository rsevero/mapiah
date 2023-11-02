import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THExploredCommandOption extends THCommandOption with THHasLength {
  THExploredCommandOption(super.parentOption, THDoublePart aDistance,
      [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'continuation')) {
      throw THCustomException(
          "'explored' command option only supported on points of type 'continuation'.");
    }
    if ((parentOption as THPoint).pointType != 'extra') {
      throw THCustomException(
          "Option 'explored' only valid for points of type 'continuation'.");
    }
    distance = aDistance;
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  THExploredCommandOption.fromString(super.parentOption, String aDistance,
      [String? aUnit]) {
    if ((parentOption as THPoint).pointType != 'continuation') {
      throw THCustomException(
          "Option 'explored' only valid for points of type 'continuation'.");
    }
    distance = THDoublePart.fromString(aDistance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  @override
  String get optionType => 'explored';
}
