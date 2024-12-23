import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_has_length.dart';
import 'package:mapiah/src/th_elements/th_has_altitude.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// altitude <value> . can be specified only with the wall type. This option creates an
// altitude label on the wall. All altitudes are exported as a difference against grid Z
// origin (which is 0 by default). If the value is specified, it gives the altitude difference
// of the point on the wall relative to the nearest station. The value will be set to 0 if
// defined as ”-”, ”.”, ”nan”, ”NAN” or ”NaN”. The value can be prefixed by a keyword
// “fix”, then no nearest station is taken into consideration; the absolute given value is
// used instead. Units can follow the value. Examples: +4, [+4 m], [fix 1510 m].
class THAltitudeCommandOption extends THCommandOption
    with THHasLength, THHasAltitude {
  THAltitudeCommandOption(super.optionParent, THDoublePart aHeight, bool aIsFix,
      [String? aUnit]) {
    if (optionParent is THPoint) {
      if ((optionParent as THPoint).plaType != 'altitude') {
        throw THCustomException(
            "'$optionType' command option only supported on points of type 'altitude'.");
      }
    } else if (optionParent is THLineSegment) {
      if ((optionParent.parent as THLine).plaType != 'wall') {
        throw THCustomException(
            "'$optionType' command option only supported on lines of type 'wall'.");
      }
    } else {
      throw THCustomException("'$optionType' command option not supported.");
    }
    length = aHeight;
    isFix = aIsFix;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeCommandOption.fromString(
      super.optionParent, String aHeight, bool aIsFix,
      [String? aUnit]) {
    if (optionParent is THPoint) {
      if ((optionParent as THPoint).plaType != 'altitude') {
        throw THCustomException(
            "'$optionType' command option only supported on points of type 'altitude'.");
      }
    } else if (optionParent is THLineSegment) {
      if ((optionParent.parent as THLine).plaType != 'wall') {
        throw THCustomException(
            "'$optionType' command option only supported on lines of type 'wall'.");
      }
    } else {
      throw THCustomException("'$optionType' command option not supported.");
    }
    length = THDoublePart.fromString(aHeight);
    isFix = aIsFix;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeCommandOption.fromNan(super.optionParent) {
    if (optionParent is THPoint) {
      if ((optionParent as THPoint).plaType != 'altitude') {
        throw THCustomException(
            "'$optionType' command option only supported on points of type 'altitude'.");
      }
    } else if (optionParent is THLineSegment) {
      if ((optionParent.parent as THLine).plaType != 'wall') {
        throw THCustomException(
            "'$optionType' command option only supported on lines of type 'wall'.");
      }
    } else {
      throw THCustomException("'$optionType' command option not supported.");
    }
    length = THDoublePart.fromString('0');
    isNan = true;
  }

  @override
  String get optionType => 'altitude';
}
