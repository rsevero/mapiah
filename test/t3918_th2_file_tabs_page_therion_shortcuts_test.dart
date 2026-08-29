// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
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

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.closeProject();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      true,
    );
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  for (final LogicalKeyboardKey modifier in <LogicalKeyboardKey>[
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.metaLeft,
  ]) {
    testWidgets('$modifier+T chooses a project and runs Therion', (
      WidgetTester tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TH2FileTabsPage(
            pickProjectAndRunTherion: (BuildContext context) async {
              callCount++;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(modifier);
      await tester.pump();

      expect(callCount, 1);

      await tester.tap(
        find.byKey(const ValueKey<String>('THProjectTreeSearchField')),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(modifier);
      await tester.pump();

      expect(callCount, 2);
    });

    testWidgets('$modifier+T does nothing when a project is loaded', (
      WidgetTester tester,
    ) async {
      int callCount = 0;

      mpLocator.thProjectController.rootConfigPath = '/tmp/loaded/thconfig';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TH2FileTabsPage(
            pickProjectAndRunTherion: (BuildContext context) async {
              callCount++;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(modifier);
      await tester.pump();

      expect(callCount, 0);
    });
  }
}
