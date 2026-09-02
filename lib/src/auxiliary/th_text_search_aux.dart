// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show TextRange;

import 'package:mapiah/src/constants/mp_constants.dart';

/// Shared, pure plain-text search primitives used by both the single-file
/// find/replace bar ([THTextEditorController.findMatches]) and the multi-file
/// project search ([THProjectSearchController]).
///
/// The matcher is a non-overlapping, left-to-right plain substring scan. There
/// is no regex, whole-word, or structural search. Returned ranges are always
/// UTF-16 offsets into the *original* [content], compatible with Flutter
/// [TextRange]/[TextSelection], even for case-insensitive matches whose
/// Unicode lowercase mapping changes UTF-16 length (`İ` U+0130 → `i` + U+0307).

/// Non-overlapping, left-to-right occurrences of [query] in [content].
///
/// - An empty (or empty-after-folding) [query] returns no matches.
/// - Every returned range is non-empty, ordered, and non-overlapping.
/// - Offsets index into [content] directly, never into a folded copy.
List<TextRange> findPlainTextMatches({
  required String content,
  required String query,
  required bool caseSensitive,
}) {
  if (query.isEmpty) {
    return const <TextRange>[];
  }

  if (caseSensitive) {
    return _scanDirect(content, query);
  }

  final _FoldResult foldedQuery = _foldPerRune(query, buildMap: false);

  if (foldedQuery.folded.isEmpty) {
    return const <TextRange>[];
  }

  final _FoldResult foldedContentProbe = _foldPerRune(content, buildMap: false);

  if (foldedContentProbe.lengthPreserving) {
    // Fast path: every content rune kept its UTF-16 length, so folded offsets
    // equal original offsets. Covers ASCII, Latin-1, and ordinary
    // non-expanding Unicode mappings.
    return _scanDirect(foldedContentProbe.folded, foldedQuery.folded);
  }

  // Mapped path: at least one content rune changed UTF-16 length when folded,
  // so folded offsets must be projected back through parallel source arrays.
  final _FoldResult foldedContent = _foldPerRune(content, buildMap: true);
  final String haystack = foldedContent.folded;
  final String needle = foldedQuery.folded;
  final List<int> sourceStarts = foldedContent.sourceStarts!;
  final List<int> sourceEnds = foldedContent.sourceEnds!;
  final List<TextRange> matches = <TextRange>[];

  int searchStart = 0;
  int previousEnd = 0;

  while (searchStart <= haystack.length - needle.length) {
    final int foundIndex = haystack.indexOf(needle, searchStart);

    if (foundIndex == -1) {
      break;
    }

    final int foldedEnd = foundIndex + needle.length;
    final int projectedStart = sourceStarts[foundIndex];
    final int projectedEnd = sourceEnds[foldedEnd - 1];

    // A candidate that touches only part of a multi-unit lowercase expansion
    // intentionally consumes the whole originating rune. Different folded
    // candidates can project onto the same original range, so accept only
    // non-empty, non-overlapping projected ranges.
    if ((projectedEnd > projectedStart) && (projectedStart >= previousEnd)) {
      matches.add(TextRange(start: projectedStart, end: projectedEnd));
      previousEnd = projectedEnd;
    }

    searchStart = foundIndex + needle.length;
  }

  return matches;
}

/// Bounded plain scan of [needle] in [haystack]; offsets are haystack offsets.
List<TextRange> _scanDirect(String haystack, String needle) {
  final List<TextRange> matches = <TextRange>[];
  int searchStart = 0;

  while (searchStart <= haystack.length - needle.length) {
    final int foundIndex = haystack.indexOf(needle, searchStart);

    if (foundIndex == -1) {
      break;
    }

    matches.add(TextRange(start: foundIndex, end: foundIndex + needle.length));
    searchStart = foundIndex + needle.length;
  }

  return matches;
}

class _FoldResult {
  final String folded;

  /// True when every original rune produced exactly the same number of UTF-16
  /// code units after folding. A whole-string length check is not sufficient.
  final bool lengthPreserving;

  /// Per folded UTF-16 code unit: the original UTF-16 start of the rune that
  /// produced it. Only populated when `buildMap` was requested.
  final List<int>? sourceStarts;

  /// Per folded UTF-16 code unit: the exclusive original UTF-16 end of the
  /// rune that produced it.
  final List<int>? sourceEnds;

  const _FoldResult({
    required this.folded,
    required this.lengthPreserving,
    this.sourceStarts,
    this.sourceEnds,
  });
}

/// Rune-by-rune Unicode lowercase fold. Iterates code points, folds each
/// complete rune string on its own, and concatenates the results so content
/// and query always share identical folding rules regardless of any later
/// optimization.
_FoldResult _foldPerRune(String input, {required bool buildMap}) {
  final StringBuffer buffer = StringBuffer();
  final List<int>? sourceStarts = buildMap ? <int>[] : null;
  final List<int>? sourceEnds = buildMap ? <int>[] : null;
  bool lengthPreserving = true;
  int originalOffset = 0;

  for (final int rune in input.runes) {
    final String runeString = String.fromCharCode(rune);
    final int originalUnits = runeString.length;
    final String foldedRune = runeString.toLowerCase();
    final int foldedUnits = foldedRune.length;

    if (foldedUnits != originalUnits) {
      lengthPreserving = false;
    }

    buffer.write(foldedRune);

    if (buildMap) {
      final int start = originalOffset;
      final int end = originalOffset + originalUnits;

      for (int unit = 0; unit < foldedUnits; unit++) {
        sourceStarts!.add(start);
        sourceEnds!.add(end);
      }
    }

    originalOffset += originalUnits;
  }

  return _FoldResult(
    folded: buffer.toString(),
    lengthPreserving: lengthPreserving,
    sourceStarts: sourceStarts,
    sourceEnds: sourceEnds,
  );
}

/// One-based line number (newline count before [offset], plus one).
int lineNumberForOffset(String content, int offset) {
  final int clamped = offset.clamp(0, content.length);
  int line = 1;

  for (int index = 0; index < clamped; index++) {
    if (content.codeUnitAt(index) == 0x0A) {
      line++;
    }
  }

  return line;
}

/// One-based column: UTF-16 units between the start of [offset]'s line and
/// [offset].
int columnNumberForOffset(String content, int offset) {
  final int clamped = offset.clamp(0, content.length);
  final int lineStart = clamped == 0
      ? 0
      : content.lastIndexOf('\n', clamped - 1) + 1;

  return clamped - lineStart + 1;
}

/// A single-line, length-bounded preview of the line containing a match, with
/// the match's position inside the preview string.
class THTextSearchLinePreview {
  final String preview;

  /// Range of the emphasized match portion inside [preview].
  final TextRange matchRange;

  const THTextSearchLinePreview({
    required this.preview,
    required this.matchRange,
  });
}

/// Builds a trimmed, single-line preview of the line that contains
/// [matchRange], windowed so the match stays visible when the line is long.
/// The source text is never altered; only whitespace trimming and windowing
/// are applied.
THTextSearchLinePreview buildLinePreview({
  required String content,
  required TextRange matchRange,
  int maxLength = mpProjectSearchPreviewMaxLength,
}) {
  final int matchStart = matchRange.start.clamp(0, content.length);
  final int matchEnd = matchRange.end.clamp(matchStart, content.length);

  final int lineStart = matchStart == 0
      ? 0
      : content.lastIndexOf('\n', matchStart - 1) + 1;
  int lineEnd = content.indexOf('\n', matchEnd);

  if (lineEnd == -1) {
    lineEnd = content.length;
  }

  final String rawLine = content.substring(lineStart, lineEnd);
  int matchStartInLine = matchStart - lineStart;
  int matchEndInLine = matchEnd - lineStart;

  // Trim leading whitespace, but never past the start of the match.
  final int leadingWhitespace = rawLine.length - rawLine.trimLeft().length;
  final int trimLeading = leadingWhitespace < matchStartInLine
      ? leadingWhitespace
      : matchStartInLine;

  String preview = rawLine.substring(trimLeading).trimRight();
  matchStartInLine -= trimLeading;
  matchEndInLine -= trimLeading;

  if (matchStartInLine > preview.length) {
    matchStartInLine = preview.length;
  }
  if (matchEndInLine > preview.length) {
    matchEndInLine = preview.length;
  }

  if (preview.length > maxLength) {
    final int matchLength = matchEndInLine - matchStartInLine;
    final int context = ((maxLength - matchLength) ~/ 2).clamp(0, maxLength);
    int windowStart = matchStartInLine - context;

    if (windowStart < 0) {
      windowStart = 0;
    }

    int windowEnd = windowStart + maxLength;

    if (windowEnd > preview.length) {
      windowEnd = preview.length;
      windowStart = (windowEnd - maxLength).clamp(0, preview.length);
    }

    preview = preview.substring(windowStart, windowEnd);
    matchStartInLine = (matchStartInLine - windowStart).clamp(0, preview.length);
    matchEndInLine = (matchEndInLine - windowStart).clamp(
      matchStartInLine,
      preview.length,
    );
  }

  return THTextSearchLinePreview(
    preview: preview,
    matchRange: TextRange(start: matchStartInLine, end: matchEndInLine),
  );
}
