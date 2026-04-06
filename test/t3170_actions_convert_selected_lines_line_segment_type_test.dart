// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

  group('actions: convert selected lines line segment type', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    const List<Map<String, Object>> cases = <Map<String, Object>>[
      <String, Object>{
        'file': '2025-10-12-001-bezier_and_straight_line.th2',
        'targetType': MPSelectedLineSegmentType.straightLineSegment,
        'expectedStraight': true,
        'expectsChange': true,
      },
      <String, Object>{
        'file': '2025-10-12-001-bezier_and_straight_line.th2',
        'targetType': MPSelectedLineSegmentType.bezierCurveLineSegment,
        'expectedStraight': false,
        'expectsChange': true,
      },
      <String, Object>{
        'file': '2025-10-27-001-straight_line.th2',
        'targetType': MPSelectedLineSegmentType.straightLineSegment,
        'expectedStraight': true,
        'expectsChange': false,
      },
      <String, Object>{
        'file': '2025-10-27-001-straight_line.th2',
        'targetType': MPSelectedLineSegmentType.bezierCurveLineSegment,
        'expectedStraight': false,
        'expectsChange': true,
      },
      <String, Object>{
        'file': '2025-10-27-002-bezier_line.th2',
        'targetType': MPSelectedLineSegmentType.bezierCurveLineSegment,
        'expectedStraight': false,
        'expectsChange': false,
      },
      <String, Object>{
        'file': '2025-10-27-002-bezier_line.th2',
        'targetType': MPSelectedLineSegmentType.straightLineSegment,
        'expectedStraight': true,
        'expectsChange': true,
      },
    ];

    for (final Map<String, Object> testCase in cases) {
      final String filename = testCase['file']! as String;
      final MPSelectedLineSegmentType targetType =
          testCase['targetType']! as MPSelectedLineSegmentType;
      final bool expectedStraight = testCase['expectedStraight']! as bool;
      final bool expectsChange = testCase['expectsChange']! as bool;

      test(
        '$filename -> ${targetType.name} ${expectsChange ? "changes and undoes" : "is no-op"}',
        () async {
          final TH2FileEditController controller = mpLocator.mpGeneralController
              .getTH2FileEditController(filename: THTestAux.testPath(filename));
          await controller.load();

          final TH2FileWriter writer = TH2FileWriter();
          final String serializedBefore = writer.serialize(controller.th2File);
          final THLine line = controller.th2File.getLines().first;

          controller.selectionController.setSelectedElements(<THElement>[line]);
          controller.userInteractionController
              .prepareSetSelectedLinesLineSegmentType(
                selectedLineSegmentType: targetType,
              );

          final List<THLineSegment> lineSegmentsAfter = controller.th2File
              .getLines()
              .first
              .getLineSegments(controller.th2File);

          _expectAllNonStartSegmentsType(
            lineSegmentsAfter.skip(1),
            expectedStraight: expectedStraight,
          );

          if (!expectsChange) {
            expect(controller.hasUndo, isFalse);
            expect(writer.serialize(controller.th2File), serializedBefore);

            return;
          }

          expect(controller.hasUndo, isTrue);
          expect(writer.serialize(controller.th2File), isNot(serializedBefore));

          controller.undo();

          expect(writer.serialize(controller.th2File), serializedBefore);
        },
      );
    }

    test(
      'multiple selected lines are converted together and undo restores',
      () async {
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(
              filename: THTestAux.testPath(
                '2026-03-30-005-2_lines_straight_bezier.th2',
              ),
            );
        await controller.load();

        final TH2FileWriter writer = TH2FileWriter();
        final String serializedBefore = writer.serialize(controller.th2File);
        final List<THLine> lines = controller.th2File.getLines().toList();

        controller.selectionController.setSelectedElements(lines);
        controller.userInteractionController
            .prepareSetSelectedLinesLineSegmentType(
              selectedLineSegmentType:
                  MPSelectedLineSegmentType.straightLineSegment,
            );

        final List<THLine> changedLines = controller.th2File
            .getLines()
            .toList();

        for (final THLine line in changedLines) {
          _expectAllNonStartSegmentsType(
            line.getLineSegments(controller.th2File).skip(1),
            expectedStraight: true,
          );
        }

        expect(controller.hasUndo, isTrue);

        controller.undo();

        expect(writer.serialize(controller.th2File), serializedBefore);
      },
    );
  });
}

void _expectAllNonStartSegmentsType(
  Iterable<THLineSegment> lineSegments, {
  required bool expectedStraight,
}) {
  for (final THLineSegment lineSegment in lineSegments) {
    if (expectedStraight) {
      expect(lineSegment, isA<THStraightLineSegment>());
    } else {
      expect(lineSegment, isA<THBezierCurveLineSegment>());
    }
  }
}
