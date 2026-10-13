// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

/// One recorded buffer change, in the lines of the text before it.
class _TH2TextLineChange {
  /// Lines [editedFirst]..[editedLast] were edited or deleted; empty when
  /// [editedLast] < [editedFirst].
  final int editedFirst;
  final int editedLast;

  /// Lines from [shiftFrom] on moved by [delta] lines.
  final int shiftFrom;
  final int delta;

  const _TH2TextLineChange({
    required this.editedFirst,
    required this.editedLast,
    required this.shiftFrom,
    required this.delta,
  });
}

/// Follows the lines of an initial text through the changes of an editor
/// buffer, so an initial line can be found in the current text.
class TH2TextLineTracker {
  final int _initialLineCount;
  final List<_TH2TextLineChange> _changes = <_TH2TextLineChange>[];

  TH2TextLineTracker(String initialContent)
    : _initialLineCount = TH2TextLineEndingsAux.lineStartOffsets(
        initialContent,
      ).length;

  /// Records the change from [oldText] to [newText]. [cursorOffset] is the
  /// cursor offset in [newText] after the change, when known: the common end
  /// is never trimmed past it.
  void recordChange({
    required String oldText,
    required String newText,
    int? cursorOffset,
  }) {
    if (oldText == newText) {
      return;
    }

    int suffixLimit = (oldText.length < newText.length)
        ? oldText.length
        : newText.length;

    if (cursorOffset != null) {
      final int cursorLimit = newText.length - cursorOffset;

      if ((cursorLimit >= 0) && (cursorLimit < suffixLimit)) {
        suffixLimit = cursorLimit;
      }
    }

    int suffix = 0;

    while ((suffix < suffixLimit) &&
        (oldText.codeUnitAt(oldText.length - 1 - suffix) ==
            newText.codeUnitAt(newText.length - 1 - suffix))) {
      suffix++;
    }

    final int oldEnd = oldText.length - suffix;
    final int newEnd = newText.length - suffix;
    final int prefixLimit = (oldEnd < newEnd) ? oldEnd : newEnd;
    int start = 0;

    while ((start < prefixLimit) &&
        (oldText.codeUnitAt(start) == newText.codeUnitAt(start))) {
      start++;
    }

    final String removed = oldText.substring(start, oldEnd);
    final String inserted = newText.substring(start, newEnd);
    final List<int> oldLineStarts = TH2TextLineEndingsAux.lineStartOffsets(
      oldText,
    );
    final int firstLine = _lineAtOffset(oldLineStarts, oldText, start);
    final int insertedEndings = _countLineEndings(inserted);

    if (removed.isEmpty && (insertedEndings > 0)) {
      final bool isAtLineStart =
          (start == 0) ||
          (oldText.codeUnitAt(start - 1) == mpLineFeedByte);

      /// Whole lines inserted at a line's start only shift that line.
      if (isAtLineStart && inserted.endsWith(mpUnixLineBreak)) {
        _changes.add(
          _TH2TextLineChange(
            editedFirst: firstLine,
            editedLast: firstLine - 1,
            shiftFrom: firstLine,
            delta: insertedEndings,
          ),
        );

        return;
      }

      /// A line break inserted at the end of a line's content leaves that
      /// line unedited and shifts the lines below.
      if (_isAtLineContentEnd(oldText, start) &&
          (inserted.startsWith(mpUnixLineBreak) ||
              inserted.startsWith(mpWindowsLineBreak))) {
        _changes.add(
          _TH2TextLineChange(
            editedFirst: firstLine,
            editedLast: firstLine - 1,
            shiftFrom: firstLine + 1,
            delta: insertedEndings,
          ),
        );

        return;
      }
    }

    final int lastLine = (oldEnd > start)
        ? _lineAtOffset(oldLineStarts, oldText, oldEnd - 1)
        : firstLine;

    _changes.add(
      _TH2TextLineChange(
        editedFirst: firstLine,
        editedLast: lastLine,
        shiftFrom: lastLine + 1,
        delta: insertedEndings - _countLineEndings(removed),
      ),
    );
  }

  /// The current line of the 0-based [initialLine]. For an edited or deleted
  /// line, the current line of the nearest unedited line above, or 0 when
  /// there is none. `null` for a line outside the initial text.
  int? currentLineOf(int initialLine) {
    if ((initialLine < 0) || (initialLine >= _initialLineCount)) {
      return null;
    }

    for (int line = initialLine; line >= 0; line--) {
      final int? currentLine = _replay(line);

      if (currentLine != null) {
        return currentLine;
      }
    }

    return 0;
  }

  /// The current line of [initialLine], or `null` when it was edited or
  /// deleted.
  int? _replay(int initialLine) {
    int line = initialLine;

    for (final _TH2TextLineChange change in _changes) {
      if ((line >= change.editedFirst) && (line <= change.editedLast)) {
        return null;
      }
      if (line >= change.shiftFrom) {
        line += change.delta;
      }
    }

    return line;
  }

  /// The line of [offset]; an offset at the end of a text with a final line
  /// ending is on the line after the last one.
  static int _lineAtOffset(List<int> lineStarts, String text, int offset) {
    if (lineStarts.isEmpty) {
      return 0;
    }
    if ((offset >= text.length) && text.endsWith(mpUnixLineBreak)) {
      return lineStarts.length;
    }

    return TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, offset);
  }

  /// Whether [offset] is right after a line's content: at its line ending or
  /// at the end of an unterminated last line.
  static bool _isAtLineContentEnd(String text, int offset) {
    if (offset >= text.length) {
      return text.isNotEmpty && !text.endsWith(mpUnixLineBreak);
    }

    return text.startsWith(mpUnixLineBreak, offset) ||
        text.startsWith(mpWindowsLineBreak, offset);
  }

  static int _countLineEndings(String text) {
    int count = 0;
    int offset = text.indexOf(mpUnixLineBreak);

    while (offset >= 0) {
      count++;
      offset = text.indexOf(mpUnixLineBreak, offset + 1);
    }

    return count;
  }
}
