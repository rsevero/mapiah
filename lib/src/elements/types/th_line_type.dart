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
  pitChimney,
  pitch,
  pit,
  rimstoneDam,
  rimstonePool,
  rockBorder,
  rockEdge,
  ropeLadder,
  rope,
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
    final String modifiedValue = value.replaceAllMapped(
      RegExp(r'-[a-z]'),
      (Match match) => match.group(0)![1].toUpperCase(),
    );

    return THLineType.values.byName(modifiedValue);
  }

  String toFileString() {
    return name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '-${match.group(0)!.toLowerCase()}',
    );
  }
}
