// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th2_text_line_map_test_aux.dart';

/// Writer maps of handcrafted text: every line's owner, own lines and ranges.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TH2TextLineMapFakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  const String body = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100

comment
file level
endcomment
scrap s1 -scale [ 0 0 \\
	96 0 0 0 200 0 in ]
  point 1 1 station -name A1
  point 2 2 label -text "First line
Second line"
  point 3 3 u:test -attr foo "the foo value" \\
      -attr bar "the bar value"
  line wall -id w1
    # inside line

    comment
    inside line
    endcomment
    1 1
      smooth off
    2 2
    3 3
  endline
  area water
    w1

  endarea
endscrap
# final comment''';

  Future<(TH2File, String, TH2TextLineMap)> writeMap(String text) async {
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(text);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final (String written, TH2TextLineMap lineMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(parsed.file);

    expect(written, text);

    return (parsed.file, written, lineMap);
  }

  List<int> childrenOf(TH2File file, int mpID) {
    return (file.elementByMPID(mpID) as THIsParentMixin).childrenMPIDs
        .toList();
  }

  test('every line of a handcrafted text', () async {
    final (TH2File file, String _, TH2TextLineMap lineMap) = await writeMap(
      body,
    );
    final List<int> fileChildren = file.childrenMPIDs.toList();
    final int encodingMPID = fileChildren[0];
    final int settingMPID = fileChildren[1];
    final int emptyLineMPID = fileChildren[2];
    final int multilineCommentMPID = fileChildren[3];
    final int scrapMPID = fileChildren[4];
    final int finalCommentMPID = fileChildren[5];
    final List<int> multilineCommentChildren = childrenOf(
      file,
      multilineCommentMPID,
    );
    final List<int> scrapChildren = childrenOf(file, scrapMPID);
    final int lineMPID = scrapChildren[3];
    final int areaMPID = scrapChildren[4];
    final List<int> lineChildren = childrenOf(file, lineMPID);
    final List<int> areaChildren = childrenOf(file, areaMPID);
    final List<int> innerCommentChildren = childrenOf(file, lineChildren[2]);

    expect(file.elementByMPID(lineMPID), isA<THLine>());
    expect(file.elementByMPID(areaMPID), isA<THArea>());
    expect(file.elementByMPID(lineChildren[3]), isA<THLineSegment>());
    expect(file.elementByMPID(areaChildren[0]), isA<THAreaBorderTHID>());

    final List<int> expectedOwners = <int>[
      encodingMPID,
      settingMPID,
      emptyLineMPID,
      multilineCommentMPID,
      multilineCommentChildren[0],
      multilineCommentChildren[1],

      /// A bracketed value over two lines.
      scrapMPID,
      scrapMPID,
      scrapChildren[0],

      /// A quoted value over two lines.
      scrapChildren[1],
      scrapChildren[1],

      /// A `\`-continued line.
      scrapChildren[2],
      scrapChildren[2],
      lineMPID,

      /// A comment, an empty line and a multiline comment inside the line.
      lineChildren[0],
      lineChildren[1],
      lineChildren[2],
      innerCommentChildren[0],
      innerCommentChildren[1],

      /// A line point and its option line.
      lineChildren[3],
      lineChildren[3],
      lineChildren[4],
      lineChildren[5],
      lineChildren[6],
      areaMPID,

      /// A border reference, an empty line inside the area and endarea.
      areaChildren[0],
      areaChildren[1],
      areaChildren[2],
      scrapChildren[5],

      /// The final line, with no line ending.
      finalCommentMPID,
    ];

    expect(lineMap.lineCount, expectedOwners.length);
    for (int line = 0; line < expectedOwners.length; line++) {
      expect(lineMap.ownerOfLine(line), expectedOwners[line], reason: '$line');
    }
    expect(lineMap.ownerOfLine(expectedOwners.length), isNull);
    expect(lineMap.ownerOfLine(-1), isNull);

    expect(lineMap.ownLinesOf(scrapMPID), <int>[6, 7]);
    expect(lineMap.ownLinesOf(lineChildren[3]), <int>[19, 20]);
    expect(lineMap.ownLinesOf(lineMPID), <int>[13]);
    expect(lineMap.firstOwnLineOf(scrapChildren[1]), 9);
    expect(lineMap.firstOwnLineOf(-12345), isNull);
    expect(lineMap.ownLinesOf(-12345), isEmpty);

    expect(lineMap.rangeOf(scrapMPID), (6, 28));
    expect(lineMap.rangeOf(lineMPID), (13, 23));
    expect(lineMap.rangeOf(areaMPID), (24, 27));
    expect(lineMap.rangeOf(multilineCommentMPID), (3, 5));
    expect(lineMap.rangeOf(lineChildren[2]), (16, 18));
    expect(lineMap.rangeOf(scrapChildren[1]), (9, 10));

    expect(
      lineMap.ownerMPIDs.toSet(),
      expectedOwners.toSet(),
    );
    expect(lineMap.removedLines, isEmpty);
    expect(lineMap.relocations, isEmpty);
    expect(lineMap.addedEndings, isEmpty);
  });

  test('the line after a trailing line ending has no owner', () async {
    final (TH2File file, String _, TH2TextLineMap lineMap) = await writeMap(
      '$body\n',
    );

    expect(lineMap.lineCount, 30);
    expect(lineMap.ownerOfLine(29), file.childrenMPIDs.last);
    expect(lineMap.ownerOfLine(30), isNull);
  });

  test('generated wrapped lines belong to their element', () async {
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
      '''encoding UTF-8
scrap s1
  point 1 1 station -name A1 -align top -scale large -visibility on -clip off -place top -id station_with_a_long_identifier
endscrap
''',
    );

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final (String text, TH2TextLineMap lineMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(
          parsed.file,
          useOriginalRepresentation: false,
        );
    final List<String> lines = text.split('\n');
    final int pointMPID = parsed.file.getPoints().single.mpID;
    final List<int> pointLines = lineMap.ownLinesOf(pointMPID);

    expect(pointLines.length, greaterThan(1));
    expect(lines[pointLines.first], startsWith('  point 1 1 station'));
    expect(lines[pointLines.first], endsWith('\\'));
    expect(lineMap.rangeOf(pointMPID), (pointLines.first, pointLines.last));
  });
}
