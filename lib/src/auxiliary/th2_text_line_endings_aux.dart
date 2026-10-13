// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';

/// Line splitting shared by the writer's line ledger and the parser's line
/// map. Lines end at `\n`; a `\r` right before it is part of that ending. A
/// lone `\r` is not a line ending: callers check for it with
/// [loneCarriageReturnOffset] first, as the splitter does not validate.
class TH2TextLineEndingsAux {
  /// The offset of the first `\r` not followed by `\n`, or `null` when there
  /// is none.
  static int? loneCarriageReturnOffset(String text) {
    int offset = text.indexOf(mpCarriageReturn);

    while (offset >= 0) {
      final int nextOffset = offset + 1;

      if ((nextOffset >= text.length) ||
          (text[nextOffset] != mpUnixLineBreak)) {
        return offset;
      }

      offset = text.indexOf(mpCarriageReturn, nextOffset);
    }

    return null;
  }

  /// The start offset of each line of [text]. A final line ending does not
  /// start another line: `"a\n"` has one line, `"a\nb"` two and `""` none, as
  /// in the parser's line split.
  static List<int> lineStartOffsets(String text) {
    final List<int> lineStarts = <int>[];

    if (text.isEmpty) {
      return lineStarts;
    }

    lineStarts.add(0);

    int lineBreakOffset = text.indexOf(mpUnixLineBreak);

    while (lineBreakOffset >= 0) {
      final int nextLineStart = lineBreakOffset + 1;

      if (nextLineStart >= text.length) {
        break;
      }

      lineStarts.add(nextLineStart);
      lineBreakOffset = text.indexOf(mpUnixLineBreak, nextLineStart);
    }

    return lineStarts;
  }

  /// The index of the line containing [offset], from the [lineStarts] given
  /// by [lineStartOffsets].
  static int lineIndexAtOffset(List<int> lineStarts, int offset) {
    int low = 0;
    int high = lineStarts.length - 1;

    while (low < high) {
      final int middle = (low + high + 1) ~/ 2;

      if (lineStarts[middle] <= offset) {
        low = middle;
      } else {
        high = middle - 1;
      }
    }

    return low;
  }
}
