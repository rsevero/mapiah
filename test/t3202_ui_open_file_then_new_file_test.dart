// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Size;

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
      'adding files while one is already open keeps one root tabs page',
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

        /// Add the first file tab. The tabs page is already the app root.
        mpLocator.mpGeneralController.addFileTab(testFilename);
        await tester.pumpAndSettle();

        expect(find.byType(TH2FileTabsPage), findsOneWidget);

        const String secondFilename = '/tmp/mapiah-second-root-tab.th2';
        final TH2FileEditController secondController = mpLocator
            .mpGeneralController
            .getTH2FileEditController(
              filename: secondFilename,
              fileBytes: Uint8List.fromList(
                utf8.encode(
                  'encoding utf-8\n'
                  'scrap second-root-tab\n'
                  'endscrap\n',
                ),
              ),
            );

        mpLocator.mpGeneralController.addFileTab(secondFilename);
        await tester.pumpAndSettle();

        expect(find.byType(TH2FileTabsPage), findsOneWidget);
        expect(mpLocator.mpGeneralController.openFileOrder.length, 2);

        secondController.close();
        th2Controller.close();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'closing and reopening a tab keeps the root tabs page mounted',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const MapiahApp());
        await tester.pumpAndSettle();

        const String filename = '/tmp/mapiah-route-overlap.th2';
        final Uint8List fileBytes = Uint8List.fromList(
          utf8.encode(
            'encoding utf-8\n'
            'scrap route-overlap\n'
            'endscrap\n',
          ),
        );
        final TH2FileEditController firstController = mpLocator
            .mpGeneralController
            .getTH2FileEditController(
              filename: filename,
              fileBytes: fileBytes,
            );
        mpLocator.mpGeneralController.addFileTab(filename);
        await tester.pumpAndSettle();

        firstController.close();
        await tester.pump();

        final TH2FileEditController secondController = mpLocator
            .mpGeneralController
            .getTH2FileEditController(
              filename: filename,
              fileBytes: fileBytes,
            );
        mpLocator.mpGeneralController.addFileTab(filename);
        await tester.pumpAndSettle();

        expect(find.byType(TH2FileTabsPage), findsOneWidget);
        expect(
          mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
            filename,
          ),
          same(secondController),
        );

        secondController.close();
        await tester.pumpAndSettle();
      },
    );
  });
}
