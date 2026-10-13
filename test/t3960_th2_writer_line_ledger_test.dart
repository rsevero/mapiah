// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/exceptions/th2_unsupported_line_ending_exception.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th2_text_line_map_test_aux.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TH2TextLineMapFakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  group('TH2TextLineEndingsAux', () {
    test('LF', () {
      expect(TH2TextLineEndingsAux.lineStartOffsets('a\nbc\nd\n'), <int>[
        0,
        2,
        5,
      ]);
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('a\nb\n'), isNull);
    });

    test('CRLF', () {
      expect(TH2TextLineEndingsAux.lineStartOffsets('a\r\nbc\r\n'), <int>[
        0,
        3,
      ]);
      expect(
        TH2TextLineEndingsAux.loneCarriageReturnOffset('a\r\nbc\r\n'),
        isNull,
      );
    });

    test('mixed endings', () {
      expect(TH2TextLineEndingsAux.lineStartOffsets('a\r\nb\nc\r\nd'), <int>[
        0,
        3,
        5,
        8,
      ]);
    });

    test('no final ending', () {
      expect(TH2TextLineEndingsAux.lineStartOffsets('a\nb'), <int>[0, 2]);
      expect(TH2TextLineEndingsAux.lineStartOffsets('a'), <int>[0]);
    });

    test('empty text', () {
      expect(TH2TextLineEndingsAux.lineStartOffsets(''), isEmpty);
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset(''), isNull);
    });

    test('lone carriage return in the middle and at the end', () {
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('ab\rc\n'), 2);
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('a\r\nb\r'), 4);
      expect(TH2TextLineEndingsAux.loneCarriageReturnOffset('\r\n\r'), 2);
    });

    test('line index at offset', () {
      final List<int> lineStarts = TH2TextLineEndingsAux.lineStartOffsets(
        'ab\r\ncd\ne',
      );

      expect(TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, 0), 0);
      expect(TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, 3), 0);
      expect(TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, 4), 1);
      expect(TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, 6), 1);
      expect(TH2TextLineEndingsAux.lineIndexAtOffset(lineStarts, 7), 2);
    });
  });

  test('every clean fixture: ledger and ordinary output agree', () async {
    final List<(String, TH2TextParsed)> cleanFixtures =
        await TH2TextLineMapTestAux.cleanFixtures();

    expect(cleanFixtures, isNotEmpty);

    for (final (String path, TH2TextParsed parsed) in cleanFixtures) {
      final TH2File file = parsed.file;

      for (final bool useOriginalRepresentation in <bool>[true, false]) {
        final String reason = '$path (original: $useOriginalRepresentation)';
        final String text = TH2TextLineMapTestAux.asSaved(
          file,
          useOriginalRepresentation: useOriginalRepresentation,
        );

        /// The ledger's contiguity, length and single-owner checks are
        /// assertions inside serializeWithLineMap.
        final (String ledgerText, TH2TextLineMap lineMap) =
            TH2TextLineMapTestAux.asSavedWithLineMap(
              file,
              useOriginalRepresentation: useOriginalRepresentation,
            );

        expect(ledgerText, text, reason: reason);
        expect(
          TH2TextLineMapTestAux.writerMapProblems(text, lineMap, file),
          isEmpty,
          reason: reason,
        );
        expect(
          TH2TextLineMapTestAux.savedBytes(
            file,
            useOriginalRepresentation: useOriginalRepresentation,
          ),
          MPEncodingAux.encode(text, file.encoding),
          reason: reason,
        );
      }

      /// Only stored text round-trips stably: some generated output doesn't
      /// reparse to the same model yet.
      final String firstWrite = TH2TextLineMapTestAux.asSaved(file);
      final TH2TextParsed reparsed = await TH2TextLineMapTestAux.parseBytes(
        TH2TextLineMapTestAux.savedBytes(file),
        filename: path,
      );

      expect(reparsed.isSuccessful, isTrue, reason: path);
      expect(
        TH2TextLineMapTestAux.asSaved(reparsed.file),
        firstWrite,
        reason: path,
      );
    }
  });

  test('a model with no stored text', () async {
    const String text = '''encoding UTF-8
##XTHERION## xth_me_area_adjust 0 0 100 100
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fplain.png;xx=10;yy=20;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=0;pivotSet=false}
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Frotated.png;xx=10;yy=20;xScale=1;yScale=2;rotationCenterDx=3;rotationCenterDy=4;rotationDeg=5}
scrap s1
  point 1 1 station -name A1 -align top -scale large -visibility on -clip off -place top -context point station -id station_with_a_long_identifier
  line wall
    1 1
      smooth off
      orientation 45
    2 2
  endline
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final TH2File file = parsed.file;

    TH2TextLineMapTestAux.stripStoredText(file);
    file.removeElement(file.elementByMPID(file.childrenMPIDs.first));

    final THXTherionConfig newSetting = THXTherionConfig(
      parentMPID: file.mpID,
      name: 'xth_me_area_zoom_to',
      value: '100',
    );

    file.addElement(newSetting);
    file.addElementToParent(newSetting);

    for (final bool useOriginalRepresentation in <bool>[true, false]) {
      final String written = TH2TextLineMapTestAux.asSaved(
        file,
        useOriginalRepresentation: useOriginalRepresentation,
      );
      final (String ledgerText, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(
            file,
            useOriginalRepresentation: useOriginalRepresentation,
          );

      expect(ledgerText, written);
      expect(
        TH2TextLineMapTestAux.writerMapProblems(written, lineMap, file),
        isEmpty,
      );

      final List<String> lines = written.split('\n');

      /// The synthesized encoding line belongs to the file.
      expect(lines.first, 'encoding UTF-8');
      expect(lineMap.ownerOfLine(0), file.mpID);

      /// The new setting moved up into the settings section.
      final int newSettingLine = lineMap.firstOwnLineOf(newSetting.mpID)!;

      expect(lines[newSettingLine], startsWith('##XTHERION## xth_me_area_zoom_to'));
      expect(newSettingLine, lessThan(lineMap.firstOwnLineOf(file.getScraps().first.mpID)!));

      /// Every wrapped part of the point line belongs to the point.
      final THPoint point = file.getPoints().single;
      final List<int> pointLines = lineMap.ownLinesOf(point.mpID);

      expect(pointLines.length, greaterThan(1));
      for (int index = 0; index < pointLines.length - 1; index++) {
        expect(lines[pointLines[index]], endsWith('\\'));
      }

      /// The representable image is written as an XTherion line owned by its
      /// element; the rotated one as a ##MAPIAH## line.
      final List<MPImageInsertConfig> images = file.elements.values
          .whereType<MPImageInsertConfig>()
          .toList();

      expect(images, hasLength(2));
      for (final MPImageInsertConfig image in images) {
        final List<int> imageLines = lineMap.ownLinesOf(image.mpID);

        expect(imageLines, hasLength(1));
        expect(
          lines[imageLines.single],
          image.isXTherionRepresentable
              ? startsWith('##XTHERION## xth_me_image_insert')
              : startsWith('##MAPIAH## image_insert_v1'),
        );
      }

      /// Generated line point option lines belong to their segment.
      final THLine line = file.getLines().single;
      final int firstSegmentMPID = line.getLineSegmentMPIDs(file).first;
      final List<int> segmentLines = lineMap.ownLinesOf(firstSegmentMPID);

      expect(segmentLines, hasLength(3));
      expect(lines[segmentLines[1]].trim(), 'orientation 45');
      expect(lines[segmentLines[2]].trim(), 'smooth off');
    }
  });

  test('a lone carriage return in stored text', () async {
    const String text = '''encoding UTF-8
# a comment
scrap s1
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final TH2File file = parsed.file;
    final THComment comment = file.elements.values
        .whereType<THComment>()
        .single;

    file.substituteElement(
      comment.copyWith(originalLineInTH2File: '# a\rcomment\n'),
    );

    expect(
      () => TH2TextLineMapTestAux.asSavedWithLineMap(file),
      throwsA(
        isA<TH2UnsupportedLineEndingException>()
            .having(
              (TH2UnsupportedLineEndingException e) => e.mpID,
              'mpID',
              comment.mpID,
            )
            .having(
              (TH2UnsupportedLineEndingException e) => e.offset,
              'offset',
              'encoding UTF-8\n# a'.length,
            ),
      ),
    );

    final String written = TH2TextLineMapTestAux.asSaved(file);

    expect(written, 'encoding UTF-8\n# a\rcomment\nscrap s1\nendscrap\n');
  });

  test('a file with no children', () {
    final TH2File file = TH2File();

    file.lineEnding = '\n';

    final String expected = 'encoding ${file.encoding}\n';

    expect(TH2FileWriter().serialize(file), expected);

    final (String text, TH2TextLineMap lineMap) = TH2FileWriter()
        .serializeWithLineMap(file);

    expect(text, expected);
    expect(lineMap.lineCount, 1);
    expect(lineMap.ownerOfLine(0), file.mpID);
  });
}
