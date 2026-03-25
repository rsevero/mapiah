// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
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

/// Adds end control points at the given segment indices to the selection.
void _selectEndControlPointsAtIndexes({
  required TH2FileEditController controller,
  required THLine line,
  required List<int> segmentIndexes,
}) {
  final List<int> segmentMPIDs = line.getLineSegmentMPIDs(controller.th2File);
  final Set<int> targetMPIDs = segmentIndexes
      .map((i) => segmentMPIDs[i])
      .toSet();

  for (final MPSelectable mpSelectable
      in controller.selectionController.getMPSelectableEndControlPoints()) {
    if (mpSelectable is! MPSelectableEndControlPoint) {
      continue;
    }

    if (targetMPIDs.contains(mpSelectable.element.mpID)) {
      controller.selectionController.addSelectedEndControlPoint(mpSelectable);
    }
  }
}

/// Returns a map from thID → THLine for all lines in the file.
Map<String?, THLine> _linesByID(TH2File th2File) {
  return {
    for (final THLine line in th2File.getLines())
      MPCommandOptionAux.getID(line): line,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group('split straight line with ID at one point', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('produces 2 sub-lines with correct IDs and segment counts', () async {
      final String path = THTestAux.testPath(
        '2026-03-25-001-split_straight_line_3pts_with_id.th2',
      );
      final TH2FileParser parser = TH2FileParser();
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(parsedFile, isA<TH2File>());

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THLine originalLine = th2File.getLines().first;

      expect(originalLine.getLineSegmentMPIDs(th2File).length, 3);

      controller.selectionController.addSelectedElement(originalLine);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      // Select the end control point at index 1 (middle point).
      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: originalLine,
        segmentIndexes: [1],
      );

      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      // Verify: 2 sub-lines exist.
      expect(th2File.getLines().length, 2);

      final Map<String?, THLine> byID = _linesByID(th2File);

      expect(byID.containsKey('blaus-1'), isTrue);
      expect(byID.containsKey('blaus-2'), isTrue);

      // Each sub-line has 2 segments.
      expect(byID['blaus-1']!.getLineSegmentMPIDs(th2File).length, 2);
      expect(byID['blaus-2']!.getLineSegmentMPIDs(th2File).length, 2);

      // State transitioned to selectNonEmptySelection.
      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.selectNonEmptySelection,
      );

      // Undo: original line is restored.
      controller.undo();

      expect(th2File.getLines().length, 1);
      expect(th2File.getLines().first.getLineSegmentMPIDs(th2File).length, 3);
      expect(MPCommandOptionAux.getID(th2File.getLines().first), 'blaus');
      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });

    test('selecting only the last segment is a no-op', () async {
      final String path = THTestAux.testPath(
        '2026-03-25-001-split_straight_line_3pts_with_id.th2',
      );
      final TH2FileParser parser = TH2FileParser();
      final (_, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File th2File = controller.th2File;

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THLine line = th2File.getLines().first;

      controller.selectionController.addSelectedElement(line);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      // Select only the last segment (index 2 out of 3): no valid split point.
      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: line,
        segmentIndexes: [2],
      );

      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      // No change: still 1 line.
      expect(th2File.getLines().length, 1);
      expect(line.getLineSegmentMPIDs(th2File).length, 3);
    });
  });

  group('split straight line with ID at two points', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('produces 3 sub-lines with correct IDs and segment counts', () async {
      final String path = THTestAux.testPath(
        '2026-03-25-002-split_straight_line_4pts_with_id.th2',
      );
      final TH2FileParser parser = TH2FileParser();
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(parsedFile, isA<TH2File>());

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THLine originalLine = th2File.getLines().first;

      expect(originalLine.getLineSegmentMPIDs(th2File).length, 4);

      controller.selectionController.addSelectedElement(originalLine);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      // Select end control points at indices 1 and 2.
      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: originalLine,
        segmentIndexes: [1, 2],
      );

      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      // Verify: 3 sub-lines.
      expect(th2File.getLines().length, 3);

      final Map<String?, THLine> byID = _linesByID(th2File);

      expect(byID.containsKey('blaus-1'), isTrue);
      expect(byID.containsKey('blaus-2'), isTrue);
      expect(byID.containsKey('blaus-3'), isTrue);

      // blaus-1: segments at indices 0 and 1 → 2 segments.
      expect(byID['blaus-1']!.getLineSegmentMPIDs(th2File).length, 2);

      // blaus-2: bridge + segment at index 2 → 2 segments.
      expect(byID['blaus-2']!.getLineSegmentMPIDs(th2File).length, 2);

      // blaus-3: bridge + segment at index 3 → 2 segments.
      expect(byID['blaus-3']!.getLineSegmentMPIDs(th2File).length, 2);

      // Undo: original state restored.
      controller.undo();

      expect(th2File.getLines().length, 1);
      expect(th2File.getLines().first.getLineSegmentMPIDs(th2File).length, 4);
      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });
  });

  group('split straight line without ID', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('sub-lines have no ID when original line had none', () async {
      final String path = THTestAux.testPath(
        '2026-03-25-003-split_straight_line_no_id.th2',
      );
      final TH2FileParser parser = TH2FileParser();
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(parsedFile, isA<TH2File>());

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THLine originalLine = th2File.getLines().first;

      expect(originalLine.getLineSegmentMPIDs(th2File).length, 3);

      controller.selectionController.addSelectedElement(originalLine);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: originalLine,
        segmentIndexes: [1],
      );

      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      expect(th2File.getLines().length, 2);

      // Neither sub-line has an ID.
      for (final THLine subLine in th2File.getLines()) {
        expect(MPCommandOptionAux.getID(subLine), isNull);
        expect(subLine.getLineSegmentMPIDs(th2File).length, 2);
      }

      // Undo.
      controller.undo();

      expect(th2File.getLines().length, 1);
      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });
  });

  group('split bezier line with ID', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test('split at middle segment produces 2 sub-lines', () async {
      // 2025-10-11-001-bezier_line.th2 has 3 bezier segments and ID blaus.
      final String path = THTestAux.testPath('2025-10-11-001-bezier_line.th2');
      final TH2FileParser parser = TH2FileParser();
      final (parsedFile, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(parsedFile, isA<TH2File>());

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      final THLine originalLine = th2File.getLines().first;

      expect(originalLine.getLineSegmentMPIDs(th2File).length, 3);

      controller.selectionController.addSelectedElement(originalLine);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: originalLine,
        segmentIndexes: [1],
      );

      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      expect(th2File.getLines().length, 2);

      final Map<String?, THLine> byID = _linesByID(th2File);

      expect(byID.containsKey('blaus-1'), isTrue);
      expect(byID.containsKey('blaus-2'), isTrue);

      // blaus-1: 2 segments (original bezier index 0 and 1).
      expect(byID['blaus-1']!.getLineSegmentMPIDs(th2File).length, 2);

      // blaus-2: bridge (straight) + original bezier index 2 → 2 segments.
      expect(byID['blaus-2']!.getLineSegmentMPIDs(th2File).length, 2);

      // Undo.
      controller.undo();

      expect(th2File.getLines().length, 1);
      expect(th2File.getLines().first.getLineSegmentMPIDs(th2File).length, 3);
      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });
  });

  group('split area border line is a no-op', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    testWidgets('area border line is not split and line count is unchanged', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // This file has an area border line (l85-3732--20) and a contour line.
      final String path = THTestAux.testPath(
        '2025-10-04-001-area_and_line.th2',
      );
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      await tester.runAsync(() async {
        await controller.load();
      });

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pump();

      controller.zoomOneToOne();

      final TH2File th2File = controller.th2File;

      controller.setActiveScrap(th2File.getScraps().first.mpID);

      // Find the area border line (ID: l85-3732--20).
      final Map<String?, THLine> byID = _linesByID(th2File);
      final THLine borderLine = byID['l85-3732--20']!;

      final int lineCountBefore = th2File.getLines().length;

      controller.selectionController.addSelectedElement(borderLine);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
      controller.selectionController.updateSelectableEndAndControlPoints();

      // Select a non-last segment.
      _selectEndControlPointsAtIndexes(
        controller: controller,
        line: borderLine,
        segmentIndexes: [1],
      );

      // Should show SnackBar and return without splitting.
      controller.splitMergeController.prepareSplitLineAtSelectedEndPoints();

      await tester.pumpAndSettle();

      // Line count unchanged.
      expect(th2File.getLines().length, lineCountBefore);
    });
  });
}
