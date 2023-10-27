enum THClinoUnit {
  degree,
  minute,
  grad,
  mil,
  percent,
}

class THClinoUnitPart {
  late THClinoUnit unit;

  static const unitNames = {
    'degree': THClinoUnit.degree,
    'degrees': THClinoUnit.degree,
    'deg': THClinoUnit.degree,
    'minute': THClinoUnit.minute,
    'minutes': THClinoUnit.minute,
    'min': THClinoUnit.minute,
    'grad': THClinoUnit.grad,
    'grads': THClinoUnit.grad,
    'mil': THClinoUnit.mil,
    'mils': THClinoUnit.mil,
    'percent': THClinoUnit.percent,
    'percentage': THClinoUnit.percent,
  };

  THClinoUnitPart(this.unit);

  THClinoUnitPart.fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw 'Unknwon clino unit.';
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
