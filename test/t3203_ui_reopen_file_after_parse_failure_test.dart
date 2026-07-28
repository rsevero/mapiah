// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    await mpLocator.mpSettingsController.initialized;
  });

  testWidgets('reopening a corrected file parses its current contents', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;

    final String filename = '/tmp/mapiah-reopen-after-parse-failure.th2';
    final Uint8List invalidFileBytes = Uint8List.fromList(
      utf8.encode(
        'encoding utf-8\n'
        'point 42 91 scallop:winter\n',
      ),
    );
    final Uint8List correctedFileBytes = Uint8List.fromList(
      utf8.encode(
        'encoding utf-8\n'
        'scrap corrected\n'
        'endscrap\n',
      ),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final TH2FileEditController persistentController = mpLocator
        .mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: 'persistent',
          scrapOptions: const [],
          encoding: mpDefaultEncoding,
        );
    final TH2FileEditController failedController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(
          filename: filename,
          fileBytes: invalidFileBytes,
        );

    mpLocator.mpGeneralController.addFileTab(
      persistentController.th2File.filename,
    );
    mpLocator.mpGeneralController.addFileTab(filename);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const TH2FileTabsPage(),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MPErrorDialog), findsOneWidget);
    expect(failedController.errorMessages, isNotEmpty);

    await tester.tap(find.text(mpLocator.appLocalizations.buttonClose));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
        filename,
      ),
      isNull,
    );

    final TH2FileEditController correctedController = mpLocator
        .mpGeneralController
        .getTH2FileEditController(
          filename: filename,
          fileBytes: correctedFileBytes,
        );

    mpLocator.mpGeneralController.addFileTab(filename);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MPErrorDialog), findsNothing);
    expect(correctedController.isFileLoaded, isTrue);
    expect(correctedController.errorMessages, isEmpty);
    expect(correctedController.currentScrapName, 'corrected');
  });
}
