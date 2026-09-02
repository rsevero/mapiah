// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' show TextRange;

/// One immutable plain-text match inside a single searched file snapshot.
class THProjectSearchMatch {
  final String canonicalPath;

  /// UTF-16 range of the match inside the searched file content snapshot.
  final TextRange range;

  /// One-based line number of [range] start.
  final int lineNumber;

  /// One-based column of [range] start.
  final int columnNumber;

  /// Trimmed, single-line preview of the line containing the match.
  final String linePreview;

  /// Range of the emphasized match portion inside [linePreview].
  final TextRange previewMatchRange;

  const THProjectSearchMatch({
    required this.canonicalPath,
    required this.range,
    required this.lineNumber,
    required this.columnNumber,
    required this.linePreview,
    required this.previewMatchRange,
  });
}
