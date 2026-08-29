// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
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

  group('TH2FileTabsPage: mixed .th2/.th tab strip', () {
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

    testWidgets(
      'renders the right body per tab, hides Properties for the text '
      'editor tab, and routes focus on switch',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-mixed',
              scrapOptions: const [],
              encoding: mpDefaultEncoding,
            );
        final String th2Filename = th2Controller.th2File.filename;
        final String thFilename =
            './test/auxiliary/th_project/multiple-sources/cave_one.th';
        final THTextEditorController textController = mpLocator
            .mpGeneralController
            .getTextEditorController(thFilename);

        mpLocator.mpGeneralController.addFileTab(th2Filename);
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

        // Both bodies are built (IndexedStack keeps every tab's subtree
        // alive), but only the active tab's is painted onstage — Finder's
        // default skipOffstage skips the other one, so each is checked
        // while its own tab is active. Only one Properties button ever
        // shows, though: the text-editor tab has none regardless of which
        // tab is active.
        expect(find.byTooltip('File properties'), findsOneWidget);

        // The .th tab was added last, so it is active and its body is the
        // one painted onstage. (The activation happened before the page
        // mounted. The page's initial focus routing establishes focus once
        // the first frame has completed.
        expect(mpLocator.mpGeneralController.activeTabIndex, 1);
        expect(find.byType(THTextEditorWidget), findsOneWidget);
        expect(find.byType(TH2FileWidget, skipOffstage: false), findsOneWidget);

        expect(textController.textEditorFocusNode.hasFocus, isTrue);

        // Switching back to the .th2 tab moves focus to its controller and
        // makes its body the one painted onstage.
        mpLocator.mpGeneralController.setActiveTab(0);
        await tester.pumpAndSettle();

        expect(find.byType(TH2FileWidget), findsOneWidget);
        expect(th2Controller.th2FileFocusNode.hasFocus, isTrue);
        expect(textController.textEditorFocusNode.hasFocus, isFalse);
      },
    );
  });
}
