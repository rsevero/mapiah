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
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// Option names are read as whole words, as Therion reads them: an option
/// that only starts with a known name, such as `-identity`, is unknown.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  Future<(TH2File, TH2FileParser)> parse(String contents) async {
    mpLocator.mpGeneralController.reset();

    final TH2FileParser parser = TH2FileParser();
    final (TH2File file, _, _) = await parser.parse(
      '/tmp/t3997.th2',
      fileBytes: utf8.encode(contents),
    );

    return (file, parser);
  }

  test('-identity is reported on its own line, not as -id', () async {
    final (TH2File file, TH2FileParser parser) = await parse(
      'encoding utf-8\n'
      'scrap s1\n'
      '  line rock-border -identity l1\n'
      '    0 0\n'
      '    10 10\n'
      '  endline\n'
      'endscrap\n',
    );

    expect(parser.problems, isNotEmpty);
    expect(parser.problems.first.kind, TH2FileProblemKind.parseError);
    expect(parser.problems.first.lineNumber, 3);
    expect(file.hasElementByTHID('entity_l1'), isFalse);
  });

  for (final String option in <String>['-idx p1', '-clipping off']) {
    test('a point with $option is a parse error', () async {
      final (_, TH2FileParser parser) = await parse(
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 1 1 station $option\n'
        'endscrap\n',
      );

      expect(
        parser.problems.map((TH2FileProblem problem) => problem.lineNumber),
        contains(3),
      );
    });
  }

  test('whole option names, including those that start with another, still '
      'parse', () async {
    final (TH2File file, TH2FileParser parser) = await parse(
      'encoding utf-8\n'
      'scrap s1 -station-names "" "@cave" -stations 1,2 -scale 1\n'
      '  point 1 1 station -id p1 -name 1 -clip off\n'
      '  point 2 2 label -orient 30 -text "x" -scale s\n'
      '  point 3 3 label -orientation 60 -text "y"\n'
      '  line wall -id l1 -reverse on\n'
      '    0 0\n'
      '    size 2\n'
      '    10 10\n'
      '    l-size 3\n'
      '  endline\n'
      'endscrap\n',
    );

    expect(parser.problems, isEmpty);
    expect(file.hasElementByTHID('p1'), isTrue);
    expect(file.hasElementByTHID('l1'), isTrue);

    final THPoint p1 = file.elementByTHID('p1') as THPoint;

    expect(p1.hasOption(THCommandOptionType.clip), isTrue);
    expect(p1.hasOption(THCommandOptionType.station), isTrue);
  });
}
