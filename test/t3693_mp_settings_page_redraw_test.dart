// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';

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
}
