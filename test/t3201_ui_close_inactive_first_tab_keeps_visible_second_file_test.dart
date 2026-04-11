// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

  group('UI: close inactive first tab while second tab is visible', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
    });

    testWidgets('visible file must stay aligned with the remaining tab', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController firstController = mpLocator
          .mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-first',
            scrapOptions: const [],
            encoding: mpDefaultEncoding,
          );
      final TH2FileEditController secondController = mpLocator
          .mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-second',
            scrapOptions: const [],
            encoding: mpDefaultEncoding,
          );
      final String firstTabLabel = p.basenameWithoutExtension(
        firstController.th2File.filename,
      );
      final String secondTabLabel = p.basenameWithoutExtension(
        secondController.th2File.filename,
      );

      mpLocator.mpGeneralController.addFileTab(
        firstController.th2File.filename,
      );
      mpLocator.mpGeneralController.addFileTab(
        secondController.th2File.filename,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TH2FileTabsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('scrap-second'), findsOneWidget);
      expect(find.text('scrap-first'), findsNothing);

      final Finder closeButtons = find.byTooltip('Close file');
      expect(closeButtons, findsNWidgets(2));

      await tester.tap(closeButtons.first);
      await tester.pumpAndSettle();

      expect(mpLocator.mpGeneralController.openFileOrder, <String>[
        secondController.th2File.filename,
      ]);
      expect(find.text('scrap-second'), findsOneWidget);
      expect(find.text('scrap-first'), findsNothing);
      expect(find.text(firstTabLabel), findsNothing);
      expect(find.text(secondTabLabel), findsOneWidget);
    });
  });
}
