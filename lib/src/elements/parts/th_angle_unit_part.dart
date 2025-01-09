import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

part 'th_angle_unit_part.mapper.dart';

@MappableEnum()
enum THAngleUnit {
  degree,
  grad,
  mil,
  minute,
}

@MappableClass()
class THAngleUnitPart with THAngleUnitPartMappable {
  late THAngleUnit unit;

  static const stringToUnit = {
    'deg': THAngleUnit.degree,
    'degree': THAngleUnit.degree,
    'degrees': THAngleUnit.degree,
    'grad': THAngleUnit.grad,
    'grads': THAngleUnit.grad,
    'mil': THAngleUnit.mil,
    'mils': THAngleUnit.mil,
    'min': THAngleUnit.minute,
    'minute': THAngleUnit.minute,
    'minutes': THAngleUnit.minute,
  };

  static const unitToString = {
    THAngleUnit.degree: 'deg',
    THAngleUnit.grad: 'grad',
    THAngleUnit.mil: 'mil',
    THAngleUnit.minute: 'min',
  };

  THAngleUnitPart(this.unit);

  THAngleUnitPart.fromString(String aUnitString) {
    fromString(aUnitString);
  }

  void fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw THConvertFromStringException('THAngleUnitPart', aUnitString);
    }

    unit = stringToUnit[aUnitString]!;
  }

  @override
  String toString() {
    return unitToString[unit]!;
  }

  static bool isUnit(String aUnitString) {
    return stringToUnit.containsKey(aUnitString);
  }
}
