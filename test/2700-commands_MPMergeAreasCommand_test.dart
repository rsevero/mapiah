// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// Loads and returns a [TH2FileEditController] for the given test fixture file.
Future<TH2FileEditController> _loadController(
  String filename,
  MPLocator mpLocator,
) async {
  final String path = THTestAux.testPath(filename);
  final TH2FileParser parser = TH2FileParser();
  final (TH2File parsedFile, bool isSuccessful, List<String> errors) =
      await parser.parse(path, forceNewController: true);

  expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
  expect(parsedFile, isA<TH2File>());

  final TH2FileEditController controller = mpLocator.mpGeneralController
      .getTH2FileEditController(filename: path);

  controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

  return controller;
}

/// Selects all areas in the file.
void _selectAllAreas(TH2FileEditController controller) {
  for (final THArea area in controller.th2File.getAreas()) {
    controller.selectionController.addSelectedElement(area);
  }
}

/// Returns a map from thID → THArea for all areas in the file.
Map<String?, THArea> _areasByID(TH2File th2File) {
  return {
    for (final THArea area in th2File.getAreas())
      MPCommandOptionAux.getID(area): area,
  };
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

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  // Scenario 1: One area with two THAreaBorderTHIDs → merged into one area
  // with one closed border line.
  group('one area with two border lines produces one area one line', () {
    test('area count=1, line count=1, undo restores', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-04-05-001-one_area_two_borders.th2',
        mpLocator,
      );
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      expect(th2File.getAreas().length, 1);
      expect(th2File.getLines().length, 2);

      _selectAllAreas(controller);

      expect(controller.canMergeAreas, isTrue);

      controller.splitMergeController.prepareMergeAreas();

      expect(th2File.getAreas().length, 1);
      expect(th2File.getLines().length, 1);

      final THArea mergedArea = th2File.getAreas().first;

      expect(mergedArea.getLineMPIDs(th2File).length, 1);

      // Undo restores original state.
      controller.undo();

      expect(th2File.getAreas().length, 1);
      expect(th2File.getLines().length, 2);
      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });

    // Scenario 5: thID of first area and first LTSA are inherited.
    test(
      'merged area inherits first area id, merged line inherits first line id',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-001-one_area_two_borders.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;

        _selectAllAreas(controller);
        controller.splitMergeController.prepareMergeAreas();

        final Map<String?, THArea> areas = _areasByID(th2File);

        // The canonical area had id 'myarea'.
        expect(areas.containsKey('myarea'), isTrue);

        final Map<String?, THLine> lines = _linesByID(th2File);

        // The canonical line had id 'topline'.
        expect(lines.containsKey('topline'), isTrue);
      },
    );
  });

  // Scenario 2: Two areas, one border line each, lines share endpoints →
  // merged into one area with one closed border line.
  group(
    'two areas one border each sharing endpoints produce one merged area',
    () {
      test('area count=1, line count=1, undo restores', () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-002-two_areas_one_border_each.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);

        _selectAllAreas(controller);

        expect(controller.canMergeAreas, isTrue);

        controller.splitMergeController.prepareMergeAreas();

        expect(th2File.getAreas().length, 1);
        expect(th2File.getLines().length, 1);

        final THArea mergedArea = th2File.getAreas().first;

        expect(mergedArea.getLineMPIDs(th2File).length, 1);

        // Undo restores all original areas and lines.
        controller.undo();

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      });

      // Scenario 5: first area's id and first line's id are preserved.
      test('merged area inherits first area id and first line id', () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-002-two_areas_one_border_each.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;

        _selectAllAreas(controller);
        controller.splitMergeController.prepareMergeAreas();

        final Map<String?, THArea> areas = _areasByID(th2File);

        expect(areas.containsKey('area1'), isTrue);

        final Map<String?, THLine> lines = _linesByID(th2File);

        expect(lines.containsKey('line1'), isTrue);
      });
    },
  );

  // Scenario 3: Non-intersecting groups (two completely separate rectangles)
  // → two new areas, each with one border line.
  group(
    'two areas with non-connected border lines produce two separate areas',
    () {
      test('area count=2, each with one border, undo restores', () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-004-two_areas_two_non_connected_borders.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);

        _selectAllAreas(controller);

        expect(controller.canMergeAreas, isTrue);

        controller.splitMergeController.prepareMergeAreas();

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);

        for (final THArea area in th2File.getAreas()) {
          expect(area.getLineMPIDs(th2File).length, 1);
        }

        // Undo restores original state.
        controller.undo();

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      });
    },
  );

  // Scenario 4: Open border lines are auto-closed before merging.
  group('open border lines are closed before merging', () {
    test('area count=1, line count=1, merged line is closed', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-04-05-005-one_area_two_open_borders.th2',
        mpLocator,
      );
      final TH2File th2File = controller.th2File;
      final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

      expect(th2File.getAreas().length, 1);
      expect(th2File.getLines().length, 2);

      _selectAllAreas(controller);
      controller.splitMergeController.prepareMergeAreas();

      expect(th2File.getAreas().length, 1);
      expect(th2File.getLines().length, 1);

      final THLine mergedLine = th2File.getLines().first;
      final List<THLineSegment> segs = mergedLine.getLineSegments(th2File);

      // Merged line is closed: first segment start == last segment end.
      final THLineSegment pinSeg = segs.first;
      final THLineSegment lastSeg = segs.last;

      expect(
        (pinSeg.endPoint.coordinates - lastSeg.endPoint.coordinates).distance,
        lessThan(1e-6),
      );

      // Undo restores.
      controller.undo();

      expect(th2File == snapshotOriginal, isTrue);
      expect(identical(th2File, snapshotOriginal), isFalse);
    });
  });

  // Scenario 7: canMergeAreas is false when only one area with one border.
  group('canMergeAreas guard', () {
    test('false when single area has one border line', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-04-05-003-one_area_one_border.th2',
        mpLocator,
      );
      final TH2File th2File = controller.th2File;

      _selectAllAreas(controller);

      expect(controller.canMergeAreas, isFalse);

      // prepareMergeAreas is a no-op: file unchanged.
      final int areaCount = th2File.getAreas().length;
      final int lineCount = th2File.getLines().length;

      controller.splitMergeController.prepareMergeAreas();

      expect(th2File.getAreas().length, areaCount);
      expect(th2File.getLines().length, lineCount);
    });

    test('true when single area has two border lines', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-04-05-001-one_area_two_borders.th2',
        mpLocator,
      );

      _selectAllAreas(controller);

      expect(controller.canMergeAreas, isTrue);
    });

    test(
      'true when two areas are selected even with one border each',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-002-two_areas_one_border_each.th2',
          mpLocator,
        );

        _selectAllAreas(controller);

        expect(controller.canMergeAreas, isTrue);
      },
    );

    test('false when no areas are selected', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-04-05-002-two_areas_one_border_each.th2',
        mpLocator,
      );

      // Do not select anything.
      expect(controller.canMergeAreas, isFalse);
    });
  });

  // Scenario 8: Bézier-only border lines are handled correctly.
  // Two non-connected Bézier closed ovals in one area → 2 separate groups →
  // 2 merged areas, each with one Bézier border line.
  group('bezier border lines merge correctly', () {
    test(
      'one area two non-connected bezier borders produces two areas two lines',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-006-one_area_two_bezier_borders.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        expect(th2File.getAreas().length, 1);
        expect(th2File.getLines().length, 2);

        _selectAllAreas(controller);

        expect(controller.canMergeAreas, isTrue);

        controller.splitMergeController.prepareMergeAreas();

        // Non-connected ovals → 2 groups → 2 areas.
        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);

        // Each area has exactly one border line.
        for (final THArea area in th2File.getAreas()) {
          expect(area.getLineMPIDs(th2File).length, 1);
        }

        // Each merged line contains Bézier segments.
        for (final THLine line in th2File.getLines()) {
          final List<THLineSegment> segs = line.getLineSegments(th2File);
          final bool hasBezier = segs.any((s) => s is THBezierCurveLineSegment);

          expect(hasBezier, isTrue);
        }

        // Undo restores.
        controller.undo();

        expect(th2File.getAreas().length, 1);
        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );
  });

  // Scenario 9: Shared straight edge is removed from merged line.
  // Two adjacent rectangles sharing one straight edge.
  // line1: (0,0)→(100,0)→(100,100)→(0,100)→(0,0) — 4 segments
  // line2: (100,0)→(200,0)→(200,100)→(100,100)→(100,0) — 4 segments
  // Shared edge: (100,0)→(100,100) and its reverse (100,100)→(100,0) — both
  // removed. Outer perimeter: 6 segments + pin = 7 total.
  group('shared straight edge is removed from merged line', () {
    test(
      'two adjacent rects produce one area with outer-perimeter-only line',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-04-05-007-two_areas_shared_straight_edge.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);

        _selectAllAreas(controller);

        expect(controller.canMergeAreas, isTrue);

        controller.splitMergeController.prepareMergeAreas();

        expect(th2File.getAreas().length, 1);
        expect(th2File.getLines().length, 1);

        // 4 + 4 segments - 2 shared = 6 outer + 1 pin = 7 total.
        final THLine mergedLine = th2File.getLines().first;

        expect(mergedLine.getLineSegments(th2File).length, 7);

        // All merged segments must be straight (no bezier in this fixture).
        for (final THLineSegment seg in mergedLine.getLineSegments(th2File)) {
          expect(seg, isA<THStraightLineSegment>());
        }

        // Undo restores original state.
        controller.undo();

        expect(th2File.getAreas().length, 2);
        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );
  });
}
