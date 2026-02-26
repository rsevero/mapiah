// ignore_for_file: constant_identifier_names
import 'package:mapiah/src/constants/mp_constants.dart';

enum MPSettingType {
  Internal_LastNewVersionCheckMS,
  Main_LocaleID,
  Main_TherionExecutablePath,
  TH2Edit_LineThickness,
  TH2Edit_PointRadius,
  TH2Edit_SelectionTolerance;

  static const Map<MPSettingType, MPSettingTypeType> types =
      <MPSettingType, MPSettingTypeType>{
        MPSettingType.Internal_LastNewVersionCheckMS: MPSettingTypeType.int,
        MPSettingType.Main_LocaleID: MPSettingTypeType.string,
        MPSettingType.Main_TherionExecutablePath:
            MPSettingTypeType.filePickerExec,
        MPSettingType.TH2Edit_LineThickness: MPSettingTypeType.double,
        MPSettingType.TH2Edit_PointRadius: MPSettingTypeType.double,
        MPSettingType.TH2Edit_SelectionTolerance: MPSettingTypeType.double,
      };

  static const Map<MPSettingType, String> filePickerExecNames =
      <MPSettingType, String>{
        MPSettingType.Main_TherionExecutablePath: mpTherionExecutableName,
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

  MPSettingTypeType type() {
    final MPSettingTypeType? value = types[this];

    if (value == null) {
      throw StateError('MPSettingsType has no type mapping: $name');
    }

    return value;
  }

  String filePickerExecName() {
    if (type() != MPSettingTypeType.filePickerExec) {
      throw ArgumentError(
        'MPSettingsType $this is not of type filePickerExec at filePickerExecName',
      );
    }

    final String? value = filePickerExecNames[this];

    if (value == null) {
      throw StateError('MPSettingsType has no filePickerExec mapping: $name');
    }

    return value;
  }

  @override
  String toString() => name;
}

enum MPSettingTypeType { bool, double, filePickerExec, int, string, stringList }
