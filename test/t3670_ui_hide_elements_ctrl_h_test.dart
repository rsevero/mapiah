// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_hide_element_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  const String testFile = '2026-03-18-002-two_scraps_with_point_line_area.th2';

  group('TH2FileHideElementController — element hiding', () {
    late TH2FileEditController th2Controller;
    late TH2FileHideElementController hideController;
    late TH2FileEditSelectionController selectionController;

    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<void> loadFile(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: THTestAux.testPath(testFile),
      );

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      hideController = th2Controller.hideElementController;
      selectionController = th2Controller.selectionController;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pump();

      th2Controller.zoomOneToOne();
      th2Controller.setActiveScrap(
        th2Controller.th2File.getScraps().first.mpID,
      );
    }

    testWidgets('initial state: all elements are visible', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      expect(hideController.allElementsVisible, isTrue);

      for (final THElement element
          in th2Controller.th2File.getScraps().first.getChildren(
            th2Controller.th2File,
          )) {
        expect(hideController.isElementVisible(element.mpID), isTrue);
      }
    });

    testWidgets(
      'performHideSelectedOrClearHidden hides selected elements and deselects them',
      (WidgetTester tester) async {
        await loadFile(tester);

        final THPoint point = th2Controller.th2File.getPoints().first;

        selectionController.setSelectedElements([point]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );

        expect(
          selectionController.mpSelectedElementsLogical.containsKey(point.mpID),
          isTrue,
        );

        hideController.performHideSelectedOrClearHidden();

        expect(hideController.isElementVisible(point.mpID), isFalse);
        expect(hideController.allElementsVisible, isFalse);
        expect(
          selectionController.mpSelectedElementsLogical.containsKey(point.mpID),
          isFalse,
        );
      },
    );

    testWidgets(
      'performHideSelectedOrClearHidden with no selection clears all hidden elements',
      (WidgetTester tester) async {
        await loadFile(tester);

        final THPoint point = th2Controller.th2File.getPoints().first;

        selectionController.setSelectedElements([point]);
        th2Controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        hideController.performHideSelectedOrClearHidden();

        expect(hideController.allElementsVisible, isFalse);

        // Now call with no selection to clear all hidden.
        hideController.performHideSelectedOrClearHidden();

        expect(hideController.allElementsVisible, isTrue);
        expect(hideController.isElementVisible(point.mpID), isTrue);
      },
    );

    testWidgets('hidden elements are removed from selectable elements', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      final THPoint point = th2Controller.th2File.getPoints().first;

      // Before hiding: point is selectable.
      expect(
        selectionController.getMPSelectableElements().containsKey(point.mpID),
        isTrue,
      );

      selectionController.setSelectedElements([point]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      hideController.performHideSelectedOrClearHidden();

      // After hiding: point is no longer selectable.
      expect(
        selectionController.getMPSelectableElements().containsKey(point.mpID),
        isFalse,
      );
    });

    testWidgets('hidden elements become selectable again after clear', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      final THPoint point = th2Controller.th2File.getPoints().first;

      selectionController.setSelectedElements([point]);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      hideController.performHideSelectedOrClearHidden();

      expect(
        selectionController.getMPSelectableElements().containsKey(point.mpID),
        isFalse,
      );

      // Clear hidden — point should be selectable again.
      hideController.performHideSelectedOrClearHidden();

      expect(
        selectionController.getMPSelectableElements().containsKey(point.mpID),
        isTrue,
      );
    });

    testWidgets('multiple elements can be hidden in one call', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      final List<THLine> lines = th2Controller.th2File.getLines().toList();

      expect(lines.length, greaterThanOrEqualTo(2));

      selectionController.setSelectedElements(lines);
      th2Controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
      hideController.performHideSelectedOrClearHidden();

      for (final THLine line in lines) {
        expect(hideController.isElementVisible(line.mpID), isFalse);
      }

      expect(hideController.allElementsVisible, isFalse);
      expect(selectionController.mpSelectedElementsLogical.isEmpty, isTrue);
    });
  });

  group('TH2FileHideElementController — scrap visibility', () {
    late TH2FileEditController th2Controller;
    late TH2FileHideElementController hideController;

    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<void> loadFile(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: THTestAux.testPath(testFile),
      );

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      hideController = th2Controller.hideElementController;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pump();

      th2Controller.zoomOneToOne();
      th2Controller.setActiveScrap(
        th2Controller.th2File.getScraps().first.mpID,
      );
    }

    testWidgets('initial state: all scraps visible', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      expect(hideController.allScrapsVisible, isTrue);
      expect(
        hideController.visibleScrapCount,
        th2Controller.th2File.scrapMPIDs.length,
      );

      for (final int scrapMPID in th2Controller.th2File.scrapMPIDs) {
        expect(hideController.isScrapVisible(scrapMPID), isTrue);
      }
    });

    testWidgets('toggleScrapVisibility hides and shows a scrap', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      final int totalScraps = th2Controller.th2File.scrapMPIDs.length;
      final int secondScrapMPID = th2Controller.th2File.getScraps().last.mpID;

      hideController.toggleScrapVisibility(secondScrapMPID);

      expect(hideController.isScrapVisible(secondScrapMPID), isFalse);
      expect(hideController.allScrapsVisible, isFalse);
      expect(hideController.visibleScrapCount, totalScraps - 1);

      hideController.toggleScrapVisibility(secondScrapMPID);

      expect(hideController.isScrapVisible(secondScrapMPID), isTrue);
      expect(hideController.allScrapsVisible, isTrue);
      expect(hideController.visibleScrapCount, totalScraps);
    });

    testWidgets(
      'toggleAllScrapsVisibility hides all but active when all visible',
      (WidgetTester tester) async {
        await loadFile(tester);

        final int activeScrapMPID = th2Controller.activeScrapID;

        expect(hideController.allScrapsVisible, isTrue);

        hideController.toggleAllScrapsVisibility();

        expect(hideController.allScrapsVisible, isFalse);
        expect(hideController.visibleScrapCount, 1);
        expect(hideController.isScrapVisible(activeScrapMPID), isTrue);

        for (final int scrapMPID in th2Controller.th2File.scrapMPIDs) {
          if (scrapMPID != activeScrapMPID) {
            expect(hideController.isScrapVisible(scrapMPID), isFalse);
          }
        }
      },
    );

    testWidgets(
      'toggleAllScrapsVisibility shows all scraps when any is hidden',
      (WidgetTester tester) async {
        await loadFile(tester);

        final int secondScrapMPID = th2Controller.th2File.getScraps().last.mpID;

        hideController.toggleScrapVisibility(secondScrapMPID);
        expect(hideController.allScrapsVisible, isFalse);

        hideController.toggleAllScrapsVisibility();

        expect(hideController.allScrapsVisible, isTrue);
        expect(
          hideController.visibleScrapCount,
          th2Controller.th2File.scrapMPIDs.length,
        );
      },
    );

    testWidgets(
      'hiding the active scrap switches to the nearest visible scrap',
      (WidgetTester tester) async {
        await loadFile(tester);

        final int firstScrapMPID = th2Controller.th2File.getScraps().first.mpID;
        final int secondScrapMPID = th2Controller.th2File.getScraps().last.mpID;

        // first scrap is the active one.
        expect(th2Controller.activeScrapID, firstScrapMPID);

        hideController.toggleScrapVisibility(firstScrapMPID);

        expect(hideController.isScrapVisible(firstScrapMPID), isFalse);
        expect(th2Controller.activeScrapID, isNot(firstScrapMPID));
        expect(th2Controller.activeScrapID, secondScrapMPID);
      },
    );

    testWidgets(
      'visibleScrapCount reflects the number of currently visible scraps',
      (WidgetTester tester) async {
        await loadFile(tester);

        final int totalScraps = th2Controller.th2File.scrapMPIDs.length;

        expect(hideController.visibleScrapCount, totalScraps);

        // Hide all non-active scraps one by one.
        for (final int scrapMPID in th2Controller.th2File.scrapMPIDs) {
          if (scrapMPID != th2Controller.activeScrapID) {
            hideController.toggleScrapVisibility(scrapMPID);
          }
        }

        expect(hideController.visibleScrapCount, 1);

        // Show them all again.
        hideController.toggleAllScrapsVisibility();

        expect(hideController.visibleScrapCount, totalScraps);
      },
    );
  });
}
