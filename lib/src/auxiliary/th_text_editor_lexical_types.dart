// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// The language of a text editor buffer. It chooses the tokenizer, the fold
/// keywords and the auto-indent block openers.
enum THTextEditorLanguage { therion, th2 }

/// Lexical token kinds recognized by `tokenizeTherionText`.
///
/// This classification is deliberately shallow: it only needs to color the
/// text editor. The real grammars remain authoritative for parse errors and
/// model updates.
enum THTextEditorTokenType {
  keyword,
  directive,
  option,
  comment,
  string,
  number,
  stationReference,
  punctuation,
  setting,
  plain,
}

/// One classified span of text, as `[start, end)` absolute offsets into the
/// complete tokenized text.
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

/// One foldable, balanced `block ... endblock` region, as zero-based,
/// inclusive line numbers.
class THTextEditorFoldRegion {
  final int startLine;

  final int endLine;

  const THTextEditorFoldRegion({
    required this.startLine,
    required this.endLine,
  });

  @override
  bool operator ==(Object other) =>
      other is THTextEditorFoldRegion &&
      other.startLine == startLine &&
      other.endLine == endLine;

  @override
  int get hashCode => Object.hash(startLine, endLine);

  @override
  String toString() => 'THTextEditorFoldRegion($startLine, $endLine)';
}
