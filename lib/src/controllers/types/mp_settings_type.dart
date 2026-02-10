// ignore_for_file: constant_identifier_names

enum MPSettingsType {
  Internal_LastNewVersionCheckMS,
  Main_LocaleID,
  TH2Edit_LineThickness,
  TH2Edit_PointRadius,
  TH2Edit_SelectionTolerance;

  static const Map<MPSettingsType, MPSettingsTypeType> types =
      <MPSettingsType, MPSettingsTypeType>{
        MPSettingsType.Internal_LastNewVersionCheckMS: MPSettingsTypeType.int,
        MPSettingsType.Main_LocaleID: MPSettingsTypeType.string,
        MPSettingsType.TH2Edit_LineThickness: MPSettingsTypeType.double,
        MPSettingsType.TH2Edit_PointRadius: MPSettingsTypeType.double,
        MPSettingsType.TH2Edit_SelectionTolerance: MPSettingsTypeType.double,
      };

  String section() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0) {
      throw StateError('MPSettingsType value has no section: $name');
    }

    return name.substring(0, underscoreIndex);
  }

  String id() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0 || underscoreIndex == name.length - 1) {
      throw StateError('MPSettingsType value has no id: $name');
    }

    return name.substring(underscoreIndex + 1);
  }

  MPSettingsTypeType type() {
    final MPSettingsTypeType? value = types[this];

    if (value == null) {
      throw StateError('MPSettingsType has no type mapping: $name');
    }

    return value;
  }

  @override
  String toString() => name;
}

enum MPSettingsTypeType { bool, double, int, string, stringList }
