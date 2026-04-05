// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_properties_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  group(
    'TH2FilePropertiesController encoding — file with existing THEncoding element',
    () {
      late TH2FileEditController th2Controller;
      late TH2FilePropertiesController propertiesController;
      late TH2FileWriter writer;

      setUp(() async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();

        writer = TH2FileWriter();

        // This file starts with "encoding  utf-8 " (trailing space, lowercase).
        final String path = THTestAux.testPath(
          'th_file_parser-00011-encoding_with_trailing_space.th2',
        );

        th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
          filename: path,
        );

        await th2Controller.load();

        propertiesController = th2Controller.propertiesController;
      });

      test('initial encoding is read correctly from loaded file', () {
        expect(th2Controller.th2File.encoding, 'UTF-8');
      });

      test('setEncoding updates TH2File.encoding field', () {
        propertiesController.prepareSetEncoding('ISO8859-1');

        expect(th2Controller.th2File.encoding, 'ISO8859-1');
      });

      test('setEncoding updates the THEncoding element value', () {
        propertiesController.prepareSetEncoding('ISO8859-2');

        final TH2File th2File = th2Controller.th2File;
        final THElement firstChild = th2File.elementByMPID(
          th2File.childrenMPIDs.first,
        );

        expect(firstChild, isA<THEncoding>());
        expect((firstChild as THEncoding).encoding, 'ISO8859-2');
      });

      test(
        'setEncoding writes new encoding to file output (useOriginalRepresentation: true)',
        () {
          propertiesController.prepareSetEncoding('ISO8859-1');

          final String output = writer.serialize(
            th2Controller.th2File,
            lineEnding: mpUnixLineBreak,
            useOriginalRepresentation: true,
          );

          expect(output, startsWith('encoding ISO8859-1\n'));
        },
      );

      test('setEncoding is a no-op when value is the same', () {
        final String originalEncoding = th2Controller.th2File.encoding;

        propertiesController.prepareSetEncoding(originalEncoding);

        expect(th2Controller.th2File.encoding, originalEncoding);
      });

      test('setEncoding normalizes input to uppercase', () {
        propertiesController.prepareSetEncoding('iso8859-1');

        expect(th2Controller.th2File.encoding, 'ISO8859-1');
      });
    },
  );

  group(
    'TH2FilePropertiesController encoding — file without THEncoding element',
    () {
      late TH2FileEditController th2Controller;
      late TH2FilePropertiesController propertiesController;
      late TH2FileWriter writer;

      setUp(() async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        mpLocator.appLocalizations = AppLocalizationsEn();
        mpLocator.mpGeneralController.reset();

        writer = TH2FileWriter();

        // This file has no leading encoding element.
        final String path = THTestAux.testPath(
          'th_file_parser-00064-scrap_and_endscrap_simplier_scale.th2',
        );

        th2Controller = mpLocator.mpGeneralController.getTH2FileEditController(
          filename: path,
        );

        await th2Controller.load();

        propertiesController = th2Controller.propertiesController;
      });

      test('file starts without a THEncoding element', () {
        final TH2File th2File = th2Controller.th2File;
        final bool hasEncodingElement =
            th2File.childrenMPIDs.isNotEmpty &&
            th2File.elementByMPID(th2File.childrenMPIDs.first) is THEncoding;

        expect(hasEncodingElement, isFalse);
      });

      test('setEncoding creates a THEncoding element at position 0', () {
        propertiesController.prepareSetEncoding('ISO8859-1');

        final TH2File th2File = th2Controller.th2File;
        final THElement firstChild = th2File.elementByMPID(
          th2File.childrenMPIDs.first,
        );

        expect(firstChild, isA<THEncoding>());
        expect((firstChild as THEncoding).encoding, 'ISO8859-1');
      });

      test(
        'setEncoding writes new encoding to file output when no THEncoding element existed (useOriginalRepresentation: true)',
        () {
          propertiesController.prepareSetEncoding('ISO8859-1');

          final String output = writer.serialize(
            th2Controller.th2File,
            lineEnding: mpUnixLineBreak,
            useOriginalRepresentation: true,
          );

          expect(output, startsWith('encoding ISO8859-1\n'));
        },
      );
    },
  );
}
