// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';

import 'th_test_aux.dart';

/// Result of parsing one in-memory `.th2` fixture.
class _ParseOutcome {
  final TH2File th2File;
  final bool isSuccessful;
  final List<String> errors;
  final List<TH2FileProblem> problems;

  const _ParseOutcome({
    required this.th2File,
    required this.isSuccessful,
    required this.errors,
    required this.problems,
  });

  bool get isBroken => problems.isNotEmpty || !isSuccessful;

  List<(TH2FileProblemKind, int)> get kindsAndLines => problems
      .map((TH2FileProblem problem) => (problem.kind, problem.lineNumber))
      .toList();
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

  /// Parses [contents] as a `.th2` file without touching the disk.
  Future<_ParseOutcome> parseText(String contents) async {
    final TH2FileParser parser = TH2FileParser();
    final Uint8List fileBytes = Uint8List.fromList(utf8.encode(contents));
    final (TH2File th2File, bool isSuccessful, List<String> errors) =
        await parser.parse('/tmp/mapiah-t3939.th2', fileBytes: fileBytes);

    return _ParseOutcome(
      th2File: th2File,
      isSuccessful: isSuccessful,
      errors: List<String>.of(errors),
      problems: List<TH2FileProblem>.of(parser.problems),
    );
  }

  /// Every non-empty source line must be in the model or reported.
  void expectNoSilentDrops(String contents, _ParseOutcome outcome) {
    final Set<String> modelLines = <String>{};

    for (final THElement element in outcome.th2File.elements.values) {
      for (final String line in element.originalLineInTH2File.split('\n')) {
        final String trimmed = line.trim();

        if (trimmed.isNotEmpty) {
          modelLines.add(trimmed);
        }
      }
    }

    final Set<int> problemLines = outcome.problems
        .map((TH2FileProblem problem) => problem.lineNumber)
        .toSet();
    final List<String> sourceLines = contents.split('\n');

    for (int index = 0; index < sourceLines.length; index++) {
      final String trimmed = sourceLines[index].trim();
      final int lineNumber = index + 1;

      if (trimmed.isEmpty || trimmed.startsWith('encoding')) {
        continue;
      }

      final bool isAccountedFor =
          modelLines.contains(trimmed) || problemLines.contains(lineNumber);

      expect(
        isAccountedFor,
        isTrue,
        reason: 'Line $lineNumber ("$trimmed") was silently dropped.',
      );
    }
  }

  /// Parses [contents], checks the expected problems and the invariant.
  Future<_ParseOutcome> expectBroken(
    String contents,
    List<(TH2FileProblemKind, int)> expected,
  ) async {
    final _ParseOutcome outcome = await parseText(contents);

    expect(outcome.isBroken, isTrue);
    expect(outcome.kindsAndLines, expected);
    expectNoSilentDrops(contents, outcome);

    return outcome;
  }

  group('hierarchy violations', () {
    test('a point at file level is reported', () async {
      await expectBroken(
        'encoding utf-8\n'
        'point 10 20 station -name 1\n'
        'scrap s1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.plaOutsideScrap, 2)],
      );
    });

    test('multi-line line and area at file level report once each', () async {
      await expectBroken(
        'encoding utf-8\n'
        'line wall -id l1\n'
        '  10 20\n'
        '  30 40\n'
        'endline\n'
        'area water\n'
        '  l1\n'
        'endarea\n',
        <(TH2FileProblemKind, int)>[
          (TH2FileProblemKind.plaOutsideScrap, 2),
          (TH2FileProblemKind.plaOutsideScrap, 6),
        ],
      );
    });

    test('a nested scrap with contents is reported', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap outer\n'
        '  point 1 1 station -name 1\n'
        '  scrap inner\n'
        '    point 2 2 station -name 2\n'
        '  endscrap\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.scrapInsideScrap, 4)],
      );
    });

    test('a stray endscrap is reported', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        'endscrap\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.strayEndscrap, 4)],
      );
    });

    test('a stray endscrap followed by a top-level element', () async {
      await expectBroken(
        'encoding utf-8\n'
        'endscrap\n'
        'scrap s1\n'
        '  point 1 1 station -name 1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.strayEndscrap, 2)],
      );
    });

    test('missing endline followed by a point', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    30 40\n'
        '  point 1 1 station -name 1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndline, 6)],
      );
    });

    test('missing endline followed by a line', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    30 40\n'
        '  line wall\n'
        '    50 60\n'
        '    70 80\n'
        '  endline\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndline, 6)],
      );
    });

    test('missing endline followed by endscrap', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    30 40\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndline, 6)],
      );
    });

    test('missing endarea followed by a line', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  area water\n'
        '    l1\n'
        '  line wall -id l1\n'
        '    10 20\n'
        '    30 40\n'
        '  endline\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndarea, 5)],
      );
    });

    test('missing endarea followed by a point', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n'
        '  area water\n'
        '    l1\n'
        '  point 1 1 station -name 1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndarea, 9)],
      );
    });

    test('missing endarea followed directly by endscrap', () async {
      final _ParseOutcome outcome = await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n'
        '  area water\n'
        '    l1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndarea, 9)],
      );
      final Iterable<THAreaBorderTHID> borderReferences = outcome
          .th2File
          .elements
          .values
          .whereType<THAreaBorderTHID>();

      expect(
        borderReferences.map((THAreaBorderTHID border) => border.thID),
        isNot(contains('endscrap')),
      );
    });

    test('missing endscrap at end of file', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 1 1 station -name 1\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.missingEndscrap, 2)],
      );
    });

    test('missing endline at end of file', () async {
      final _ParseOutcome outcome = await parseText(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    30 40\n',
      );

      expect(outcome.isBroken, isTrue);
      expect(
        outcome.kindsAndLines,
        containsAll(<(TH2FileProblemKind, int)>[
          (TH2FileProblemKind.missingEndline, 3),
          (TH2FileProblemKind.missingEndscrap, 2),
        ]),
      );
    });
  });

  group('valid files stay valid', () {
    test('a border thID that is an ordinary word is valid', () async {
      final _ParseOutcome outcome = await parseText(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line border -id wall\n'
        '    10 20\n'
        '    30 40\n'
        '    10 20\n'
        '  endline\n'
        '  area water\n'
        '    wall\n'
        '  endarea\n'
        'endscrap\n',
      );

      expect(outcome.isBroken, isFalse);
      expect(outcome.problems, isEmpty);
    });

    const Map<String, String> unknownTypes = <String, String>{
      'unknown point type': '  point 1 2 foobarpoint\n',
      'unknown line type': '  line foobarline\n    10 20\n    30 40\n  endline\n',
      'unknown area type':
          '  line wall -id l1\n    10 20\n    30 40\n  endline\n  area foobararea\n    l1\n  endarea\n',
      'unknown point subtype': '  point 1 2 station:weirdsub\n',
      'unknown line subtype':
          '  line wall:weirdsub\n    10 20\n    30 40\n  endline\n',
      'user type': '  point 1 2 u:myuser\n',
    };

    for (final MapEntry<String, String> entry in unknownTypes.entries) {
      test('${entry.key} is not a problem and round-trips', () async {
        final String contents =
            'encoding utf-8\n'
            'scrap s1\n'
            '${entry.value}'
            'endscrap\n';
        final _ParseOutcome outcome = await parseText(contents);
        final String written = TH2FileWriter().serialize(
          outcome.th2File,
          includeEmptyLines: true,
          useOriginalRepresentation: true,
        );

        expect(outcome.problems, isEmpty);
        expect(outcome.isBroken, isFalse);
        expect(written, contents);
      });
    }
  });

  group('unknown options are problems', () {
    const Map<String, (String, int)> unknownOptions = <String, (String, int)>{
      'point option with argument': (
        '  point 1 2 station -weirdpointopt abc\n',
        3,
      ),
      'point flag': ('  point 1 2 station -weirdflag\n', 3),
      'line option with argument': (
        '  line wall -weirdlineopt abc\n    10 20\n    30 40\n  endline\n',
        3,
      ),
      'line flag': (
        '  line wall -weirdflag\n    10 20\n    30 40\n  endline\n',
        3,
      ),
      'area option with argument': (
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n  area water -weirdareaopt abc\n    l1\n  endarea\n',
        7,
      ),
      'area flag': (
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n  area water -weirdflag\n    l1\n  endarea\n',
        7,
      ),
    };

    for (final MapEntry<String, (String, int)> entry
        in unknownOptions.entries) {
      test('${entry.key} is one parseError with no cascade', () async {
        await expectBroken(
          'encoding utf-8\n'
          'scrap s1\n'
          '${entry.value.$1}'
          '  point 5 5 station -name 5\n'
          'endscrap\n',
          <(TH2FileProblemKind, int)>[
            (TH2FileProblemKind.parseError, entry.value.$2),
          ],
        );
      });
    }

    test('scrap option with argument is one parseError', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1 -weirdscrapopt abc\n'
        '  point 5 5 station -name 5\n'
        'endscrap\n'
        'scrap s2\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 2)],
      );
    });

    test('scrap flag is one parseError', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1 -weirdflag\n'
        '  point 5 5 station -name 5\n'
        'endscrap\n'
        'scrap s2\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 2)],
      );
    });

    test('an unknown line-point option line is reported', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    weirdsegopt xyz\n'
        '    30 40\n'
        '  endline\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 5)],
      );
    });

    test('an unknown option line inside an area is reported', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n'
        '  area water\n'
        '    l1\n'
        '    weirdareaopt 5\n'
        '  endarea\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 9)],
      );
    });

    test('an unknown option line does not hide a closing point', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    weirdsegopt xyz\n'
        '    30 40\n'
        '  point 1 1 station -name 1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[
          (TH2FileProblemKind.parseError, 5),
          (TH2FileProblemKind.missingEndline, 7),
        ],
      );
    });

    test('an unknown area option line does not hide an endscrap', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id l1\n    10 20\n    30 40\n  endline\n'
        '  area water\n'
        '    l1\n'
        '    weirdareaopt 5\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[
          (TH2FileProblemKind.parseError, 9),
          (TH2FileProblemKind.missingEndarea, 10),
        ],
      );
    });
  });

  group('plain syntax errors', () {
    test('a misspelled command inside a scrap', () async {
      final _ParseOutcome outcome = await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  poin 150 250 station -name 2\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 3)],
      );

      expect(
        outcome.problems.single.sourceLine.trimRight(),
        '  poin 150 250 station -name 2',
      );
    });

    test('a line point with one coordinate', () async {
      final _ParseOutcome outcome = await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    10 20\n'
        '    150\n'
        '    30 40\n'
        '  endline\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 5)],
      );

      expect(outcome.problems.single.sourceLine.trimRight(), '    150');
    });

    test('a line-segment option with no segment', () async {
      await expectBroken(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall\n'
        '    smooth off\n'
        '    10 20\n'
        '    30 40\n'
        '  endline\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 4)],
      );
    });

    test('a malformed XTherion image setting', () async {
      await expectBroken(
        'encoding utf-8\n'
        '##XTHERION## xth_me_image_insert {broken\n'
        'scrap s1\n'
        'endscrap\n',
        <(TH2FileProblemKind, int)>[(TH2FileProblemKind.parseError, 2)],
      );
    });

    test('an unclosed multiline comment at end of file', () async {
      final _ParseOutcome outcome = await parseText(
        'encoding utf-8\n'
        'scrap s1\n'
        'endscrap\n'
        'comment\n'
        '  some text\n',
      );

      expect(outcome.isBroken, isTrue);
      expect(
        outcome.problems.map((TH2FileProblem problem) => problem.kind),
        everyElement(TH2FileProblemKind.parseError),
      );
      expect(outcome.problems, isNotEmpty);
    });
  });

  test('parsing never throws on a pathological file', () async {
    final _ParseOutcome outcome = await parseText(
      'encoding utf-8\n'
      'endline\n'
      'endarea\n'
      'area water\n'
      'scrap s1\n'
      'scrap s2\n'
      'line wall\n'
      'endscrap\n'
      'endscrap\n'
      'endscrap\n',
    );

    expect(outcome.isBroken, isTrue);
  });
}
