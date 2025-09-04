import 'package:mapiah/src/auxiliary/mp_type_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

enum THPointType {
  airDraught,
  altar,
  altitude,
  anastomosis,
  anchor,
  aragonite,
  archeoExcavation,
  archeoMaterial,
  audio,
  bat,
  bedrock,
  blocks,
  bones,
  breakdownChoke,
  bridge,
  camp,
  cavePearl,
  clay,
  clayChoke,
  clayTree,
  continuation,
  crystal,
  curtain,
  curtains,
  danger,
  date,
  debris,
  dig,
  dimensions,
  discPillar,
  discPillars,
  discStalactite,
  discStalactites,
  discStalagmite,
  discStalagmites,
  disk,
  electricLight,
  entrance,
  extra,
  exVoto,
  fixedLadder,
  flowstone,
  flowstoneChoke,
  flute,
  gate,
  gradient,
  guano,
  gypsum,
  gypsumFlower,
  handrail,
  height,
  helictite,
  helictites,
  humanBones,
  ice,
  icePillar,
  iceStalactite,
  iceStalagmite,
  karren,
  label,
  lowEnd,
  mapConnection,
  masonry,
  moonmilk,
  mud,
  mudcrack,
  namePlate,
  narrowEnd,
  noEquipment,
  noWheelchair,
  paleoMaterial,
  passageHeight,
  pebbles,
  pendant,
  photo,
  pillar,
  pillarsWithCurtains,
  pillarWithCurtains,
  popcorn,
  raft,
  raftCone,
  remark,
  rimstoneDam,
  rimstonePool,
  root,
  rope,
  ropeLadder,
  sand,
  scallop,
  section,
  seedGermination,
  sink,
  snow,
  sodaStraw,
  spring,
  stalactite,
  stalactites,
  stalactitesStalagmites,
  stalactiteStalagmite,
  stalagmite,
  stalagmites,
  station,
  stationName,
  steps,
  traverse,
  treeTrunk,
  u,
  unknown,
  vegetableDebris,
  viaFerrata,
  volcano,
  walkway,
  wallCalcite,
  water,
  waterDrip,
  waterFlow,
  wheelchair;

  static final Set<String> nameSet = {
    for (final t in THPointType.values) t.name,
  };

  static bool hasPointType(String pointType) {
    final String normalizedPLAType = MPTypeAux.convertHyphenatedToCamelCase(
      pointType,
    );

    if (normalizedPLAType == mpUnknownPLAType) {
      return false;
    }

    return nameSet.contains(normalizedPLAType);
  }

  static THPointType fromString(String value) {
    if (hasPointType(value)) {
      value = MPTypeAux.convertHyphenatedToCamelCase(value);

      return THPointType.values.byName(value);
    } else {
      return THPointType.unknown;
    }
  }

  static String unknownPLATypeFromString(String value) {
    return hasPointType(value) ? '' : value;
  }

  String toFileString() {
    return MPTypeAux.convertCamelCaseToHyphenated(name);
  }
}
