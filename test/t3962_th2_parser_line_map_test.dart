// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th2_text_line_map_test_aux.dart';

/// Fixtures whose parser and writer maps disagree because of parser behavior
/// out of this phase's scope. Expected to stay empty.
const Set<String> _mapAgreementExceptions = <String>{};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TH2TextLineMapFakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  /// The MPID the parser started at each 1-based source line.
  Map<int, int> mpIDByStartLine(TH2TextParsed parsed) {
    return <int, int>{
      for (final MapEntry<int, int> entry
          in parsed.parser.elementStartLines.entries)
        entry.value: entry.key,
    };
  }

  List<int> childrenOf(TH2File file, int mpID) {
    return (file.elementByMPID(mpID) as THIsParentMixin).childrenMPIDs
        .toList();
  }

  Future<TH2TextParsed> parseClean(String text) async {
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    return parsed;
  }

  test('every clean fixture: parser and writer maps agree', () async {
    final List<(String, TH2TextParsed)> cleanFixtures =
        await TH2TextLineMapTestAux.cleanFixtures();
    final List<String> disagreements = <String>[];

    expect(cleanFixtures, isNotEmpty);

    for (final (String path, TH2TextParsed parsed) in cleanFixtures) {
      final String written = TH2TextLineMapTestAux.asSaved(parsed.file);
      final TH2TextParsed reparsed = await TH2TextLineMapTestAux.parseBytes(
        TH2TextLineMapTestAux.savedBytes(parsed.file),
        filename: path,
      );

      expect(reparsed.isSuccessful, isTrue, reason: path);

      final TH2TextLineMap parserMap = reparsed.parserMap;
      final (String text, TH2TextLineMap writerMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(reparsed.file);

      expect(text, written, reason: path);
      expect(parserMap.lineCount, writerMap.lineCount, reason: path);
      expect(parserMap.removedLines, isEmpty, reason: path);

      for (int line = 0; line < writerMap.lineCount; line++) {
        if (parserMap.ownerOfLine(line) != writerMap.ownerOfLine(line)) {
          disagreements.add('$path:$line');
          break;
        }
      }
    }

    expect(
      disagreements.where(
        (String disagreement) => !_mapAgreementExceptions.contains(
          disagreement.substring(0, disagreement.lastIndexOf(':')),
        ),
      ),
      isEmpty,
    );
  });

  test('option lines, multi-line values and a final unterminated line', () async {
    const String text = '''encoding UTF-8
scrap s1 -scale [ 0 0 \\
	96 0 0 0 200 0 in ]
  point 2 2 label -text "First line \\
Second line"
  point 3 3 u:test -attr foo "the foo value" \\
      -attr bar "the bar value"
  line wall
    1 1
      orientation 45
      smooth \\
        off
    2 2
  endline
endscrap
# final comment''';
    final TH2TextParsed parsed = await parseClean(text);
    final TH2TextLineMap parserMap = parsed.parserMap;
    final (String written, TH2TextLineMap writerMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(parsed.file);

    expect(written, text);
    expect(parserMap.lineCount, 16);
    for (int line = 0; line < 16; line++) {
      expect(
        parserMap.ownerOfLine(line),
        writerMap.ownerOfLine(line),
        reason: '$line',
      );
    }

    final TH2File file = parsed.file;
    final int scrapMPID = file.getScraps().single.mpID;
    final THLine line = file.getLines().single;
    final int firstSegmentMPID = line.getLineSegmentMPIDs(file).first;

    expect(parserMap.ownLinesOf(scrapMPID), <int>[1, 2]);
    expect(parserMap.ownLinesOf(firstSegmentMPID), <int>[8, 9, 10, 11]);
    expect(parserMap.ownerOfLine(15), file.childrenMPIDs.last);
    expect(parserMap.ownerOfLine(16), isNull);
  });

  test('removed lines', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall
    1 1
    1 1
    2 2
  endline
  line wall -id l1
    1 1
  endline
  line wall -id l2
    0 0
    5 0
    5 5
    0 0
  endline
  area water
    l1
    l2
  endarea
  area water
    place bottom
  endarea
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);
    final TH2File file = parsed.file;
    final Map<int, int> startedAt = mpIDByStartLine(parsed);
    final TH2TextLineMap parserMap = parsed.parserMap;

    /// 1-based source lines whose element was removed.
    const List<int> removedSourceLines = <int>[5, 8, 9, 10, 18, 21, 22, 23];

    for (final int sourceLine in removedSourceLines) {
      final int line = sourceLine - 1;
      final int expectedMPID = (sourceLine == 22)
          ? startedAt[21]!
          : startedAt[sourceLine]!;

      expect(file.hasElementByMPID(expectedMPID), isFalse, reason: '$line');
      expect(parserMap.removedLines[line], expectedMPID, reason: '$line');
      expect(parserMap.ownerOfLine(line), isNull, reason: '$line');
    }
    expect(parserMap.removedLines.keys.toSet(), <int>{
      for (final int sourceLine in removedSourceLines) sourceLine - 1,
    });

    /// The surviving area still owns its remaining border line.
    final int survivingAreaMPID = startedAt[17]!;

    expect(file.hasElementByMPID(survivingAreaMPID), isTrue);
    expect(parserMap.ownerOfLine(18), startedAt[19]);
    expect(
      childrenOf(file, survivingAreaMPID).first,
      startedAt[19],
    );

    /// The lines around the duplicate point keep their owners.
    expect(parserMap.ownerOfLine(3), startedAt[4]);
    expect(parserMap.ownerOfLine(5), startedAt[6]);
  });

  test('a line option moved to the header, on raw text', () async {
    for (final String text in <String>[
      '''encoding UTF-8
scrap s1
  line wall
    1 1
    subtype clay
    2 2
  endline
endscrap
''',
      '''encoding UTF-8
scrap s1
  line wall
    subtype clay
    1 1
    2 2
  endline
endscrap
''',
    ]) {
      final TH2TextParsed parsed = await parseClean(text);
      final THLine line = parsed.file.getLines().single;
      final int subtypeLine = text.split('\n').indexOf('    subtype clay');

      expect(line.hasOption(THCommandOptionType.subtype), isTrue);
      expect(parsed.parserMap.ownerOfLine(subtypeLine), line.mpID);

      final (String written, TH2TextLineMap writerMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(parsed.file);

      expect(written, contains('  line wall:clay\n'));
      expect(written, isNot(contains('subtype')));
      expect(writerMap.ownLinesOf(line.mpID), <int>[2]);
    }
  });

  test('area option lines, on raw text', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall -id l1 -close on
    0 0
    5 0
    5 5
  endline
  area water
    place bottom
    l1

    clip off
  endarea
endscrap
''';
    final TH2TextParsed parsed = await parseClean(text);
    final TH2File file = parsed.file;
    final THArea area = file.elements.values.whereType<THArea>().single;
    final List<int> areaChildren = childrenOf(file, area.mpID);
    final TH2TextLineMap parserMap = parsed.parserMap;

    expect(parserMap.ownerOfLine(7), area.mpID);
    expect(parserMap.ownerOfLine(8), area.mpID);
    expect(parserMap.ownerOfLine(9), areaChildren[0]);
    expect(file.elementByMPID(areaChildren[1]), isA<THEmptyLine>());
    expect(parserMap.ownerOfLine(10), areaChildren[1]);
    expect(parserMap.ownerOfLine(11), area.mpID);
    expect(parserMap.ownLinesOf(area.mpID), <int>[7, 8, 11]);

    final (String written, TH2TextLineMap writerMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(file);
    final List<String> writtenLines = written.split('\n');
    final List<int> areaLines = writerMap.ownLinesOf(area.mpID);

    expect(areaLines, hasLength(1));
    expect(writtenLines[areaLines.single], contains('-place bottom'));
    expect(writtenLines[areaLines.single], contains('-clip off'));
    expect(written, isNot(contains('\n    place bottom')));
  });

  test('a subtype kept as a line point option', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall
    1 1
    2 2
    subtype clay
    3 3
  endline
endscrap
''';
    final TH2TextParsed parsed = await parseClean(text);
    final TH2File file = parsed.file;
    final int secondSegmentMPID = file.getLines().single
        .getLineSegmentMPIDs(file)[1];
    final (String written, TH2TextLineMap writerMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(file);

    expect(written, text);
    expect(parsed.parserMap.ownerOfLine(5), secondSegmentMPID);
    expect(writerMap.ownerOfLine(5), secondSegmentMPID);
  });

  test('option lines after another element, on raw text', () async {
    const String afterComment = '''encoding UTF-8
scrap s1
  line wall
    1 1
    # c
    smooth off
    2 2
  endline
endscrap
''';
    final TH2TextParsed parsedAfterComment = await parseClean(afterComment);
    final TH2File fileAfterComment = parsedAfterComment.file;
    final THLine lineAfterComment = fileAfterComment.getLines().single;
    final List<int> childrenAfterComment = childrenOf(
      fileAfterComment,
      lineAfterComment.mpID,
    );

    expect(
      fileAfterComment.elementByMPID(childrenAfterComment[1]),
      isA<THComment>(),
    );
    expect(
      parsedAfterComment.parserMap.ownerOfLine(4),
      childrenAfterComment[1],
    );
    expect(
      parsedAfterComment.parserMap.ownerOfLine(5),
      childrenAfterComment[0],
    );

    const String beforePoint = '''encoding UTF-8
scrap s1
  line wall
    # c
    close on
    1 1
    2 2
  endline
endscrap
''';
    final TH2TextParsed parsedBeforePoint = await parseClean(beforePoint);
    final THLine lineBeforePoint = parsedBeforePoint.file.getLines().single;

    expect(parsedBeforePoint.parserMap.ownerOfLine(4), lineBeforePoint.mpID);

    const String afterBlank = '''encoding UTF-8
scrap s1
  line wall
    1 1

    smooth off
    2 2
  endline
endscrap
''';
    final TH2TextParsed parsedAfterBlank = await parseClean(afterBlank);
    final TH2File fileAfterBlank = parsedAfterBlank.file;
    final THLine lineAfterBlank = fileAfterBlank.getLines().single;
    final List<int> childrenAfterBlank = childrenOf(
      fileAfterBlank,
      lineAfterBlank.mpID,
    );
    final int firstSegmentMPID = childrenAfterBlank[0];
    final int emptyLineMPID = childrenAfterBlank[1];

    expect(fileAfterBlank.elementByMPID(emptyLineMPID), isA<THEmptyLine>());
    expect(parsedAfterBlank.parserMap.ownerOfLine(4), emptyLineMPID);
    expect(parsedAfterBlank.parserMap.ownerOfLine(5), firstSegmentMPID);

    /// The writer writes the option line right after its segment.
    final (String written, TH2TextLineMap writerMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(fileAfterBlank);
    final List<String> writtenLines = written.split('\n');

    expect(writtenLines[4].trim(), 'smooth off');
    expect(writtenLines[5], isEmpty);
    expect(writerMap.ownerOfLine(4), firstSegmentMPID);
    expect(writerMap.ownerOfLine(5), emptyLineMPID);
  });

  test('leading blank lines have no owner', () async {
    final TH2TextParsed parsed = await parseClean(
      '\n\nencoding UTF-8\nscrap s1\nendscrap\n',
    );
    final TH2TextLineMap parserMap = parsed.parserMap;

    expect(parserMap.lineCount, 5);
    expect(parserMap.ownerOfLine(0), isNull);
    expect(parserMap.ownerOfLine(1), isNull);
    expect(parserMap.removedLines, isEmpty);
    expect(parserMap.ownerOfLine(2), parsed.file.childrenMPIDs.first);
    expect(
      parsed.file.elementByMPID(parsed.file.childrenMPIDs.first),
      isA<THEncoding>(),
    );
  });

  test('one start per added element and per option line', () async {
    const String text = '''encoding UTF-8
scrap s1
  point 1 1 station
  line wall
    1 1
      smooth off
    close on
    2 2
  endline
  area water
    place bottom
  endarea
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    /// The empty area is removed by the clean-up, so its elements are counted
    /// apart from the file's.
    const int removedElementCount = 2;

    expect(
      parsed.parser.elementStartLines.length,
      parsed.file.countElements() + removedElementCount,
    );
    expect(
      parsed.parser.lineStarts.length,
      parsed.parser.elementStartLines.length + 3,
    );
    expect(parsed.parser.parsedLineCount, 13);
  });
}
