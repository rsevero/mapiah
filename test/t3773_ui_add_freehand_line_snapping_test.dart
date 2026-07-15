// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
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

  group('freehand line snapping', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'start and final samples snap to an existing point; intermediate '
      'samples over the same target are left unsnapped',
      () {
        final TH2FileEditController controller = buildController();
        const Offset startSnapCanvas = Offset(100, 100);
        const Offset endSnapCanvas = Offset(400, 100);
        final Offset startSnapScreen = controller.offsetCanvasToScreen(
          startSnapCanvas,
        );
        final Offset endSnapScreen = controller.offsetCanvasToScreen(
          endSnapCanvas,
        );

        for (final Offset target in [startSnapCanvas, endSnapCanvas]) {
          controller.execute(
            MPCommandFactory.addPoint(
              screenPosition: controller.offsetCanvasToScreen(target),
              pointTypeString: 'station',
              pointSubtypeString: '',
              th2FileEditController: controller,
            ),
          );
        }
        controller.snapController.setSnapTargets(
          pointTarget: MPSnapPointTarget.point,
          linePointTarget: MPSnapLinePointTarget.none,
        );

        // Start a stroke slightly off the point: it must snap onto it.
        final Offset nearStartScreen =
            startSnapScreen + const Offset(1.0, 1.0);

        controller.freehandLineCreationController.startStroke(nearStartScreen);

        expect(
          controller.freehandLineCreationController.sampledCanvasPoints.first,
          startSnapCanvas,
        );

        // An intermediate sample within snapping distance of the start
        // target must NOT be pulled onto it: only the first/final points
        // are snapped. (Landing exactly on the target's screen position
        // would make the raw conversion coincide with the snapped one, so
        // offset slightly to make the distinction observable.)
        final Offset nearIntermediateScreen =
            startSnapScreen + const Offset(2.0, 0.0);

        controller.freehandLineCreationController.appendStrokeSample(
          nearIntermediateScreen,
        );

        final Offset intermediateSample = controller
            .freehandLineCreationController
            .sampledCanvasPoints
            .last;

        expect(intermediateSample, isNot(startSnapCanvas));
        expect(
          intermediateSample,
          controller.offsetScreenToCanvas(nearIntermediateScreen),
        );

        // Move far enough away for a valid stroke length, then finish near
        // the second point: the final point must snap onto it.
        controller.freehandLineCreationController.appendStrokeSample(
          endSnapScreen + const Offset(0, 40),
        );

        final Offset nearEndScreen =
            endSnapScreen + const Offset(-1.0, -1.0);

        controller.freehandLineCreationController.finishStroke(nearEndScreen);

        final THLine committedLine = controller.th2File.getLines().first;
        final List<THStraightLineSegment> segments = committedLine
            .getLineSegments(controller.th2File)
            .cast<THStraightLineSegment>();

        expect(segments.first.endPoint.coordinates, startSnapCanvas);
        expect(segments.last.endPoint.coordinates, endSnapCanvas);
      },
    );

    test(
      'without an active snap target, samples use the raw canvas position',
      () {
        final TH2FileEditController controller = buildController();
        const Offset canvasPosition = Offset(50, 50);
        final Offset screenPosition = controller.offsetCanvasToScreen(
          canvasPosition,
        );

        controller.freehandLineCreationController.startStroke(screenPosition);

        expect(
          controller.freehandLineCreationController.sampledCanvasPoints.first,
          canvasPosition,
        );

        controller.freehandLineCreationController.abandonStroke();
      },
    );
  });
}
