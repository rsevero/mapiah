// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_tracker.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_parser_line_start.dart';

import 'th2_text_line_map_test_aux.dart';
import 'th_test_aux.dart';

/// A buffer that records each change in a tracker, as Phase 3's
/// `setContent` will.
class _Buffer {
  String text;
  final TH2TextLineTracker tracker;

  _Buffer(this.text) : tracker = TH2TextLineTracker(text);

  void replace(int start, int end, String inserted, {bool withCursor = true}) {
    final String newText = text.replaceRange(start, end, inserted);

    tracker.recordChange(
      oldText: text,
      newText: newText,
      cursorOffset: withCursor ? start + inserted.length : null,
    );
    text = newText;
  }

  void insert(int offset, String inserted, {bool withCursor = true}) =>
      replace(offset, offset, inserted, withCursor: withCursor);

  void setText(String newText, {int? cursorOffset}) {
    tracker.recordChange(
      oldText: text,
      newText: newText,
      cursorOffset: cursorOffset,
    );
    text = newText;
  }

  /// The offset of the start of [line].
  int lineStart(int line) =>
      TH2TextLineEndingsAux.lineStartOffsets(text)[line];

  /// The offset of the end of [line]'s content, before its ending.
  int lineContentEnd(int line) {
    final List<int> starts = TH2TextLineEndingsAux.lineStartOffsets(text);
    int end = (line + 1 < starts.length) ? starts[line + 1] : text.length;

    if ((end > starts[line]) && (text[end - 1] == '\n')) {
      end--;
      if ((end > starts[line]) && (text[end - 1] == '\r')) {
        end--;
      }
    }

    return end;
  }
}

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  group('TH2TextLineEndingsAux splits editor buffers as the parser', () {
    for (final (String name, String text) in <(String, String)>[
      ('LF', 'encoding utf-8\nscrap s1\n  point 1 1 station\nendscrap\n'),
      ('CRLF', 'encoding utf-8\r\nscrap s1\r\nendscrap\r\n'),
      ('no final ending', 'encoding utf-8\nscrap s1\nendscrap'),
      ('mixed', 'encoding utf-8\r\nscrap s1\n\nendscrap'),
    ]) {
      test(name, () async {
        final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
          text,
        );
        final List<int> offsets = TH2TextLineEndingsAux.lineStartOffsets(text);

        expect(parsed.isSuccessful, isTrue);
        expect(offsets.length, parsed.parser.parsedLineCount);
        for (final TH2ParserLineStart lineStart in parsed.parser.lineStarts) {
          expect(lineStart.line, lessThanOrEqualTo(offsets.length));
        }
        expect(
          TH2TextLineEndingsAux.lineIndexAtOffset(offsets, text.length - 1),
          offsets.length - 1,
        );
      });
    }

    test('finds a lone carriage return', () {
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('a\r\nb\rc'), 4);
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('a\r\nb\r\n'), isNull);
    });
  });

  group('TH2TextLineTracker', () {
    const String text = 'line0\nline1\nline2\nline3\n';

    test('typing in a line marks it edited', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(2) + 2, 'x');

      expect(buffer.tracker.currentLineOf(2), 1);
      expect(buffer.tracker.currentLineOf(3), 3);
    });

    test('inserting lines above shifts a line', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(1), 'new a\nnew b\n');

      expect(buffer.tracker.currentLineOf(0), 0);
      expect(buffer.tracker.currentLineOf(1), 3);
      expect(buffer.tracker.currentLineOf(3), 5);
    });

    test('a deleted line maps to the nearest unedited line above', () {
      final _Buffer buffer = _Buffer(text);

      buffer.replace(buffer.lineStart(2), buffer.lineStart(3), '');

      expect(buffer.tracker.currentLineOf(2), 1);
      expect(buffer.tracker.currentLineOf(3), 2);
    });

    test('whole lines inserted at a line start only shift it; a character edits it', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(2), 'whole\n');
      expect(buffer.tracker.currentLineOf(2), 3);

      buffer.insert(buffer.lineStart(3), 'x');
      expect(buffer.tracker.currentLineOf(2), 1);
    });

    test('Replace All recorded as one change counts as one', () {
      final _Buffer buffer = _Buffer(text);

      buffer.setText(text.replaceAll('line', 'row'), cursorOffset: 0);

      expect(buffer.tracker.currentLineOf(0), 0);
      expect(buffer.tracker.currentLineOf(3), 0);
    });

    test('undoing an edit leaves the line edited', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(2) + 1, 'x');
      buffer.replace(buffer.lineStart(2) + 1, buffer.lineStart(2) + 2, '');

      expect(buffer.text, text);
      expect(buffer.tracker.currentLineOf(2), 1);
    });

    test('a CRLF buffer counts CRLF as one ending', () {
      const String crlf = 'line0\r\nline1\r\nline2\r\n';
      final _Buffer buffer = _Buffer(crlf);

      buffer.insert(buffer.lineStart(1), 'new\r\n');

      expect(buffer.tracker.currentLineOf(1), 2);
      expect(buffer.tracker.currentLineOf(2), 3);
    });

    test('no unedited line above gives 0', () {
      final _Buffer buffer = _Buffer(text);

      buffer.replace(0, buffer.lineStart(2), 'changed\n');

      expect(buffer.tracker.currentLineOf(1), 0);
      expect(buffer.tracker.currentLineOf(0), 0);
      expect(buffer.tracker.currentLineOf(2), 1);
    });

    test('pasting a copy of a line directly above it keeps the original', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(2), 'line2\n');

      expect(buffer.text, 'line0\nline1\nline2\nline2\nline3\n');
      expect(buffer.tracker.currentLineOf(2), 3);
    });

    test('deleting the first of two identical adjacent lines', () {
      final _Buffer buffer = _Buffer('a\nsame\nsame\nb\n');

      buffer.replace(buffer.lineStart(1), buffer.lineStart(2), '');

      expect(buffer.tracker.currentLineOf(1), 0);
      expect(buffer.tracker.currentLineOf(2), 1);
      expect(buffer.tracker.currentLineOf(3), 2);
    });

    group('Enter at the end of a line', () {
      for (final (String name, String content, String ending) in <(
        String,
        String,
        String,
      )>[
        ('LF', '  line0\n  line1\n  line2\n', '\n'),
        ('CRLF', '  line0\r\n  line1\r\n  line2\r\n', '\r\n'),
      ]) {
        for (final String indent in <String>['', '  ']) {
          test('$name, ${indent.isEmpty ? 'no' : 'with'} auto-indent', () {
            final _Buffer buffer = _Buffer(content);

            buffer.insert(buffer.lineContentEnd(1), '$ending$indent');

            expect(buffer.tracker.currentLineOf(1), 1);
            expect(buffer.tracker.currentLineOf(2), 3);
          });
        }
      }

      test('at the end of an unterminated last line', () {
        final _Buffer buffer = _Buffer('line0\nline1');

        buffer.insert(buffer.text.length, '\n  ');

        expect(buffer.tracker.currentLineOf(1), 1);
      });

      test('a character typed at a line end marks it edited', () {
        final _Buffer buffer = _Buffer(text);

        buffer.insert(buffer.lineContentEnd(1), 'x');

        expect(buffer.tracker.currentLineOf(1), 0);
        expect(buffer.tracker.currentLineOf(2), 2);
      });
    });

    test('a change with no cursor offset is recorded with no limit', () {
      final _Buffer buffer = _Buffer(text);

      buffer.insert(buffer.lineStart(1), 'line1\n', withCursor: false);

      expect(buffer.tracker.currentLineOf(0), 0);
      expect(buffer.tracker.currentLineOf(3), 4);

      buffer.insert(buffer.lineStart(3) + 1, 'x', withCursor: false);

      expect(buffer.tracker.currentLineOf(2), 2);
    });

    test('a line outside the initial text has no current line', () {
      final TH2TextLineTracker tracker = TH2TextLineTracker(text);

      expect(tracker.currentLineOf(4), isNull);
      expect(tracker.currentLineOf(-1), isNull);
    });
  });
}
