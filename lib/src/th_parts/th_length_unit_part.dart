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
    if (!isUnit(aUnitString)) {
      throw 'Unknown unit';
    }

    fromString(aUnitString);
  }

  bool fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      return false;
    }

    unit = stringToUnit[aUnitString]!;

    return true;
  }

  @override
  String toString() {
    return unitToString[unit]!;
  }

  static bool isUnit(String aUnitString) {
    return stringToUnit.containsKey(aUnitString);
  }
}
