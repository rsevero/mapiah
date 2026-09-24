// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th_id_aux.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';

import 'th_test_aux.dart';

/// A scrap with one closed border line whose id is [lineID] and one area
/// referencing it as [reference].
String _areaFixture({required String lineID, required String reference}) {
  return 'encoding utf-8\n'
      'scrap s1\n'
      '  line border -id $lineID -close on\n'
      '    0 0\n'
      '    10 0\n'
      '    10 10\n'
      '    0 0\n'
      '  endline\n'
      '  area water\n'
      '    $reference\n'
      '  endarea\n'
      'endscrap\n';
}

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  Future<(TH2File, List<TH2FileProblem>)> parse(String contents) async {
    final TH2FileParser parser = TH2FileParser();
    final (TH2File th2File, bool _, List<String> _) = await parser.parse(
      '/tmp/mapiah-t3946.th2',
      fileBytes: Uint8List.fromList(utf8.encode(contents)),
    );

    return (th2File, List<TH2FileProblem>.of(parser.problems));
  }

  String write(TH2File th2File) => TH2FileWriter().serialize(
    th2File,
    includeEmptyLines: true,
    useOriginalRepresentation: true,
  );

  THLine borderLine(TH2File th2File) =>
      th2File.getLines().firstWhere((THLine line) => line.hasOption(
            THCommandOptionType.id,
          ));

  /// The line ids the area's border references resolve to.
  List<int> areaLineMPIDs(TH2File th2File) {
    final List<THArea> areas = th2File.getAreas().toList();

    expect(areas, hasLength(1), reason: 'the area must not be dropped');

    return areas.single.getLineMPIDs(th2File);
  }

  group('THIDAux', () {
    test('valid ext_keywords are unchanged', () {
      for (final String id in <String>[
        'p1',
        'p.1',
        'a+b',
        "o'neil",
        'x*y,z',
        '-lead',
        '/path/like',
        'under_score',
      ]) {
        expect(THIDAux.toExtKeyword(id), id);
      }
    });

    test('invalid characters become underscores', () {
      expect(THIDAux.toExtKeyword('b@1'), 'b_1');
      expect(THIDAux.toExtKeyword('[b@1]'), '_b_1_');
      expect(THIDAux.toExtKeyword('.lead'), '_lead');
      expect(THIDAux.toExtKeyword('a b'), 'a_b');
      expect(THIDAux.toExtKeyword('área'), '_rea');
    });

    test('the object name is the part before @', () {
      expect(THIDAux.objectNamePart('b1@cave.north'), 'b1');
      expect(THIDAux.objectNamePart('b1'), 'b1');
    });
  });

  group('ids valid in Therion are kept verbatim', () {
    for (final String id in <String>['p.1', 'a+b', "o'neil", 'x*y,z']) {
      test('$id round-trips on a line and its border reference', () async {
        final String contents = _areaFixture(lineID: id, reference: id);
        final (TH2File th2File, List<TH2FileProblem> problems) = await parse(
          contents,
        );

        expect(problems, isEmpty);
        expect(MPCommandOptionAux.getID(borderLine(th2File)), id);
        expect(areaLineMPIDs(th2File), <int>[borderLine(th2File).mpID]);
        expect(write(th2File), contents);
      });
    }

    test('a dotted point id is kept', () async {
      const String contents =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station -id p.1 -name 1\n'
          'endscrap\n';
      final (TH2File th2File, List<TH2FileProblem> problems) = await parse(
        contents,
      );

      expect(problems, isEmpty);
      expect(th2File.mpIDByTHID('p.1'), isNotNull);
      expect(write(th2File), contents);
    });
  });

  group('border references', () {
    test('name@survey resolves to the line and keeps its text', () async {
      final String contents = _areaFixture(
        lineID: 'b1',
        reference: 'b1@cave.north',
      );
      final (TH2File th2File, List<TH2FileProblem> problems) = await parse(
        contents,
      );
      final THAreaBorderTHID border = th2File.elements.values
          .whereType<THAreaBorderTHID>()
          .single;

      expect(problems, isEmpty);
      expect(areaLineMPIDs(th2File), <int>[borderLine(th2File).mpID]);
      expect(border.thID, 'b1');
      expect(write(th2File), contents);
    });

    for (final String invalidID in <String>['b@1', '[b@1]', 'b 1', 'á@b']) {
      test('an invalid id "$invalidID" is repaired on both sides', () async {
        final String repaired = THIDAux.toExtKeyword(invalidID);
        final (TH2File th2File, List<TH2FileProblem> problems) = await parse(
          _areaFixture(lineID: invalidID, reference: invalidID),
        );
        final String written = write(th2File);

        expect(problems, isEmpty);
        expect(MPCommandOptionAux.getID(borderLine(th2File)), repaired);
        expect(areaLineMPIDs(th2File), <int>[borderLine(th2File).mpID]);
        expect(written, contains('-id $repaired '));
        expect(written, contains('\n    $repaired\n'));
      });
    }

    for (final String reference in <String>['missing', 'b2@cave']) {
      test('a reference "$reference" to a missing line is reported', () async {
        final (TH2File _, List<TH2FileProblem> problems) = await parse(
          _areaFixture(lineID: 'b1', reference: reference),
        );

        expect(
          problems
              .map((TH2FileProblem problem) => (problem.kind, problem.lineNumber))
              .toList(),
          <(TH2FileProblemKind, int)>[
            (TH2FileProblemKind.invalidBorderReference, 10),
          ],
        );
        expect(problems.single.detail, contains(reference.split('@').first));
      });
    }

    test('a reference to a point is reported', () async {
      const String contents =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station -id p1\n'
          '  area water\n'
          '    p1\n'
          '  endarea\n'
          'endscrap\n';
      final (TH2File _, List<TH2FileProblem> problems) = await parse(contents);

      expect(
        problems
            .map((TH2FileProblem problem) => (problem.kind, problem.lineNumber))
            .toList(),
        <(TH2FileProblemKind, int)>[
          (TH2FileProblemKind.invalidBorderReference, 5),
        ],
      );
    });

    test('a reference to a missing line is still reported when rewritten', () async {
      final (TH2File _, List<TH2FileProblem> problems) = await parse(
        _areaFixture(lineID: 'b1', reference: 'weirdareaopt 5'),
      );

      expect(
        problems.map((TH2FileProblem problem) => problem.lineNumber),
        <int>[10],
      );
    });
  });
}
