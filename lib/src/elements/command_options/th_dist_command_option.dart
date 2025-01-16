import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_dist_command_option.mapper.dart';

// dist <distance> . valid for extra points, specifies the distance to the nearest station
// (or station specified using -from option. If not specified, appropriate value from LRUD
// data is used.
@MappableClass()
class THDistCommandOption extends THCommandOption
    with THDistCommandOptionMappable, THHasLength {
  static const String _thisOptionType = 'dist';

  /// Constructor necessary for dart_mappable support.
  THDistCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    THDoublePart length, [
    String? unit,
  ]) : super.withExplicitParameters() {
    this.length = length;
    if (unit != null) {
      unitFromString(unit);
    }
  }

  THDistCommandOption.fromString(THHasOptions optionParent, String distance,
      [String? aUnit])
      : super(optionParent, _thisOptionType) {
    length = THDoublePart.fromString(distance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }
}
