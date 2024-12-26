import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_dist_command_option.mapper.dart';

// dist <distance> . valid for extra points, specifies the distance to the nearest station
// (or station specified using -from option. If not specified, appropriate value from LRUD
// data is used.
@MappableClass()
class THDistCommandOption extends THCommandOption
    with THDistCommandOptionMappable, THHasLength {
  THDistCommandOption(super.optionParent, THDoublePart length, [String? unit]) {
    _checkoptionParent();
    this.length = length;
    if (unit != null) {
      unitFromString(unit);
    }
  }

  THDistCommandOption.fromString(super.optionParent, String distance,
      [String? aUnit]) {
    _checkoptionParent();
    length = THDoublePart.fromString(distance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  void _checkoptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'extra')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'extra'.");
    }
  }

  @override
  String get optionType => 'dist';
}
