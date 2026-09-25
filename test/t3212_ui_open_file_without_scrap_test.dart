// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_overlay_window_widget.dart';
import 'package:material_ui/material_ui.dart';
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

  group('UI: open file without scrap', () {
    setUp(() async {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      await mpLocator.mpSettingsController.initialized;
    });

    for (final String fixture in [
      '2026-09-25-001-no_scrap_with_xvi_image.th2',
      '2025-10-06-004-only_encoding.th2',
    ]) {
      testWidgets('opens $fixture without errors', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const MapiahApp());
        await tester.pumpAndSettle();

        final String testFilename = THTestAux.testPath(fixture);
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        mpLocator.mpGeneralController.addFileTab(testFilename);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(TH2FileTabsPage), findsOneWidget);
        expect(th2Controller.activeScrapID, 0);

        th2Controller.close();
        await tester.pumpAndSettle();
      });
    }

    for (final bool createScrap in [true, false]) {
      testWidgets(
        'adding a point asks for a scrap first (create: $createScrap)',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1280, 1000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(const MapiahApp());
          await tester.pumpAndSettle();

          final String testFilename = THTestAux.testPath(
            '2026-09-25-001-no_scrap_with_xvi_image.th2',
          );
          final TH2FileEditController th2Controller = mpLocator
              .mpGeneralController
              .getTH2FileEditController(filename: testFilename);

          await tester.runAsync(() async {
            await th2Controller.load();
          });

          mpLocator.mpGeneralController.addFileTab(testFilename);
          await tester.pumpAndSettle();

          final bool stateChanged = th2Controller.stateController.setState(
            MPTH2FileEditStateType.addPoint,
          );
          await tester.pumpAndSettle();

          expect(stateChanged, isFalse);
          expect(
            th2Controller.stateController.state.type,
            MPTH2FileEditStateType.selectEmptySelection,
          );

          final Finder dialog = find.byType(
            MPAddScrapDialogOverlayWindowWidget,
          );

          expect(dialog, findsOneWidget);

          await tester.tap(
            find.descendant(
              of: dialog,
              matching: createScrap
                  ? find.byType(ElevatedButton)
                  : find.byType(TextButton),
            ),
          );
          await tester.pumpAndSettle();

          expect(dialog, findsNothing);
          expect(tester.takeException(), isNull);

          if (createScrap) {
            expect(th2Controller.th2File.scrapMPIDs.length, 1);
            expect(
              th2Controller.activeScrapID,
              th2Controller.th2File.scrapMPIDs.first,
            );
            expect(
              th2Controller.stateController.state.type,
              MPTH2FileEditStateType.addPoint,
            );
          } else {
            expect(th2Controller.th2File.scrapMPIDs, isEmpty);
            expect(th2Controller.activeScrapID, 0);
            expect(
              th2Controller.stateController.state.type,
              MPTH2FileEditStateType.selectEmptySelection,
            );
          }

          th2Controller.close();
          await tester.pumpAndSettle();
        },
      );
    }
  });
}
