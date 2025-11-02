import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
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

  group('UI: New file dialog flow', () {
    setUp(() {
      // Ensure we have an English localization available for any direct string needs
      mpLocator.appLocalizations = AppLocalizationsEn();
      // Reset controller state between tests
      mpLocator.mpGeneralController.reset();
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

      // Assert we've navigated to the TH2FileEditPage
      expect(find.byType(TH2FileEditPage), findsOneWidget);

      // Optionally, press ESC to ensure the page handles it gracefully (no crash)
      // and does not pop the editor unexpectedly (since ESC was for modals).
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      // Still on the editor page
      expect(find.byType(TH2FileEditPage), findsOneWidget);
    });
  });
}
