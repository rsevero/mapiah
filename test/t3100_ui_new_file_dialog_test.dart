// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:mapiah/src/widgets/mp_add_file_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
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

    testWidgets('creating a file from the dialog adds it to the root editor', (
      WidgetTester tester,
    ) async {
      // Pump the full app so the tabs page is mounted as the root route.
      await tester.pumpWidget(const MapiahApp());
      await tester.pumpAndSettle();

      final BuildContext tabsPageContext = tester.element(
        find.byType(TH2FileTabsPage),
      );

      MPModalOverlayWidget.show(
        context: tabsPageContext,
        scrollChild: false,
        childBuilder: (VoidCallback onPressedClose) {
          return MPAddFileDialogWidget(onPressedClose: onPressedClose);
        },
      );
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

      // The dialog adds a tab without pushing another tabs page route.
      expect(find.byType(TH2FileTabsPage), findsOneWidget);
      expect(mpLocator.mpGeneralController.openFileOrder, hasLength(1));

      // Optionally, press ESC to ensure the page handles it gracefully (no crash)
      // and does not pop the editor unexpectedly (since ESC was for modals).
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // Still on the root tabs page.
      expect(find.byType(TH2FileTabsPage), findsOneWidget);
    });
  });
}
