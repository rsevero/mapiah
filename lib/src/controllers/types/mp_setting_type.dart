// ignore_for_file: constant_identifier_names
import 'package:mapiah/src/constants/mp_constants.dart';

enum MPSettingID {
  Internal_LastNewVersionCheckMS,
  Main_LocaleID,
  Main_TherionExecutablePath,
  TH2Edit_LineThickness,
  TH2Edit_PointRadius,
  TH2Edit_SelectionTolerance;

  static const Map<MPSettingID, MPSettingType> types =
      <MPSettingID, MPSettingType>{
        MPSettingID.Internal_LastNewVersionCheckMS: MPSettingType.int,
        MPSettingID.Main_LocaleID: MPSettingType.string,
        MPSettingID.Main_TherionExecutablePath: MPSettingType.filePickerExec,
        MPSettingID.TH2Edit_LineThickness: MPSettingType.double,
        MPSettingID.TH2Edit_PointRadius: MPSettingType.double,
        MPSettingID.TH2Edit_SelectionTolerance: MPSettingType.double,
      };

  static const Map<MPSettingID, String> filePickerExecNames =
      <MPSettingID, String>{
        MPSettingID.Main_TherionExecutablePath: mpTherionExecutableName,
      };

  String section() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0) {
      throw StateError('MPSettingID value has no section: $name');
    }

    return name.substring(0, underscoreIndex);
  }

  String id() {
    final int underscoreIndex = name.indexOf('_');

    if (underscoreIndex <= 0 || underscoreIndex == name.length - 1) {
      throw StateError('MPSettingID value has no id: $name');
    }

    return name.substring(underscoreIndex + 1);
  }

  MPSettingType type() {
    final MPSettingType? value = types[this];

    if (value == null) {
      throw StateError('MPSettingID has no type mapping: $name');
    }

    return value;
  }

  String filePickerExecName() {
    if (type() != MPSettingType.filePickerExec) {
      throw ArgumentError(
        'MPSettingID $this is not of type filePickerExec at filePickerExecName',
      );
    }

    final String? value = filePickerExecNames[this];

    if (value == null) {
      throw StateError('MPSettingID has no filePickerExec mapping: $name');
    }

    return value;
  }

  @override
  String toString() => name;
}

enum MPSettingType { bool, double, filePickerExec, int, string, stringList }
