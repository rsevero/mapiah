enum THAngleUnit {
  degree,
  minute,
  grad,
  mil,
}

class THAngleUnitPart {
  late THAngleUnit unit;

  static const unitNames = {
    'degree': THAngleUnit.degree,
    'degrees': THAngleUnit.degree,
    'deg': THAngleUnit.degree,
    'minute': THAngleUnit.minute,
    'minutes': THAngleUnit.minute,
    'min': THAngleUnit.minute,
    'grad': THAngleUnit.grad,
    'grads': THAngleUnit.grad,
    'mil': THAngleUnit.mil,
    'mils': THAngleUnit.mil,
  };

  THAngleUnitPart(this.unit);

  THAngleUnitPart.fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw 'Unknwon angle unit.';
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
