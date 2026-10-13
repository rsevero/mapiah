// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_parser_line_start.dart';

/// A setting the writer moved up into the settings section.
class TH2TextRelocation {
  final int mpID;

  /// 0-based line where the setting was written.
  final int destinationLine;

  const TH2TextRelocation({required this.mpID, required this.destinationLine});

  @override
  String toString() =>
      'TH2TextRelocation(mpID: $mpID, destinationLine: $destinationLine)';
}

/// A line ending the writer added after an unterminated chunk.
class TH2TextAddedEnding {
  /// The element whose chunk the ending terminates.
  final int ownerMPID;

  /// 0-based line the ending terminates.
  final int line;

  const TH2TextAddedEnding({required this.ownerMPID, required this.line});

  @override
  String toString() => 'TH2TextAddedEnding(ownerMPID: $ownerMPID, line: $line)';
}

/// Relates the lines of a TH2 text to the elements that own them. Lines are
/// 0-based.
class TH2TextLineMap {
  final List<int?> _ownerByLine;
  final Map<int, List<int>> _ownLinesByMPID;
  final Map<int, (int, int)> _rangeByMPID;

  /// Line → MPID of the removed element that owned it (parser maps only).
  final Map<int, int> removedLines;

  /// Settings moved up into the settings section (writer maps only).
  final List<TH2TextRelocation> relocations;

  /// Line endings added after unterminated chunks (writer maps only).
  final List<TH2TextAddedEnding> addedEndings;

  TH2TextLineMap._({
    required List<int?> ownerByLine,
    required TH2File th2File,
    required Map<int, int> removedLines,
    required List<TH2TextRelocation> relocations,
    required List<TH2TextAddedEnding> addedEndings,
  }) : _ownerByLine = List<int?>.unmodifiable(ownerByLine),
       _ownLinesByMPID = <int, List<int>>{},
       _rangeByMPID = <int, (int, int)>{},
       removedLines = Map<int, int>.unmodifiable(removedLines),
       relocations = List<TH2TextRelocation>.unmodifiable(relocations),
       addedEndings = List<TH2TextAddedEnding>.unmodifiable(addedEndings) {
    final int lineCount = _ownerByLine.length;

    for (int line = 0; line < lineCount; line++) {
      final int? owner = _ownerByLine[line];

      if (owner == null) {
        continue;
      }

      _ownLinesByMPID.putIfAbsent(owner, () => <int>[]).add(line);
      _extendRanges(owner, line, th2File);
    }
  }

  /// The map of the text the writer wrote, from the owner of each line.
  factory TH2TextLineMap.fromWriterLedger({
    required List<int?> ownerByLine,
    required TH2File th2File,
    required List<TH2TextRelocation> relocations,
    required List<TH2TextAddedEnding> addedEndings,
  }) {
    return TH2TextLineMap._(
      ownerByLine: ownerByLine,
      th2File: th2File,
      removedLines: const <int, int>{},
      relocations: relocations,
      addedEndings: addedEndings,
    );
  }

  /// The map of the text the parser read, from the 1-based lines where it
  /// started each element or read an option line, in parse order.
  ///
  /// Each start owns its line and the following ones up to the next start on
  /// a different line. Lines before the first start have no owner. A line
  /// whose owner is no longer in [th2File] goes to [removedLines].
  factory TH2TextLineMap.fromParserStartLines({
    required List<TH2ParserLineStart> lineStarts,
    required int lineCount,
    required TH2File th2File,
  }) {
    final List<int?> ownerByLine = List<int?>.filled(lineCount, null);
    final Map<int, int> removedLines = <int, int>{};
    final int startsCount = lineStarts.length;
    int index = 0;

    while (index < startsCount) {
      final TH2ParserLineStart lineStart = lineStarts[index];

      /// Starts on the same line after the first one own no line.
      int nextIndex = index + 1;

      while ((nextIndex < startsCount) &&
          (lineStarts[nextIndex].line == lineStart.line)) {
        nextIndex++;
      }

      final int firstLine = lineStart.line - 1;
      final int endLine = (nextIndex < startsCount)
          ? lineStarts[nextIndex].line - 1
          : lineCount;
      final bool isRemoved = !th2File.hasElementByMPID(lineStart.mpID);

      for (int line = firstLine; (line < endLine) && (line < lineCount); line++) {
        if (line < 0) {
          continue;
        }
        if (isRemoved) {
          removedLines[line] = lineStart.mpID;
        } else {
          ownerByLine[line] = lineStart.mpID;
        }
      }

      index = nextIndex;
    }

    return TH2TextLineMap._(
      ownerByLine: ownerByLine,
      th2File: th2File,
      removedLines: removedLines,
      relocations: const <TH2TextRelocation>[],
      addedEndings: const <TH2TextAddedEnding>[],
    );
  }

  int get lineCount => _ownerByLine.length;

  /// The MPID of the element that owns [line], or `null` outside the text and
  /// for lines with no owner.
  int? ownerOfLine(int line) {
    if ((line < 0) || (line >= _ownerByLine.length)) {
      return null;
    }

    return _ownerByLine[line];
  }

  /// The lines [mpID] owns, sorted; empty when it owns none.
  List<int> ownLinesOf(int mpID) {
    return List<int>.unmodifiable(_ownLinesByMPID[mpID] ?? const <int>[]);
  }

  int? firstOwnLineOf(int mpID) {
    final List<int>? ownLines = _ownLinesByMPID[mpID];

    return (ownLines == null) ? null : ownLines.first;
  }

  /// From the first own line of [mpID] to the last line of its last
  /// descendant, or `null` when neither it nor its descendants own a line.
  (int first, int last)? rangeOf(int mpID) {
    return _rangeByMPID[mpID];
  }

  Iterable<int> get ownerMPIDs => _ownLinesByMPID.keys;

  /// Extends the ranges of [owner] and of its ancestors below the file with
  /// [line].
  void _extendRanges(int owner, int line, TH2File th2File) {
    int mpID = owner;

    for (int depth = 0; depth <= mpMaxParseNestingDepth; depth++) {
      final (int, int)? range = _rangeByMPID[mpID];

      _rangeByMPID[mpID] = (range == null)
          ? (line, line)
          : ((range.$1 < line) ? range.$1 : line, (range.$2 > line) ? range.$2 : line);

      if ((mpID == th2File.mpID) || !th2File.hasElementByMPID(mpID)) {
        return;
      }

      mpID = th2File.elementByMPID(mpID).parentMPID;

      if (mpID == th2File.mpID) {
        return;
      }
    }
  }
}
