// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:material_ui/material_ui.dart';
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

  group('TH2FileTabsPage Save As routing', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.thProjectController.closeProject();
      await mpLocator.mpSettingsController.initialized;
      mpLocator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        false,
      );
    });

    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TH2FileTabsPage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'the app-bar Save As button is enabled for both a .th2 tab and a '
      'thconfig/.th text tab (previously text tabs had no Save As at all)',
      (WidgetTester tester) async {
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-routing',
              scrapOptions: const [],
              encoding: mpDefaultEncoding,
            );
        final String th2Filename = th2Controller.th2File.filename;
        final String thFilename =
            './test/auxiliary/th_project/multiple-sources/cave_one.th';
        mpLocator.mpGeneralController.getTextEditorController(thFilename);

        mpLocator.mpGeneralController.addFileTab(th2Filename);
        mpLocator.mpGeneralController.addFileTab(thFilename);

        await pumpPage(tester);

        // The .th tab (added last) is active: the Save As icon button must
        // be enabled (this is the routing Phase 10 adds — previously the
        // TH2-only controller lookup returned null here, so the button had
        // no effect).
        final Finder saveAsButton = find.ancestor(
          of: find.byIcon(Icons.save_as_outlined),
          matching: find.byType(IconButton),
        );
        expect(saveAsButton, findsOneWidget);
        expect(
          tester.widget<IconButton>(saveAsButton).onPressed,
          isNotNull,
        );

        // Switch to the .th2 tab: Save As stays enabled and routes through
        // the existing TH2 path.
        mpLocator.mpGeneralController.setActiveTab(0);
        await tester.pumpAndSettle();

        expect(
          tester.widget<IconButton>(saveAsButton).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'the compact overflow menu Save As entry is enabled for a '
      'thconfig/.th text tab',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String thFilename =
            './test/auxiliary/th_project/multiple-sources/cave_one.th';
        mpLocator.mpGeneralController.getTextEditorController(thFilename);

        mpLocator.mpGeneralController.addFileTab(thFilename);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const TH2FileTabsPage(),
          ),
        );
        await tester.pumpAndSettle();

        final Finder overflowButton = find.byKey(
          const ValueKey('TH2FileTabsPageMoreActionsButton'),
        );
        expect(overflowButton, findsOneWidget);

        await tester.tap(overflowButton);
        await tester.pumpAndSettle();

        final Finder saveAsMenuItem = find.ancestor(
          of: find.text(mpLocator.appLocalizations.textEditorTabSaveAs),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is PopupMenuItem,
          ),
        );
        expect(saveAsMenuItem, findsOneWidget);
        expect(
          (tester.widget(saveAsMenuItem) as PopupMenuItem).enabled,
          isTrue,
        );

        // Close the still-open popup route.
        Navigator.of(tester.element(overflowButton)).pop();
        await tester.pumpAndSettle();
      },
    );
  });
}
