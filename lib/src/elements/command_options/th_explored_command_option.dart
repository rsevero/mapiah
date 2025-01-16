import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_explored_command_option.mapper.dart';

// explored <length> . if the point type is continuation, you can specify length of pas-
// sages explored but not surveyed yet. This value is afterwards displayed in survey/cave
// statistics.
@MappableClass()
class THExploredCommandOption extends THCommandOption
    with THExploredCommandOptionMappable, THHasLength {
  static const String _thisOptionType = 'explored';

  /// Constructor necessary for dart_mappable support.
  THExploredCommandOption.withExplicitParameters(
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

  THExploredCommandOption.fromString(THHasOptions optionParent, String distance,
      [String? aUnit])
      : super(optionParent, _thisOptionType) {
    length = THDoublePart.fromString(distance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }
}
