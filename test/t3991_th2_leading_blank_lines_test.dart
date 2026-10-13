// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// Blank lines before a .th2 file's first command are discarded on load, so
/// the encoding line, when there is one, is always the file's first child.
/// Before, the encoding was not detected after a blank line, and Save added a
/// second encoding line, which made the saved file fail to load.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();
  const String filename = '/tmp/t3991.th2';

  Future<(TH2File, bool, List<String>)> parseBytes(Uint8List bytes) {
    mpLocator.mpGeneralController.reset();

    return TH2FileParser().parse(filename, fileBytes: bytes);
  }

  Future<(TH2File, bool, List<String>)> parseText(String text) {
    return parseBytes(utf8.encode(text));
  }

  String asSaved(TH2File file) {
    return TH2FileWriter().serialize(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );
  }

  const String body = '''encoding UTF-8
##XTHERION## xth_me_area_adjust 0 0 100 100

scrap s1
endscrap
''';

  const Map<String, String> leadingBlanks = <String, String>{
    'one blank line': '\n',
    'two blank lines': '\n\n',
    'a whitespace-only line': '  \t\n',
  };

  for (final MapEntry<String, String> leading in leadingBlanks.entries) {
    test('${leading.key} before encoding is discarded', () async {
      final (TH2File file, bool isSuccessful, List<String> errors) =
          await parseText('${leading.value}$body');

      expect(isSuccessful, isTrue, reason: errors.join('\n'));

      final THElement firstChild = file.elementByMPID(
        file.childrenMPIDs.first,
      );

      expect(firstChild, isA<THEncoding>());
      expect(firstChild.originalLineInTH2File, 'encoding UTF-8\n');

      final String saved = asSaved(file);

      expect(saved, body);

      final (_, bool isReloadSuccessful, List<String> reloadErrors) =
          await parseText(saved);

      expect(isReloadSuccessful, isTrue, reason: reloadErrors.join('\n'));
    });
  }

  test('empty lines after the first command are kept', () async {
    const String text = 'encoding UTF-8\n\nscrap s1\n\nendscrap\n\n';
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(asSaved(file), text);
  });

  test('blank lines before a file with no encoding line', () async {
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText('\nscrap s1\nendscrap\n');

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(
      file.elementByMPID(file.childrenMPIDs.first).elementType,
      THElementType.scrap,
    );
    expect(asSaved(file), 'encoding UTF-8\nscrap s1\nendscrap\n');
  });

  test('ISO-8859-1 encoding is detected after a blank line', () async {
    const String text = '\nencoding ISO8859-1\nscrap s1 -title "Caverna Água"\nendscrap\n';
    final Uint8List bytes = MPEncodingAux.encode(text, 'ISO8859-1');
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseBytes(bytes);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(file.encoding, 'ISO8859-1');

    final THScrap scrap = file.getScraps().single;

    expect(scrap.originalLineInTH2File, contains('Caverna Água'));

    final Uint8List savedBytes = TH2FileWriter().toBytes(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );

    expect(savedBytes, MPEncodingAux.encode(text.substring(1), 'ISO8859-1'));
  });

  test('CRLF line ending is detected after a blank line', () async {
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText('\r\nencoding UTF-8\r\nscrap s1\r\nendscrap\r\n');

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(file.lineEnding, mpWindowsLineBreak);
  });

  test('changing the encoding keeps a single encoding element', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    mpLocator.appLocalizations = AppLocalizationsEn();

    final (TH2File parsedFile, bool isSuccessful, List<String> errors) =
        await parseText('\n$body');

    expect(isSuccessful, isTrue, reason: errors.join('\n'));

    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: filename);

    expect(controller.th2File, same(parsedFile));

    controller.propertiesController.prepareSetEncoding('ISO8859-2');

    final TH2File file = controller.th2File;
    final Iterable<THEncoding> encodings = file.childrenMPIDs
        .map((int mpID) => file.elementByMPID(mpID))
        .whereType<THEncoding>();

    expect(encodings.length, 1);
    expect(encodings.single.encoding, 'ISO8859-2');
    expect(
      asSaved(file),
      body.replaceFirst('encoding UTF-8', 'encoding ISO8859-2'),
    );
  });

  test('a file of only blank lines loads empty and saves', () async {
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText('\n  \n\n');

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(file.childrenMPIDs, isEmpty);
    expect(asSaved(file), 'encoding UTF-8\n');
  });
}
