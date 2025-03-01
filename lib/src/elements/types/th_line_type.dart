import 'package:mapiah/src/auxiliary/mp_type_aux.dart';

enum THLineType {
  abyssEntrance,
  arrow,
  border,
  ceilingMeander,
  ceilingStep,
  chimney,
  contour,
  dripline,
  fault,
  fixedLadder,
  floorMeander,
  floorStep,
  flowstone,
  gradient,
  handrail,
  joint,
  label,
  lowCeiling,
  mapConnection,
  moonmilk,
  overhang,
  pit,
  pitch,
  pitChimney,
  rimstoneDam,
  rimstonePool,
  rockBorder,
  rockEdge,
  rope,
  ropeLadder,
  section,
  slope,
  steps,
  survey,
  u,
  viaFerrata,
  walkWay,
  wall,
  waterFlow;

  static THLineType fromFileString(String value) {
    value = MPTypeAux.convertHyphenatedToCamelCase(value);

    return THLineType.values.byName(value);
  }

  String toFileString() {
    return MPTypeAux.convertCamelCaseToHyphenated(name);
  }
}
