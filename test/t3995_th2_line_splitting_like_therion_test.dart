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
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// Lines are split as Therion's `thinput::read_line` does: only a trailing
/// backslash continues a line. Comments, double quotes and square brackets
/// are read inside one line, as Therion's `thsplit_args` does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  Future<TH2File> parseScrap(String scrapContent) async {
    mpLocator.mpGeneralController.reset();

    final (TH2File file, bool isSuccessful, List<String> errors) =
        await TH2FileParser().parse(
          '/tmp/t3995.th2',
          fileBytes: utf8.encode(
            'encoding UTF-8\nscrap s1\n${scrapContent}endscrap\n',
          ),
        );

    expect(isSuccessful, isTrue, reason: errors.join('\n'));

    return file;
  }

  String pointText(THPoint point) {
    return (point.getOption(THCommandOptionType.text) as THTextCommandOption)
        .text
        .content;
  }

  group('comments', () {
    test('a double quote in a comment opens no value', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 station # say "hi\n'
        '  point 2 2 station\n',
      );

      expect(file.getPoints(), hasLength(2));
      expect(file.getPoints().first.sameLineComment, 'say "hi');
    });

    test('a square bracket in a comment opens no value', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 station # see [note\n'
        '  point 2 2 station\n',
      );

      expect(file.getPoints(), hasLength(2));
      expect(file.getPoints().first.sameLineComment, 'see [note');
    });

    test('a trailing backslash continues a comment', () async {
      final TH2File file = await parseScrap(
        '  # first \\\n'
        '  point 9 9 station\n'
        '  point 2 2 station\n',
      );

      expect(file.getPoints(), hasLength(1));
      expect(
        file.elements.values.whereType<THComment>().single.content,
        'first   point 9 9 station',
      );
    });

    test('a hash inside a word is part of it', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text a#b\n',
      );

      expect(pointText(file.getPoints().single), 'a#b');
      expect(file.getPoints().single.sameLineComment, isNull);
    });
  });

  group('double quotes', () {
    test('a hash inside a quoted value is content', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text "a # b"\n',
      );

      expect(pointText(file.getPoints().single), 'a # b');
    });

    test('a double quote inside a word is part of it', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text a"b\n',
      );

      expect(pointText(file.getPoints().single), 'a"b');
    });

    test('an unclosed quoted value ends at the end of the line', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text "open\n'
        '  point 2 2 station\n',
      );

      expect(file.getPoints(), hasLength(2));
      expect(pointText(file.getPoints().first), 'open');
    });

    test('a trailing backslash continues a quoted value', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text "first \\\n'
        'second"\n',
      );

      expect(pointText(file.getPoints().single), 'first second');
    });
  });

  group('square brackets', () {
    test('a hash inside a bracket value is content', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text [a # b]\n',
      );

      expect(pointText(file.getPoints().single), 'a # b');
    });

    test('an unclosed bracket value ends at the end of the line', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text [open\n'
        '  point 2 2 station\n',
      );

      expect(file.getPoints(), hasLength(2));
      expect(pointText(file.getPoints().first), 'open');
    });

    test('brackets nest', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text [a [b] c]\n',
      );

      expect(pointText(file.getPoints().single), 'a [b] c');
    });

    test('a trailing backslash continues a bracket value', () async {
      final TH2File file = await parseScrap(
        '  point 1 1 label -text [first \\\n'
        'second]\n',
      );

      expect(pointText(file.getPoints().single), 'first second');
    });
  });
}
