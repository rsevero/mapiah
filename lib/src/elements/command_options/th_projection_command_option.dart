import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/th_exceptions/th_convert_from_string_exception.dart';
import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

enum THProjectionTypes {
  elevation,
  extended,
  none,
  plan,
}

// projection <specification> . specifies the drawing projection. Each projection is
// identified by a type and optionally by an index in the form type[:index]. The index
// can be any keyword. The following projection types are supported:
// 1. none . no projection, used for cross sections or maps that are independent of survey
// data (e.g. digitization of old maps where no centreline data are available). No index is
// allowed for this projection.
// 2. plan . basic plan projection (default).
// 3. elevation . orthogonal projection (a.k.a. projected profile) which optionally takes
// a view direction as an argument (e.g. [elevation 10] or [elevation 10 deg]).
// 4. extended . extended elevation (a.k.a. extended profile).
class THProjectionCommandOption extends THCommandOption {
  late THProjectionTypes type;
  String index;
  THDoublePart? elevationAngle;
  THAngleUnitPart? elevationUnit;

  static const stringToType = {
    'elevation': THProjectionTypes.elevation,
    'extended': THProjectionTypes.extended,
    'none': THProjectionTypes.none,
    'plan': THProjectionTypes.plan,
  };

  static const typeToString = {
    THProjectionTypes.elevation: 'elevation',
    THProjectionTypes.extended: 'extended',
    THProjectionTypes.none: 'none',
    THProjectionTypes.plan: 'plan',
  };

  THProjectionCommandOption(super.parent, this.type,
      {this.index = '', this.elevationAngle, this.elevationUnit});

  THProjectionCommandOption.fromString(super.parent, String aType,
      {this.index = '', this.elevationAngle, this.elevationUnit}) {
    typeFromString(aType);
  }

  static bool isType(String aType) {
    return stringToType.containsKey(aType);
  }

  void typeFromString(String aType) {
    if (!THProjectionCommandOption.isType(aType)) {
      throw THConvertFromStringException(runtimeType.toString(), aType);
    }

    type = stringToType[aType]!;
  }

  void elevationAngleFromString(String aAngle) {
    elevationAngle = THDoublePart.fromString(aAngle);
  }

  void elevationUnitFromString(String aUnit) {
    elevationUnit = THAngleUnitPart.fromString(aUnit);
  }

  @override
  String get optionType {
    return 'projection';
  }

  @override
  String specToFile() {
    var asString = '';

    asString += THProjectionCommandOption.typeToString[type]!;

    if (index.isNotEmpty && index.trim().isNotEmpty) {
      asString += ':${index.trim()}';
    }

    if (type == THProjectionTypes.elevation) {
      if (elevationAngle != null) {
        asString += " ${elevationAngle.toString()}";
        if (elevationUnit != null) {
          asString += " ${elevationUnit.toString()}";
        }
      }
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = "[ $asString ]";
    }

    return asString;
  }
}
