import 'package:mapiah/src/auxiliary/mp_type_aux.dart';

enum THAreaType {
  bedrock,
  blocks,
  clay,
  debris,
  flowstone,
  ice,
  moonmilk,
  mudcrack,
  pebbles,
  pillar,
  pillars,
  pillarsWithCurtains,
  pillarWithCurtains,
  sand,
  snow,
  stalactite,
  stalactiteStalagmite,
  stalagmite,
  sump,
  u,
  water;

  static THAreaType fromFileString(String value) {
    value = MPTypeAux.convertHyphenatedToCamelCase(value);

    return THAreaType.values.byName(value);
  }

  String toFileString() {
    return MPTypeAux.convertCamelCaseToHyphenated(name);
  }
}
