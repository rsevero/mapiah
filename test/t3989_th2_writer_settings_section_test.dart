// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/exceptions/th2_unsupported_line_ending_exception.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_output_planner.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th2_text_line_map_test_aux.dart';

/// Builds TH2 text from tokens. The first letter gives the kind:
/// `enc` encoding, `S` setting, `X` XTherion image, `P` ##MAPIAH## image,
/// `C` comment, `E` empty line, `M` multiline comment, `K` scrap. The rest of
/// the token tells same-kind tokens apart.
class _Token {
  static List<String> lines(String token) {
    final String id = token.substring(1).toLowerCase();

    if (token == 'enc') {
      return <String>['encoding UTF-8'];
    }

    switch (token[0]) {
      case 'S':
        return <String>['##XTHERION## xth_me_area_zoom_to 1$id'];
      case 'X':
        return <String>[
          '##XTHERION## xth_me_image_insert {1$id 1 1} 0 "./x$id.png" 0 {}',
        ];
      case 'P':
        return <String>[
          '##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fp$id.png;xx=1;yy=2;xScale=1;yScale=2;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=5}',
        ];
      case 'I':
        return <String>['##XTHERION## xth_me_area_adjust 0 0 10$id 100'];
      case 'C':
        return <String>['# c$id'];
      case 'E':
        return <String>[''];
      case 'M':
        return <String>[
          'comment',
          '##XTHERION## xth_me_area_zoom_to 9$id',
          'endcomment',
        ];
      case 'K':
        return <String>['scrap k$id', 'endscrap'];
    }

    throw ArgumentError(token);
  }

  static THElementType type(String token) {
    if (token == 'enc') {
      return THElementType.encoding;
    }

    return switch (token[0]) {
      'S' || 'I' => THElementType.xTherionConfig,
      'X' => THElementType.xTherionImageInsertConfig,
      'P' => THElementType.mapiahImageInsertConfig,
      'C' => THElementType.comment,
      'E' => THElementType.emptyLine,
      'M' => THElementType.multilineComment,
      'K' => THElementType.scrap,
      _ => throw ArgumentError(token),
    };
  }

  /// The text of [tokens], every line ended by [endingOf] its global index.
  static String text(
    List<String> tokens, {
    String Function(int line) endingOf = _lf,
  }) {
    final StringBuffer buffer = StringBuffer();
    int line = 0;

    for (final String token in tokens) {
      for (final String tokenLine in lines(token)) {
        buffer.write('$tokenLine${endingOf(line)}');
        line++;
      }
    }

    return buffer.toString();
  }

  static String _lf(int line) => '\n';
}

class _Row {
  final List<String> children;
  final List<String> output;
  final List<String> relocated;

  const _Row(this.children, this.output, [this.relocated = const <String>[]]);
}

/// Parent §4.16 and plan §4.3 table.
const List<_Row> _tableRows = <_Row>[
  _Row(
    <String>['enc', 'S1', 'C1', 'E1', 'S2', 'S3', 'K1'],
    <String>['enc', 'S1', 'C1', 'E1', 'S2', 'S3', 'K1'],
  ),
  _Row(
    <String>['enc', 'S1', 'C1', 'E1', 'K1', 'I1'],
    <String>['enc', 'S1', 'C1', 'I1', 'E1', 'K1'],
    <String>['I1'],
  ),
  _Row(
    <String>['enc', 'E1', 'K1', 'E2', 'K2', 'I1'],
    <String>['enc', 'I1', 'E1', 'K1', 'E2', 'K2'],
    <String>['I1'],
  ),
  _Row(
    <String>['enc', 'S1', 'E1', 'C1', 'K1', 'I1'],
    <String>['enc', 'S1', 'I1', 'E1', 'C1', 'K1'],
    <String>['I1'],
  ),
  _Row(
    <String>['enc', 'C1', 'K1', 'I1'],
    <String>['enc', 'I1', 'C1', 'K1'],
    <String>['I1'],
  ),
  _Row(
    <String>['enc', 'S1', 'K1', 'C1', 'S2'],
    <String>['enc', 'S1', 'S2', 'K1', 'C1'],
    <String>['S2'],
  ),
  _Row(
    <String>['enc', 'S1', 'S2', 'E1', 'C1', 'E2', 'K1', 'I1'],
    <String>['enc', 'S1', 'S2', 'E1', 'C1', 'I1', 'E2', 'K1'],
    <String>['I1'],
  ),
  _Row(
    <String>['enc', 'S1', 'C1', 'I1'],
    <String>['enc', 'S1', 'C1', 'I1'],
  ),
  _Row(
    <String>['enc', 'S1', 'E1', 'I1'],
    <String>['enc', 'S1', 'E1', 'I1'],
  ),
];

/// Cases the table leaves implicit.
const List<_Row> _extraRows = <_Row>[
  /// A section with no trailing empty lines.
  _Row(
    <String>['enc', 'S1', 'K1', 'I1'],
    <String>['enc', 'S1', 'I1', 'K1'],
    <String>['I1'],
  ),

  /// A section of only empty lines.
  _Row(
    <String>['enc', 'E1', 'E2', 'K1', 'I1'],
    <String>['enc', 'I1', 'E1', 'E2', 'K1'],
    <String>['I1'],
  ),

  /// Several later settings keep their order, images included.
  _Row(
    <String>['enc', 'S1', 'E1', 'K1', 'X1', 'C1', 'P1', 'K2', 'I1'],
    <String>['enc', 'S1', 'X1', 'P1', 'I1', 'E1', 'K1', 'C1', 'K2'],
    <String>['X1', 'P1', 'I1'],
  ),

  /// No settings.
  _Row(
    <String>['enc', 'C1', 'E1', 'K1', 'C2'],
    <String>['enc', 'C1', 'E1', 'K1', 'C2'],
  ),

  /// A multiline comment inside the section.
  _Row(
    <String>['enc', 'S1', 'M1', 'E1', 'K1', 'I1'],
    <String>['enc', 'S1', 'M1', 'I1', 'E1', 'K1'],
    <String>['I1'],
  ),

  /// A multiline comment trailing the section.
  _Row(
    <String>['enc', 'S1', 'E1', 'M1', 'K1', 'I1'],
    <String>['enc', 'S1', 'I1', 'E1', 'M1', 'K1'],
    <String>['I1'],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TH2TextLineMapFakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  List<int> plannedOrder(List<String> tokens) {
    final TH2FileOutputPlan plan = TH2FileOutputPlanner.plan(<(int, THElementType)>[
      for (int index = 0; index < tokens.length; index++)
        (index, _Token.type(tokens[index])),
    ]);

    return plan.orderedChildMPIDs;
  }

  group('planner', () {
    for (final _Row row in <_Row>[..._tableRows, ..._extraRows]) {
      test(row.children.join(', '), () {
        final TH2FileOutputPlan plan = TH2FileOutputPlanner.plan(
          <(int, THElementType)>[
            for (int index = 0; index < row.children.length; index++)
              (index, _Token.type(row.children[index])),
          ],
        );

        expect(plan.synthesizeEncoding, isFalse);
        expect(
          plan.orderedChildMPIDs.map((int index) => row.children[index]),
          row.output,
        );
        expect(
          plan.relocatedSettingMPIDs.map((int index) => row.children[index]),
          row.relocated,
        );
      });
    }

    test('a synthesized encoding', () {
      final List<String> tokens = <String>['S1', 'C1', 'K1', 'I1'];
      final TH2FileOutputPlan plan = TH2FileOutputPlanner.plan(
        <(int, THElementType)>[
          for (int index = 0; index < tokens.length; index++)
            (index, _Token.type(tokens[index])),
        ],
      );

      expect(plan.synthesizeEncoding, isTrue);
      expect(plan.orderedChildMPIDs.map((int index) => tokens[index]), <String>[
        'S1',
        'I1',
        'C1',
        'K1',
      ]);
    });

    test('no children', () {
      final TH2FileOutputPlan plan = TH2FileOutputPlanner.plan(
        <(int, THElementType)>[],
      );

      expect(plan.synthesizeEncoding, isTrue);
      expect(plan.orderedChildMPIDs, isEmpty);
      expect(plan.relocatedSettingMPIDs, isEmpty);
    });

    test('every child exactly once', () {
      expect(plannedOrder(<String>['enc', 'K1', 'S1', 'K2', 'S2', 'C1']), <int>[
        0,
        2,
        4,
        1,
        3,
        5,
      ]);
    });
  });

  /// The MPIDs of the top-level children, keyed by token.
  Map<String, int> mpIDsByToken(TH2File file, List<String> tokens) {
    final List<int> childrenMPIDs = file.childrenMPIDs.toList();

    expect(childrenMPIDs, hasLength(tokens.length));

    return <String, int>{
      for (int index = 0; index < tokens.length; index++)
        tokens[index]: childrenMPIDs[index],
    };
  }

  int firstLineOf(List<String> tokens, String token) {
    int line = 0;

    for (final String current in tokens) {
      if (current == token) {
        return line;
      }
      line += _Token.lines(current).length;
    }

    throw ArgumentError(token);
  }

  Future<void> checkRow(
    _Row row, {
    String Function(int line) endingOf = _Token._lf,
  }) async {
    final String input = _Token.text(row.children, endingOf: endingOf);

    /// Each token keeps its stored lines, endings included.
    final List<String> inputLines = RegExp(
      r'[^\n]*\n',
    ).allMatches(input).map((Match match) => match.group(0)!).toList();
    final Map<String, List<String>> storedLinesByToken =
        <String, List<String>>{};
    int line = 0;

    for (final String token in row.children) {
      final int lineCount = _Token.lines(token).length;

      storedLinesByToken[token] = inputLines.sublist(line, line + lineCount);
      line += lineCount;
    }

    final String expected = row.output
        .expand((String token) => storedLinesByToken[token]!)
        .join();
    final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

    expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

    final TH2File file = parsed.file;
    final Map<String, int> mpIDs = mpIDsByToken(file, row.children);

    expect(TH2TextLineMapTestAux.asSaved(file), expected);
    expect(
      TH2TextLineMapTestAux.savedBytes(file),
      MPEncodingAux.encode(expected, file.encoding),
    );

    final (String text, TH2TextLineMap lineMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(file);

    expect(text, expected);
    expect(lineMap.addedEndings, isEmpty);
    expect(
      lineMap.relocations.map(
        (TH2TextRelocation relocation) =>
            (relocation.mpID, relocation.destinationLine),
      ),
      row.relocated.map(
        (String token) => (mpIDs[token]!, firstLineOf(row.output, token)),
      ),
    );

    /// No element emitted twice or omitted.
    for (final String token in row.output) {
      final List<int> ownLines = lineMap.ownLinesOf(mpIDs[token]!);

      expect(ownLines, hasLength(1), reason: token);
      expect(ownLines.single, firstLineOf(row.output, token), reason: token);
    }
  }

  group('writer, stored text', () {
    for (final _Row row in <_Row>[..._tableRows, ..._extraRows]) {
      test(row.children.join(', '), () async {
        await checkRow(row);
      });

      test('${row.children.join(', ')}, mixed line endings', () async {
        await checkRow(
          row,
          endingOf: (int line) => line.isOdd ? '\r\n' : '\n',
        );
      });
    }

    test('stored formatting is kept when a setting moves', () async {
      const String input =
          'encoding  UTF-8\n'
          '##XTHERION##   xth_me_area_zoom_to   100   \n'
          '\n'
          'scrap s1\n'
          'endscrap\n'
          '##XTHERION##\txth_me_area_adjust 0 0 100 100 \n';
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));
      expect(
        TH2TextLineMapTestAux.asSaved(parsed.file),
        'encoding  UTF-8\n'
        '##XTHERION##   xth_me_area_zoom_to   100   \n'
        '##XTHERION##\txth_me_area_adjust 0 0 100 100 \n'
        '\n'
        'scrap s1\n'
        'endscrap\n',
      );
    });
  });

  group('writer, contents', () {
    test('nested comments, empty lines and settings-looking text stay', () async {
      const String input = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100

scrap s1
  # ##XTHERION## xth_me_area_adjust 0 0 1 1

  comment
  ##XTHERION## xth_me_area_adjust 0 0 2 2
  endcomment
  line wall -id a1
    # inside line

    comment
    inside line
    endcomment
    1 1
    2 2
  endline
  area water
    a1

  endarea
endscrap
comment
##XTHERION## xth_me_area_adjust 0 0 3 3
endcomment
##XTHERION## xth_me_area_adjust 0 0 4 4
''';
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

      const String expected = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100
##XTHERION## xth_me_area_adjust 0 0 4 4

scrap s1
  # ##XTHERION## xth_me_area_adjust 0 0 1 1

  comment
  ##XTHERION## xth_me_area_adjust 0 0 2 2
  endcomment
  line wall -id a1
    # inside line

    comment
    inside line
    endcomment
    1 1
    2 2
  endline
  area water
    a1

  endarea
endscrap
comment
##XTHERION## xth_me_area_adjust 0 0 3 3
endcomment
''';
      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(parsed.file);

      expect(TH2TextLineMapTestAux.asSaved(parsed.file), expected);
      expect(text, expected);
      expect(lineMap.relocations, hasLength(1));
      expect(lineMap.relocations.single.destinationLine, 2);
    });

    test('generated settings mixed with stored ones', () async {
      const String input = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100
# section comment

scrap s1
endscrap
''';
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

      final TH2File file = parsed.file;
      final THXTherionConfig newSetting = THXTherionConfig(
        parentMPID: file.mpID,
        name: 'xth_me_area_adjust',
        value: '0 0 100 100',
      );

      file.addElement(newSetting);
      file.addElementToParent(newSetting);

      const String expected = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100
# section comment
##XTHERION## xth_me_area_adjust 0 0 100 100

scrap s1
endscrap
''';
      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(file);

      expect(TH2TextLineMapTestAux.asSaved(file), expected);
      expect(text, expected);
      expect(lineMap.relocations, hasLength(1));
      expect(lineMap.relocations.single.mpID, newSetting.mpID);
      expect(lineMap.relocations.single.destinationLine, 3);
    });
  });

  group('writer, line boundaries', () {
    test('an unterminated final setting that moves up', () async {
      const String input =
          'encoding UTF-8\n'
          '##XTHERION## xth_me_area_zoom_to 100\n'
          'scrap s1\n'
          'endscrap\n'
          '##XTHERION## xth_me_area_adjust 0 0 100 100';
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

      final TH2File file = parsed.file;
      final int movedMPID = file.childrenMPIDs.last;
      const String expected =
          'encoding UTF-8\n'
          '##XTHERION## xth_me_area_zoom_to 100\n'
          '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
          'scrap s1\n'
          'endscrap\n';
      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(file);

      expect(TH2TextLineMapTestAux.asSaved(file), expected);
      expect(text, expected);
      expect(lineMap.addedEndings, hasLength(1));
      expect(lineMap.addedEndings.single.ownerMPID, movedMPID);
      expect(lineMap.addedEndings.single.line, 2);
      expect(lineMap.ownerOfLine(2), movedMPID);
    });

    test('an unterminated last line that stays last gets no ending', () async {
      const String input =
          'encoding UTF-8\n'
          'scrap s1\n'
          'endscrap';
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(parsed.file);

      expect(TH2TextLineMapTestAux.asSaved(parsed.file), input);
      expect(text, input);
      expect(lineMap.addedEndings, isEmpty);
      expect(lineMap.lineCount, 3);
    });

    Future<(TH2File, TH2FileEditController)> loadAsController(
      String input,
    ) async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
        input,
        filename: './test/auxiliary/t3989_inline.th2',
      );

      expect(parsed.isSuccessful, isTrue, reason: parsed.errors.join('\n'));

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: './test/auxiliary/t3989_inline.th2',
          );

      return (parsed.file, controller);
    }

    void addImage(TH2FileEditController controller) {
      controller.setCanvasScale(1);

      final MPCommand addImageCommand = MPCommandFactory.addImageInsertConfig(
        imageFilename: './test/auxiliary/jpg/2025-10-07-001.jpg',
        th2FileEditController: controller,
      );

      controller.execute(addImageCommand);
    }

    void addScrap(TH2FileEditController controller) {
      controller.execute(
        MPCommandFactory.addScrap(thID: 's2', th2File: controller.th2File),
      );
    }

    test('an added image after an unterminated encoding', () async {
      final (TH2File file, TH2FileEditController controller) =
          await loadAsController('encoding UTF-8');
      final int encodingMPID = file.childrenMPIDs.first;

      addImage(controller);

      const String expected =
          'encoding UTF-8\n'
          '##XTHERION## xth_me_image_insert {-0 1 1} 0 "./jpg/2025-10-07-001.jpg" 0 {}\n';
      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(controller.th2File);

      expect(TH2TextLineMapTestAux.asSaved(controller.th2File), expected);
      expect(text, expected);
      expect(lineMap.relocations, isEmpty);
      expect(lineMap.addedEndings, hasLength(1));
      expect(lineMap.addedEndings.single.ownerMPID, encodingMPID);
      expect(lineMap.addedEndings.single.line, 0);
      expect(lineMap.ownerOfLine(0), encodingMPID);
      expect(lineMap.ownerOfLine(1), controller.th2File.childrenMPIDs.last);
    });

    test('an added image after an unterminated leading setting', () async {
      final (TH2File file, TH2FileEditController controller) =
          await loadAsController(
            'encoding UTF-8\n##XTHERION## xth_me_area_zoom_to 100',
          );
      final int settingMPID = file.childrenMPIDs.last;

      addImage(controller);

      const String expected =
          'encoding UTF-8\n'
          '##XTHERION## xth_me_area_zoom_to 100\n'
          '##XTHERION## xth_me_image_insert {-0 1 1} 0 "./jpg/2025-10-07-001.jpg" 0 {}\n';
      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(controller.th2File);

      expect(text, expected);
      expect(lineMap.relocations, isEmpty);
      expect(lineMap.addedEndings, hasLength(1));
      expect(lineMap.addedEndings.single.ownerMPID, settingMPID);
      expect(lineMap.addedEndings.single.line, 1);
    });

    test('an unterminated closing marker gains following output', () async {
      final (TH2File file, TH2FileEditController controller) =
          await loadAsController('encoding UTF-8\nscrap s1\nendscrap');
      final THScrap scrap = file.getScraps().single;
      final int endscrapMPID = scrap.childrenMPIDs.last;

      addScrap(controller);

      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(controller.th2File);

      expect(text, 'encoding UTF-8\nscrap s1\nendscrap\nscrap s2\nendscrap\n');
      expect(TH2TextLineMapTestAux.asSaved(controller.th2File), text);
      expect(lineMap.addedEndings, hasLength(1));
      expect(lineMap.addedEndings.single.ownerMPID, endscrapMPID);
      expect(lineMap.addedEndings.single.line, 2);
    });

    test('an unterminated file-level comment gains following output', () async {
      final (TH2File file, TH2FileEditController controller) =
          await loadAsController('encoding UTF-8\nscrap s1\nendscrap\n# c');
      final int commentMPID = file.childrenMPIDs.last;

      addScrap(controller);

      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(controller.th2File);

      expect(
        text,
        'encoding UTF-8\nscrap s1\nendscrap\n# c\nscrap s2\nendscrap\n',
      );
      expect(lineMap.addedEndings.single.ownerMPID, commentMPID);
      expect(lineMap.addedEndings.single.line, 3);
    });

    test('an empty line after an unterminated chunk keeps its line', () async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
        'encoding UTF-8\nscrap s1\nendscrap\n# c',
      );
      final TH2File file = parsed.file;
      final int commentMPID = file.childrenMPIDs.last;
      final THEmptyLine emptyLine = THEmptyLine(
        parentMPID: file.mpID,
        originalLineInTH2File: '\n',
      );

      file.addElement(emptyLine);
      file.addElementToParent(emptyLine);

      final THComment lastComment = THComment(
        parentMPID: file.mpID,
        content: 'd',
      );

      file.addElement(lastComment);
      file.addElementToParent(lastComment);

      final (String text, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(file);

      expect(text, 'encoding UTF-8\nscrap s1\nendscrap\n# c\n\n# d\n');
      expect(lineMap.addedEndings.single.ownerMPID, commentMPID);
      expect(lineMap.ownerOfLine(3), commentMPID);
      expect(lineMap.ownerOfLine(4), emptyLine.mpID);
      expect(lineMap.ownerOfLine(5), lastComment.mpID);
    });

    Future<TH2File> unterminatedCommentThenScrap({
      required String lineEnding,
    }) async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
        'encoding UTF-8${lineEnding}scrap s1${lineEnding}endscrap$lineEnding# c',
      );
      final TH2File file = parsed.file;

      expect(file.lineEnding, lineEnding);

      final THScrap newScrap = THScrap(parentMPID: file.mpID, thID: 's2');

      file.addElement(newScrap);
      file.addElementToParent(newScrap);

      final THEndscrap endscrap = THEndscrap(parentMPID: newScrap.mpID);

      file.addElement(endscrap);
      newScrap.addElementToParent(
        endscrap,
        elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );

      return file;
    }

    test('the selected ending: LF, CRLF and an override', () async {
      final TH2File lfFile = await unterminatedCommentThenScrap(
        lineEnding: '\n',
      );

      expect(
        TH2TextLineMapTestAux.asSaved(lfFile),
        'encoding UTF-8\nscrap s1\nendscrap\n# c\nscrap s2\nendscrap\n',
      );

      final TH2File crlfFile = await unterminatedCommentThenScrap(
        lineEnding: '\r\n',
      );
      const String crlfExpected =
          'encoding UTF-8\r\nscrap s1\r\nendscrap\r\n# c\r\nscrap s2\r\nendscrap\r\n';

      expect(TH2TextLineMapTestAux.asSaved(crlfFile), crlfExpected);
      expect(
        TH2TextLineMapTestAux.asSavedWithLineMap(crlfFile).$1,
        crlfExpected,
      );

      /// The override applies to generated lines and to the added ending.
      final (String overridden, TH2TextLineMap lineMap) =
          TH2TextLineMapTestAux.asSavedWithLineMap(crlfFile, lineEnding: '\n');

      expect(
        overridden,
        'encoding UTF-8\r\nscrap s1\r\nendscrap\r\n# c\nscrap s2\nendscrap\n',
      );
      expect(lineMap.addedEndings.single.line, 3);
    });

    test('empty chunks emit no separator; nothing is added at EOF', () async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
        'encoding UTF-8\n# c',
      );
      final TH2File file = parsed.file;
      final THEmptyLine emptyLine = THEmptyLine(
        parentMPID: file.mpID,
        originalLineInTH2File: '\n',
      );

      file.addElement(emptyLine);
      file.addElementToParent(emptyLine);

      final THComment lastComment = THComment(
        parentMPID: file.mpID,
        content: 'd',
        originalLineInTH2File: '# d',
      );

      file.addElement(lastComment);
      file.addElementToParent(lastComment);

      final (String text, TH2TextLineMap lineMap) = TH2FileWriter()
          .serializeWithLineMap(file, useOriginalRepresentation: true);

      expect(text, 'encoding UTF-8\n# c\n# d');
      expect(
        TH2FileWriter().serialize(file, useOriginalRepresentation: true),
        text,
      );
      expect(lineMap.addedEndings, hasLength(1));
      expect(lineMap.ownLinesOf(emptyLine.mpID), isEmpty);
    });

    test('a stored lone carriage return before more output', () async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(
        'encoding UTF-8\n# c\nscrap s1\nendscrap\n',
      );
      final TH2File file = parsed.file;
      final THComment comment = file.elements.values
          .whereType<THComment>()
          .single;

      file.substituteElement(comment.copyWith(originalLineInTH2File: '# c\r'));

      /// Ledger mode refuses it before a separator could make it `\r\n`.
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
                'encoding UTF-8\n# c'.length,
              ),
        ),
      );

      /// Ordinary mode adds the selected ending after it.
      expect(
        TH2TextLineMapTestAux.asSaved(file),
        'encoding UTF-8\n# c\r\nscrap s1\nendscrap\n',
      );
    });
  });

  group('writer options', () {
    const String input = '''encoding UTF-8
##XTHERION##   xth_me_area_zoom_to   100

scrap s1
endscrap
##XTHERION## xth_me_area_adjust 0 0 100 100
''';

    test('includeEmptyLines: false', () async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);
      final (String text, TH2TextLineMap _) = TH2FileWriter()
          .serializeWithLineMap(parsed.file, useOriginalRepresentation: true);

      expect(
        text,
        'encoding UTF-8\n'
        '##XTHERION##   xth_me_area_zoom_to   100\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        'scrap s1\n'
        'endscrap\n',
      );
    });

    test('useOriginalRepresentation: false', () async {
      final TH2TextParsed parsed = await TH2TextLineMapTestAux.parseText(input);
      final (String text, TH2TextLineMap _) = TH2FileWriter()
          .serializeWithLineMap(parsed.file, includeEmptyLines: true);

      expect(
        text,
        'encoding UTF-8\n'
        '##XTHERION## xth_me_area_zoom_to 100\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        '\n'
        'scrap s1\n'
        'endscrap\n',
      );
    });
  });

  test('stability: a second write moves nothing', () async {
    const String input = '''encoding UTF-8
##XTHERION## xth_me_area_zoom_to 100
# section comment

scrap s1
endscrap
##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fp.png;xx=1;yy=2;xScale=1;yScale=2;rotationCenterDx=0;rotationCenterDy=0;rotationDeg=5}
##XTHERION## xth_me_image_insert {1 1 1} 0 "./x.png" 0 {}
''';
    final TH2TextParsed first = await TH2TextLineMapTestAux.parseText(input);

    expect(first.isSuccessful, isTrue, reason: first.errors.join('\n'));

    final (String firstText, TH2TextLineMap firstMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(first.file);

    expect(firstMap.relocations, hasLength(2));

    final TH2TextParsed second = await TH2TextLineMapTestAux.parseBytes(
      TH2TextLineMapTestAux.savedBytes(first.file),
    );

    expect(second.isSuccessful, isTrue, reason: second.errors.join('\n'));

    final (String secondText, TH2TextLineMap secondMap) =
        TH2TextLineMapTestAux.asSavedWithLineMap(second.file);

    expect(secondText, firstText);
    expect(secondMap.relocations, isEmpty);
    expect(second.file.encoding, first.file.encoding);
    expect(
      second.file.getScraps().map((THScrap scrap) => scrap.thID),
      first.file.getScraps().map((THScrap scrap) => scrap.thID),
    );
    expect(
      second.file.childrenMPIDs.map(
        (int mpID) => second.file.elementByMPID(mpID).elementType,
      ),
      <THElementType>[
        THElementType.encoding,
        THElementType.xTherionConfig,
        THElementType.comment,
        THElementType.mapiahImageInsertConfig,
        THElementType.xTherionImageInsertConfig,
        THElementType.emptyLine,
        THElementType.scrap,
      ],
    );
  });
}
