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

void _selectAllLines(TH2FileEditController controller) {
  for (final THLine line in controller.th2File.getLines()) {
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

  group('split lines at crossings', () {
    test(
      '2 straight lines crossing once -> each splits into 2 sub-lines, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-002-two_straight_lines_crossing_once.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        expect(th2File.getLines().length, 4);

        final Map<String?, THLine> byID = _linesByID(th2File);

        expect(byID.containsKey('line1-1'), isTrue);
        expect(byID.containsKey('line1-2'), isTrue);
        expect(byID.containsKey('line2-1'), isTrue);
        expect(byID.containsKey('line2-2'), isTrue);

        expect(byID['line1-1']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line1-2']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line2-1']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line2-2']!.getLineSegmentMPIDs(th2File).length, 2);

        controller.undo();

        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      '2 straight lines crossing multiple times -> correct sub-line counts, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-001-2_straight_lines_intercepting.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        final List<THLine> resultLines = th2File.getLines().toList();

        expect(resultLines.length, greaterThan(2));

        for (final THLine line in resultLines) {
          final String? id = MPCommandOptionAux.getID(line);

          if (id != null) {
            expect(id, matches(RegExp(r'.+-\d+$')));
          }
        }

        controller.undo();

        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test('2 parallel lines (no crossing) -> no changes', () async {
      final TH2FileEditController controller = await _loadController(
        '2026-03-30-003-two_straight_lines_not_crossing.th2',
        mpLocator,
      );
      final TH2File th2File = controller.th2File;

      _selectAllLines(controller);

      controller.splitMergeController.prepareSplitLinesAtCrossings();

      expect(th2File.getLines().length, 2);
    });

    test(
      '3 straight lines (lineX crossed by lineY and lineZ) -> correct sub-line counts, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-004-three_straight_lines_multiple_crossings.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        final Map<String?, THLine> byID = _linesByID(th2File);

        expect(byID.containsKey('lineX-1'), isTrue);
        expect(byID.containsKey('lineX-2'), isTrue);
        expect(byID.containsKey('lineX-3'), isTrue);
        expect(byID.containsKey('lineY-1'), isTrue);
        expect(byID.containsKey('lineY-2'), isTrue);
        expect(byID.containsKey('lineZ-1'), isTrue);
        expect(byID.containsKey('lineZ-2'), isTrue);

        expect(th2File.getLines().length, 7);

        controller.undo();

        expect(th2File.getLines().length, 3);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );
  });
}
