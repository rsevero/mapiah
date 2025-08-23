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

  static final Set<String> nameSet = {
    for (final t in THAreaType.values) t.name,
  };

  static bool hasAreaType(String areaType) {
    final String normalizedPLAType = MPTypeAux.convertHyphenatedToCamelCase(
      areaType,
    );

    return nameSet.contains(normalizedPLAType);
  }

  static THAreaType fromFileString(String value) {
    if (!hasAreaType(value)) {
      throw ArgumentError(
        'At THAreaType.fromFileString: Invalid area type: $value',
      );
    }

    value = MPTypeAux.convertHyphenatedToCamelCase(value);

    return THAreaType.values.byName(value);
  }

  String toFileString() {
    return MPTypeAux.convertCamelCaseToHyphenated(name);
  }
}
