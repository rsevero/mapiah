import 'package:dart_mappable/dart_mappable.dart';

part 'th_clino_unit_part.mapper.dart';

@MappableEnum()
enum THClinoUnit {
  degree,
  grad,
  mil,
  minute,
  percent,
}

@MappableClass()
class THClinoUnitPart with THClinoUnitPartMappable {
  late THClinoUnit unit;

  static const stringToUnit = {
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

  static const unitToString = {
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
