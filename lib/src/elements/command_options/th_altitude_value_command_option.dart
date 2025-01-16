import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/th_has_altitude.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_altitude_value_command_option.mapper.dart';

// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
@MappableClass()
class THAltitudeValueCommandOption extends THCommandOption
    with THAltitudeValueCommandOptionMappable, THHasLength, THHasAltitude {
  static const String _thisOptionType = 'value';

  /// Constructor necessary for dart_mappable support.
  THAltitudeValueCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    THDoublePart length,
    bool isFix, [
    String? unit,
  ]) : super.withExplicitParameters() {
    this.length = length;
    this.isFix = isFix;
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  THAltitudeValueCommandOption(
      THHasOptions optionParent, THDoublePart length, bool isFix,
      [String? unit])
      : super(optionParent, _thisOptionType) {
    this.length = length;
    this.isFix = isFix;
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  THAltitudeValueCommandOption.fromString(
      THHasOptions optionParent, String aHeight, bool aIsFix,
      [String? aUnit])
      : super(optionParent, _thisOptionType) {
    length = THDoublePart.fromString(aHeight);
    isFix = aIsFix;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THAltitudeValueCommandOption.fromNan(THHasOptions optionParent)
      : super(optionParent, _thisOptionType) {
    length = THDoublePart.fromString('0');
    isNan = true;
  }
}
