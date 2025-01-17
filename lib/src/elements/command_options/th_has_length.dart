import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

mixin THHasLength on THCommandOption {
  late THDoublePart length;
  final THLengthUnitPart _unit = THLengthUnitPart.fromString('m');
  late final bool unitSet;

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      _unit.fromString(unit);
      unitSet = true;
    } else {
      unitSet = false;
    }
  }

  String get unit {
    return _unit.toString();
  }

  @override
  String specToFile() {
    if (unitSet) {
      return "[ $length $_unit ]";
    } else {
      return length.toString();
    }
  }
}
