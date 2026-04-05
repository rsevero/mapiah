// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
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

  group('UI: New file dialog flow', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
      // Suppress the telemetry consent dialog so it does not block the home UI.
      mpLocator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
    });

    testWidgets('tapping New file opens modal and OK navigates to editor', (
      WidgetTester tester,
    ) async {
      // Pump the full app so we use the real home page and navigator key
      await tester.pumpWidget(const MapiahApp());
      await tester.pumpAndSettle();

      // Tap the New file button on the home app bar
      final Finder newFileButton = find.byKey(
        const ValueKey('MapiahHomeNewFileButton'),
      );
      expect(newFileButton, findsOneWidget);
      await tester.tap(newFileButton);
      await tester.pumpAndSettle();

      // The modal overlay should be visible; tap the OK button to create the file
      // We expect the defaults to be valid (scrap-1, no-op options, default encoding),
      // so OK should be enabled without extra input.
      final Finder okButton = find.widgetWithText(ElevatedButton, 'OK');
      expect(okButton, findsOneWidget);
      // Ensure it's in view in case the dialog content overflows the viewport
      await tester.ensureVisible(okButton);
      await tester.pump();
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      // Assert we've navigated to the TH2FileTabsPage (which contains TH2FileEditBodyWidget)
      expect(find.byType(TH2FileTabsPage), findsOneWidget);

      // Optionally, press ESC to ensure the page handles it gracefully (no crash)
      // and does not pop the editor unexpectedly (since ESC was for modals).
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // Still on the tabs page
      expect(find.byType(TH2FileTabsPage), findsOneWidget);
    });
  });
}
