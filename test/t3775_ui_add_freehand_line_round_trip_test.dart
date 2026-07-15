// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

  group('freehand line .th2 round trip', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'save and reload preserves the committed straight-segment geometry',
      () async {
        final TH2FileEditController controller = mpLocator
            .mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-1',
              scrapOptions: const [],
              encoding: 'utf-8',
            );

        controller.setCanvasScale(1);

        controller.freehandLineCreationController.startStroke(
          const Offset(0, 0),
        );
        controller.freehandLineCreationController.appendStrokeSample(
          const Offset(20, 0),
        );
        controller.freehandLineCreationController.appendStrokeSample(
          const Offset(40, 20),
        );
        controller.freehandLineCreationController.appendStrokeSample(
          const Offset(60, 20),
        );
        controller.freehandLineCreationController.finishStroke(
          const Offset(80, 40),
        );

        final THLine originalLine = controller.th2File.getLines().first;
        final int decimalPositions = controller.currentDecimalPositions;
        final List<Offset> originalCoordinates = originalLine
            .getLineSegments(controller.th2File)
            .cast<THStraightLineSegment>()
            .map((THStraightLineSegment s) => s.endPoint.coordinates)
            .toList();

        expect(originalCoordinates.length, greaterThanOrEqualTo(2));

        final TH2FileWriter writer = TH2FileWriter();
        final String serialized = writer.serialize(controller.th2File);

        final TH2FileParser parser = TH2FileParser();
        final String reparsedFilename =
            '${controller.th2File.filename}_reparsed';
        final (reparsedFile, isSuccessful, errors) = await parser.parse(
          reparsedFilename,
          fileBytes: Uint8List.fromList(utf8.encode(serialized)),
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
        expect(reparsedFile, isA<TH2File>());

        final List<THLine> reparsedLines = reparsedFile.getLines().toList();

        expect(reparsedLines, hasLength(1));

        final List<THLineSegment> reparsedSegments = reparsedLines.first
            .getLineSegments(reparsedFile);

        expect(
          reparsedSegments.every((THLineSegment s) => s is THStraightLineSegment),
          isTrue,
        );

        final List<Offset> reparsedCoordinates = reparsedSegments
            .cast<THStraightLineSegment>()
            .map((THStraightLineSegment s) => s.endPoint.coordinates)
            .toList();
        final double tolerance = math.pow(10, -decimalPositions).toDouble();

        expect(reparsedCoordinates.length, originalCoordinates.length);

        for (int i = 0; i < originalCoordinates.length; i++) {
          expect(
            reparsedCoordinates[i].dx,
            closeTo(originalCoordinates[i].dx, tolerance),
          );
          expect(
            reparsedCoordinates[i].dy,
            closeTo(originalCoordinates[i].dy, tolerance),
          );
        }
      },
    );
  });
}
