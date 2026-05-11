// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';

import 'th_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();

  group('TH2FileEditUserInteractionController station point name cache', () {
    test('includes stations from every visible scrap', () async {
      const String filename = '/tmp/mapiah_station_cache_visible_scraps.th2';
      const String th2Content = '''
encoding utf-8
scrap first_scrap
  point 10 20 station -name Z9
  point 15 25 station -name A1
endscrap

scrap second_scrap
  point 30 40 station -name M5
endscrap
''';

      final TH2FileEditController controller = await _parseController(
        filename: filename,
        th2Content: th2Content,
      );

      final List<MPStationPointNameCoordinateRecord> allVisibleRecords =
          controller.userInteractionController
              .getStationPointNameCoordinateCache();
      final List<String> allVisibleStationNames = allVisibleRecords
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toList();

      expect(allVisibleStationNames, <String>['A1', 'M5', 'Z9']);

      final THScrap secondScrap = controller.th2File.getScraps().firstWhere(
        (THScrap scrap) => scrap.thID == 'second_scrap',
      );

      controller.hideElementController.toggleScrapVisibility(secondScrap.mpID);

      final List<MPStationPointNameCoordinateRecord> afterHideRecords =
          controller.userInteractionController
              .getStationPointNameCoordinateCache();
      final List<String> afterHideStationNames = afterHideRecords
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toList();

      expect(afterHideStationNames, <String>['A1', 'Z9']);
    });

    test('includes visible XVI stations', () async {
      final String filename = THTestAux.testPath(
        '2026-04-23-001-xvi_station_name_with_underscore_and_accent.th2',
      );
      final TH2FileParser parser = TH2FileParser();

      mpLocator.mpGeneralController.reset();
      final (TH2File _, bool isSuccessful, List<String> errors) = await parser
          .parse(filename, forceNewController: true);

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: filename);
      final List<MPStationPointNameCoordinateRecord> records = controller
          .userInteractionController
          .getStationPointNameCoordinateCache();
      final Set<String> stationNames = records
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toSet();

      expect(stationNames, contains('3R9_nó_agua'));
    });

    test('orders Therion stations before alphabetically sorted XVI stations', () async {
      final String filename = THTestAux.testPath(
        'mapiah_station_cache_sorted_sources.th2',
      );
      const String th2Content = '''
encoding utf-8
##XTHERION## xth_me_image_insert {0 1 1.0} {0 0} "./xvi/2026-04-23-001-xvi-station_name_with_underscore_and_accent.xvi" 0 {}
scrap first_scrap
  point 10 20 station -name TherionZ
  point 15 25 station -name TherionA
endscrap
''';

      final TH2FileEditController controller = await _parseController(
        filename: filename,
        th2Content: th2Content,
      );
      final List<MPStationPointNameCoordinateRecord> records = controller
          .userInteractionController
          .getStationPointNameCoordinateCache();
      final List<String> stationNames = records
          .map(
            (MPStationPointNameCoordinateRecord record) =>
                '${record.source}:${record.name}',
          )
          .toList();

      expect(
        stationNames,
        <String>[
          'Therion:TherionA',
          'Therion:TherionZ',
          'XVI:3R9_nó_agua',
        ],
      );
    });
  });
}

Future<TH2FileEditController> _parseController({
  required String filename,
  required String th2Content,
}) async {
  final TH2FileParser parser = TH2FileParser();
  final Uint8List fileBytes = utf8.encode(th2Content);

  mpLocator.mpGeneralController.reset();
  final (TH2File _, bool isSuccessful, List<String> errors) = await parser
      .parse(filename, fileBytes: fileBytes, forceNewController: true);

  expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

  return mpLocator.mpGeneralController.getTH2FileEditController(
    filename: filename,
  );
}
