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
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

Map<String?, THLine> _linesByID(TH2File th2File) {
  return {
    for (final THLine line in th2File.getLines())
      MPCommandOptionAux.getID(line): line,
  };
}

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

void _selectLines(TH2FileEditController controller, List<THLine> lines) {
  for (final THLine line in lines) {
    controller.selectionController.addSelectedElement(line);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  group('join lines at coinciding extremities', () {
    test(
      'two lines sharing one endpoint are joined with first-selected line options',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-101-join_two_straight_lines.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());
        final List<THLine> originalLines = th2File.getLines().toList();

        final THLine firstSelected = originalLines[0];
        final THLine secondSelected = originalLines[1];

        _selectLines(controller, [firstSelected, secondSelected]);

        controller.splitMergeController
            .prepareJoinLinesAtCoincidingExtremities();

        expect(th2File.getLines().length, 1);

        final THLine joinedLine = th2File.getLines().single;

        expect(joinedLine.lineType, firstSelected.lineType);
        expect(joinedLine.optionsMap, firstSelected.optionsMap);
        expect(joinedLine.originalLineInTH2File, '');
        expect(joinedLine.getLineSegmentMPIDs(th2File).length, 3);

        final List<THLine> selectedAfterJoin = controller
            .selectionController
            .mpSelectedElementsLogical
            .values
            .whereType<MPSelectedLine>()
            .map((MPSelectedLine selected) => th2File.lineByMPID(selected.mpID))
            .toList();

        expect(selectedAfterJoin.length, 1);
        expect(selectedAfterJoin.first.mpID, joinedLine.mpID);

        controller.undo();

        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      'four lines in two independent pairs produce two joined lines in one run',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-102-join_two_pairs.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectLines(controller, th2File.getLines().toList());

        controller.splitMergeController
            .prepareJoinLinesAtCoincidingExtremities();

        expect(th2File.getLines().length, 2);

        final List<THLine> joinedLines = th2File.getLines().toList();
        expect(joinedLines[0].getLineSegmentMPIDs(th2File).length, 3);
        expect(joinedLines[1].getLineSegmentMPIDs(th2File).length, 3);

        final List<THLine> selectedAfterJoin = controller
            .selectionController
            .mpSelectedElementsLogical
            .values
            .whereType<MPSelectedLine>()
            .map((MPSelectedLine selected) => th2File.lineByMPID(selected.mpID))
            .toList();

        expect(selectedAfterJoin.length, 2);

        controller.undo();

        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      'bezier line reversed for joining keeps curve geometry visually equivalent',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-103-join_reversed_bezier_and_straight.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        final Map<String?, THLine> linesByID = _linesByID(th2File);
        final THLine straight = linesByID['straight']!;
        final THLine bezier = linesByID['bez']!;

        _selectLines(controller, [straight, bezier]);

        controller.splitMergeController
            .prepareJoinLinesAtCoincidingExtremities();

        expect(th2File.getLines().length, 1);

        final THLine joinedLine = th2File.getLines().single;
        final List<THLineSegment> segments = joinedLine.getLineSegments(
          th2File,
        );

        expect(segments.length, 3);
        expect(segments[2], isA<THBezierCurveLineSegment>());

        final THBezierCurveLineSegment reversedBezier =
            segments[2] as THBezierCurveLineSegment;

        expect(reversedBezier.endPoint.coordinates, const Offset(100, 0));
        expect(reversedBezier.controlPoint1.coordinates, const Offset(60, 20));
        expect(reversedBezier.controlPoint2.coordinates, const Offset(90, 20));

        controller.undo();

        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      'near endpoints inside 3 screen-pixel tolerance are joined at current zoom',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-104-join_near_extremities_2_9_screen_pixels_away.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;

        controller.zoomOneToOne();

        _selectLines(controller, th2File.getLines().toList());

        controller.splitMergeController
            .prepareJoinLinesAtCoincidingExtremities();

        expect(th2File.getLines().length, 1);
      },
    );

    test('state button dispatch triggers join action', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-03-30-101-join_two_straight_lines.th2',
        mpLocator,
      );
      final TH2File th2File = controller.th2File;

      _selectLines(controller, th2File.getLines().toList());

      controller.stateController.onButtonPressed(
        MPButtonType.joinLinesAtCoincidingExtremities,
      );

      expect(th2File.getLines().length, 1);
    });
  });
}
