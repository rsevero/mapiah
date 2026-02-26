// ignore_for_file: constant_identifier_names
import 'package:mapiah/src/constants/mp_constants.dart';

enum MPSetting {
  Internal_LastNewVersionCheckMS,
  Main_LocaleID,
  Main_TherionExecutablePath,
  TH2Edit_LineThickness,
  TH2Edit_PointRadius,
  TH2Edit_SelectionTolerance;

  static const Map<MPSetting, MPSettingType> types = <MPSetting, MPSettingType>{
    MPSetting.Internal_LastNewVersionCheckMS: MPSettingType.int,
    MPSetting.Main_LocaleID: MPSettingType.string,
    MPSetting.Main_TherionExecutablePath: MPSettingType.filePickerExec,
    MPSetting.TH2Edit_LineThickness: MPSettingType.double,
    MPSetting.TH2Edit_PointRadius: MPSettingType.double,
    MPSetting.TH2Edit_SelectionTolerance: MPSettingType.double,
  };

  static const Map<MPSetting, String> filePickerExecNames = <MPSetting, String>{
    MPSetting.Main_TherionExecutablePath: mpTherionExecutableName,
  };

  String section() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0) {
      throw StateError('MPSettings value has no section: $name');
    }

    return name.substring(0, underscoreIndex);
  }

  String id() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0 || underscoreIndex == name.length - 1) {
      throw StateError('MPSettings value has no id: $name');
    }

    return name.substring(underscoreIndex + 1);
  }

  MPSettingType type() {
    final MPSettingType? value = types[this];

    if (value == null) {
      throw StateError('MPSettings has no type mapping: $name');
    }

    return value;
  }

  String filePickerExecName() {
    if (type() != MPSettingType.filePickerExec) {
      throw ArgumentError(
        'MPSettings $this is not of type filePickerExec at filePickerExecName',
      );
    }

    final String? value = filePickerExecNames[this];

    if (value == null) {
      throw StateError('MPSettings has no filePickerExec mapping: $name');
    }

    return value;
  }

  @override
  String toString() => name;
}

enum MPSettingType { bool, double, filePickerExec, int, string, stringList }
