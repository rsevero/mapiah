// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_element_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th2_text_line_map_test_aux.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TH2TextLineMapFakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  List<int> childrenOf(TH2File file, int mpID) {
    return (file.elementByMPID(mpID) as THIsParentMixin).childrenMPIDs
        .toList();
  }

  TH2TextLocation locate(int line, TH2TextLineMap lineMap, TH2File file) {
    return TH2TextElementLocator.locate(
      line: line,
      lineMap: lineMap,
      th2File: file,
    );
  }

  test('every row of a written text', () async {
    const String text = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100
# file comment

scrap s1
  point 1 1 station -name A1 \\
      -align top

  # scrap comment
  comment
  inside scrap
  endcomment
  line slope -id l1
    # inside line

    comment
    inside line
    endcomment
    1 1
      orientation 45
      smooth off
    2 2
      l-size 10
    3 3
  endline
  line wall
    1 1
    2 2
    subtype clay
    3 3
  endline
  area water
    l1

  endarea
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final TH2File file = parsed.file;
    final (String written, TH2TextLineMap lineMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(file);

    expect(written, text);

    final int scrapMPID = file.getScraps().single.mpID;
    final List<int> scrapChildren = childrenOf(file, scrapMPID);
    final int pointMPID = scrapChildren[0];
    final int slopeMPID = scrapChildren[4];
    final int wallMPID = scrapChildren[5];
    final int areaMPID = scrapChildren[6];
    final List<int> slopeSegments = (file.elementByMPID(slopeMPID) as THLine)
        .getLineSegmentMPIDs(file);
    final List<int> wallSegments = (file.elementByMPID(wallMPID) as THLine)
        .getLineSegmentMPIDs(file);

    const TH2TextLocation fileLevel = TH2TextLocationFileLevel();
    final TH2TextLocation activateScrap = TH2TextLocationActivateScrap(
      scrapMPID: scrapMPID,
    );

    TH2TextLocation selectElement(int mpID) =>
        TH2TextLocationSelectElement(mpID: mpID, scrapMPID: scrapMPID);

    TH2TextLocation selectLinePoint(int lineMPID, int lineSegmentMPID) =>
        TH2TextLocationSelectLinePoint(
          lineMPID: lineMPID,
          lineSegmentMPID: lineSegmentMPID,
          scrapMPID: scrapMPID,
        );

    final List<TH2TextLocation> expected = <TH2TextLocation>[
      /// encoding, a setting, a file-level comment and empty line.
      fileLevel,
      fileLevel,
      fileLevel,
      fileLevel,

      /// scrap
      activateScrap,

      /// A point line and its continuation.
      selectElement(pointMPID),
      selectElement(pointMPID),

      /// An empty line, a comment and a multiline comment inside a scrap.
      activateScrap,
      activateScrap,
      activateScrap,
      activateScrap,
      activateScrap,

      /// A line header; a comment, an empty line and a multiline comment
      /// inside the line.
      selectElement(slopeMPID),
      selectElement(slopeMPID),
      selectElement(slopeMPID),
      selectElement(slopeMPID),
      selectElement(slopeMPID),
      selectElement(slopeMPID),

      /// Line points and their option lines.
      selectLinePoint(slopeMPID, slopeSegments[0]),
      selectLinePoint(slopeMPID, slopeSegments[0]),
      selectLinePoint(slopeMPID, slopeSegments[0]),
      selectLinePoint(slopeMPID, slopeSegments[1]),
      selectLinePoint(slopeMPID, slopeSegments[1]),
      selectLinePoint(slopeMPID, slopeSegments[2]),

      /// endline
      selectElement(slopeMPID),

      /// A subtype after the line's second point.
      selectElement(wallMPID),
      selectLinePoint(wallMPID, wallSegments[0]),
      selectLinePoint(wallMPID, wallSegments[1]),
      selectLinePoint(wallMPID, wallSegments[1]),
      selectLinePoint(wallMPID, wallSegments[2]),
      selectElement(wallMPID),

      /// An area header, a border reference, an empty line and endarea.
      selectElement(areaMPID),
      selectElement(areaMPID),
      selectElement(areaMPID),
      selectElement(areaMPID),

      /// endscrap
      activateScrap,
    ];

    expect(lineMap.lineCount, expected.length);
    for (int line = 0; line < expected.length; line++) {
      expect(locate(line, lineMap, file), expected[line], reason: '$line');
    }

    /// The empty editor line after the trailing ending and a line past the
    /// end.
    expect(locate(expected.length, lineMap, file), fileLevel);
    expect(locate(expected.length + 10, lineMap, file), fileLevel);
    expect(locate(-1, lineMap, file), fileLevel);
  });

  test('a blank line before encoding, on a parser map', () async {
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
      '\nencoding UTF-8\nscrap s1\nendscrap\n',
    );

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));
    expect(
      locate(0, parsed.parserMap, parsed.file),
      const TH2TextLocationFileLevel(),
    );
    expect(
      locate(2, parsed.parserMap, parsed.file),
      TH2TextLocationActivateScrap(
        scrapMPID: parsed.file.getScraps().single.mpID,
      ),
    );
  });

  test('the synthesized encoding line', () async {
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
      'encoding UTF-8\nscrap s1\nendscrap\n',
    );
    final TH2File file = parsed.file;

    file.removeElement(file.elementByMPID(file.childrenMPIDs.first));

    final (String text, TH2TextLineMap lineMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(file);

    expect(text, 'encoding UTF-8\nscrap s1\nendscrap\n');
    expect(lineMap.ownerOfLine(0), file.mpID);
    expect(file.hasElementByMPID(file.mpID), isFalse);
    expect(locate(0, lineMap, file), const TH2TextLocationFileLevel());
  });

  test('an area option line and a line option line, on raw text', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall -id l1
    0 0
    close on
    5 0
    5 5
  endline
  area water
    place bottom
    l1
  endarea
endscrap
''';
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final TH2File file = parsed.file;
    final int scrapMPID = file.getScraps().single.mpID;
    final int lineMPID = file.getLines().single.mpID;
    final int areaMPID = file.elements.values.whereType<THArea>().single.mpID;

    expect(
      locate(4, parsed.parserMap, file),
      TH2TextLocationSelectElement(mpID: lineMPID, scrapMPID: scrapMPID),
    );
    expect(
      locate(9, parsed.parserMap, file),
      TH2TextLocationSelectElement(mpID: areaMPID, scrapMPID: scrapMPID),
    );
  });
}
