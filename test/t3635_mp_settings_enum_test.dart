// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/types/mp_new_line_creation_method.dart';
import 'package:mapiah/src/controllers/types/mp_setting_enum_definition.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_pt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  group('MPSettingsController enum settings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('uses the first enum value as the implicit default', () async {
      final MPSettingsController settingsController = MPSettingsController();

      await settingsController.initialized;

      expect(
        settingsController.getEnumWithDefault(
          MPSettingID.TH2Edit_NewLineCreationMethod,
        ),
        MPNewLineCreationMethod.mapiahQuadratic,
      );
      expect(
        settingsController.isEnumSet(MPSettingID.TH2Edit_NewLineCreationMethod),
        isFalse,
      );
      expect(
        settingsController.getEnumWithDefault(
          MPSettingID.TH2Edit_VisualizationMethod,
        ),
        MPTH2EditVisualizationMethod.mapiahPlaceholder,
      );
      expect(
        settingsController.tH2EditVisualizationMethod,
        MPTH2EditVisualizationMethod.mapiahPlaceholder,
      );
    });

    test('tH2EditVisualizationMethod reflects a stored value', () async {
      final MPSettingsController settingsController = MPSettingsController();

      await settingsController.initialized;
      settingsController.setEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );

      expect(
        settingsController.tH2EditVisualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );
    });

    test('persists and resets enumeration-backed settings', () async {
      final MPSettingsController settingsController = MPSettingsController();

      await settingsController.initialized;

      final bool isChanged = settingsController.setEnum(
        MPSettingID.TH2Edit_NewLineCreationMethod,
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      expect(isChanged, isTrue);
      expect(
        settingsController.getEnumWithDefault(
          MPSettingID.TH2Edit_NewLineCreationMethod,
        ),
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      final MPSettingsController reloadedController = MPSettingsController();

      await reloadedController.initialized;

      expect(
        reloadedController.getEnumWithDefault(
          MPSettingID.TH2Edit_NewLineCreationMethod,
        ),
        MPNewLineCreationMethod.xTherionCubicSmooth,
      );

      reloadedController.resetEnum(MPSettingID.TH2Edit_NewLineCreationMethod);

      expect(
        reloadedController.getEnumWithDefault(
          MPSettingID.TH2Edit_NewLineCreationMethod,
        ),
        MPNewLineCreationMethod.mapiahQuadratic,
      );
      expect(
        reloadedController.isEnumSet(MPSettingID.TH2Edit_NewLineCreationMethod),
        isFalse,
      );
    });

    test(
      'removes invalid stored enum values and falls back to default',
      () async {
        final MPSettingsController settingsController = MPSettingsController();

        await settingsController.initialized;

        settingsController.prefs.setString(
          MPSettingID.TH2Edit_NewLineCreationMethod.name,
          'invalidSettingValue',
        );

        final MPSettingsController reloadedController = MPSettingsController();

        await reloadedController.initialized;

        expect(
          reloadedController.getEnumWithDefault(
            MPSettingID.TH2Edit_NewLineCreationMethod,
          ),
          MPNewLineCreationMethod.mapiahQuadratic,
        );
        expect(
          reloadedController.prefs.getString(
            MPSettingID.TH2Edit_NewLineCreationMethod.name,
          ),
          isNull,
        );
      },
    );

    test('localizes enum values for the new line creation method', () {
      final MPSettingEnumDefinition enumDefinition =
          MPSettingID.TH2Edit_NewLineCreationMethod.enumDefinition();

      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsEn(),
          MPNewLineCreationMethod.mapiahQuadratic,
        ),
        'Mapiah quadratic',
      );
      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsEn(),
          MPNewLineCreationMethod.xTherionCubicSmooth,
        ),
        'xTherion cubic smooth',
      );
      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsPt(),
          MPNewLineCreationMethod.mapiahQuadratic,
        ),
        'Quadrático do Mapiah',
      );
      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsPt(),
          MPNewLineCreationMethod.xTherionCubicSmooth,
        ),
        'Cúbico suave do xTherion',
      );
    });

    test('defines every Therion visualization method', () {
      final MPSettingEnumDefinition enumDefinition =
          MPSettingID.TH2Edit_VisualizationMethod.enumDefinition();

      expect(enumDefinition.values, MPTH2EditVisualizationMethod.values);
      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsEn(),
          MPTH2EditVisualizationMethod.therionUIS,
        ),
        'Therion UIS',
      );
      expect(
        enumDefinition.localizedLabel(
          AppLocalizationsPt(),
          MPTH2EditVisualizationMethod.mapiahPlaceholder,
        ),
        'Marcador do Mapiah',
      );
    });
  });
}
