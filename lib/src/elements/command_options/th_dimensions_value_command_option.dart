import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_dimensions_value_command_option.mapper.dart';

// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
@MappableClass()
class THDimensionsValueCommandOption extends THCommandOption
    with THDimensionsValueCommandOptionMappable {
  late THDoublePart _above;
  late THDoublePart _below;
  final THLengthUnitPart _unit = THLengthUnitPart.fromString('m');
  bool unitSet = false;

  THDimensionsValueCommandOption(
      super.optionParent, THDoublePart above, THDoublePart below,
      [String? unit]) {
    _checkOptionParent();
    _above = above;
    _below = below;
    if ((unit != null) && (unit.isNotEmpty)) {
      unitFromString(unit);
    }
  }

  THDimensionsValueCommandOption.fromString(
      super.optionParent, String aAbove, String aBelow,
      [String? aUnit]) {
    _checkOptionParent();
    aboveFromString = aAbove;
    belowFromString = aBelow;
    if ((aUnit != null) && (aUnit.isNotEmpty)) {
      unitFromString(aUnit);
    }
  }

  void _checkOptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'dimensions')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'dimensions'.");
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

  @override
  String get optionType => 'value';

  THDoublePart get above => _above;

  THDoublePart get below => _below;

  String get unit => _unit.toString();
}
