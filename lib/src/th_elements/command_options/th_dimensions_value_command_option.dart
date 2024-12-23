import 'package:mapiah/src/th_elements/command_options/th_value_command_option.dart';
import 'package:mapiah/src/th_elements/parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
class THDimensionsValueCommandOption extends THValueCommandOption {
  late THDoublePart _above;
  late THDoublePart _below;
  final _unit = THLengthUnitPart.fromString('m');
  bool unitSet = false;

  THDimensionsValueCommandOption(
      super.optionParent, THDoublePart aAbove, THDoublePart aBelow,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'dimensions')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'dimensions'.");
    }
    _above = aAbove;
    _below = aBelow;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  THDimensionsValueCommandOption.fromString(
      super.optionParent, String aAbove, String aBelow,
      [String? aUnit]) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'dimensions')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'dimensions'.");
    }
    aboveFromString = aAbove;
    belowFromString = aBelow;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  void unitFromString(String aUnit) {
    _unit.fromString(aUnit);
    unitSet = true;
  }

  set aboveFromString(String aAbove) {
    _above = THDoublePart.fromString(aAbove);
  }

  set belowFromString(String aBelow) {
    _below = THDoublePart.fromString(aBelow);
  }

  @override
  String specToFile() {
    var asString = "${_above.toString()} ${_below.toString()}";

    if (unitSet) {
      asString += " ${_unit.toString()}";
    }

    asString = "[ $asString ]";

    return asString;
  }
}
