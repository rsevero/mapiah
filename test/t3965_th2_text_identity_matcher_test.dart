// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_identity_matcher.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
  });

  /// A matcher side parsed from [text].
  Future<(TH2TextMatchSide, TH2TextValidationResult)> side(String text) async {
    final TH2TextValidationResult result = await TH2TextValidator.validate(
      content: text,
      filename: '/tmp/t3965.th2',
      th2FileMPID: -1000,
      lineEnding: mpUnixLineBreak,
    );

    expect(result.isValid, isTrue, reason: result.diagnostics.join('\n'));

    return (
      (result.detachedFile, result.normalizedText, result.writerMap),
      result,
    );
  }

  /// The owner of the [occurrence]-th line of [text] equal to [lineText].
  int ownerOfText(
    String text,
    TH2TextLineMap lineMap,
    String lineText, {
    int occurrence = 0,
  }) {
    final List<String> lines = TH2TextNormalizationAnalyzer.lineTexts(text);
    int seen = 0;

    for (int line = 0; line < lines.length; line++) {
      if (lines[line] == lineText) {
        if (seen == occurrence) {
          return lineMap.ownerOfLine(line)!;
        }
        seen++;
      }
    }

    throw StateError('No line "$lineText" #$occurrence.');
  }

  /// The live owner of a line of [controller]'s text.
  int liveOwner(
    TH2FileEditController controller,
    String lineText, {
    int occurrence = 0,
  }) {
    final (String text, TH2TextLineMap lineMap) = controller
        .serializeForTextMode();

    return ownerOfText(text, lineMap, lineText, occurrence: occurrence);
  }

  /// Applies [text] to [controller] in a fresh session.
  Future<TH2TextApplyResult> apply(
    TH2FileEditController controller,
    String text,
  ) async {
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    session.content = text;

    return controller.applyTextContent(text, session: session);
  }

  group('matcher', () {
    test('unchanged elements match; a changed element does not', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station -id p1\n'
          '  point 2 2 station -id p2\n'
          'endscrap\n';
      final (TH2TextMatchSide live, _) = await side(text);
      final (TH2TextMatchSide detached, _) = await side(
        text.replaceFirst('point 2 2', 'point 3 3'),
      );
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );
      int liveID(String line) => ownerOfText(live.$2, live.$3, line);
      int detachedID(String line) =>
          ownerOfText(detached.$2, detached.$3, line);

      expect(matching[detached.$1.mpID], live.$1.mpID);
      expect(matching[detachedID('scrap s1')], liveID('scrap s1'));
      expect(
        matching[detachedID('  point 1 1 station -id p1')],
        liveID('  point 1 1 station -id p1'),
      );
      expect(matching[detachedID('endscrap')], liveID('endscrap'));
      expect(
        matching.containsKey(detachedID('  point 3 3 station -id p2')),
        isFalse,
      );
      expect(
        matching.values.toSet().contains(liveID('  point 2 2 station -id p2')),
        isFalse,
      );
      expect(matching.values.toSet(), hasLength(matching.length));
    });

    test('identical duplicates in one parent stay unmatched', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station\n'
          '  point 1 1 station\n'
          '  point 2 2 station\n'
          'endscrap\n';
      final (TH2TextMatchSide live, _) = await side(text);
      final (TH2TextMatchSide detached, _) = await side(text);
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );

      for (final int occurrence in <int>[0, 1]) {
        expect(
          matching.containsKey(
            ownerOfText(
              detached.$2,
              detached.$3,
              '  point 1 1 station',
              occurrence: occurrence,
            ),
          ),
          isFalse,
        );
      }
      expect(
        matching[ownerOfText(detached.$2, detached.$3, '  point 2 2 station')],
        ownerOfText(live.$2, live.$3, '  point 2 2 station'),
      );
    });

    test('repeated text in different matched parents matches in each', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  line wall -id a\n'
          '    1 1\n'
          '    2 2\n'
          '  endline\n'
          '  line wall -id b\n'
          '    1 1\n'
          '    2 2\n'
          '  endline\n'
          'endscrap\n';
      final (TH2TextMatchSide live, _) = await side(text);
      final (TH2TextMatchSide detached, _) = await side(text);
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );

      for (final String line in <String>['    1 1', '    2 2', '  endline']) {
        for (final int occurrence in <int>[0, 1]) {
          expect(
            matching[ownerOfText(
              detached.$2,
              detached.$3,
              line,
              occurrence: occurrence,
            )],
            ownerOfText(live.$2, live.$3, line, occurrence: occurrence),
            reason: '$line #$occurrence',
          );
        }
      }
    });

    test('lines differing only in their ending match', () async {
      const String text =
          'encoding utf-8\r\n'
          'scrap s1\r\n'
          '  point 1 1 station\r\n'
          'endscrap\r\n';
      final (TH2TextMatchSide live, _) = await side(text);
      final (TH2TextMatchSide detached, _) = await side(
        text.replaceFirst('station\r\n', 'station\n'),
      );
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );

      expect(
        matching[ownerOfText(detached.$2, detached.$3, '  point 1 1 station')],
        ownerOfText(live.$2, live.$3, '  point 1 1 station'),
      );
    });

    test('containers with no substantive matched child stay unmatched', () async {
      final (TH2TextMatchSide live, _) = await side(
        'encoding utf-8\n'
        'scrap a\n'
        '  # a comment\n'
        'endscrap\n'
        'scrap b\n'
        'endscrap\n',
      );
      final (TH2TextMatchSide detached, _) = await side(
        'encoding utf-8\n'
        'scrap c\n'
        '  # a comment\n'
        'endscrap\n'
        'scrap d\n'
        'endscrap\n',
      );
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );

      expect(
        matching.containsKey(ownerOfText(detached.$2, detached.$3, 'scrap c')),
        isFalse,
      );
      expect(
        matching.containsKey(ownerOfText(detached.$2, detached.$3, 'scrap d')),
        isFalse,
      );
    });

    test('a container whose children come from two candidates matches neither', () async {
      final (TH2TextMatchSide live, _) = await side(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id a\n'
        '    1 1\n'
        '    2 2\n'
        '  endline\n'
        '  line wall -id b\n'
        '    3 3\n'
        '    4 4\n'
        '  endline\n'
        'endscrap\n',
      );
      final (TH2TextMatchSide detached, _) = await side(
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id c\n'
        '    1 1\n'
        '    2 2\n'
        '    3 3\n'
        '    4 4\n'
        '  endline\n'
        'endscrap\n',
      );
      final Map<int, int> matching = TH2TextIdentityMatcher.match(
        live: live,
        detached: detached,
      );

      expect(
        matching.containsKey(
          ownerOfText(detached.$2, detached.$3, '  line wall -id c'),
        ),
        isFalse,
      );
      expect(
        matching[ownerOfText(detached.$2, detached.$3, '    3 3')],
        ownerOfText(live.$2, live.$3, '    3 3'),
      );
    });
  });

  group('through applyTextContent', () {
    test('a point cut and pasted into another scrap keeps its MPID', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station -id p1\n'
          '  point 2 2 station\n'
          'endscrap\n'
          'scrap s2\n'
          'endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final int p1 = liveOwner(controller, '  point 1 1 station -id p1');
      final int s2 = liveOwner(controller, 'scrap s2');

      await apply(
        controller,
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 2 2 station\n'
        'endscrap\n'
        'scrap s2\n'
        '  point 1 1 station -id p1\n'
        'endscrap\n',
      );

      expect(liveOwner(controller, '  point 1 1 station -id p1'), p1);
      expect(controller.th2File.elementByMPID(p1).parentMPID, s2);
    });

    test('a line moved to another scrap is matched with its children', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '  line wall -id moving\n'
          '    1 1\n'
          '    2 2\n'
          '  endline\n'
          '  line wall -id other\n'
          '    1 1\n'
          '    2 2\n'
          '  endline\n'
          'endscrap\n'
          'scrap s2\n'
          'endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final List<int> before = <int>[
        liveOwner(controller, '  line wall -id moving'),
        liveOwner(controller, '    1 1'),
        liveOwner(controller, '    2 2'),
        liveOwner(controller, '  endline'),
      ];

      await apply(
        controller,
        'encoding utf-8\n'
        'scrap s1\n'
        '  line wall -id other\n'
        '    1 1\n'
        '    2 2\n'
        '  endline\n'
        'endscrap\n'
        'scrap s2\n'
        '  line wall -id moving\n'
        '    1 1\n'
        '    2 2\n'
        '  endline\n'
        'endscrap\n',
      );

      expect(<int>[
        liveOwner(controller, '  line wall -id moving'),
        liveOwner(controller, '    1 1', occurrence: 1),
        liveOwner(controller, '    2 2', occurrence: 1),
        liveOwner(controller, '  endline', occurrence: 1),
      ], before);
    });

    for (final (String name, String newScrap, String newLine)
        in <(String, String, String)>[
          ('a scrap header', 'scrap s1 -projection plan', '  line wall'),
          ('a line header', 'scrap s1', '  line wall -id w'),
          ('both headers', 'scrap s1 -projection plan', '  line wall -id w'),
        ]) {
      test('editing $name keeps the MPIDs', () async {
        const String text =
            'encoding utf-8\n'
            'scrap s1\n'
            '  point 5 5 station\n'
            '  line wall\n'
            '    1 1\n'
            '    2 2\n'
            '  endline\n'
            'endscrap\n';
        final TH2FileEditController controller = await TH2TextApplyTestAux
            .load(text);
        final List<int> before = <int>[
          liveOwner(controller, 'scrap s1'),
          liveOwner(controller, '  point 5 5 station'),
          liveOwner(controller, '  line wall'),
          liveOwner(controller, '    1 1'),
          liveOwner(controller, '    2 2'),
          liveOwner(controller, '  endline'),
          liveOwner(controller, 'endscrap'),
        ];

        final TH2TextApplyResult result = await apply(
          controller,
          text
              .replaceFirst('scrap s1\n', '$newScrap\n')
              .replaceFirst('  line wall\n', '$newLine\n'),
        );

        expect(result, isA<TH2TextApplyApplied>());
        expect(<int>[
          liveOwner(controller, newScrap),
          liveOwner(controller, '  point 5 5 station'),
          liveOwner(controller, newLine),
          liveOwner(controller, '    1 1'),
          liveOwner(controller, '    2 2'),
          liveOwner(controller, '  endline'),
          liveOwner(controller, 'endscrap'),
        ], before);
      });
    }

    test('a wholesale replacement keeps no drawing MPIDs and undoes exactly', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '\n'
          '  # comment\n'
          '  line wall\n'
          '    1 1\n'
          '    2 2\n'
          '  endline\n'
          '  line border -id b -close on\n'
          '    0 0\n'
          '    5 0\n'
          '    5 5\n'
          '    0 0\n'
          '  endline\n'
          '  area water\n'
          '    b\n'
          '  endarea\n'
          'endscrap\n';
      const String replaced =
          'encoding utf-8\n'
          'scrap s9\n'
          '\n'
          '  # comment\n'
          '  line pit\n'
          '    7 7\n'
          '    8 8\n'
          '  endline\n'
          '  line border -id c -close on\n'
          '    10 10\n'
          '    15 10\n'
          '    15 15\n'
          '    10 10\n'
          '  endline\n'
          '  area clay\n'
          '    c\n'
          '  endarea\n'
          'endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final Map<String, dynamic> modelBefore = controller.th2File.toMap();
      final Set<int> mpIDsBefore = controller.th2File.elements.keys.toSet();
      final int encoding = liveOwner(controller, 'encoding utf-8');

      final TH2TextApplyResult result = await apply(controller, replaced);

      expect(result, isA<TH2TextApplyApplied>());
      expect(controller.serializeForTextMode().$1, replaced);
      expect(liveOwner(controller, 'encoding utf-8'), encoding);
      for (final String line in <String>[
        'scrap s9',
        '',
        '  # comment',
        '  line pit',
        '    7 7',
        '  endline',
        '  area clay',
        '    c',
        '  endarea',
        'endscrap',
      ]) {
        expect(
          mpIDsBefore.contains(liveOwner(controller, line)),
          isFalse,
          reason: line,
        );
      }

      controller.undo();

      expect(controller.serializeForTextMode().$1, text);
      expect(controller.th2File.toMap(), modelBefore);
    });

    test('a 1,000-line block deleted and pasted elsewhere keeps its MPIDs', () async {
      final StringBuffer block = StringBuffer();

      for (int i = 0; i < 1000; i++) {
        block.write('  point $i ${i * 2} station\n');
      }

      final String text =
          'encoding utf-8\n'
          'scrap s1\n'
          '${block}endscrap\n'
          'scrap s2\n'
          '  point -1 -1 station\n'
          'endscrap\n';
      final String moved =
          'encoding utf-8\n'
          'scrap s1\n'
          'endscrap\n'
          'scrap s2\n'
          '  point -1 -1 station\n'
          '${block}endscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final (String liveText, TH2TextLineMap liveMap) = controller
          .serializeForTextMode();
      final List<int> before = <int>[
        for (int line = 2; line < 1002; line++) liveMap.ownerOfLine(line)!,
      ];

      expect(liveText, text);

      final TH2TextApplyResult result = await apply(controller, moved);

      expect(result, isA<TH2TextApplyApplied>());

      final TH2TextLineMap afterMap = (result as TH2TextApplyApplied).lineMap;

      expect(<int>[
        for (int line = 5; line < 1005; line++) afterMap.ownerOfLine(line)!,
      ], before);
    });
  });
}
