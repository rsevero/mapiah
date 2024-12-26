import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_explored_command_option.mapper.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
@MappableClass()
class THExploredCommandOption extends THCommandOption
    with THExploredCommandOptionMappable, THHasLength {
  THExploredCommandOption(super.optionParent, THDoublePart length,
      [String? unit]) {
    _checkoptionParent();
    this.length = length;
    if (unit != null) {
      unitFromString(unit);
    }
  }

  THExploredCommandOption.fromString(super.optionParent, String distance,
      [String? aUnit]) {
    _checkoptionParent();
    length = THDoublePart.fromString(distance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  void _checkoptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'continuation')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'continuation'.");
    }
  }

  @override
  String get optionType => 'explored';
}
