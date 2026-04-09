// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/types/mp_new_line_creation_method.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  // Each test creates its own fresh MPSettingsController so there is no
  // cross-test contamination via the singleton.
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  Future<MPSettingsController> freshController() async {
    final MPSettingsController controller = MPSettingsController();

    await controller.initialized;

    return controller;
  }

  // ---------------------------------------------------------------------------
  // Bool
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setBool always persists', () {
    test(
      'Therion_DebugLog1 defaults to false before any explicit write',
      () async {
        final MPSettingsController ctrl = await freshController();

        expect(ctrl.isBoolSet(MPSettingID.Therion_DebugLog1), isFalse);
        expect(ctrl.getBoolWithDefault(MPSettingID.Therion_DebugLog1), isFalse);
      },
    );

    test(
      'setting a bool to its implicit default (false) marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        expect(
          ctrl.isBoolSet(MPSettingID.Main_TelemetryConsent),
          isFalse,
          reason: 'should be unset before any explicit write',
        );

        final bool isChanged = ctrl.setBool(
          MPSettingID.Main_TelemetryConsent,
          mpDefaultDefaultBoolSetting,
        );

        expect(
          ctrl.isBoolSet(MPSettingID.Main_TelemetryConsent),
          isTrue,
          reason:
              'explicit write must be stored even when value equals default',
        );
        expect(
          ctrl.getBoolIfSet(MPSettingID.Main_TelemetryConsent),
          mpDefaultDefaultBoolSetting,
        );
        expect(
          isChanged,
          isFalse,
          reason: 'value did not change, so observers should not fire',
        );
      },
    );

    test(
      'setting a bool to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setBool(
          MPSettingID.Main_TelemetryConsent,
          true,
        );

        expect(ctrl.isBoolSet(MPSettingID.Main_TelemetryConsent), isTrue);
        expect(ctrl.getBoolIfSet(MPSettingID.Main_TelemetryConsent), isTrue);
        expect(isChanged, isTrue);
      },
    );

    test(
      'setting Therion_DebugLog1 to false still marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setBool(
          MPSettingID.Therion_DebugLog1,
          false,
        );

        expect(ctrl.isBoolSet(MPSettingID.Therion_DebugLog1), isTrue);
        expect(ctrl.getBoolIfSet(MPSettingID.Therion_DebugLog1), isFalse);
        expect(isChanged, isFalse);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Int
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setInt always persists', () {
    test(
      'setting an int to its implicit default (0) marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        expect(
          ctrl.isIntSet(MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount),
          isFalse,
        );

        final bool isChanged = ctrl.setInt(
          MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
          mpDefaultDefaultIntSetting,
        );

        expect(
          ctrl.isIntSet(MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount),
          isTrue,
        );
        expect(
          ctrl.getIntIfSet(
            MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
          ),
          mpDefaultDefaultIntSetting,
        );
        expect(isChanged, isFalse);
      },
    );

    test(
      'setting an int to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setInt(
          MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
          5,
        );

        expect(
          ctrl.isIntSet(MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount),
          isTrue,
        );
        expect(
          ctrl.getIntWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
          ),
          5,
        );
        expect(isChanged, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Double
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setDouble always persists', () {
    test(
      'new TH2 edit nudge factor uses its explicit default before any write',
      () async {
        final MPSettingsController ctrl = await freshController();

        expect(ctrl.isDoubleSet(MPSettingID.TH2Edit_NudgeFactor), isFalse);
        expect(
          ctrl.getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor),
          mpDefaultNudgeFactor,
        );
      },
    );

    test(
      'setting a double to its explicit default marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        // TH2Edit_LineThickness has mpDefaultLineThickness as its default.
        expect(ctrl.isDoubleSet(MPSettingID.TH2Edit_LineThickness), isFalse);

        final bool isChanged = ctrl.setDouble(
          MPSettingID.TH2Edit_LineThickness,
          mpDefaultLineThickness,
        );

        expect(ctrl.isDoubleSet(MPSettingID.TH2Edit_LineThickness), isTrue);
        expect(
          ctrl.getDoubleIfSet(MPSettingID.TH2Edit_LineThickness),
          mpDefaultLineThickness,
        );
        expect(isChanged, isFalse);
      },
    );

    test(
      'setting a double to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setDouble(
          MPSettingID.TH2Edit_LineThickness,
          mpDefaultLineThickness + 1.0,
        );

        expect(ctrl.isDoubleSet(MPSettingID.TH2Edit_LineThickness), isTrue);
        expect(
          ctrl.getDoubleWithDefault(MPSettingID.TH2Edit_LineThickness),
          mpDefaultLineThickness + 1.0,
        );
        expect(isChanged, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // String
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setString always persists', () {
    test(
      'setting a string to its explicit default marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        // Main_LocaleID has mpDefaultLocaleID ('sys') as its default.
        expect(ctrl.isStringSet(MPSettingID.Main_LocaleID), isFalse);

        final bool isChanged = ctrl.setString(
          MPSettingID.Main_LocaleID,
          mpDefaultLocaleID,
        );

        expect(ctrl.isStringSet(MPSettingID.Main_LocaleID), isTrue);
        expect(
          ctrl.getStringIfSet(MPSettingID.Main_LocaleID),
          mpDefaultLocaleID,
        );
        expect(isChanged, isFalse);
      },
    );

    test(
      'setting a string to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setString(MPSettingID.Main_LocaleID, 'pt');

        expect(ctrl.isStringSet(MPSettingID.Main_LocaleID), isTrue);
        expect(ctrl.getStringWithDefault(MPSettingID.Main_LocaleID), 'pt');
        expect(isChanged, isTrue);
      },
    );
  });

  group('MPSettingsController — legacy Therion setting names', () {
    test('reads legacy executable-path key into renamed setting', () async {
      final Map<String, Object> initialValues = <String, Object>{
        'Main_TherionExecutablePath': '/legacy/therion',
      };

      SharedPreferences.setMockInitialValues(initialValues);
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(initialValues);

      final MPSettingsController ctrl = await freshController();

      expect(ctrl.isStringSet(MPSettingID.Therion_ExecutablePath), isTrue);
      expect(
        ctrl.getStringIfSet(MPSettingID.Therion_ExecutablePath),
        '/legacy/therion',
      );
    });

    test('reads legacy run-parameters key into renamed setting', () async {
      final Map<String, Object> initialValues = <String, Object>{
        'Main_TherionRunParameters': '-d -q',
      };

      SharedPreferences.setMockInitialValues(initialValues);
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(initialValues);

      final MPSettingsController ctrl = await freshController();

      expect(ctrl.isStringSet(MPSettingID.Therion_RunParameters), isTrue);
      expect(ctrl.getStringIfSet(MPSettingID.Therion_RunParameters), '-d -q');
    });

    test(
      'prefers renamed key when both renamed and legacy keys exist',
      () async {
        final Map<String, Object> initialValues = <String, Object>{
          'Therion_RunParameters': '-new',
          'Main_TherionRunParameters': '-old',
        };

        SharedPreferences.setMockInitialValues(initialValues);
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData(initialValues);

        final MPSettingsController ctrl = await freshController();

        expect(ctrl.getStringIfSet(MPSettingID.Therion_RunParameters), '-new');
      },
    );
  });

  // ---------------------------------------------------------------------------
  // StringList
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setStringList always persists', () {
    test('setting a stringList to its implicit default ([]) marks it as '
        'explicitly set', () async {
      final MPSettingsController ctrl = await freshController();

      expect(
        ctrl.isStringListSet(MPSettingID.Internal_TelemetryPendingRecords),
        isFalse,
      );

      final bool isChanged = ctrl.setStringList(
        MPSettingID.Internal_TelemetryPendingRecords,
        List<String>.from(mpDefaultDefaultStringListSetting),
      );

      expect(
        ctrl.isStringListSet(MPSettingID.Internal_TelemetryPendingRecords),
        isTrue,
      );
      expect(
        ctrl.getStringListWithDefault(
          MPSettingID.Internal_TelemetryPendingRecords,
        ),
        isEmpty,
      );
      expect(isChanged, isFalse);
    });

    test(
      'setting a stringList to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setStringList(
          MPSettingID.Internal_TelemetryPendingRecords,
          <String>['record1'],
        );

        expect(
          ctrl.isStringListSet(MPSettingID.Internal_TelemetryPendingRecords),
          isTrue,
        );
        expect(
          ctrl.getStringListWithDefault(
            MPSettingID.Internal_TelemetryPendingRecords,
          ),
          <String>['record1'],
        );
        expect(isChanged, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Enum
  // ---------------------------------------------------------------------------

  group('MPSettingsController — setEnum always persists', () {
    test(
      'setting an enum to its implicit default marks it as explicitly set',
      () async {
        final MPSettingsController ctrl = await freshController();

        // The first enum value is the implicit default for
        // TH2Edit_NewLineCreationMethod.
        expect(
          ctrl.isEnumSet(MPSettingID.TH2Edit_NewLineCreationMethod),
          isFalse,
        );

        final bool isChanged = ctrl.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.mapiahQuadratic,
        );

        expect(
          ctrl.isEnumSet(MPSettingID.TH2Edit_NewLineCreationMethod),
          isTrue,
        );
        expect(
          ctrl.getEnumWithDefault(MPSettingID.TH2Edit_NewLineCreationMethod),
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        expect(isChanged, isFalse);
      },
    );

    test(
      'setting an enum to a non-default value is changed and stored',
      () async {
        final MPSettingsController ctrl = await freshController();

        final bool isChanged = ctrl.setEnum(
          MPSettingID.TH2Edit_NewLineCreationMethod,
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );

        expect(
          ctrl.isEnumSet(MPSettingID.TH2Edit_NewLineCreationMethod),
          isTrue,
        );
        expect(
          ctrl.getEnumWithDefault(MPSettingID.TH2Edit_NewLineCreationMethod),
          MPNewLineCreationMethod.xTherionCubicSmooth,
        );
        expect(isChanged, isTrue);
      },
    );
  });
}
