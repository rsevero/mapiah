// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// The writer wraps generated lines longer than the maximum line length. A
/// quoted value or a single token that didn't fit on one line made it loop
/// forever or throw.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  Future<TH2File> parseText(String text) async {
    mpLocator.mpGeneralController.reset();

    final (TH2File file, bool isSuccessful, List<String> errors) =
        await TH2FileParser().parse(
          '/tmp/t3993.th2',
          fileBytes: utf8.encode(text),
        );

    expect(isSuccessful, isTrue, reason: errors.join('\n'));

    return file;
  }

  /// Writes [file] generating every line, as for elements whose stored text
  /// was cleared by an edit.
  String asGenerated(TH2File file) {
    return TH2FileWriter().serialize(file, includeEmptyLines: true);
  }

  String pointText(String pointLine) {
    return 'encoding UTF-8\nscrap s1\n  $pointLine\nendscrap\n';
  }

  Future<void> checkRoundTrip(String pointLine, String expectedPoint) async {
    final TH2File file = await parseText(pointText(pointLine));
    final String written = asGenerated(file);

    expect(written, 'encoding UTF-8\nscrap s1\n${expectedPoint}endscrap\n');

    final TH2File reparsed = await parseText(written);

    expect(asGenerated(reparsed), written);
  }

  test('a quoted value longer than the line', () async {
    const String text =
        'a label text long enough to make the writer wrap the point line in two or more parts';

    await checkRoundTrip(
      'point 1 1 label -text "$text"',
      '  point 1 1 label -text \\\n'
          '      "$text"\n',
    );

    final TH2File file = await parseText(
      pointText('point 1 1 label -text "$text"'),
    );
    final THPoint point = file.getPoints().single;

    expect(
      (point.getOption(THCommandOptionType.text) as THTextCommandOption).text
          .content,
      text,
    );
  });

  test('a quoted value longer than the line, followed by an option', () async {
    const String text =
        'a label text long enough to make the writer wrap the point line in two or more parts';

    await checkRoundTrip(
      'point 1 1 label -attr foo "$text" -text x',
      '  point 1 1 label -attr foo \\\n'
          '      "$text" \\\n'
          '      -text x\n',
    );
  });

  test('a quoted value without spaces longer than the line', () async {
    final String text = 'x' * 90;

    await checkRoundTrip(
      'point 1 1 label -text "$text"',
      '  point 1 1 label -text \\\n'
          '      $text\n',
    );
  });

  test('a single token longer than the line', () async {
    final String id = 'p${'1' * 90}';

    await checkRoundTrip(
      'point 1 1 station -id $id',
      '  point 1 1 station -id \\\n'
          '      $id\n',
    );
  });

  test('ordinary wrapping is unchanged', () async {
    await checkRoundTrip(
      'point 1 1 station -name A1 -align top -scale large -visibility on -clip off -place top -id station_with_a_long_identifier',
      '  point 1 1 station -id station_with_a_long_identifier -align top -clip off \\\n'
          '      -name A1 -place top -scale l -visibility on\n',
    );
  });
}
