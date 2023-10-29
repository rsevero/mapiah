enum THAngleUnit {
  degree,
  grad,
  mil,
  minute,
}

class THAngleUnitPart {
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
    THAngleUnit.minute: 'minute',
  };

  THAngleUnitPart(this.unit);

  THAngleUnitPart.fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw 'Unknown angle unit.';
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
