// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:ui' show Offset, Size;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';

import 'th_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();

  group('TH2FileEditUserInteractionController station point name cache', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
    });

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
              .getTherionStationPointNameCoordinateCache();
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
              .getTherionStationPointNameCoordinateCache();
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

      _prepareVisibleScreen(controller);

      final List<MPStationPointNameCoordinateRecord> records = controller
          .userInteractionController
          .getXVIStationPointNameCoordinateCache();
      final Set<String> stationNames = records
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toSet();

      expect(stationNames, contains('3R9_nó_agua'));
    });

    test('exposes Therion and XVI caches separately', () async {
      final String filename = THTestAux.testPath(
        'mapiah_station_cache_separate_sources.th2',
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
      final List<String> therionStationNames = controller
          .userInteractionController
          .getTherionStationPointNameCoordinateCache()
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toList();
      final List<String> xviStationNames = controller.userInteractionController
          .getXVIStationPointNameCoordinateCache()
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toList();

      expect(therionStationNames, <String>['TherionA', 'TherionZ']);
      expect(xviStationNames, <String>['3R9_nó_agua']);
    });

    test(
      'orders Therion stations before alphabetically sorted XVI stations',
      () async {
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

        expect(stationNames, <String>[
          'Therion:TherionA',
          'Therion:TherionZ',
          'XVI:3R9_nó_agua',
        ]);
      },
    );

    test('does not invalidate cache on redraw but does on zoom', () async {
      const String filename = '/tmp/mapiah_station_cache_redraw_zoom.th2';
      const String th2Content = '''
encoding utf-8
scrap first_scrap
  point 10 20 station -name A1
endscrap
''';

      final TH2FileEditController controller = await _parseController(
        filename: filename,
        th2Content: th2Content,
      );
      final Offset initialCoordinates = controller.userInteractionController
          .getTherionStationPointNameCoordinateCache()
          .single
          .coordinates;
      controller.triggerAllElementsRedraw();

      final Offset coordinatesAfterRedraw = controller.userInteractionController
          .getTherionStationPointNameCoordinateCache()
          .single
          .coordinates;

      expect(coordinatesAfterRedraw, initialCoordinates);

      controller.zoomIn();

      final Offset coordinatesAfterZoom = controller.userInteractionController
          .getTherionStationPointNameCoordinateCache()
          .single
          .coordinates;

      expect(coordinatesAfterZoom, initialCoordinates);
    });

    test(
      'uses the only unused XVI station under a new station point',
      () async {
        final String filename = THTestAux.testPath(
          'mapiah_station_cache_use_xvi_station_name.th2',
        );
        const String th2Content = '''
encoding utf-8
scrap first_scrap
  point 10 20 station -name Visible
  point 2000 2000 station -name Outside
endscrap
''';

        final TH2FileEditController controller = await _parseController(
          filename: filename,
          th2Content: th2Content,
          prepareVisibleScreen: false,
        );

        controller.updateScreenSize(const Size(1280.0, 720.0));

        final List<String> stationNames = controller.userInteractionController
            .getTherionStationPointNameCoordinateCache()
            .map((MPStationPointNameCoordinateRecord record) => record.name)
            .toList();

        expect(stationNames, <String>['Visible']);
      },
    );

    test('finds stations on sector borders under the cursor', () async {
      const String filename = '/tmp/mapiah_station_cache_sector_border.th2';
      const String th2Content = '''
encoding utf-8
scrap first_scrap
  point 7 0 station -name Border
endscrap
''';

      final TH2FileEditController controller = await _parseController(
        filename: filename,
        th2Content: th2Content,
        prepareVisibleScreen: false,
      );

      controller.updateScreenSize(const Size(1280.0, 720.0));

      final List<String> stationNames = controller.userInteractionController
          .getStationPointNameCoordinateCacheUnderScreenPosition(
            controller.offsetCanvasToScreen(Offset.zero),
          )
          .map((MPStationPointNameCoordinateRecord record) => record.name)
          .toList();

      expect(stationNames, <String>['Border']);
    });

    test(
      'uses the only unused XVI station under a new station point',
      () async {
        final String filename = THTestAux.testPath(
          'mapiah_station_cache_use_xvi_station_name.th2',
        );
        const String th2Content = '''
encoding utf-8
##XTHERION## xth_me_image_insert {0 1 1.0} {0 0} "./xvi/2026-04-23-001-xvi-station_name_with_underscore_and_accent.xvi" 0 {}
scrap first_scrap
endscrap
''';

        final TH2FileEditController controller = await _parseController(
          filename: filename,
          th2Content: th2Content,
        );

        controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

        final MPStationPointNameCoordinateRecord xviStation = controller
            .userInteractionController
            .getXVIStationPointNameCoordinateCache()
            .firstWhere(
              (MPStationPointNameCoordinateRecord record) =>
                  record.name == '3R9_nó_agua',
            );
        final Offset screenPosition = controller.offsetCanvasToScreen(
          xviStation.coordinates,
        );
        final MPCommand command = MPCommandFactory.addPoint(
          screenPosition: screenPosition,
          pointTypeString: 'station',
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        controller.execute(command);

        final THPoint newStationPoint = controller.th2File.getPoints().last;
        final THStationNameCommandOption? stationNameOption =
            newStationPoint.getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(stationNameOption, isNotNull);
        expect(stationNameOption!.name, '3R9_nó_agua');
        expect(
          controller.elementEditController.lastUsedStationName,
          '3R9_nó_agua',
        );
      },
    );

    test(
      'does not reuse an XVI station name already used by Therion',
      () async {
        final String filename = THTestAux.testPath(
          'mapiah_station_cache_skip_used_xvi_station_name.th2',
        );
        const String th2Content = '''
encoding utf-8
##XTHERION## xth_me_image_insert {0 1 1.0} {0 0} "./xvi/2026-04-23-001-xvi-station_name_with_underscore_and_accent.xvi" 0 {}
scrap first_scrap
endscrap
''';

        final TH2FileEditController controller = await _parseController(
          filename: filename,
          th2Content: th2Content,
        );

        controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

        final THPoint existingStationPoint = THPoint.pointTypeFromString(
          parentMPID: controller.activeScrapID,
          pointTypeString: 'station',
          position: THPositionPart(coordinates: const Offset(10, 20)),
        );

        controller.execute(
          MPAddPointCommand(newPoint: existingStationPoint, posCommand: null),
        );
        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: existingStationPoint.mpID,
              name: '3R9_nó_agua',
            ),
          ),
        );

        final MPStationPointNameCoordinateRecord xviStation = controller
            .userInteractionController
            .getXVIStationPointNameCoordinateCache()
            .firstWhere(
              (MPStationPointNameCoordinateRecord record) =>
                  record.name == '3R9_nó_agua',
            );
        final Offset screenPosition = controller.offsetCanvasToScreen(
          xviStation.coordinates,
        );
        final MPCommand command = MPCommandFactory.addPoint(
          screenPosition: screenPosition,
          pointTypeString: 'station',
          pointSubtypeString: '',
          th2FileEditController: controller,
        );

        controller.execute(command);

        final THPoint newStationPoint = controller.th2File.getPoints().last;
        final THStationNameCommandOption? stationNameOption =
            newStationPoint.getOption(THCommandOptionType.station)
                as THStationNameCommandOption?;

        expect(stationNameOption, isNotNull);
        expect(stationNameOption!.name, isNot('3R9_nó_agua'));
      },
    );

    test(
      'reflects station option edit create and delete in Therion cache',
      () async {
        const String filename =
            '/tmp/mapiah_station_cache_station_option_ops.th2';
        const String th2Content = '''
encoding utf-8
scrap first_scrap
  point 10 20 station -name A1
  point 30 40 station
endscrap
''';

        final TH2FileEditController controller = await _parseController(
          filename: filename,
          th2Content: th2Content,
        );
        final List<THPoint> points = controller.th2File.getPoints().toList();
        final THPoint namedStationPoint = points.first;
        final THPoint unnamedStationPoint = points.last;

        expect(
          controller.userInteractionController
              .getTherionStationPointNameCoordinateCache()
              .map((MPStationPointNameCoordinateRecord record) => record.name)
              .toList(),
          <String>['A1'],
        );

        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: namedStationPoint.mpID,
              name: 'B2',
            ),
          ),
        );

        expect(
          controller.userInteractionController
              .getTherionStationPointNameCoordinateCache()
              .map((MPStationPointNameCoordinateRecord record) => record.name)
              .toList(),
          <String>['B2'],
        );

        controller.execute(
          MPSetOptionToElementCommand(
            toOption: THStationNameCommandOption.fromStringWithParentMPID(
              parentMPID: unnamedStationPoint.mpID,
              name: 'C3',
            ),
          ),
        );

        expect(
          controller.userInteractionController
              .getTherionStationPointNameCoordinateCache()
              .map((MPStationPointNameCoordinateRecord record) => record.name)
              .toList(),
          <String>['B2', 'C3'],
        );

        controller.execute(
          MPRemoveOptionFromElementCommand(
            optionType: THCommandOptionType.station,
            parentMPID: namedStationPoint.mpID,
          ),
        );

        expect(
          controller.userInteractionController
              .getTherionStationPointNameCoordinateCache()
              .map((MPStationPointNameCoordinateRecord record) => record.name)
              .toList(),
          <String>['C3'],
        );
      },
    );
  });
}

Future<TH2FileEditController> _parseController({
  required String filename,
  required String th2Content,
  bool prepareVisibleScreen = true,
}) async {
  final TH2FileParser parser = TH2FileParser();
  final Uint8List fileBytes = utf8.encode(th2Content);

  mpLocator.mpGeneralController.reset();
  final (TH2File _, bool isSuccessful, List<String> errors) = await parser
      .parse(filename, fileBytes: fileBytes, forceNewController: true);

  expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

  final TH2FileEditController controller = mpLocator.mpGeneralController
      .getTH2FileEditController(filename: filename);

  if (prepareVisibleScreen) {
    _prepareVisibleScreen(controller);
  }

  return controller;
}

void _prepareVisibleScreen(TH2FileEditController controller) {
  controller.updateScreenSize(const Size(1280.0, 720.0));
  controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);
}
