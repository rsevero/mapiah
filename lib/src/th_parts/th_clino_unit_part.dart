enum THClinoUnit {
  degree,
  grad,
  mil,
  minute,
  percent,
}

class THClinoUnitPart {
  late THClinoUnit unit;

  static const unitNames = {
    'deg': THClinoUnit.degree,
    'degree': THClinoUnit.degree,
    'degrees': THClinoUnit.degree,
    'grad': THClinoUnit.grad,
    'grads': THClinoUnit.grad,
    'mil': THClinoUnit.mil,
    'mils': THClinoUnit.mil,
    'min': THClinoUnit.minute,
    'minute': THClinoUnit.minute,
    'minutes': THClinoUnit.minute,
    'percent': THClinoUnit.percent,
    'percentage': THClinoUnit.percent,
  };

  static const textRepresentations = {
    THClinoUnit.degree: 'deg',
    THClinoUnit.grad: 'grad',
    THClinoUnit.mil: 'mil',
    THClinoUnit.minute: 'minute',
    THClinoUnit.percent: 'percent',
  };

  THClinoUnitPart(this.unit);

  THClinoUnitPart.fromString(String aUnitString) {
    if (!isUnit(aUnitString)) {
      throw 'Unknown clino unit.';
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

  @override
  String toString() {
    return textRepresentations[unit]!;
  }

  static bool isUnit(String aUnitString) {
    return unitNames.containsKey(aUnitString);
  }
}
