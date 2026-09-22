// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group('UI: bottom status bar message updates when a selected element '
      'option is toggled', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'toggling border (B) and visibility (V) via keyboard shortcuts '
      'immediately updates the bottom status bar message',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final String testFilename =
            './test/auxiliary/2026-02-17-001-slope_straight_line.th2';
        final TH2FileEditController th2Controller = mpLocator
            .mpGeneralController
            .getTH2FileEditController(filename: testFilename);

        await tester.runAsync(() async {
          await th2Controller.load();
        });

        final TH2FileEditSelectionController selectionController =
            th2Controller.selectionController;
        final TH2File th2File = th2Controller.th2File;

        await tester.pumpWidget(
          buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
        );
        await tester.pump();

        th2Controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);

        final THLine line = th2File.getLines().first;

        selectionController.setSelectedElements([line]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        await tester.pump();

        final String messageBeforeToggles = th2Controller.statusBarMessage;

        expect(messageBeforeToggles, isNot(contains('Border')));
        expect(messageBeforeToggles, isNot(contains('Visibility')));

        /// Toggle the border option via the B keyboard shortcut.
        await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
        await tester.pumpAndSettle();

        final String messageAfterBorderToggle = th2Controller.statusBarMessage;

        expect(
          messageAfterBorderToggle,
          contains('Border'),
          reason:
              'Bottom status bar message should immediately include the '
              'Border option after toggling it via the B shortcut.',
        );
        expect(messageAfterBorderToggle, isNot(equals(messageBeforeToggles)));

        /// Toggle the visibility option via the V keyboard shortcut.
        await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
        await tester.pumpAndSettle();

        final String messageAfterVisibilityToggle =
            th2Controller.statusBarMessage;

        expect(
          messageAfterVisibilityToggle,
          contains('Visibility'),
          reason:
              'Bottom status bar message should immediately include the '
              'Visibility option after toggling it via the V shortcut.',
        );
        expect(
          messageAfterVisibilityToggle,
          isNot(equals(messageAfterBorderToggle)),
        );
        expect(messageAfterVisibilityToggle, contains('Border'));
      },
    );
  });
}
