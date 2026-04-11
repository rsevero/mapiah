// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  group('selected elements transform states', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_EnableElementTransforms,
        false,
      );
    });

    Future<TH2FileEditController> loadController() async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(
        '2026-03-18-002-two_scraps_with_point_line_area.th2',
      );
      final (_, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      for (final THScrap scrap in controller.th2File.getScraps()) {
        controller.setActiveScrap(scrap.mpID);

        final List<THLine> lines = controller.th2File
            .getLines()
            .where((THLine line) => line.parentMPID == scrap.mpID)
            .toList();

        if (lines.isNotEmpty) {
          return controller;
        }
      }

      return controller;
    }

    THLine pickTransformLine(TH2FileEditController controller) {
      final List<THLine> activeScrapLines = controller.th2File
          .getLines()
          .where((THLine line) => line.parentMPID == controller.activeScrapID)
          .toList();

      expect(activeScrapLines, isNotEmpty);

      for (final THLine line in activeScrapLines) {
        final Rect boundingBox = line.getBoundingBox(controller)!;

        if ((boundingBox.width > 0.0001) && (boundingBox.height > 0.0001)) {
          return line;
        }
      }

      return activeScrapLines.first;
    }

    void selectLine({
      required TH2FileEditController controller,
      required THLine line,
    }) {
      controller.selectionController.setSelectedElements(<THElement>[line]);
      controller.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
    }

    List<Offset> lineSegmentPoints(THLineSegment lineSegment) {
      switch (lineSegment) {
        case THStraightLineSegment _:
          return <Offset>[lineSegment.endPoint.coordinates];
        case THBezierCurveLineSegment _:
          return <Offset>[
            lineSegment.controlPoint1.coordinates,
            lineSegment.controlPoint2.coordinates,
            lineSegment.endPoint.coordinates,
          ];
      }

      throw StateError(
        'Unsupported line segment type: ${lineSegment.runtimeType}',
      );
    }

    List<Offset> captureLinePoints(
      TH2FileEditController controller,
      THLine line,
    ) {
      final List<Offset> result = <Offset>[];

      for (final THLineSegment lineSegment in line.getLineSegments(
        controller.th2File,
      )) {
        result.addAll(lineSegmentPoints(lineSegment));
      }

      return result;
    }

    Offset rotatePoint({
      required Offset point,
      required Offset pivot,
      required double angleInDeg,
    }) {
      final double angleInRad = angleInDeg * mp1DegreeInRads;
      final Offset delta = point - pivot;
      final double cosValue = math.cos(angleInRad);
      final double sinValue = math.sin(angleInRad);

      return pivot +
          Offset(
            (delta.dx * cosValue) - (delta.dy * sinValue),
            (delta.dx * sinValue) + (delta.dy * cosValue),
          );
    }

    Offset dragScreenPositionForScale({
      required TH2FileEditController controller,
      required Offset handleCanvas,
      required Offset desiredHandleCanvas,
      required Offset handleCenterCanvas,
    }) {
      final Offset handleCenterScreen = controller.offsetCanvasToScreen(
        handleCenterCanvas,
      );
      final Offset canvasDeltaOnScreen =
          controller.offsetCanvasToScreen(desiredHandleCanvas) -
          controller.offsetCanvasToScreen(handleCanvas);

      return handleCenterScreen + canvasDeltaOnScreen;
    }

    void expectLineMatchesTransformedPoints({
      required TH2FileEditController controller,
      required THLine line,
      required List<Offset> originalPoints,
      required Offset Function(Offset point) transformPoint,
    }) {
      final THLine updatedLine = controller.th2File.lineByMPID(line.mpID);
      final List<Offset> actualPoints =
          captureLinePoints(controller, updatedLine)
            ..sort((Offset a, Offset b) {
              final int dxCompare = a.dx.compareTo(b.dx);

              return (dxCompare != 0) ? dxCompare : a.dy.compareTo(b.dy);
            });
      final List<Offset> expectedPoints =
          originalPoints.map(transformPoint).toList()
            ..sort((Offset a, Offset b) {
              final int dxCompare = a.dx.compareTo(b.dx);

              return (dxCompare != 0) ? dxCompare : a.dy.compareTo(b.dy);
            });

      expect(actualPoints.length, expectedPoints.length);

      for (int i = 0; i < actualPoints.length; i++) {
        expect(actualPoints[i].dx, closeTo(expectedPoints[i].dx, 0.0001));
        expect(actualPoints[i].dy, closeTo(expectedPoints[i].dy, 0.0001));
      }
    }

    test('H and V mirror the selected elements when enabled', () async {
      final TH2FileEditController controller = await loadController();
      final THLine line = pickTransformLine(controller);

      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_EnableElementTransforms,
        true,
      );
      selectLine(controller: controller, line: line);

      final Rect startBounds =
          controller.selectionController.selectedElementsBoundingBox;
      final Offset center = startBounds.center;
      final List<Offset> originalPoints = captureLinePoints(controller, line);

      controller.stateController.onKeyDownEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyH,
          logicalKey: LogicalKeyboardKey.keyH,
          timeStamp: Duration.zero,
        ),
      );

      expectLineMatchesTransformedPoints(
        controller: controller,
        line: line,
        originalPoints: originalPoints,
        transformPoint: (Offset point) {
          return Offset(center.dx - (point.dx - center.dx), point.dy);
        },
      );

      controller.undo();

      controller.stateController.onKeyDownEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyV,
          logicalKey: LogicalKeyboardKey.keyV,
          timeStamp: Duration.zero,
        ),
      );

      expectLineMatchesTransformedPoints(
        controller: controller,
        line: line,
        originalPoints: originalPoints,
        transformPoint: (Offset point) {
          return Offset(point.dx, center.dy - (point.dy - center.dy));
        },
      );
    });

    test('dragging a selection handle scales the selected elements', () async {
      final TH2FileEditController controller = await loadController();
      final THLine line = pickTransformLine(controller);

      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_EnableElementTransforms,
        true,
      );
      selectLine(controller: controller, line: line);

      final Rect startBounds =
          controller.selectionController.selectedElementsBoundingBox;
      final Offset anchorCanvas = startBounds.centerLeft;
      final Offset handleCanvas = startBounds.centerRight;
      final Offset desiredHandleCanvas = Offset(
        anchorCanvas.dx + ((handleCanvas.dx - anchorCanvas.dx) * 2.0),
        handleCanvas.dy,
      );
      final Offset handleCenterCanvas = controller.selectionController
          .getSelectionHandleCenters()[MPSelectionHandleType.rightCenter]!;
      final Offset pointerDownScreenPosition = controller.offsetCanvasToScreen(
        handleCenterCanvas,
      );
      final Offset dragScreenPosition = dragScreenPositionForScale(
        controller: controller,
        handleCanvas: handleCanvas,
        desiredHandleCanvas: desiredHandleCanvas,
        handleCenterCanvas: handleCenterCanvas,
      );
      final List<Offset> originalPoints = captureLinePoints(controller, line);

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: pointerDownScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragScreenPosition,
          delta: dragScreenPosition - pointerDownScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(position: dragScreenPosition),
      );

      expectLineMatchesTransformedPoints(
        controller: controller,
        line: line,
        originalPoints: originalPoints,
        transformPoint: (Offset point) {
          return Offset(
            anchorCanvas.dx + ((point.dx - anchorCanvas.dx) * 2.0),
            point.dy,
          );
        },
      );
    });

    test('dragging a rotation handle rotates the selected elements', () async {
      final TH2FileEditController controller = await loadController();
      final THLine line = pickTransformLine(controller);

      mpLocator.mpSettingsController.setBool(
        MPSettingID.TH2Edit_EnableElementTransforms,
        true,
      );
      selectLine(controller: controller, line: line);

      final Rect startBounds =
          controller.selectionController.selectedElementsBoundingBox;
      final Offset center = startBounds.center;
      controller.stateController.setState(MPTH2FileEditStateType.elementRotate);

      final Offset pointerDownScreenPosition = controller.offsetCanvasToScreen(
        controller.selectionController
            .getSelectionHandleCenters()[MPSelectionHandleType.topRight]!,
      );
      final Offset startHandleCanvas = startBounds.topRight;
      final Offset desiredHandleCanvas = rotatePoint(
        point: startHandleCanvas,
        pivot: center,
        angleInDeg: 90.0,
      );
      final Offset dragScreenPosition = controller.offsetCanvasToScreen(
        desiredHandleCanvas,
      );
      final List<Offset> originalPoints = captureLinePoints(controller, line);

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: pointerDownScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragScreenPosition,
          delta: dragScreenPosition - pointerDownScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(position: dragScreenPosition),
      );

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.selectNonEmptySelection,
      );

      expectLineMatchesTransformedPoints(
        controller: controller,
        line: line,
        originalPoints: originalPoints,
        transformPoint: (Offset point) {
          return rotatePoint(point: point, pivot: center, angleInDeg: 90.0);
        },
      );
    });
  });
}
