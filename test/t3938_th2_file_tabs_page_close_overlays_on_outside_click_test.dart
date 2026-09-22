// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/mp_default_options_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';

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

  group('TH2FileTabsPage: overlay windows close on outside click', () {
    late TH2FileEditOverlayWindowController overlayWindowController;

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

    Future<void> pumpPageWithDefaultOptionsOverlay(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController th2Controller = mpLocator
          .mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'scrap-outside-click',
            scrapOptions: const [],
            encoding: mpDefaultEncoding,
          );

      overlayWindowController = th2Controller.overlayWindowController;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pumpAndSettle();

      overlayWindowController.setShowOverlayWindow(
        MPWindowType.defaultOptions,
        true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(MPDefaultOptionsOverlayWindowWidget), findsOneWidget);
    }

    testWidgets('click outside the drawing area closes overlay windows', (
      WidgetTester tester,
    ) async {
      await pumpPageWithDefaultOptionsOverlay(tester);

      const Offset appBarPosition = Offset(2, 2);
      final Rect drawingArea = tester.getRect(find.byType(TH2FileWidget));

      expect(drawingArea.contains(appBarPosition), isFalse);

      await tester.tapAt(appBarPosition);
      await tester.pumpAndSettle();

      expect(
        overlayWindowController.getIsOverlayWindowShown(
          MPWindowType.defaultOptions,
        ),
        isFalse,
      );
      expect(overlayWindowController.overlayWindows, isEmpty);
      expect(find.byType(MPDefaultOptionsOverlayWindowWidget), findsNothing);
    });

    testWidgets('click on the Settings app bar button closes overlay windows', (
      WidgetTester tester,
    ) async {
      await pumpPageWithDefaultOptionsOverlay(tester);

      await tester.tap(
        find.byKey(const ValueKey('TH2FileTabsPageSettingsButton')),
      );
      await tester.pumpAndSettle();

      expect(overlayWindowController.overlayWindows, isEmpty);
      expect(find.byType(MPDefaultOptionsOverlayWindowWidget), findsNothing);
    });

    testWidgets('click on the status bar below the drawing area closes '
        'overlay windows', (WidgetTester tester) async {
      await pumpPageWithDefaultOptionsOverlay(tester);

      final Rect drawingArea = tester.getRect(find.byType(TH2FileWidget));
      final Offset statusBarPosition = Offset(
        drawingArea.center.dx,
        tester.view.physicalSize.height - 2,
      );

      expect(drawingArea.contains(statusBarPosition), isFalse);

      await tester.tapAt(statusBarPosition);
      await tester.pumpAndSettle();

      expect(overlayWindowController.overlayWindows, isEmpty);
      expect(find.byType(MPDefaultOptionsOverlayWindowWidget), findsNothing);
    });
  });
}
