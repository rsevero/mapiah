import 'package:mapiah/src/auxiliary/mp_text_aux.dart';

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
    value = MPTextAux.convertHyphenatedToCamelCase(value);

    return THAreaType.values.byName(value);
  }

  String toFileString() {
    return MPTextAux.convertCamelCaseToHyphenated(name);
  }
}
