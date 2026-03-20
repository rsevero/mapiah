// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_search_select_criteria.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_search_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
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

  // File: first_scrap has 1 station point (id=first-point, visibility on),
  // 2 lines (border: visibility off + close on; contour: visibility on + close on),
  // 1 clay area (no options). second_scrap is empty.
  const String mainTestFile =
      '2026-03-18-002-two_scraps_with_point_line_area.th2';

  // File: test scrap has 1 contour line (id=blaus) with a segment with smooth on.
  const String lineSegmentTestFile =
      '2025-12-01-001-bezier_line_with_line_segment_options.th2';

  group('TH2FileEditSearchController — getMatchingElements', () {
    late TH2FileEditController th2Controller;
    late TH2FileEditSearchController searchController;

    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<void> loadFile(
      WidgetTester tester, {
      required String filename,
    }) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
        filename: THTestAux.testPath(filename),
      );

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      searchController = th2Controller.searchController;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pump();

      th2Controller.zoomOneToOne();
      th2Controller.setActiveScrap(
        th2Controller.th2File.getScraps().first.mpID,
      );
    }

    testWidgets('returns empty when no criteria section is enabled', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isEmpty);
    });

    testWidgets('selectAll for points returns all points in active scrap', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, th2Controller.th2File.getPoints().length);
      expect(result.every((THElement e) => e is THPoint), isTrue);
    });

    testWidgets('selectAll for lines returns all lines in active scrap', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, th2Controller.th2File.getLines().length);
      expect(result.every((THElement e) => e is THLine), isTrue);
    });

    testWidgets('selectAll for areas returns all areas in active scrap', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.areas.enabled = true;
      searchController.criteria.areas.selectAll = true;

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, th2Controller.th2File.getAreas().length);
      expect(result.every((THElement e) => e is THArea), isTrue);
    });

    testWidgets('selectAll for all sections returns all elements', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;
      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;
      searchController.criteria.areas.enabled = true;
      searchController.criteria.areas.selectAll = true;

      final List<THElement> result = searchController.getMatchingElements();

      final int expectedCount =
          th2Controller.th2File.getPoints().length +
          th2Controller.th2File.getLines().length +
          th2Controller.th2File.getAreas().length;

      expect(result.length, expectedCount);
    });

    testWidgets('byType filters points by station type', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.byType = true;
      searchController.criteria.points.selectedPointTypes.add(
        THPointType.station,
      );

      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isNotEmpty);
      expect(
        result.every(
          (THElement e) => e is THPoint && e.pointType == THPointType.station,
        ),
        isTrue,
      );
    });

    testWidgets('byType filters lines by border type', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byType = true;
      searchController.criteria.lines.selectedLineTypes.add(THLineType.border);

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect(result.first, isA<THLine>());
      expect((result.first as THLine).lineType, THLineType.border);
    });

    testWidgets('byType filters areas by clay type', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.areas.enabled = true;
      searchController.criteria.areas.byType = true;
      searchController.criteria.areas.selectedAreaTypes.add(THAreaType.clay);

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect(result.first, isA<THArea>());
    });

    testWidgets('byType with unmatched type returns empty', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.byType = true;
      searchController.criteria.points.selectedPointTypes.add(
        THPointType.entrance,
      );

      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isEmpty);
    });

    testWidgets('byID partial match returns matching element', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.byID = true;
      searchController.criteria.points.idSearchText = 'first';

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect(result.first, isA<THPoint>());
    });

    testWidgets('byID is case-insensitive', (WidgetTester tester) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byID = true;
      searchController.criteria.lines.idSearchText = 'BORDER';

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect((result.first as THLine).lineType, THLineType.border);
    });

    testWidgets('byID with no match returns empty', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.byID = true;
      searchController.criteria.points.idSearchText = 'no-such-id';

      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isEmpty);
    });

    testWidgets('byOption with visibility set matches elements that have it', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byOption = true;
      searchController.criteria.lines.optionStates[THCommandOptionType
              .visibility] =
          MPOptionSearchState.set;

      final List<THElement> result = searchController.getMatchingElements();

      // Both border (visibility off) and contour (visibility on) have the
      // visibility option set on the element, so both should match.
      expect(result.length, 2);
    });

    testWidgets('byOption with visibility unset matches elements without it', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.areas.enabled = true;
      searchController.criteria.areas.byOption = true;
      searchController.criteria.areas.optionStates[THCommandOptionType
              .visibility] =
          MPOptionSearchState.unset;

      // The clay area has no visibility option, so it should match.
      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect(result.first, isA<THArea>());
    });

    testWidgets(
      'byOption AND logic: element must match all non-undefined states',
      (WidgetTester tester) async {
        await loadFile(tester, filename: mainTestFile);

        searchController.criteria.lines.enabled = true;
        searchController.criteria.lines.byOption = true;
        // Both border and contour have close and visibility options.
        // Only border has visibility "off" (but the option IS set).
        // Require visibility set AND close set → both lines match.
        searchController.criteria.lines.optionStates[THCommandOptionType
                .visibility] =
            MPOptionSearchState.set;
        searchController.criteria.lines.optionStates[THCommandOptionType
                .close] =
            MPOptionSearchState.set;

        final List<THElement> result = searchController.getMatchingElements();

        expect(result.length, 2);
      },
    );

    testWidgets('byOption: undefined state is ignored and does not filter', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byOption = true;
      searchController.criteria.lines.optionStates[THCommandOptionType
              .visibility] =
          MPOptionSearchState.undefined;

      // All states are undefined → hasAnyCriteria is true but _matchesOptionStates
      // returns true for every element → all lines match.
      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 2);
    });

    testWidgets('resetCriteria clears all state and returns empty afterwards', (
      WidgetTester tester,
    ) async {
      await loadFile(tester, filename: mainTestFile);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;
      searchController.updateMatchingCount();

      expect(searchController.matchingCount, greaterThan(0));

      searchController.resetCriteria();

      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isEmpty);
      expect(searchController.matchingCount, 0);
      expect(searchController.criteria.points.enabled, isFalse);
    });
  });

  group('TH2FileEditSearchController — line segment options', () {
    late TH2FileEditController th2Controller;
    late TH2FileEditSearchController searchController;

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
        filename: THTestAux.testPath(lineSegmentTestFile),
      );

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      searchController = th2Controller.searchController;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: th2Controller),
      );
      await tester.pump();

      th2Controller.zoomOneToOne();
      th2Controller.setActiveScrap(
        th2Controller.th2File.getScraps().first.mpID,
      );
    }

    testWidgets('byLineSegmentOption smooth set matches line with smooth', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byLineSegmentOption = true;
      searchController
              .criteria
              .lines
              .lineSegmentOptionStates[THCommandOptionType.smooth] =
          MPOptionSearchState.set;

      final List<THElement> result = searchController.getMatchingElements();

      expect(result.length, 1);
      expect(result.first, isA<THLine>());
    });

    testWidgets('byLineSegmentOption smooth unset returns empty', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.byLineSegmentOption = true;
      searchController
              .criteria
              .lines
              .lineSegmentOptionStates[THCommandOptionType.smooth] =
          MPOptionSearchState.unset;

      // The line HAS a segment with smooth → does not match "smooth unset".
      final List<THElement> result = searchController.getMatchingElements();

      expect(result, isEmpty);
    });
  });

  group('TH2FileEditSearchController — selection actions', () {
    late TH2FileEditController th2Controller;
    late TH2FileEditSearchController searchController;
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
        filename: THTestAux.testPath(mainTestFile),
      );

      await tester.runAsync(() async {
        await th2Controller.load();
      });

      searchController = th2Controller.searchController;
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

    testWidgets('setSelection selects exactly the matching elements', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;

      searchController.setSelection();

      final THPoint point = th2Controller.th2File.getPoints().first;

      expect(
        selectionController.mpSelectedElementsLogical.containsKey(point.mpID),
        isTrue,
      );
      expect(
        selectionController.mpSelectedElementsLogical.length,
        th2Controller.th2File.getPoints().length,
      );
    });

    testWidgets('addToSelection adds matching elements to existing selection', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      // First select all points.
      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;
      searchController.setSelection();

      final int pointCount = th2Controller.th2File.getPoints().length;

      expect(selectionController.mpSelectedElementsLogical.length, pointCount);

      // Then add all lines.
      searchController.resetCriteria();
      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;
      searchController.addToSelection();

      final int lineCount = th2Controller.th2File.getLines().length;

      expect(
        selectionController.mpSelectedElementsLogical.length,
        pointCount + lineCount,
      );
    });

    testWidgets('removeFromSelection removes matching elements', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      // Select all points and lines.
      searchController.criteria.points.enabled = true;
      searchController.criteria.points.selectAll = true;
      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;
      searchController.setSelection();

      final int totalSelected =
          selectionController.mpSelectedElementsLogical.length;

      expect(totalSelected, greaterThan(0));

      // Remove only lines.
      searchController.resetCriteria();
      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;
      searchController.removeFromSelection();

      final int lineCount = th2Controller.th2File.getLines().length;

      expect(
        selectionController.mpSelectedElementsLogical.length,
        totalSelected - lineCount,
      );
    });

    testWidgets('updateMatchingCount reflects the current match count', (
      WidgetTester tester,
    ) async {
      await loadFile(tester);

      searchController.criteria.lines.enabled = true;
      searchController.criteria.lines.selectAll = true;
      searchController.updateMatchingCount();

      expect(
        searchController.matchingCount,
        th2Controller.th2File.getLines().length,
      );
    });
  });
}
