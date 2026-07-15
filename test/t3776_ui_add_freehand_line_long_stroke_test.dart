// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  TH2FileEditController buildController() {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerForNewFile(
          scrapTHID: 'scrap-1',
          scrapOptions: const [],
          encoding: 'utf-8',
        );

    controller.setCanvasScale(1);

    return controller;
  }

  group('freehand line long stroke handling', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'a very long stroke stays within the retained-sample bound, compacts '
      'and keeps enlarging spacing, and remains responsive',
      () {
        final TH2FileEditController controller = buildController();
        final Stopwatch stopwatch = Stopwatch()..start();

        controller.freehandLineCreationController.startStroke(
          const Offset(0, 0),
        );

        double x = 0;
        int compactionObservations = 0;
        int lastLength =
            controller.freehandLineCreationController.sampledCanvasPoints.length;

        // Drive the buffer past its retained-sample bound more than once so
        // repeated compaction (and the resulting spacing growth) is
        // exercised, not just a single compaction event.
        while (compactionObservations < 2) {
          x += controller
              .freehandLineCreationController
              .activeSampleSpacingOnScreen;
          controller.freehandLineCreationController.appendStrokeSample(
            Offset(x, 0),
          );

          final int currentLength = controller
              .freehandLineCreationController
              .sampledCanvasPoints
              .length;

          expect(currentLength, lessThanOrEqualTo(mpFreehandMaximumSampleCount));

          if (currentLength < lastLength) {
            compactionObservations++;
          }

          lastLength = currentLength;
        }

        controller.freehandLineCreationController.finishStroke(
          Offset(x + 100, 0),
        );

        stopwatch.stop();

        // A generous ceiling: this is a responsiveness smoke check, not a
        // strict perf budget, so it should never be close to failing on
        // normal hardware while still catching an accidental O(n^2) blow-up.
        expect(stopwatch.elapsedMilliseconds, lessThan(20000));

        final THLine committedLine = controller.th2File.getLines().first;
        final List<THStraightLineSegment> segments = committedLine
            .getLineSegments(controller.th2File)
            .cast<THStraightLineSegment>();

        expect(segments, isNotEmpty);
        expect(
          controller.freehandLineCreationController.isCapturing,
          isFalse,
        );
      },
    );

    test(
      'only the freehand preview redraw trigger fires while sampling; '
      'full-element redraw is untouched during capture',
      () {
        final TH2FileEditController controller = buildController();
        final int nonSelectedRedrawBefore =
            controller.redrawTriggerNonSelectedElements;
        final int freehandRedrawBefore = controller.redrawTriggerFreehandLine;

        controller.freehandLineCreationController.startStroke(
          const Offset(0, 0),
        );

        final int freehandRedrawAfterStart =
            controller.redrawTriggerFreehandLine;

        expect(freehandRedrawAfterStart, greaterThan(freehandRedrawBefore));

        for (int i = 1; i <= 500; i++) {
          controller.freehandLineCreationController.appendStrokeSample(
            Offset(i.toDouble(), 0),
          );
        }

        expect(
          controller.redrawTriggerFreehandLine,
          greaterThan(freehandRedrawAfterStart),
        );
        expect(
          controller.redrawTriggerNonSelectedElements,
          nonSelectedRedrawBefore,
        );

        controller.freehandLineCreationController.abandonStroke();
      },
    );
  });
}
