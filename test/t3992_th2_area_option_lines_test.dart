// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// An area option on its own line in an area body (`place top`, `clip off`,
/// …) used to be lost on Save: the "area" line kept its original text, which
/// lacks the option, and the option line itself is never written. A blank line
/// right before such an option line also made the parser throw a `TypeError`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  Future<(TH2File, bool, List<String>)> parseText(String text) {
    mpLocator.mpGeneralController.reset();

    return TH2FileParser().parse(
      '/tmp/t3992.th2',
      fileBytes: utf8.encode(text),
    );
  }

  String asSaved(TH2File file) {
    return TH2FileWriter().serialize(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );
  }

  THArea onlyArea(TH2File file) {
    return file.getAreas().single;
  }

  Future<void> expectSavedAndStable(String text, String saved) async {
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(asSaved(file), saved);

    final (TH2File reparsed, bool isReparseSuccessful, _) = await parseText(
      saved,
    );

    expect(isReparseSuccessful, isTrue);
    expect(asSaved(reparsed), saved);
  }

  const String borderLine = '''  line wall -id l1
    1 1
    2 2
    3 1
    1 1
  endline
''';

  test('area option line before a border reference', () async {
    const String text =
        '''encoding UTF-8
scrap s1
$borderLine  area water
    place bottom
    l1
  endarea
endscrap
''';
    const String saved =
        '''encoding UTF-8
scrap s1
$borderLine  area water -place bottom
    l1
  endarea
endscrap
''';

    await expectSavedAndStable(text, saved);
  });

  test('area option line after a border reference', () async {
    const String text =
        '''encoding UTF-8
scrap s1
$borderLine  area water
    l1
    clip off
  endarea
endscrap
''';
    const String saved =
        '''encoding UTF-8
scrap s1
$borderLine  area water -clip off
    l1
  endarea
endscrap
''';

    await expectSavedAndStable(text, saved);
  });

  test('area option line with a same line comment', () async {
    const String text =
        '''encoding UTF-8
scrap s1
$borderLine  area water
    place top # top
    l1
  endarea
endscrap
''';
    const String saved =
        '''encoding UTF-8
scrap s1
$borderLine  area water -place top # top
    l1
  endarea
endscrap
''';

    await expectSavedAndStable(text, saved);
  });

  test('blank line before an area option line', () async {
    const String text =
        '''encoding UTF-8
scrap s1
$borderLine  area water
    l1

    visibility off
  endarea
endscrap
''';
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(onlyArea(file).hasOption(THCommandOptionType.visibility), isTrue);

    const String saved =
        '''encoding UTF-8
scrap s1
$borderLine  area water -visibility off
    l1

  endarea
endscrap
''';

    await expectSavedAndStable(text, saved);
  });

  test('fixture with an area option line keeps it on Save', () async {
    mpLocator.mpGeneralController.reset();

    final (
      TH2File file,
      bool isSuccessful,
      List<String> errors,
    ) = await TH2FileParser().parse(
      './test/auxiliary/th_file_parser-03223-area_with_command_like_place_option_and_same_line_comment.th2',
    );

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(
      asSaved(file),
      startsWith('''encoding utf-8
scrap test
  area clay -place top # With a same line comment in the command like option
l85-3732--20
endarea
'''),
    );
  });
}
