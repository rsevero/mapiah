// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_syntax_highlighter.dart';

void main() {
  String textAt(String source, THTextEditorToken token) =>
      source.substring(token.start, token.end);

  List<THTextEditorToken> tokensOfType(
    String source,
    THTextEditorTokenType type,
  ) {
    return tokenizeTherionText(
      source,
    ).where((THTextEditorToken token) => token.type == type).toList();
  }

  group('tokenizeTherionText', () {
    test('classifies a full-line comment', () {
      const String source = '# a comment';
      final List<THTextEditorToken> comments = tokensOfType(
        source,
        THTextEditorTokenType.comment,
      );

      expect(comments, hasLength(1));
      expect(textAt(source, comments.single), source);
    });

    test('classifies single- and double-quoted strings', () {
      const String source = "cs 'UTM 33N' \"another string\"";
      final List<THTextEditorToken> strings = tokensOfType(
        source,
        THTextEditorTokenType.string,
      );

      expect(strings, hasLength(2));
      expect(textAt(source, strings[0]), "'UTM 33N'");
      expect(textAt(source, strings[1]), '"another string"');
    });

    test('classifies integers, decimals, and exponents as numbers', () {
      const String source = '10 -3.14 6.02e23';
      final List<THTextEditorToken> numbers = tokensOfType(
        source,
        THTextEditorTokenType.number,
      );

      expect(numbers, hasLength(3));
      expect(textAt(source, numbers[0]), '10');
      expect(textAt(source, numbers[1]), '-3.14');
      expect(textAt(source, numbers[2]), '6.02e23');
    });

    test('classifies station@survey references', () {
      const String source = 'equate station1@cave.passage station2@cave';
      final List<THTextEditorToken> stationReferences = tokensOfType(
        source,
        THTextEditorTokenType.stationReference,
      );

      expect(stationReferences, hasLength(2));
      expect(textAt(source, stationReferences[0]), 'station1@cave.passage');
      expect(textAt(source, stationReferences[1]), 'station2@cave');
    });

    test('classifies known block/end keywords case-insensitively', () {
      const String source = 'Survey one\nendsurvey';
      final List<THTextEditorToken> keywords = tokensOfType(
        source,
        THTextEditorTokenType.keyword,
      );

      expect(keywords, hasLength(2));
      expect(textAt(source, keywords[0]), 'Survey');
      expect(textAt(source, keywords[1]), 'endsurvey');
    });

    test('classifies -option tokens', () {
      const String source = 'scrap s1 -projection plan';
      final List<THTextEditorToken> options = tokensOfType(
        source,
        THTextEditorTokenType.option,
      );

      expect(options, hasLength(1));
      expect(textAt(source, options.single), '-projection');
    });

    test('classifies other identifiers as plain text', () {
      const String source = 'somethingUnknown';
      final List<THTextEditorToken> plain = tokensOfType(
        source,
        THTextEditorTokenType.plain,
      );

      expect(plain, hasLength(1));
      expect(textAt(source, plain.single), source);
    });

    test('a malformed line still receives lexical coloring', () {
      const String source = 'survey ((unbalanced';
      final List<THTextEditorToken> tokens = tokenizeTherionText(source);

      expect(tokens.first.type, THTextEditorTokenType.keyword);
      expect(
        tokens.any(
          (THTextEditorToken token) =>
              token.type == THTextEditorTokenType.punctuation,
        ),
        isTrue,
      );
    });

    test('handles multi-line input with correct absolute offsets', () {
      const String source = 'survey one\n  -title "Cave One"\nendsurvey';
      final List<THTextEditorToken> tokens = tokenizeTherionText(source);
      final THTextEditorToken lastToken = tokens.last;

      expect(textAt(source, lastToken), 'endsurvey');
      expect(lastToken.start, source.lastIndexOf('endsurvey'));
    });

    test('an empty string tokenizes to no tokens', () {
      expect(tokenizeTherionText(''), isEmpty);
    });
  });
}
