// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  group('MPEncodingAux.encodingByTherionName', () {
    test('known names', () {
      expect(MPEncodingAux.encodingByTherionName('UTF-8'), utf8);
      expect(MPEncodingAux.encodingByTherionName('utf-8'), utf8);
      expect(MPEncodingAux.encodingByTherionName('ASCII'), ascii);
      expect(MPEncodingAux.encodingByTherionName('ISO8859-1'), latin1);
      expect(MPEncodingAux.encodingByTherionName('ISO-8859-1'), latin1);
    });

    test('Therion ISO names without hyphen after ISO', () {
      expect(MPEncodingAux.encodingByTherionName('ISO8859-2'), isNotNull);
      expect(MPEncodingAux.encodingByTherionName('iso8859-15'), isNotNull);
      expect(MPEncodingAux.encodingByTherionName('ISO-8859-2'), isNotNull);
    });

    test('unknown name', () {
      expect(MPEncodingAux.encodingByTherionName('NOT-AN-ENCODING'), isNull);
    });

    test('encode and decode round trip ISO8859-2 text', () {
      const String text = 'ŕáâăäĺç';
      final Uint8List bytes = MPEncodingAux.encode(text, 'ISO8859-2');

      expect(bytes.length, text.length);
      expect(MPEncodingAux.decode(bytes, 'ISO8859-2'), text);
    });
  });

  group('TH2 Save keeps ISO-8859 encodings', () {
    const List<String> files = [
      'th_file_parser-00013-iso8859-1_encoding.th2',
      'th_file_parser-00014-iso8859-2_encoding.th2',
      'th_file_parser-00015-iso8859-15_encoding.th2',
    ];

    for (final String fileName in files) {
      test(fileName, () async {
        final String path = THTestAux.testPath(fileName);
        final Uint8List originalBytes = File(path).readAsBytesSync();

        mpLocator.mpGeneralController.reset();

        final (TH2File file, bool isSuccessful, _) = await TH2FileParser()
            .parse(path);

        expect(isSuccessful, true);

        final Uint8List savedBytes = TH2FileWriter().toBytes(
          file,
          includeEmptyLines: true,
          useOriginalRepresentation: true,
        );

        expect(savedBytes, originalBytes);

        final String firstText = TH2FileWriter().serialize(
          file,
          includeEmptyLines: true,
          useOriginalRepresentation: true,
        );

        mpLocator.mpGeneralController.reset();

        final (TH2File reloaded, bool isReloadSuccessful, _) =
            await TH2FileParser().parse(path, fileBytes: savedBytes);

        expect(isReloadSuccessful, true);
        expect(reloaded.encoding, file.encoding);
        expect(
          TH2FileWriter().serialize(
            reloaded,
            includeEmptyLines: true,
            useOriginalRepresentation: true,
          ),
          firstText,
        );
      });
    }
  });
}
