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
    final String modifiedValue = value.replaceAllMapped(
      RegExp(r'-[a-z]'),
      (Match match) => match.group(0)![1].toUpperCase(),
    );

    return THAreaType.values.byName(modifiedValue);
  }

  String toFileString() {
    return name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '-${match.group(0)!.toLowerCase()}',
    );
  }
}
