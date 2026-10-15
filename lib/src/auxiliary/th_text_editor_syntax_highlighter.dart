// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/painting.dart';
import 'package:mapiah/src/auxiliary/th2_text_editor_lexer.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';

export 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';

const Set<String> _thTextEditorKeywords = <String>{
  'survey',
  'endsurvey',
  'centreline',
  'endcentreline',
  'map',
  'endmap',
  'scrap',
  'endscrap',
  'layout',
  'endlayout',
  'input',
  'source',
  'select',
  'unselect',
  'export',
  'join',
  'equate',
  'cs',
  'encoding',
};

final RegExp _thTextEditorNumberRegExp = RegExp(
  r'^-?\d+(\.\d+)?([eE][+-]?\d+)?',
);

final RegExp _thTextEditorStationReferenceRegExp = RegExp(
  r'^[A-Za-z0-9_.]+@[A-Za-z0-9_.]+',
);

final RegExp _thTextEditorIdentifierRegExp = RegExp(r'^[A-Za-z_][A-Za-z0-9_.]*');

const Set<String> _thTextEditorPunctuation = <String>{
  '(',
  ')',
  '[',
  ']',
  '{',
  '}',
  ',',
  ';',
  ':',
};

/// Tokenizes [text] for syntax highlighting. Token offsets are absolute
/// offsets in [text].
///
/// For [THTextEditorLanguage.therion], tokenizes line by line, recognizing,
/// in order of specificity: `#` comments, quoted strings, numbers,
/// `station@cave.passage`-style station references, known block/end
/// keywords, `-option` tokens, single-character punctuation, and otherwise
/// plain text. Whitespace is skipped rather than tokenized.
///
/// For [THTextEditorLanguage.th2], see [scanTH2EditorText].
List<THTextEditorToken> tokenizeTherionText(
  String text, {
  THTextEditorLanguage language = THTextEditorLanguage.therion,
}) {
  if (language == THTextEditorLanguage.th2) {
    return scanTH2EditorText(text).tokens;
  }

  final List<THTextEditorToken> tokens = <THTextEditorToken>[];
  final List<String> lines = text.split('\n');
  int lineStartOffset = 0;

  for (final String line in lines) {
    tokens.addAll(_tokenizeLine(line, lineStartOffset));
    lineStartOffset += line.length + 1;
  }

  return tokens;
}

List<THTextEditorToken> _tokenizeLine(String line, int lineStartOffset) {
  final List<THTextEditorToken> tokens = <THTextEditorToken>[];
  int index = 0;

  while (index < line.length) {
    final String char = line[index];

    if (char == ' ' || char == '\t') {
      index++;

      continue;
    }

    if (char == '#') {
      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + line.length,
          type: THTextEditorTokenType.comment,
        ),
      );

      break;
    }

    if (char == "'" || char == '"') {
      final int stringEnd = _findStringEnd(line, index, char);

      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + stringEnd,
          type: THTextEditorTokenType.string,
        ),
      );
      index = stringEnd;

      continue;
    }

    final String remaining = line.substring(index);
    final RegExpMatch? stationMatch = _thTextEditorStationReferenceRegExp
        .firstMatch(remaining);

    if (stationMatch != null) {
      final int matchLength = stationMatch.end;

      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + index + matchLength,
          type: THTextEditorTokenType.stationReference,
        ),
      );
      index += matchLength;

      continue;
    }

    final RegExpMatch? numberMatch = _thTextEditorNumberRegExp.firstMatch(
      remaining,
    );

    if (numberMatch != null && numberMatch.end > 0) {
      final int matchLength = numberMatch.end;

      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + index + matchLength,
          type: THTextEditorTokenType.number,
        ),
      );
      index += matchLength;

      continue;
    }

    if (char == '-' &&
        index + 1 < line.length &&
        RegExp(r'[A-Za-z_]').hasMatch(line[index + 1])) {
      final RegExpMatch? optionMatch = _thTextEditorIdentifierRegExp
          .firstMatch(line.substring(index + 1));
      final int identifierLength = optionMatch?.end ?? 0;
      final int matchLength = 1 + identifierLength;

      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + index + matchLength,
          type: THTextEditorTokenType.option,
        ),
      );
      index += matchLength;

      continue;
    }

    final RegExpMatch? identifierMatch = _thTextEditorIdentifierRegExp
        .firstMatch(remaining);

    if (identifierMatch != null) {
      final int matchLength = identifierMatch.end;
      final String word = remaining.substring(0, matchLength);

      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + index + matchLength,
          type: _thTextEditorKeywords.contains(word.toLowerCase())
              ? THTextEditorTokenType.keyword
              : THTextEditorTokenType.plain,
        ),
      );
      index += matchLength;

      continue;
    }

    if (_thTextEditorPunctuation.contains(char)) {
      tokens.add(
        THTextEditorToken(
          start: lineStartOffset + index,
          end: lineStartOffset + index + 1,
          type: THTextEditorTokenType.punctuation,
        ),
      );
      index++;

      continue;
    }

    tokens.add(
      THTextEditorToken(
        start: lineStartOffset + index,
        end: lineStartOffset + index + 1,
        type: THTextEditorTokenType.plain,
      ),
    );
    index++;
  }

  return tokens;
}

/// Returns the exclusive end index of a quoted string starting at
/// `line[start]` (the opening [quote]). Unterminated strings run to the end
/// of the line.
int _findStringEnd(String line, int start, String quote) {
  int index = start + 1;

  while (index < line.length && line[index] != quote) {
    index++;
  }

  return index < line.length ? index + 1 : line.length;
}

/// Builds the syntax overlay's spans of [content] in one merged pass over
/// [tokens] and [findMatches], both sorted and non-overlapping. Each span has
/// its token's color, or none outside tokens, and the find-match background
/// where a match covers it; the active match gets [activeFindMatchColor].
List<InlineSpan> buildTHTextEditorOverlaySpans({
  required String content,
  required List<THTextEditorToken> tokens,
  required Map<THTextEditorTokenType, Color> tokenColors,
  required List<TextRange> findMatches,
  required int? activeMatchIndex,
  required Color findMatchColor,
  required Color activeFindMatchColor,
}) {
  final List<InlineSpan> spans = <InlineSpan>[];
  final int contentLength = content.length;
  final int tokenCount = tokens.length;
  final int matchCount = findMatches.length;
  int tokenIndex = 0;
  int matchIndex = 0;
  int position = 0;

  while (position < contentLength) {
    while ((tokenIndex < tokenCount) && (tokens[tokenIndex].end <= position)) {
      tokenIndex++;
    }
    while ((matchIndex < matchCount) &&
        (findMatches[matchIndex].end <= position)) {
      matchIndex++;
    }

    int next = contentLength;
    Color? foregroundColor;
    Color? backgroundColor;

    if (tokenIndex < tokenCount) {
      final THTextEditorToken token = tokens[tokenIndex];

      if (token.start <= position) {
        foregroundColor = tokenColors[token.type];
        next = (token.end < next) ? token.end : next;
      } else {
        next = (token.start < next) ? token.start : next;
      }
    }

    if (matchIndex < matchCount) {
      final TextRange match = findMatches[matchIndex];

      if (match.start <= position) {
        backgroundColor = (matchIndex == activeMatchIndex)
            ? activeFindMatchColor
            : findMatchColor;
        next = (match.end < next) ? match.end : next;
      } else {
        next = (match.start < next) ? match.start : next;
      }
    }

    if (next > contentLength) {
      next = contentLength;
    }

    spans.add(
      TextSpan(
        text: content.substring(position, next),
        style: TextStyle(
          color: foregroundColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
    position = next;
  }

  return spans;
}
