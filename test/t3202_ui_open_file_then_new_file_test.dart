// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('UI: open file then create new file', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
    });

    testWidgets(
      'creating new file while a file is already open must not duplicate TH2FileTabsPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        /// Pump the full app
        await tester.pumpWidget(const MapiahApp());
        await tester.pumpAndSettle();

        /// Load a file and register it with the general controller
        final String testFilename = THTestAux.testPath(
          '2025-10-07-002-point.th2',
        );
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        /// Add the file tab and navigate to the tabs page, simulating opening a
        /// file via the file picker.
        mpLocator.mpGeneralController.addFileTab(testFilename);
        mpLocator.mpNavigatorKey.currentState?.push(
          MaterialPageRoute<void>(builder: (_) => const TH2FileTabsPage()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TH2FileTabsPage), findsOneWidget);

        /// Tap the "New file" button in the TH2FileTabsPage AppBar
        final Finder newFileButton = find.byKey(
          const ValueKey('TH2FileTabsPageNewFileButton'),
        );
        expect(newFileButton, findsOneWidget);
        await tester.tap(newFileButton);
        await tester.pumpAndSettle();

        /// Tap OK to create the new file with default values
        final Finder okButton = find.widgetWithText(ElevatedButton, 'OK');
        expect(okButton, findsOneWidget);
        await tester.ensureVisible(okButton);
        await tester.pump();
        await tester.tap(okButton);
        await tester.pumpAndSettle();

        /// There must be exactly one TH2FileTabsPage in the widget tree —
        /// not two. A second push would cause duplicate GlobalKey errors.
        expect(find.byType(TH2FileTabsPage), findsOneWidget);

        /// Both files should be registered as open tabs
        expect(mpLocator.mpGeneralController.openFileOrder.length, 2);
      },
    );
  });
}
