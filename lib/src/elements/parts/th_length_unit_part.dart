import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';

enum THLengthUnit {
  centimeter,
  feet,
  inch,
  meter,
  yard,
}

class THLengthUnitPart {
  late THLengthUnit unit;

  static const stringToUnit = {
    'centimeter': THLengthUnit.centimeter,
    'centimeters': THLengthUnit.centimeter,
    'cm': THLengthUnit.centimeter,
    'feet': THLengthUnit.feet,
    'feets': THLengthUnit.feet,
    'ft': THLengthUnit.feet,
    'in': THLengthUnit.inch,
    'inch': THLengthUnit.inch,
    'inches': THLengthUnit.inch,
    'm': THLengthUnit.meter,
    'meter': THLengthUnit.meter,
    'meters': THLengthUnit.meter,
    'yard': THLengthUnit.yard,
    'yards': THLengthUnit.yard,
    'yd': THLengthUnit.yard,
  };

  static const unitToString = {
    THLengthUnit.centimeter: 'cm',
    THLengthUnit.feet: 'ft',
    THLengthUnit.inch: 'in',
    THLengthUnit.meter: 'm',
    THLengthUnit.yard: 'yd',
  };

  THLengthUnitPart(this.unit);

  THLengthUnitPart.fromString(String aUnitString) {
    fromString(aUnitString);
  }

  void fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw THConvertFromStringException('THLengthUnitPart', aUnitString);
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
