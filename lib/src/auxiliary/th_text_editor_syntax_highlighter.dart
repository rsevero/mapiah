// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Lexical token kinds recognized by [tokenizeTherionText].
///
/// This classification is deliberately shallow: it only needs to color the
/// text editor. The real `thconfig`/`.th` grammar remains authoritative for
/// parse errors and project-tree updates.
enum THTextEditorTokenType {
  keyword,
  directive,
  option,
  comment,
  string,
  number,
  stationReference,
  punctuation,
  plain,
}

/// One classified span of [THTextEditorTokenType.plain]-or-otherwise text
/// within a single line, as `[start, end)` character offsets into that line.
class THTextEditorToken {
  final int start;

  final int end;

  final THTextEditorTokenType type;

  const THTextEditorToken({
    required this.start,
    required this.end,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      other is THTextEditorToken &&
      other.start == start &&
      other.end == end &&
      other.type == type;

  @override
  int get hashCode => Object.hash(start, end, type);

  @override
  String toString() => 'THTextEditorToken($start, $end, $type)';
}

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

/// Tokenizes [text] line by line for syntax highlighting.
///
/// Recognizes, in order of specificity: `#` comments, quoted strings,
/// numbers, `station@cave.passage`-style station references, known
/// block/end keywords, `-option` tokens, single-character punctuation, and
/// otherwise plain text. Whitespace is skipped rather than tokenized.
List<THTextEditorToken> tokenizeTherionText(String text) {
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
