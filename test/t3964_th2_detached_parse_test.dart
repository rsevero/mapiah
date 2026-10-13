// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_parser_line_start.dart';

import 'th2_text_apply_test_aux.dart';
import 'th2_text_line_map_test_aux.dart';
import 'th_test_aux.dart';

const String _validText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

/// A duplicated scrap id makes the parser throw.
const String _throwingText =
    'encoding utf-8\n'
    'scrap repeated\n'
    'endscrap\n'
    'scrap repeated\n'
    'endscrap\n';

const String _problemText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  poin 1 1 station\n'
    'endscrap\n';

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    TH2TextValidator.onScratchControllerCreatedForTesting = null;
    TH2TextValidator.afterParseForTesting = null;
    TH2FileParser.beforeCleanUpForTesting = null;
    mpLocator.mpGeneralController.reset();
  });

  Future<TH2TextValidationResult> validate(
    String content, {
    String filename = '/tmp/t3964_never_opened.th2',
    int th2FileMPID = -1000,
    String lineEnding = mpUnixLineBreak,
  }) {
    return TH2TextValidator.validate(
      content: content,
      filename: filename,
      th2FileMPID: th2FileMPID,
      lineEnding: lineEnding,
    );
  }

  /// Parses [contents] into a detached controller and returns its file.
  Future<(TH2File, TH2FileParser)> parseDetached(
    String contents, {
    required int th2FileMPID,
    required String lineEnding,
    String filename = '/tmp/t3964_detached.th2',
  }) async {
    final TH2FileEditController scratch =
        TH2FileEditControllerBase.createForDetachedParse(
          filename: filename,
          th2FileMPID: th2FileMPID,
          lineEnding: lineEnding,
        );
    final TH2FileParser parser = TH2FileParser();
    final (TH2File file, _, _) = await parser.parse(
      filename,
      contents: contents,
      targetController: scratch,
    );

    return (file, parser);
  }

  List<(int, int)> lineStartsOf(TH2FileParser parser) => <(int, int)>[
    for (final TH2ParserLineStart lineStart in parser.lineStarts)
      (lineStart.line, lineStart.mpID),
  ];

  group('isolation', () {
    test('a detached validation registers, replaces and dirties nothing', () async {
      final TH2FileEditController live = await TH2TextApplyTestAux.load(
        _validText,
      );
      final TH2File liveFile = live.th2File;
      final Map<String, dynamic> liveMap = liveFile.toMap();
      final int controllersRevision =
          mpLocator.mpGeneralController.th2ControllersRevision;
      final int structureRevision = live.structureRevision;
      final Set<String> dirtyPaths = mpLocator.thProjectController
          .dirtyFilePaths
          .toSet();

      for (final String content in <String>[
        _validText,
        '${_validText}scrap s2\nendscrap\n',
        _problemText,
        _throwingText,
      ]) {
        await validate(
          content,
          filename: liveFile.filename,
          th2FileMPID: liveFile.mpID,
          lineEnding: liveFile.lineEnding,
        );
        await validate(content, filename: '/tmp/t3964_no_controller.th2');
      }

      expect(
        mpLocator.mpGeneralController.th2ControllersRevision,
        controllersRevision,
      );
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          '/tmp/t3964_no_controller.th2',
        ),
        isNull,
      );
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          liveFile.filename,
        ),
        same(live),
      );
      expect(identical(live.th2File, liveFile), isTrue);
      expect(liveFile.toMap(), liveMap);
      expect(live.structureRevision, structureRevision);
      expect(mpLocator.thProjectController.dirtyFilePaths.toSet(), dirtyPaths);
    });

    test('the scratch controller is disposed after every outcome', () async {
      final List<TH2FileEditController> scratches = <TH2FileEditController>[];

      TH2TextValidator.onScratchControllerCreatedForTesting =
          scratches.add;

      final TH2TextValidationResult valid = await validate(_validText);
      final TH2TextValidationResult rejected = await validate(_problemText);
      final TH2TextValidationResult thrown = await validate(_throwingText);

      expect(valid.isValid, isTrue);
      expect(rejected.isValid, isFalse);
      expect(thrown.isValid, isFalse);
      expect(
        thrown.diagnostics.single.kind,
        TH2TextDiagnosticKind.unreadableText,
      );
      expect(scratches, hasLength(3));
      for (final TH2FileEditController scratch in scratches) {
        expect(scratch.isDisposed, isTrue);
      }
    });

    test('a detached controller refuses to install reactions', () {
      final TH2FileEditController scratch =
          TH2FileEditControllerBase.createForDetachedParse(
            filename: '/tmp/t3964_detached.th2',
            th2FileMPID: -1000,
            lineEnding: mpUnixLineBreak,
          );

      addTearDown(scratch.dispose);

      expect(
        scratch.initializeReactionsForTesting,
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('encoding detection', () {
    bool isASCIIWindow(Uint8List bytes) {
      int i = 0;

      while ((i < bytes.length) &&
          <int>[
            mpSpaceByte,
            mpTabByte,
            mpCarriageReturnByte,
            mpLineFeedByte,
          ].contains(bytes[i])) {
        i++;
      }

      for (
        int read = 0;
        (i < bytes.length) && (read < mpthMaxEncodingLength);
        i++, read++
      ) {
        if (bytes[i] >= 0x80) {
          return false;
        }
      }

      return true;
    }

    test('bytes and text helpers agree on every fixture', () {
      final List<File> fixtures = TH2TextLineMapTestAux.fixtures();
      int asciiWindows = 0;

      expect(fixtures, isNotEmpty);

      for (final File fixture in fixtures) {
        final Uint8List bytes = fixture.readAsBytesSync();
        final ({String encoding, String? lineEnding}) fromBytes =
            TH2FileParser.detectEncodingFromBytes(bytes);
        final String text = MPEncodingAux.decode(bytes, fromBytes.encoding);
        final ({String encoding, String? lineEnding}) fromText =
            TH2FileParser.detectEncodingFromText(text);

        expect(fromText.encoding, fromBytes.encoding, reason: fixture.path);

        if (isASCIIWindow(bytes)) {
          asciiWindows++;
          expect(
            fromText.lineEnding,
            fromBytes.lineEnding,
            reason: fixture.path,
          );
        }
      }

      expect(asciiWindows, greaterThan(0));
    });

    test('the helpers on CRLF, short windows, blank lines and no encoding', () {
      final Map<String, ({String encoding, String? lineEnding})> cases =
          <String, ({String encoding, String? lineEnding})>{
            'encoding iso8859-2\r\nscrap s1\r\n': (
              encoding: 'ISO8859-2',
              lineEnding: mpWindowsLineBreak,
            ),
            'encoding utf-8\nscrap s1\n': (
              encoding: 'UTF-8',
              lineEnding: mpUnixLineBreak,
            ),
            'encoding ascii': (encoding: 'ASCII', lineEnding: null),
            '\n\n  encoding ascii\n': (
              encoding: 'ASCII',
              lineEnding: mpUnixLineBreak,
            ),
            '##XTHERION## xth_me_area_adjust 0 0 1 1\n': (
              encoding: mpDefaultEncoding,
              lineEnding: null,
            ),
            'scrap s1 -title "a very long scrap title"\n': (
              encoding: mpDefaultEncoding,
              lineEnding: null,
            ),
            '': (encoding: mpDefaultEncoding, lineEnding: null),
          };

      for (final MapEntry<String, ({String encoding, String? lineEnding})>
          entry
          in cases.entries) {
        expect(
          TH2FileParser.detectEncodingFromText(entry.key),
          entry.value,
          reason: jsonEncode(entry.key),
        );
        expect(
          TH2FileParser.detectEncodingFromBytes(
            Uint8List.fromList(utf8.encode(entry.key)),
          ),
          entry.value,
          reason: jsonEncode(entry.key),
        );
      }
    });

    test('a non-ASCII character in the window is an ordinary character', () {
      final Uint8List bytes = Uint8List.fromList(
        utf8.encode('scrap s1 -title "Çã"\nendscrap\n'),
      );

      expect(
        TH2FileParser.detectEncodingFromBytes(bytes).encoding,
        mpDefaultEncoding,
      );
    });
  });

  group('contents', () {
    test('every clean fixture parses from text as from its bytes', () async {
      final List<File> fixtures = TH2TextLineMapTestAux.fixtures();
      int compared = 0;

      for (final File fixture in fixtures) {
        final Uint8List bytes = fixture.readAsBytesSync();
        final TH2TextParsed fromBytes = await TH2TextLineMapTestAux.parseBytes(
          bytes,
          filename: fixture.path,
        );

        if (!fromBytes.isSuccessful) {
          continue;
        }

        final Map<String, dynamic> bytesMap = fromBytes.file.toMap();
        final String encoding = fromBytes.file.encoding;
        final List<(int, int)> bytesLineStarts = lineStartsOf(
          fromBytes.parser,
        );
        final int bytesLineCount = fromBytes.parser.parsedLineCount;
        final String text = MPEncodingAux.decode(
          bytes,
          TH2FileParser.detectEncodingFromBytes(bytes).encoding,
        );

        mpLocator.mpGeneralController.reset();

        final (TH2File fromText, TH2FileParser textParser) =
            await parseDetached(
              text,
              th2FileMPID: fromBytes.file.mpID,
              lineEnding: fromBytes.file.lineEnding,
              filename: fromBytes.file.filename,
            );

        expect(fromText.toMap(), bytesMap, reason: fixture.path);
        expect(fromText.encoding, encoding, reason: fixture.path);
        expect(
          lineStartsOf(textParser),
          bytesLineStarts,
          reason: fixture.path,
        );
        expect(
          textParser.parsedLineCount,
          bytesLineCount,
          reason: fixture.path,
        );
        compared++;
      }

      expect(compared, greaterThan(0));
    });

    test('text with NUL characters parses as its bytes do', () async {
      const String text =
          'encoding utf-8\n'
          'scrap s\u00001\n'
          '  point 1 1 station -id \u0000p1\n'
          'endscrap\n';
      final TH2TextParsed fromBytes = await TH2TextLineMapTestAux.parseText(
        text,
      );

      expect(fromBytes.isSuccessful, isTrue);

      final Map<String, dynamic> bytesMap = fromBytes.file.toMap();

      mpLocator.mpGeneralController.reset();

      final (TH2File fromText, _) = await parseDetached(
        text,
        th2FileMPID: fromBytes.file.mpID,
        lineEnding: fromBytes.file.lineEnding,
        filename: fromBytes.file.filename,
      );

      expect(fromText.toMap(), bytesMap);
      expect(fromText.hasElementByTHID('p1'), isTrue);
    });

    test('a non-ASCII first line with no encoding line loads', () async {
      const String text = 'scrap s1 -title "Çã"\nendscrap\n';
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );

      expect(controller.loadError, isNull);
      expect(controller.isBroken, isFalse);
      expect(controller.th2File.encoding, mpDefaultEncoding);
      expect(controller.th2File.hasElementByTHID('s1'), isTrue);

      final TH2TextValidationResult result = await validate(text);

      expect(result.isValid, isTrue);
      expect(result.detachedFile.encoding, mpDefaultEncoding);
      expect(result.normalizedText, 'encoding $mpDefaultEncoding\n$text');
    });

    test('the scratch file keeps the line ending it was created with', () async {
      const Map<String, String> texts = <String, String>{
        'crlf': 'encoding utf-8\r\nscrap s1\r\nendscrap\r\n',
        'lf': 'encoding utf-8\nscrap s1\nendscrap\n',
        'comment': '# a comment\r\nscrap s1\r\nendscrap\r\n',
      };

      for (final MapEntry<String, String> entry in texts.entries) {
        for (final String lineEnding in <String>[
          mpUnixLineBreak,
          mpWindowsLineBreak,
        ]) {
          final (TH2File file, _) = await parseDetached(
            entry.value,
            th2FileMPID: -1000,
            lineEnding: lineEnding,
          );

          expect(file.lineEnding, lineEnding, reason: entry.key);
        }
      }
    });
  });
}
