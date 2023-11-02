import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_length_unit_part.dart';

mixin THHasLength on THCommandOption {
  late THDoublePart distance;
  final _unit = THLengthUnitPart.fromString('m');
  bool unitSet = false;

  void unitFromString(String aUnit) {
    _unit.fromString(aUnit);
    unitSet = true;
  }

  String get unit {
    return _unit.toString();
  }

  @override
  String specToFile() {
    if (unitSet) {
      return "[ $distance $_unit ]";
    } else {
      return distance.toString();
    }
  }
}
