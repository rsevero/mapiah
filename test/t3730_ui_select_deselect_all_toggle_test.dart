// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th2_file_tabs_page_test_aux.dart';
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

  // File: first_scrap has 1 station point, 2 lines (border + contour), 1 area.
  // Selectable via selectAllElements: 1 point + 2 lines = 3 elements.
  const String testFile = '2026-03-18-002-two_scraps_with_point_line_area.th2';

  final AppLocalizationsEn loc = AppLocalizationsEn();

  group('UI: select/deselect all button toggle', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<({TH2File th2File, TH2FileEditController th2Controller})> pumpEditor(
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: THTestAux.testPath(testFile));

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      final TH2File th2File = th2Controller.th2File;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pumpAndSettle();

      th2Controller.zoomOneToOne();
      th2Controller.setActiveScrap(th2File.getScraps().first.mpID);
      await tester.pumpAndSettle();

      return (th2File: th2File, th2Controller: th2Controller);
    }

    testWidgets(
      'from empty selection: select all toggles to deselect all and back',
      (WidgetTester tester) async {
        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await pumpEditor(tester);
        final TH2FileEditController th2Controller = editor.th2Controller;

        // Initial state: nothing selected.
        expect(th2Controller.isInSelectEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isFalse);
        expect(find.byTooltip(loc.th2FileEditPageSelectAllElements), findsOne);

        // Click 1: select all → all selected, state → selectNonEmptySelection.
        await tester.tap(find.byTooltip(loc.th2FileEditPageSelectAllElements));
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isTrue);
        expect(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
          findsOne,
        );

        // Click 2: deselect all → nothing selected, state → selectEmptySelection.
        await tester.tap(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
        );
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isFalse);
        expect(find.byTooltip(loc.th2FileEditPageSelectAllElements), findsOne);

        // Click 3: select all again.
        await tester.tap(find.byTooltip(loc.th2FileEditPageSelectAllElements));
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isTrue);
        expect(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
          findsOne,
        );
      },
    );

    testWidgets(
      'starting with some selected: first click selects all, subsequent clicks toggle',
      (WidgetTester tester) async {
        final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
            await pumpEditor(tester);
        final TH2FileEditController th2Controller = editor.th2Controller;
        final TH2FileEditSelectionController selectionController =
            th2Controller.selectionController;

        // Select one element (the first point) to start in non-empty selection.
        final THPoint firstPoint = editor.th2File.getPoints().first;

        selectionController.addSelectedElement(firstPoint, setState: true);
        await tester.pumpAndSettle();

        // Some (not all) elements are selected.
        expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isFalse);
        expect(find.byTooltip(loc.th2FileEditPageSelectAllElements), findsOne);

        // Click 1: select all → all selected.
        await tester.tap(find.byTooltip(loc.th2FileEditPageSelectAllElements));
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isTrue);
        expect(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
          findsOne,
        );

        // Click 2: deselect all → nothing selected.
        await tester.tap(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
        );
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isFalse);
        expect(find.byTooltip(loc.th2FileEditPageSelectAllElements), findsOne);

        // Click 3: select all again.
        await tester.tap(find.byTooltip(loc.th2FileEditPageSelectAllElements));
        await tester.pumpAndSettle();

        expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
        expect(th2Controller.areAllElementsSelected, isTrue);
        expect(
          find.byTooltip(loc.th2FileEditPageDeselectAllElements),
          findsOne,
        );
      },
    );

    testWidgets('select all action works from add line border to area state', (
      WidgetTester tester,
    ) async {
      final ({TH2File th2File, TH2FileEditController th2Controller}) editor =
          await pumpEditor(tester);
      final TH2FileEditController th2Controller = editor.th2Controller;
      final TH2FileEditSelectionController selectionController =
          th2Controller.selectionController;
      final THArea area = editor.th2File.getAreas().first;

      selectionController.setSelectedElements(<THElement>[
        area,
      ], setState: true);
      await tester.pumpAndSettle();

      th2Controller.userInteractionController.prepareAddAreaBorderTHID();
      await tester.pumpAndSettle();

      expect(th2Controller.statusBarMessage, isNotEmpty);
      expect(th2Controller.areAllElementsSelected, isFalse);

      th2Controller.stateController.onSelectAll();
      await tester.pumpAndSettle();

      expect(th2Controller.isInSelectNonEmptySelectionState, isTrue);
      expect(th2Controller.areAllElementsSelected, isTrue);
      expect(find.byTooltip(loc.th2FileEditPageDeselectAllElements), findsOne);
    });
  });
}
