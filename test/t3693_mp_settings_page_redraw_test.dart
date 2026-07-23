// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  setUpAll(() async {
    await mpLocator.mpSettingsController.initialized;
  });

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  testWidgets('save and close redraws every open TH2 drawing', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController firstController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-redraw-first.th2');
    final TH2FileEditController secondController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-redraw-second.th2');
    final int firstRedrawTrigger = firstController.redrawTriggerAllElements;
    final int secondRedrawTrigger = secondController.redrawTriggerAllElements;

    await tester.pumpWidget(const MaterialApp(home: MPSettingsPage()));
    await tester.tap(
      find.text(mpLocator.appLocalizations.mpButtonSaveAndClose),
    );
    await tester.pump();

    expect(
      firstController.redrawTriggerAllElements,
      firstRedrawTrigger + 1,
    );
    expect(
      secondController.redrawTriggerAllElements,
      secondRedrawTrigger + 1,
    );
  });

  testWidgets('apply redraws every open TH2 drawing', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController firstController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-apply-first.th2');
    final TH2FileEditController secondController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-apply-second.th2');
    final int firstRedrawTrigger = firstController.redrawTriggerAllElements;
    final int secondRedrawTrigger = secondController.redrawTriggerAllElements;

    await tester.pumpWidget(const MaterialApp(home: MPSettingsPage()));
    await tester.tap(find.text(mpLocator.appLocalizations.mpButtonApply));
    await tester.pump();

    expect(
      firstController.redrawTriggerAllElements,
      firstRedrawTrigger + 1,
    );
    expect(
      secondController.redrawTriggerAllElements,
      secondRedrawTrigger + 1,
    );
  });

  testWidgets('reset all settings redraws every open TH2 drawing', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController firstController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-reset-first.th2');
    final TH2FileEditController secondController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'settings-reset-second.th2');
    final int firstRedrawTrigger = firstController.redrawTriggerAllElements;
    final int secondRedrawTrigger = secondController.redrawTriggerAllElements;

    await tester.pumpWidget(const MaterialApp(home: MPSettingsPage()));
    await tester.tap(
      find.text(mpLocator.appLocalizations.mpButtonResetAllSettings),
    );
    await tester.pump();

    expect(
      firstController.redrawTriggerAllElements,
      firstRedrawTrigger + 1,
    );
    expect(
      secondController.redrawTriggerAllElements,
      secondRedrawTrigger + 1,
    );
  });

  testWidgets('direction-tick shortcut redraws every open TH2 drawing', (
    WidgetTester tester,
  ) async {
    final TH2FileEditController firstController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(
          filename: THTestAux.testPath(
            '2026-02-17-001-slope_straight_line.th2',
          ),
        );
    final TH2FileEditController secondController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(filename: 'shortcut-redraw-second.th2');

    await tester.runAsync(() async {
      await firstController.load();
    });
    await tester.pumpWidget(
      buildTH2FileTabsPageTestApp(th2FileEditController: firstController),
    );
    await tester.pump();

    final bool initialSetting = mpLocator.mpSettingsController
        .getBoolWithDefault(
          MPSettingID.TH2Edit_ShowDirectionTicksOnNonSelectedLines,
        );
    final int firstRedrawTrigger = firstController.redrawTriggerAllElements;
    final int secondRedrawTrigger = secondController.redrawTriggerAllElements;

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(
      mpLocator.mpSettingsController.getBoolWithDefault(
        MPSettingID.TH2Edit_ShowDirectionTicksOnNonSelectedLines,
      ),
      !initialSetting,
    );
    expect(
      firstController.redrawTriggerAllElements,
      firstRedrawTrigger + 1,
    );
    expect(
      secondController.redrawTriggerAllElements,
      secondRedrawTrigger + 1,
    );
  });
}
