// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
// ignore_for_file: constant_identifier_names
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_new_line_creation_method.dart';
import 'package:mapiah/src/controllers/types/mp_setting_enum_definition.dart';

enum MPSettingID {
  Internal_DefaultAreaOptions,
  Internal_DefaultLineOptions,
  Internal_DefaultPointOptions,
  Internal_LastCheckNumberOfNewerVersions,
  Internal_LastNewVersionCheckMS,
  Internal_TelemetryCurrentDate,
  Internal_TelemetryCurrentDayTH2Files,
  Internal_TelemetryCurrentDayTH2OpenCount,
  Internal_TelemetryCurrentDayTH2TimeSecs,
  Internal_TelemetryCurrentDayTHConfigFiles,
  Internal_TelemetryCurrentDayTherionRunCount,
  Internal_TelemetryCurrentDayTherionTimeSecs,
  Internal_TelemetryPendingRecords,
  Main_LocaleID,
  Main_TelemetryConsent,
  Main_TherionExecutablePath,
  Main_TherionRunParameters,
  TH2Edit_LineThickness,
  TH2Edit_NewLineCreationMethod,
  TH2Edit_PointRadius,
  TH2Edit_RotationSnapAngle,
  TH2Edit_SelectionTolerance,
  TH2Edit_ShowDirectionTicksOnNonSelectedLines;

  static const Map<MPSettingID, MPSettingType>
  types = <MPSettingID, MPSettingType>{
    MPSettingID.Internal_DefaultAreaOptions: MPSettingType.stringList,
    MPSettingID.Internal_DefaultLineOptions: MPSettingType.stringList,
    MPSettingID.Internal_DefaultPointOptions: MPSettingType.stringList,
    MPSettingID.Internal_LastCheckNumberOfNewerVersions: MPSettingType.int,
    MPSettingID.Internal_LastNewVersionCheckMS: MPSettingType.int,
    MPSettingID.Internal_TelemetryCurrentDate: MPSettingType.string,
    MPSettingID.Internal_TelemetryCurrentDayTH2Files: MPSettingType.stringList,
    MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount: MPSettingType.int,
    MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs: MPSettingType.int,
    MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles:
        MPSettingType.stringList,
    MPSettingID.Internal_TelemetryCurrentDayTherionRunCount: MPSettingType.int,
    MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs: MPSettingType.int,
    MPSettingID.Internal_TelemetryPendingRecords: MPSettingType.stringList,
    MPSettingID.Main_LocaleID: MPSettingType.string,
    MPSettingID.Main_TelemetryConsent: MPSettingType.bool,
    MPSettingID.Main_TherionExecutablePath: MPSettingType.filePickerExec,
    MPSettingID.Main_TherionRunParameters: MPSettingType.string,
    MPSettingID.TH2Edit_LineThickness: MPSettingType.double,
    MPSettingID.TH2Edit_NewLineCreationMethod: MPSettingType.enumeration,
    MPSettingID.TH2Edit_PointRadius: MPSettingType.double,
    MPSettingID.TH2Edit_RotationSnapAngle: MPSettingType.double,
    MPSettingID.TH2Edit_SelectionTolerance: MPSettingType.double,
    MPSettingID.TH2Edit_ShowDirectionTicksOnNonSelectedLines:
        MPSettingType.bool,
  };

  static const Map<MPSettingID, String> filePickerExecNames =
      <MPSettingID, String>{
        MPSettingID.Main_TherionExecutablePath: mpTherionExecutableName,
      };

  static final Map<MPSettingID, MPSettingEnumDefinition>
  enumDefinitions = <MPSettingID, MPSettingEnumDefinition>{
    MPSettingID.TH2Edit_NewLineCreationMethod:
        MPSettingEnumDefinitionImpl<MPNewLineCreationMethod>(
          enumValues: MPNewLineCreationMethod.values,
          parser: (String storedValue) {
            try {
              return MPNewLineCreationMethod.values.byName(storedValue);
            } on ArgumentError {
              return null;
            }
          },
          localizedLabelBuilder:
              (appLocalizations, MPNewLineCreationMethod value) {
                switch (value) {
                  case MPNewLineCreationMethod.mapiahQuadratic:
                    return appLocalizations
                        .mpSettingsEnumNewLineCreationMethodMapiahQuadratic;
                  case MPNewLineCreationMethod.xTherionCubicSmooth:
                    return appLocalizations
                        .mpSettingsEnumNewLineCreationMethodXTherionCubicSmooth;
                }
              },
        ),
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

  MPSettingEnumDefinition enumDefinition() {
    if (type() != MPSettingType.enumeration) {
      throw ArgumentError(
        'MPSettingID $this is not of type enumeration at enumDefinition',
      );
    }

    final MPSettingEnumDefinition? value = enumDefinitions[this];

    if (value == null) {
      throw StateError('MPSettingID has no enum mapping: $name');
    }

    return value;
  }

  @override
  String toString() => name;
}

enum MPSettingType {
  bool,
  double,
  enumeration,
  filePickerExec,
  int,
  string,
  stringList,
}
