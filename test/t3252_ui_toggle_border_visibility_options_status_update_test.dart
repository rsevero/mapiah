// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
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
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
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

  group('UI: toggling border/visibility options immediately updates the '
      'already-open options window', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      MPTextToUser.initialize();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets(
      'open options window via right click on the selected line, then '
      'toggle border (B) and visibility (V) via keyboard shortcuts and see '
      'the window reflect the change without closing/reopening it',
      (tester) async {
        /// Increase test surface to avoid BottomAppBar Row overflow in
        /// small test window.
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

        /// Right click (secondary pointer button click) on the canvas opens
        /// the options edit overlay window for the current selection,
        /// mirroring how a user opens it from the context menu.
        final Finder listenerFinder = find.byKey(
          ValueKey('MPListenerWidget|${th2Controller.th2FileMPID}'),
        );

        expect(listenerFinder, findsOneWidget);

        final Offset canvasCenter = tester.getCenter(listenerFinder);
        final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);

        await tester.sendEventToBinding(
          mouse.down(canvasCenter, buttons: kSecondaryButton),
        );
        await tester.pump();
        await tester.sendEventToBinding(mouse.up());
        await tester.pumpAndSettle();

        final Finder editWidgetFinder = find.byWidgetPredicate((widget) {
          final Key? k = widget.key;

          if (k is ValueKey) {
            final dynamic v = k.value;

            return (v is String) && v.startsWith('MPOptionsEditWidget|');
          }

          return false;
        }, description: 'ValueKey starts with MPOptionsEditWidget|');

        expect(editWidgetFinder, findsOneWidget);

        final Color unsetColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.surfaceContainer;
        final Color setColor = Theme.of(
          tester.element(editWidgetFinder),
        ).colorScheme.tertiaryFixed;

        Finder tileFinderForLabel(String label) => find.descendant(
          of: editWidgetFinder,
          matching: find.ancestor(
            of: find.text(label),
            matching: find.byType(MPTileWidget),
          ),
        );

        final Finder borderTileFinder = tileFinderForLabel('Border');
        final Finder visibilityTileFinder = tileFinderForLabel('Visibility');

        expect(borderTileFinder, findsOneWidget);
        expect(visibilityTileFinder, findsOneWidget);

        /// Both options start unset.
        expect(
          tester.widget<MPTileWidget>(borderTileFinder).backgroundColor,
          unsetColor,
        );
        expect(
          tester.widget<MPTileWidget>(visibilityTileFinder).backgroundColor,
          unsetColor,
        );

        /// Toggle the border option via the B keyboard shortcut while the
        /// options window is still open, without touching it directly.
        await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
        await tester.pumpAndSettle();

        expect(
          tester.widget<MPTileWidget>(borderTileFinder).backgroundColor,
          setColor,
          reason:
              'Border option tile should reflect the toggled state '
              'immediately, without closing and reopening the options '
              'window.',
        );
        expect(
          tester.widget<MPTileWidget>(visibilityTileFinder).backgroundColor,
          unsetColor,
        );

        /// Toggle the visibility option via the V keyboard shortcut while
        /// the options window is still open.
        await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
        await tester.pumpAndSettle();

        expect(
          tester.widget<MPTileWidget>(visibilityTileFinder).backgroundColor,
          setColor,
          reason:
              'Visibility option tile should reflect the toggled state '
              'immediately, without closing and reopening the options '
              'window.',
        );
        expect(
          tester.widget<MPTileWidget>(borderTileFinder).backgroundColor,
          setColor,
        );
      },
    );
  });
}
