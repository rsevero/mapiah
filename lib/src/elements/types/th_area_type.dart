import 'package:mapiah/src/auxiliary/mp_type_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

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
  unknown,
  water;

  static final Set<String> nameSet = {
    for (final t in THAreaType.values) t.name,
  };

  static bool hasAreaType(String areaType) {
    final String normalizedPLAType = MPTypeAux.convertHyphenatedToCamelCase(
      areaType,
    );

    if (normalizedPLAType == mpUnknownPLAType) {
      return false;
    }

    return nameSet.contains(normalizedPLAType);
  }

  static THAreaType fromFileString(String value) {
    if (hasAreaType(value)) {
      value = MPTypeAux.convertHyphenatedToCamelCase(value);

      return THAreaType.values.byName(value);
    } else {
      return THAreaType.unknown;
    }
  }

  String toFileString() {
    return MPTypeAux.convertCamelCaseToHyphenated(name);
  }
}
