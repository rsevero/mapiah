// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/foundation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_normalization.dart';

/// The information markers of a valid text and its cursor mapper.
class TH2TextNormalizationAnalysis {
  final List<TH2TextDiagnostic> markers;
  final TH2TextCursorMapper cursorMapper;

  const TH2TextNormalizationAnalysis({
    required this.markers,
    required this.cursorMapper,
  });
}

/// Compares a raw text *T* with the text *N(T)* its detached model writes and
/// tells, line by line, what the normalization changed. Both line maps use
/// the detached model's MPIDs. Line texts are compared without their endings.
class TH2TextNormalizationAnalyzer {
  /// Called, in debug builds, with each element whose text changed although
  /// the writer should have reproduced its stored text.
  @visibleForTesting
  static void Function(THElement)? onUnrecordedRewriteForTesting;

  /// The text of each line of [text], without its ending, split as the
  /// parser splits.
  static List<String> lineTexts(String text) {
    final List<int> lineStarts = TH2TextLineEndingsAux.lineStartOffsets(text);
    final int lineCount = lineStarts.length;
    final List<String> texts = <String>[];

    for (int line = 0; line < lineCount; line++) {
      final int start = lineStarts[line];
      final int end = (line + 1 < lineCount)
          ? lineStarts[line + 1]
          : text.length;

      texts.add(_withoutEnding(text.substring(start, end)));
    }

    return texts;
  }

  static String _withoutEnding(String line) {
    if (line.endsWith(mpWindowsLineBreak)) {
      return line.substring(0, line.length - mpWindowsLineBreak.length);
    }
    if (line.endsWith(mpUnixLineBreak)) {
      return line.substring(0, line.length - mpUnixLineBreak.length);
    }

    return line;
  }

  static TH2TextNormalizationAnalysis analyze({
    required String rawText,
    required TH2TextLineMap parserMap,
    required String normalizedText,
    required TH2TextLineMap writerMap,
    required List<TH2FileNormalization> normalizations,
    required TH2File detachedFile,
  }) {
    final List<String> rawLines = lineTexts(rawText);
    final List<String> writerLines = lineTexts(normalizedText);
    final List<TH2TextDiagnostic> markers = <TH2TextDiagnostic>[];

    /// 1. Removed lines.
    final List<int> removedLines = parserMap.removedLines.keys.toList()
      ..sort();

    for (final int line in removedLines) {
      final int mpID = parserMap.removedLines[line]!;
      TH2FileNormalization? covering;

      for (final TH2FileNormalization normalization in normalizations) {
        if (normalization.removedMPIDs.contains(mpID)) {
          covering = normalization;
          break;
        }
      }

      assert(
        covering != null,
        'Removed line $line (MPID $mpID) has no normalization record.',
      );

      markers.add(
        TH2TextDiagnostic.information(
          line: line,
          kind: (covering == null)
              ? TH2TextDiagnosticKind.genericRewrite
              : _removalKind(covering.kind),
        ),
      );
    }

    /// 2. Recorded rewrites.
    final Set<int> recordedRewrites = <int>{};

    for (final TH2FileNormalization normalization in normalizations) {
      if ((normalization.kind != TH2FileNormalizationKind.rewrittenLine) ||
          !detachedFile.hasElementByMPID(normalization.mpID) ||
          !recordedRewrites.add(normalization.mpID)) {
        continue;
      }

      for (final int line in parserMap.ownLinesOf(normalization.mpID)) {
        markers.add(
          TH2TextDiagnostic.information(
            line: line,
            kind: TH2TextDiagnosticKind.rewrittenLine,
          ),
        );
      }
    }

    /// 3. Generic rewrites.
    for (final int mpID in parserMap.ownerMPIDs) {
      if (recordedRewrites.contains(mpID)) {
        continue;
      }

      final List<int> rawOwnLines = parserMap.ownLinesOf(mpID);
      final List<int> writerOwnLines = writerMap.ownLinesOf(mpID);

      if (_sameTexts(rawOwnLines, rawLines, writerOwnLines, writerLines)) {
        continue;
      }

      if (kDebugMode && detachedFile.hasElementByMPID(mpID)) {
        final THElement element = detachedFile.elementByMPID(mpID);

        /// The writer reproduces stored text, so the difference comes from a
        /// path that changes text without recording it, unless the element is
        /// an image the writer always writes in XTherion format.
        if (element.originalLineInTH2File.isNotEmpty &&
            !((element is MPImageInsertConfig) &&
                element.isXTherionRepresentable)) {
          mpLocator.mpLog.d(
            'TH2 text normalization changed the text of $element without '
            'recording it.',
          );
          onUnrecordedRewriteForTesting?.call(element);
        }
      }

      for (final int line in rawOwnLines) {
        markers.add(
          TH2TextDiagnostic.information(
            line: line,
            kind: TH2TextDiagnosticKind.genericRewrite,
          ),
        );
      }
    }

    /// 4. Moves.
    for (final TH2TextRelocation relocation in writerMap.relocations) {
      for (final int line in parserMap.ownLinesOf(relocation.mpID)) {
        markers.add(
          TH2TextDiagnostic.information(
            line: line,
            kind: TH2TextDiagnosticKind.movedSetting,
            destinationLine: relocation.destinationLine,
          ),
        );
      }
    }

    /// 5. Added lines.
    final int writerLineCount = writerMap.lineCount;
    int writerLine = 0;

    while (writerLine < writerLineCount) {
      final int? owner = writerMap.ownerOfLine(writerLine);

      if (_hasRawLines(owner, parserMap)) {
        writerLine++;
        continue;
      }

      final int blockStart = writerLine;

      while ((writerLine < writerLineCount) &&
          (writerMap.ownerOfLine(writerLine) == owner)) {
        writerLine++;
      }

      int? markerLine;

      for (int next = writerLine; next < writerLineCount; next++) {
        final int? nextOwner = writerMap.ownerOfLine(next);

        if (_hasRawLines(nextOwner, parserMap)) {
          markerLine = parserMap.firstOwnLineOf(nextOwner!);
          break;
        }
      }

      markerLine ??= rawLines.isEmpty ? 0 : rawLines.length - 1;

      markers.add(
        TH2TextDiagnostic.information(
          line: markerLine,
          kind: TH2TextDiagnosticKind.addedLine,
          detail: writerLines
              .sublist(blockStart, writerLine)
              .join(mpUnixLineBreak),
        ),
      );
    }

    /// 6. Added endings.
    for (final TH2TextAddedEnding addedEnding in writerMap.addedEndings) {
      final List<int> ownLines = parserMap.ownLinesOf(addedEnding.ownerMPID);

      if (ownLines.isEmpty) {
        continue;
      }

      markers.add(
        TH2TextDiagnostic.information(
          line: ownLines.last,
          kind: TH2TextDiagnosticKind.addedEnding,
        ),
      );
    }

    return TH2TextNormalizationAnalysis(
      markers: markers,
      cursorMapper: TH2TextCursorMapper(
        parserMap: parserMap,
        writerMap: writerMap,
        detachedFile: detachedFile,
      ),
    );
  }

  static bool _hasRawLines(int? owner, TH2TextLineMap parserMap) {
    return (owner != null) && (parserMap.firstOwnLineOf(owner) != null);
  }

  static bool _sameTexts(
    List<int> rawOwnLines,
    List<String> rawLines,
    List<int> writerOwnLines,
    List<String> writerLines,
  ) {
    if (rawOwnLines.length != writerOwnLines.length) {
      return false;
    }

    final int count = rawOwnLines.length;

    for (int i = 0; i < count; i++) {
      if (rawLines[rawOwnLines[i]] != writerLines[writerOwnLines[i]]) {
        return false;
      }
    }

    return true;
  }

  static TH2TextDiagnosticKind _removalKind(TH2FileNormalizationKind kind) {
    switch (kind) {
      case TH2FileNormalizationKind.removedDuplicateLinePoint:
        return TH2TextDiagnosticKind.removedDuplicateLinePoint;
      case TH2FileNormalizationKind.removedShortLine:
        return TH2TextDiagnosticKind.removedShortLine;
      case TH2FileNormalizationKind.removedBorderOfShortLine:
        return TH2TextDiagnosticKind.removedBorderOfShortLine;
      case TH2FileNormalizationKind.removedEmptyArea:
        return TH2TextDiagnosticKind.removedEmptyArea;
      case TH2FileNormalizationKind.rewrittenLine:
        return TH2TextDiagnosticKind.genericRewrite;
    }
  }
}

/// Maps a raw line of a valid text to its line in the normalized text,
/// through the line maps' owners. No line is matched by text.
class TH2TextCursorMapper {
  final TH2TextLineMap _parserMap;
  final TH2TextLineMap _writerMap;
  final TH2File _detachedFile;

  TH2TextCursorMapper({
    required TH2TextLineMap parserMap,
    required TH2TextLineMap writerMap,
    required TH2File detachedFile,
  }) : _parserMap = parserMap,
       _writerMap = writerMap,
       _detachedFile = detachedFile;

  int mapRawLine(int rawLine) {
    int line = (rawLine >= _parserMap.lineCount)
        ? _parserMap.lineCount - 1
        : rawLine;
    int? owner;

    for (; line >= 0; line--) {
      owner = _parserMap.ownerOfLine(line);

      if (owner != null) {
        break;
      }
    }

    if (owner == null) {
      return 0;
    }

    final int index = _parserMap.ownLinesOf(owner).indexOf(line);
    final List<int> writerOwnLines = _writerMap.ownLinesOf(owner);

    if (writerOwnLines.isEmpty) {
      if (!_detachedFile.hasElementByMPID(owner)) {
        return 0;
      }

      final int parentMPID = _detachedFile.elementByMPID(owner).parentMPID;

      return _writerMap.rangeOf(parentMPID)?.$1 ?? 0;
    }

    return (index < writerOwnLines.length)
        ? writerOwnLines[index]
        : writerOwnLines.last;
  }
}
