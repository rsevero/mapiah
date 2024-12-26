import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_point_height_value_command_option.mapper.dart';

// height: according to the sign of the value (positive, negative or unsigned), this type of
// symbol represents chimney height, pit depth or step height in general. The numeric
// value can be optionally followed by ‘?’, if the value is presumed and units can be added
// (e.g. -value [40? ft]).
@MappableClass()
class THPointHeightValueCommandOption extends THCommandOption
    with THPointHeightValueCommandOptionMappable, THHasLength {
  late bool isPresumed;

  THPointHeightValueCommandOption(
      super.optionParent, THDoublePart length, this.isPresumed,
      [String? unit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'height')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'height'.");
    }
    this.length = length;
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  THPointHeightValueCommandOption.fromString(
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

  @override
  String get optionType => 'value';
}
