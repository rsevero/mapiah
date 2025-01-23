import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

mixin THHasLength on THCommandOption {
  late final THDoublePart length;
  late final THLengthUnitPart unit;
  late final bool unitSet;

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      this.unit = THLengthUnitPart.fromString(unitString: unit);
      unitSet = true;
    } else {
      this.unit = THLengthUnitPart.fromString(unitString: thDefaultLengthUnit);
      unitSet = false;
    }
  }

  @override
  String specToFile() {
    if (unitSet) {
      return "[ $length $unit ]";
    } else {
      return length.toString();
    }
  }
}
