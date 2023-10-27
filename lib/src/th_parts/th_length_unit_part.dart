enum THLengthUnit {
  meter,
  centimeter,
  inch,
  feet,
  yard,
}

class THLengthUnitPart {
  late THLengthUnit unit;

  static const unitNames = {
    'meter': THLengthUnit.meter,
    'meters': THLengthUnit.meter,
    'm': THLengthUnit.meter,
    'centimeter': THLengthUnit.centimeter,
    'centimeters': THLengthUnit.centimeter,
    'cm': THLengthUnit.centimeter,
    'inch': THLengthUnit.inch,
    'inches': THLengthUnit.inch,
    'in': THLengthUnit.inch,
    'feet': THLengthUnit.feet,
    'feets': THLengthUnit.feet,
    'ft': THLengthUnit.feet,
    'yard': THLengthUnit.yard,
    'yards': THLengthUnit.yard,
    'yd': THLengthUnit.yard,
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

    unit = unitNames[aUnitString]!;

    return true;
  }

  static bool isUnit(String aUnitString) {
    return unitNames.containsKey(aUnitString);
  }
}
