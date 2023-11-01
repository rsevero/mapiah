import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_length_unit_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THDistCommandOption extends THCommandOption {
  late THDoublePart distance;
  final _unit = THLengthUnitPart.fromString('m');
  bool unitSet = false;

  THDistCommandOption(super.parentOption, this.distance, [String? aUnit]) {
    if ((parentOption is! THPoint) ||
        ((parentOption as THPoint).pointType != 'remark')) {
      throw THCustomException(
          "'dist' command option only supported on points of type 'remark'.");
    }
    if ((parentOption as THPoint).pointType != 'extra') {
      throw THCustomException(
          "Pption 'dist' only valid for points of type 'extra'.");
    }
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  THDistCommandOption.fromString(super.parentOption, String aDistance,
      [String? aUnit]) {
    if ((parentOption as THPoint).pointType != 'extra') {
      throw THCustomException(
          "Pption 'dist' only valid for points of type 'extra'.");
    }
    distance = THDoublePart.fromString(aDistance);
    if (aUnit != null) {
      unitFromString(aUnit);
    }
  }

  void unitFromString(String aUnit) {
    _unit.fromString(aUnit);
    unitSet = true;
  }

  String get unit {
    return _unit.toString();
  }

  @override
  String get optionType => 'dist';

  @override
  String specToFile() {
    if (unitSet) {
      return "[ $distance $_unit ]";
    } else {
      return distance.toString();
    }
  }
}
