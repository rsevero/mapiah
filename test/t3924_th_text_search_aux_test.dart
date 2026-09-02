// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show TextRange;

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_text_search_aux.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  List<TextRange> matches(
    String content,
    String query, {
    bool caseSensitive = false,
  }) => findPlainTextMatches(
    content: content,
    query: query,
    caseSensitive: caseSensitive,
  );

  void expectAllRangesWithinContent(List<TextRange> ranges, String content) {
    for (final TextRange range in ranges) {
      expect(range.start, greaterThanOrEqualTo(0));
      expect(range.end, greaterThan(range.start));
      expect(range.end, lessThanOrEqualTo(content.length));
    }
  }

  group('findPlainTextMatches — structural compatibility', () {
    test('empty query returns no matches', () {
      expect(matches('survey one', ''), isEmpty);
    });

    test('no matches when the substring is absent', () {
      expect(matches('survey one', 'zzz'), isEmpty);
    });

    test('query longer than content returns no matches', () {
      expect(matches('short', 'a much longer query'), isEmpty);
    });

    test('non-overlapping, left-to-right matches', () {
      expect(matches('aaaa', 'aa', caseSensitive: true), <TextRange>[
        const TextRange(start: 0, end: 2),
        const TextRange(start: 2, end: 4),
      ]);
    });

    test('case-insensitive by default', () {
      expect(matches('Survey One\nEndsurvey', 'survey'), hasLength(2));
    });

    test('case-sensitive when requested', () {
      final List<TextRange> result = matches(
        'Survey One\nendsurvey',
        'survey',
        caseSensitive: true,
      );

      expect(result, hasLength(1));
      expect(result.single, const TextRange(start: 14, end: 20));
    });

    test('ASCII / Latin-1 folding is unchanged from a plain lowercase scan', () {
      const String content = 'Café ÑOÑO çedilha CAFÉ';

      expect(matches(content, 'café'), <TextRange>[
        const TextRange(start: 0, end: 4),
        const TextRange(start: 18, end: 22),
      ]);
      expect(matches(content, 'ñoño'), <TextRange>[
        const TextRange(start: 5, end: 9),
      ]);
    });
  });

  group('findPlainTextMatches — Unicode offset safety', () {
    // Dart's String.toLowerCase() is 1:1 in UTF-16 length for every code
    // point, so folded offsets always coincide with original offsets. The
    // per-rune fold + source-map machinery in the matcher is defensive: these
    // cases lock in that returned ranges always index the original content.

    test('a cased character before the term does not shift the range', () {
      // 'İ' (U+0130) folds to 'i', one UTF-16 unit, so 'survey' stays at 2.
      const String content = 'İ survey';
      final List<TextRange> result = matches(content, 'survey');

      expect(result.single, const TextRange(start: 2, end: 8));
      expectAllRangesWithinContent(result, content);
    });

    test('searching plain "i" in "İ" returns the non-empty [0, 1] range', () {
      const String content = 'İ';
      final List<TextRange> result = matches(content, 'i');

      expect(result.single, const TextRange(start: 0, end: 1));
      expect(content.substring(result.single.start, result.single.end), 'İ');
    });

    test('a bare combining mark has no match in "İ" (Dart does not decompose)', () {
      const String content = 'İ';

      expect(matches(content, '̇'), isEmpty);
    });

    test('repeated adjacent cased chars never emit duplicate/overlapping ranges', () {
      const String content = 'İİİ';
      final List<TextRange> result = matches(content, 'i');

      expect(result, <TextRange>[
        const TextRange(start: 0, end: 1),
        const TextRange(start: 1, end: 2),
        const TextRange(start: 2, end: 3),
      ]);

      int previousEnd = 0;
      for (final TextRange range in result) {
        expect(range.start, greaterThanOrEqualTo(previousEnd));
        expect(range.end, greaterThan(range.start));
        previousEnd = range.end;
      }
    });

    test('every returned range is usable for substring/replacement', () {
      const String content = 'aİbİc';
      final List<TextRange> result = matches(content, 'i');

      String replaced = content;
      for (final TextRange range in result.reversed) {
        replaced = replaced.replaceRange(range.start, range.end, 'X');
      }

      expect(replaced, 'aXbXc');
    });

    test('mixed İ / i / I hits and ranges', () {
      const String content = 'İiI';
      final List<TextRange> result = matches(content, 'i');

      expect(result, hasLength(3));
      expectAllRangesWithinContent(result, content);
    });

    test('a precomposed query matches its own folded form in content', () {
      const String content = 'x İ y';
      final List<TextRange> result = matches(content, 'İ');

      expect(result.single.start, 2);
      expect(content.substring(result.single.start, result.single.end), 'İ');
    });

    test('non-BMP cased text proves rune iteration (Deseret)', () {
      // U+10400 DESERET CAPITAL LETTER LONG I -> U+10428 small.
      const String upper = '\u{10400}\u{10401}';
      const String lower = '\u{10428}\u{10429}';
      final String content = '$upper mid $lower';

      final List<TextRange> result = matches(content, lower);

      expect(result, hasLength(2));
      expectAllRangesWithinContent(result, content);
    });
  });

  group('line / column / preview helpers', () {
    const String content = 'first line\nsecond line here\nthird';

    test('lineNumberForOffset is one-based and counts newlines', () {
      expect(lineNumberForOffset(content, 0), 1);
      expect(lineNumberForOffset(content, 11), 2);
      expect(lineNumberForOffset(content, content.length), 3);
    });

    test('columnNumberForOffset is one-based from the line start', () {
      expect(columnNumberForOffset(content, 0), 1);
      expect(columnNumberForOffset(content, 11), 1);
      expect(columnNumberForOffset(content, 18), 8);
    });

    test('buildLinePreview trims leading whitespace but keeps the match', () {
      const String indented = 'scrap s1\n        point 0 0 station\nendscrap';
      final TextRange range = matches(indented, 'point').single;
      final THTextSearchLinePreview preview = buildLinePreview(
        content: indented,
        matchRange: range,
      );

      expect(preview.preview.startsWith('point 0 0 station'), isTrue);
      expect(
        preview.preview.substring(
          preview.matchRange.start,
          preview.matchRange.end,
        ),
        'point',
      );
    });

    test('buildLinePreview windows a long line around the match', () {
      final String longLine = '${'a' * 400}NEEDLE${'b' * 400}';
      final TextRange range = matches(
        longLine,
        'NEEDLE',
        caseSensitive: true,
      ).single;
      final THTextSearchLinePreview preview = buildLinePreview(
        content: longLine,
        matchRange: range,
        maxLength: 80,
      );

      expect(preview.preview.length, lessThanOrEqualTo(80));
      expect(
        preview.preview.substring(
          preview.matchRange.start,
          preview.matchRange.end,
        ),
        'NEEDLE',
      );
    });
  });
}
