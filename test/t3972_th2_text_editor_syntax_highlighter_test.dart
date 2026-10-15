// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_syntax_highlighter.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import 'auxiliary/th2_text_edit_fake_owner.dart';
import 'th_test_aux.dart';

const THTextEditorTokenType _k = THTextEditorTokenType.keyword;
const THTextEditorTokenType _o = THTextEditorTokenType.option;
const THTextEditorTokenType _c = THTextEditorTokenType.comment;
const THTextEditorTokenType _s = THTextEditorTokenType.string;
const THTextEditorTokenType _n = THTextEditorTokenType.number;
const THTextEditorTokenType _r = THTextEditorTokenType.stationReference;
const THTextEditorTokenType _p = THTextEditorTokenType.plain;
const THTextEditorTokenType _t = THTextEditorTokenType.setting;

/// The (text, type) of each TH2 token of [text].
List<(String, THTextEditorTokenType)> _lex(String text) {
  return tokenizeTherionText(text, language: THTextEditorLanguage.th2)
      .map(
        (THTextEditorToken token) =>
            (text.substring(token.start, token.end), token.type),
      )
      .toList();
}

/// The types of the tokens whose text is [fragment].
List<THTextEditorTokenType> _typesOf(String text, String fragment) {
  return _lex(text)
      .where(((String, THTextEditorTokenType) token) => token.$1 == fragment)
      .map(((String, THTextEditorTokenType) token) => token.$2)
      .toList();
}

List<THTextEditorFoldRegion> _folds(String text) =>
    buildFoldRegions(text, language: THTextEditorLanguage.th2);

/// A scrap with [lineCount] lines of [pointsPerLine] points each, as in
/// t3971.
String _generatedText({int lineCount = 300, int pointsPerLine = 10}) {
  final StringBuffer text = StringBuffer('encoding utf-8\nscrap s1\n');

  for (int line = 0; line < lineCount; line++) {
    text.write('  line wall -id l$line\n');
    for (int point = 0; point < pointsPerLine; point++) {
      text.write('    ${line * 100 + point} ${point * 3}\n');
    }
    text.write('  endline\n');
    text.write('  point $line ${line + 7} station -id p$line\n');
  }
  text.write('endscrap\nscrap s2\nendscrap\n');

  return text.toString();
}

const List<String> _keywords = <String>[
  'scrap',
  'endscrap',
  'point',
  'line',
  'endline',
  'area',
  'endarea',
  'endcomment',
];

const List<String> _lineOptionWords = <String>[
  'adjust',
  'altitude',
  'anchors',
  'border',
  'clip',
  'close',
  'context',
  'direction',
  'gradient',
  'head',
  'height',
  'id',
  'scale',
  'l-size',
  'size',
  'mark',
  'orientation',
  'orient',
  'outline',
  'place',
  'rebelays',
  'reverse',
  'smooth',
  'subtype',
  'text',
  'visibility',
];

const List<String> _areaOptionWords = <String>[
  'clip',
  'context',
  'id',
  'place',
  'visibility',
];

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  group('TH2 keywords', () {
    test('every keyword, in any case, as a first word', () {
      for (final String keyword in _keywords) {
        for (final String word in <String>[keyword, keyword.toUpperCase()]) {
          expect(
            _lex('  $word x').first,
            (word, _k),
            reason: word,
          );
        }
      }
      expect(_lex('encoding utf-8').first, ('encoding', _k));
      expect(_lex('ENCODING utf-8').first, ('ENCODING', _k));
      expect(_lex('comment\nendcomment').first, ('comment', _k));
      expect(_lex('COMMENT\nendcomment').first, ('COMMENT', _k));
    });

    test('the same words elsewhere are plain', () {
      expect(_typesOf('point 1 2 u:point -context point anchor', 'point'), <
        THTextEditorTokenType
      >[_k, _p]);
      expect(_lex('point 1 2 u:point').last, ('u:point', _p));
      expect(_typesOf('point 1 2 x -context line fault', 'line'), <
        THTextEditorTokenType
      >[_p]);
      expect(_typesOf('point 1 2 scrap', 'scrap'), <THTextEditorTokenType>[
        _p,
      ]);
    });

    test('encoding is a keyword only on the first non-blank line', () {
      expect(_typesOf('\n  \nencoding utf-8', 'encoding'), <
        THTextEditorTokenType
      >[_k]);
      expect(_typesOf('scrap s\nencoding utf-8', 'encoding'), <
        THTextEditorTokenType
      >[_p]);
    });

    test('comment opens a block only before nothing or an inline comment', () {
      expect(_lex('comment foo\nscrap s'), <(String, THTextEditorTokenType)>[
        ('comment', _p),
        ('foo', _p),
        ('scrap', _k),
        ('s', _p),
      ]);
      expect(_folds('comment foo\nendcomment'), isEmpty);
      expect(_lex('comment # note\nscrap'), <(String, THTextEditorTokenType)>[
        ('comment', _k),
        ('# note', _c),
        ('scrap', _c),
      ]);
    });

    test('comment#c opens and endcomment#x closes a comment block', () {
      const String text = 'comment#c\nscrap s\nendcomment#x\nscrap t';

      expect(_lex(text), <(String, THTextEditorTokenType)>[
        ('comment', _k),
        ('#c', _c),
        ('scrap s', _c),
        ('endcomment', _k),
        ('#x', _c),
        ('scrap', _k),
        ('t', _p),
      ]);
      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 2),
      ]);
    });

    test('glued endcomment forms close a comment block', () {
      for (final String closer in <String>[
        'endcomment foo',
        'endcommentx',
        'endcomment"x"',
        '  ENDCOMMENT',
      ]) {
        final String text = 'comment\nbody\n$closer\nscrap s';

        expect(_typesOf(text, 'scrap'), <THTextEditorTokenType>[
          _k,
        ], reason: closer);
        expect(_folds(text), const <THTextEditorFoldRegion>[
          THTextEditorFoldRegion(startLine: 0, endLine: 2),
        ], reason: closer);
      }
    });

    test('endcomment only closes as the start of a body line', () {
      const String text = 'comment\nfoo endcomment\n"endcomment"\nscrap s';

      expect(_typesOf(text, 'scrap s'), <THTextEditorTokenType>[_c]);
      expect(_folds(text), isEmpty);
    });
  });

  group('TH2 option lines', () {
    test('every line option word starts an option line in a line block', () {
      for (final String word in _lineOptionWords) {
        for (final String spelled in <String>[word, word.toUpperCase()]) {
          final String text = 'line wall\n  $spelled 1\nendline';

          expect(_typesOf(text, spelled), <THTextEditorTokenType>[
            _o,
          ], reason: spelled);
        }
      }
    });

    test('every area option word starts an option line in an area block', () {
      for (final String word in _areaOptionWords) {
        final String text = 'area water\n  $word on\nendarea';

        expect(_typesOf(text, word), <THTextEditorTokenType>[
          _o,
        ], reason: word);
      }
    });

    test('option words are plain elsewhere', () {
      expect(_typesOf('scrap s\ntext x\nendscrap', 'text'), <
        THTextEditorTokenType
      >[_p]);
      expect(_typesOf('area water\n  text x\nendarea', 'text'), <
        THTextEditorTokenType
      >[_p]);
      expect(_typesOf('line wall\n  1 2 text\nendline', 'text'), <
        THTextEditorTokenType
      >[_p]);
      expect(_typesOf('line wall\n  "text"\nendline', '"text"'), <
        THTextEditorTokenType
      >[_s]);
      expect(_typesOf('line wall\nendline\ntext x', 'text'), <
        THTextEditorTokenType
      >[_p]);
    });

    test('l-size and size are one option word each', () {
      expect(_lex('line slope\n  l-size 3\nendline')[2], ('l-size', _o));
      expect(_lex('line slope\n  size 3\nendline')[2], ('size', _o));
    });

    test('size3 glued to its argument stays plain', () {
      expect(_typesOf('line slope\n  size3\nendline', 'size3'), <
        THTextEditorTokenType
      >[_p]);
    });
  });

  group('TH2 settings', () {
    test('both prefixes at file level, indented and in any case', () {
      for (final String line in <String>[
        '##XTHERION## xth_me_area_adjust 0 0 1 1',
        '  ##XTHERION## xth_me_area_adjust 0 0 1 1',
        '##xtherion## xth_me_area_adjust 0 0 1 1',
        '##MAPIAH## mapiah_setting 1',
        '##mapiah## mapiah_setting 1',
        '##XTHERION##xth_me_area_adjust 0 0 1 1',
      ]) {
        expect(_lex(line), <(String, THTextEditorTokenType)>[
          (line.trimLeft(), _t),
        ], reason: line);
      }
    });

    test('a prefix without keyword and value is a comment', () {
      for (final String line in <String>[
        '##XTHERION##',
        '##MAPIAH##',
        '##XTHERION## xth_me_area_adjust',
        '##XTHERION## !foo',
        '##XTHERION##abc',
      ]) {
        expect(_lex(line), <(String, THTextEditorTokenType)>[
          (line, _c),
        ], reason: line);
      }
    });

    test('inside a scrap, line or area a setting is a comment', () {
      for (final String block in <String>[
        'scrap s',
        'line wall',
        'area water',
      ]) {
        const String setting = '##XTHERION## xth_me_area_adjust 0 0 1 1';

        expect(_typesOf('$block\n$setting', setting), <
          THTextEditorTokenType
        >[_c], reason: block);
      }
    });
  });

  group('TH2 comment blocks', () {
    test('apparent commands and settings in the body are comment', () {
      const String text =
          'comment\nscrap s\n##XTHERION## xth_me_area_adjust 0 0 1 1\n'
          'endscrap\nendcomment';

      expect(_lex(text), <(String, THTextEditorTokenType)>[
        ('comment', _k),
        ('scrap s', _c),
        ('##XTHERION## xth_me_area_adjust 0 0 1 1', _c),
        ('endscrap', _c),
        ('endcomment', _k),
      ]);
      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 4),
      ]);
    });

    test('a body line ending in \\ keeps the block open past endcomment', () {
      const String text = 'comment\nbody \\\nendcomment\nscrap s';

      expect(_typesOf(text, 'scrap s'), <THTextEditorTokenType>[_c]);
      expect(_folds(text), isEmpty);
    });
  });

  group('TH2 words and values', () {
    test('numbers, strings and inline comments', () {
      expect(
        _lex('point 1.5 -2 station -text "a b" # note'),
        <(String, THTextEditorTokenType)>[
          ('point', _k),
          ('1.5', _n),
          ('-2', _n),
          ('station', _p),
          ('-text', _o),
          ('"a b"', _s),
          ('# note', _c),
        ],
      );
      expect(_typesOf('point 1 2 x -value +3', '+3'), <THTextEditorTokenType>[
        _n,
      ]);
    });

    test('"" escapes a quote and brackets nest', () {
      expect(_lex('point 1 2 x -text "a ""b"" c" d').sublist(5), <
        (String, THTextEditorTokenType)
      >[('"a ""b"" c"', _s), ('d', _p)]);
      expect(_lex('point 1 2 x -value [1 [2] 3] d').sublist(5), <
        (String, THTextEditorTokenType)
      >[('[1 [2] 3]', _s), ('d', _p)]);
    });

    test("' is plain text", () {
      expect(_typesOf("point 1 2 x -text 'a'", "'a'"), <
        THTextEditorTokenType
      >[_p]);
    });

    test('an open value ends at the end of its line', () {
      expect(_lex('point 1 2 x -text "open\n-id p1').sublist(5), <
        (String, THTextEditorTokenType)
      >[('"open', _s), ('-id', _o), ('p1', _p)]);
      expect(_typesOf('point 1 2 x -value [open\n-id', '-id'), <
        THTextEditorTokenType
      >[_o]);
    });

    test('dash options and signed numbers start only at a word start', () {
      expect(_lex('point 1 2 x -align bottom-left top-right').sublist(4), <
        (String, THTextEditorTokenType)
      >[('-align', _o), ('bottom-left', _p), ('top-right', _p)]);
      expect(_typesOf('point 1 2 a+3', 'a+3'), <THTextEditorTokenType>[_p]);
      expect(_lex('point 1 2 x -station-names a b').sublist(4, 5), <
        (String, THTextEditorTokenType)
      >[('-station-names', _o)]);
    });

    test('words that are not whole numbers are plain', () {
      expect(_typesOf('point 1 2 x 2024.01.02', '2024.01.02'), <
        THTextEditorTokenType
      >[_p]);
      expect(_typesOf('point 1 2 x 3rd', '3rd'), <THTextEditorTokenType>[_p]);
      expect(_typesOf('point 1 2 x 1e3', '1e3'), <THTextEditorTokenType>[_p]);
    });

    test('station references and bracket values', () {
      expect(_typesOf('point 1 2 station -name 1@cave', '1@cave'), <
        THTextEditorTokenType
      >[_r]);
      expect(_typesOf('point 1 2 x -value [1 m]', '[1 m]'), <
        THTextEditorTokenType
      >[_s]);
    });

    test('# " and [ open nothing inside a comment or a word', () {
      expect(_lex('point 1 2 x # a "b [c #d\n-id p'), <
        (String, THTextEditorTokenType)
      >[
        ('point', _k),
        ('1', _n),
        ('2', _n),
        ('x', _p),
        ('# a "b [c #d', _c),
        ('-id', _o),
        ('p', _p),
      ]);
      expect(_typesOf('point 1 2 a#b', 'a#b'), <THTextEditorTokenType>[_p]);
      expect(_typesOf('point 1 2 a"b', 'a"b'), <THTextEditorTokenType>[_p]);
      expect(_typesOf('point 1 2 a[b', 'a[b'), <THTextEditorTokenType>[_p]);
    });

    test('closing delimiters restore normal tokens', () {
      expect(_lex('point 1 2 x -text "a" -id p1').sublist(4), <
        (String, THTextEditorTokenType)
      >[('-text', _o), ('"a"', _s), ('-id', _o), ('p1', _p)]);
    });
  });

  group('TH2 line continuations', () {
    test('a trailing \\ continues a comment as comment', () {
      expect(_lex('point 1 2 x # note \\\nmore'), <
        (String, THTextEditorTokenType)
      >[
        ('point', _k),
        ('1', _n),
        ('2', _n),
        ('x', _p),
        ('# note \\', _c),
        ('more', _c),
      ]);
    });

    test('a continued quoted value keeps its value tokens and #', () {
      expect(_lex('point 1 2 x -text "a # \\\nb" -id p').sublist(4), <
        (String, THTextEditorTokenType)
      >[('-text', _o), ('"a # \\', _s), ('b"', _s), ('-id', _o), ('p', _p)]);
      expect(_lex('point 1 2 x -value [1 \\\n2] 3').sublist(5), <
        (String, THTextEditorTokenType)
      >[('[1 \\', _s), ('2]', _s), ('3', _n)]);
    });

    test('a \\ with no whitespace before it continues the same word', () {
      expect(_lex('point 1 2 ab\\\n#c "d'), <(String, THTextEditorTokenType)>[
        ('point', _k),
        ('1', _n),
        ('2', _n),
        ('ab\\', _p),
        ('#c', _p),
        ('"d', _s),
      ]);
      expect(_typesOf('point 1 2 ab\\\n"c"', '"c"'), <THTextEditorTokenType>[
        _p,
      ]);
      expect(_typesOf('point 1 2 ab\\\n[c]', '[c]'), <THTextEditorTokenType>[
        _p,
      ]);
    });

    test('continuations keep numbers, options, strings and comments', () {
      const String text =
          'point 1 2 label \\\n  -text "label" # note\nscrap s';

      expect(_lex(text), <(String, THTextEditorTokenType)>[
        ('point', _k),
        ('1', _n),
        ('2', _n),
        ('label', _p),
        ('-text', _o),
        ('"label"', _s),
        ('# note', _c),
        ('scrap', _k),
        ('s', _p),
      ]);
    });

    test('a continuation starts no command, option line or fold', () {
      const String text =
          'line wall\n  1 2 \\\n  text x\n  1 2 \\\nendline\nendline\n'
          'point 1 2 x \\\nscrap s';

      expect(_typesOf(text, 'text'), <THTextEditorTokenType>[_p]);
      expect(_typesOf(text, 'endline'), <THTextEditorTokenType>[_p, _k]);
      expect(_typesOf(text, 'scrap'), <THTextEditorTokenType>[_p]);
      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 5),
      ]);
    });

    test("the writer's wrapped long lines keep their tokens", () {
      const String text =
          'scrap s1 -author 2024.01.01 "Some Name" \\\n'
          '  -copyright 2024.01.01 "Holder" \\\n'
          '  -title "A long title"\nendscrap';

      expect(_lex(text), <(String, THTextEditorTokenType)>[
        ('scrap', _k),
        ('s1', _p),
        ('-author', _o),
        ('2024.01.01', _p),
        ('"Some Name"', _s),
        ('-copyright', _o),
        ('2024.01.01', _p),
        ('"Holder"', _s),
        ('-title', _o),
        ('"A long title"', _s),
        ('endscrap', _k),
      ]);
      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 3),
      ]);
    });
  });

  group('TH2 offsets and endings', () {
    test('CRLF and mixed endings keep exact offsets', () {
      const String text = 'scrap s\r\n  point 1 2 x\n# c\r\nendscrap';
      final List<THTextEditorToken> tokens = tokenizeTherionText(
        text,
        language: THTextEditorLanguage.th2,
      );

      for (final THTextEditorToken token in tokens) {
        final String tokenText = text.substring(token.start, token.end);

        expect(tokenText.contains('\r'), isFalse, reason: tokenText);
        expect(tokenText.contains('\n'), isFalse, reason: tokenText);
      }
      expect(_lex(text), <(String, THTextEditorTokenType)>[
        ('scrap', _k),
        ('s', _p),
        ('point', _k),
        ('1', _n),
        ('2', _n),
        ('x', _p),
        ('# c', _c),
        ('endscrap', _k),
      ]);
      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 3),
      ]);
    });

    test('a CRLF continuation and an unterminated last line', () {
      expect(_lex('point 1 2 x # a \\\r\nb'), containsAllInOrder(
        <(String, THTextEditorTokenType)>[('# a \\', _c), ('b', _c)],
      ));
      expect(_lex('scrap'), <(String, THTextEditorTokenType)>[('scrap', _k)]);
      expect(_lex(''), isEmpty);
    });
  });

  group('TH2 folds', () {
    test('scrap, line, area and comment blocks', () {
      const String text =
          'scrap s\n  line wall\n    1 2\n  endline\n  area water\n    l1\n'
          '  endarea\n  comment\n    x\n  endcomment\nendscrap';

      expect(_folds(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 10),
        THTextEditorFoldRegion(startLine: 1, endLine: 3),
        THTextEditorFoldRegion(startLine: 4, endLine: 6),
        THTextEditorFoldRegion(startLine: 7, endLine: 9),
      ]);
    });

    test('malformed and unfinished blocks', () {
      expect(_folds('scrap s\n  line wall\n    1 2\nendscrap'), const <
        THTextEditorFoldRegion
      >[THTextEditorFoldRegion(startLine: 0, endLine: 3)]);
      expect(_folds('scrap s\n  line wall'), isEmpty);
      expect(_folds('endline\nendscrap'), isEmpty);
      expect(_lex('point 1 2 x -text "open'), isNotEmpty);
    });

    test('project fold regions and tokens are unchanged by default', () {
      const String text = 'survey s\n  scrap x\n  endscrap\nendsurvey';

      expect(buildFoldRegions(text), const <THTextEditorFoldRegion>[
        THTextEditorFoldRegion(startLine: 0, endLine: 3),
        THTextEditorFoldRegion(startLine: 1, endLine: 2),
      ]);
      expect(
        tokenizeTherionText("cs 'UTM 33N' 6.02e23 a@b"),
        tokenizeTherionText(
          "cs 'UTM 33N' 6.02e23 a@b",
          language: THTextEditorLanguage.therion,
        ),
      );
      expect(
        tokenizeTherionText("cs 'UTM'")
            .map((THTextEditorToken token) => token.type)
            .toList(),
        <THTextEditorTokenType>[_k, _s],
      );
    });
  });

  group('TH2 performance', () {
    test('tokens of a large text are computed within a time bound', () {
      final String text = _generatedText();
      final Stopwatch stopwatch = Stopwatch()..start();
      final List<THTextEditorToken> tokens = tokenizeTherionText(
        text,
        language: THTextEditorLanguage.th2,
      );

      stopwatch.stop();
      expect(tokens, isNotEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('a cursor move does not recompute the tokens', () {
      final TH2TextEditController controller = th2TextEditControllerWithSession(
        TH2TextEditFakeOwner(),
        _generatedText(),
      );
      final List<List<THTextEditorToken>> reads = <List<THTextEditorToken>>[];
      final ReactionDisposer dispose = autorun((_) {
        controller.cursorLine;
        reads.add(controller.tokens);
      });

      controller.setCursorPosition(line: 5, column: 2);
      controller.setCursorPosition(line: 9, column: 0);
      expect(reads, hasLength(3));
      expect(identical(reads[0], reads[1]), isTrue);
      expect(identical(reads[1], reads[2]), isTrue);

      controller.setContent('${controller.content}x');
      expect(identical(reads.last, reads.first), isFalse);

      dispose();
      controller.dispose();
    });

    test('overlay spans with many find matches are built within a bound', () {
      final String text = _generatedText();
      final List<THTextEditorToken> tokens = tokenizeTherionText(
        text,
        language: THTextEditorLanguage.th2,
      );
      final List<TextRange> matches = <TextRange>[];
      int index = text.indexOf('line');

      while (index != -1) {
        matches.add(TextRange(start: index, end: index + 4));
        index = text.indexOf('line', index + 4);
      }

      final Stopwatch stopwatch = Stopwatch()..start();
      final List<InlineSpan> spans = buildTHTextEditorOverlaySpans(
        content: text,
        tokens: tokens,
        tokenColors: const <THTextEditorTokenType, Color>{},
        findMatches: matches,
        activeMatchIndex: 3,
        findMatchColor: const Color(0x11000000),
        activeFindMatchColor: const Color(0x22000000),
      );

      stopwatch.stop();
      expect(matches.length, greaterThan(500));
      expect(
        spans.map((InlineSpan span) => (span as TextSpan).text).join(),
        text,
      );
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('overlay spans carry token colors and match backgrounds', () {
      const String text = 'scrap s1';
      const Color keywordColor = Color(0xFF000001);
      const Color matchColor = Color(0xFF000002);
      const Color activeColor = Color(0xFF000003);
      final List<InlineSpan> spans = buildTHTextEditorOverlaySpans(
        content: text,
        tokens: tokenizeTherionText(text, language: THTextEditorLanguage.th2),
        tokenColors: const <THTextEditorTokenType, Color>{_k: keywordColor},
        findMatches: const <TextRange>[
          TextRange(start: 3, end: 7),
          TextRange(start: 7, end: 8),
        ],
        activeMatchIndex: 1,
        findMatchColor: matchColor,
        activeFindMatchColor: activeColor,
      );
      final List<(String?, Color?, Color?)> parts = spans
          .map((InlineSpan span) {
            final TextSpan textSpan = span as TextSpan;

            return (
              textSpan.text,
              textSpan.style?.color,
              textSpan.style?.backgroundColor,
            );
          })
          .toList();

      expect(parts, <(String?, Color?, Color?)>[
        ('scr', keywordColor, null),
        ('ap', keywordColor, matchColor),
        (' ', null, matchColor),
        ('s', null, matchColor),
        ('1', null, activeColor),
      ]);
    });
  });
}
