import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_parts/th_angle_unit_part.dart';
import 'package:mapiah/src/th_parts/th_double_part.dart';

enum THProjectionTypes {
  elevation,
  extended,
  none,
  plan,
}

class THProjectionCommandOption extends THCommandOption {
  THProjectionTypes? projectionType;
  String? projectionIndex;
  THDoublePart? elevationAngleValue;
  THAngleUnitPart? elevationAngleUnit;

  static const typeNames = {
    'elevation': THProjectionTypes.elevation,
    'extended': THProjectionTypes.extended,
    'none': THProjectionTypes.none,
    'plan': THProjectionTypes.plan,
  };

  static const textRepresentations = {
    THProjectionTypes.elevation: 'elevation',
    THProjectionTypes.extended: 'extended',
    THProjectionTypes.none: 'none',
    THProjectionTypes.plan: 'plan',
  };

  THProjectionCommandOption(super.parent);

  @override
  String optionType() {
    return 'projection';
  }

  @override
  String specToString() {
    var asString = '';

    if (projectionType == null) {
      return asString;
    }

    asString += THProjectionCommandOption.textRepresentations[projectionType]!;

    if (projectionIndex != null) {
      asString += ":$projectionIndex";
    }

    if (projectionType == THProjectionTypes.elevation) {
      if (elevationAngleValue != null) {
        asString += " ${elevationAngleValue.toString()}";
        if (elevationAngleUnit != null) {
          asString += " ${elevationAngleUnit.toString()}";
        }
      }
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = "[$asString]";
    }

    return asString;
  }
}
