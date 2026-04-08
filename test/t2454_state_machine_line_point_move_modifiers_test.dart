// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
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

  group('line point move modifiers', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      MPInteractionAux.debugPressedKeysOverride = null;
    });

    tearDown(() {
      MPInteractionAux.debugPressedKeysOverride = null;
    });

    Future<TH2FileEditController> loadController(String filename) async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(filename);
      final (_, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

      return controller;
    }

    void prepareSingleLineState(TH2FileEditController controller, THLine line) {
      controller.selectionController.setSelectedElements(<THElement>[line]);
      controller.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );
    }

    void sendArrowKeyDown({
      required TH2FileEditController controller,
      required PhysicalKeyboardKey physicalKey,
      required LogicalKeyboardKey logicalKey,
    }) {
      controller.stateController.onKeyDownEvent(
        KeyDownEvent(
          physicalKey: physicalKey,
          logicalKey: logicalKey,
          timeStamp: Duration.zero,
        ),
      );
    }

    MPSelectableEndControlPoint getControlPoint1Selectable({
      required TH2FileEditController controller,
      required THBezierCurveLineSegment bezierSegment,
    }) {
      return controller.selectionController.selectableEndControlPoints
          .firstWhere(
            (MPSelectableEndControlPoint selectablePoint) =>
                (selectablePoint.lineSegment.mpID == bezierSegment.mpID) &&
                (selectablePoint.type == MPEndControlPointType.controlPoint1),
          );
    }

    test(
      'Alt drag moves selected end point even when drag starts away from it',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;

        prepareSingleLineState(controller, line);

        final List<THLineSegment> lineSegments = line.getLineSegments(
          controller.th2File,
        );
        final THLineSegment selectedSegment = lineSegments.first;
        final Offset originalEndPoint = selectedSegment.endPoint.coordinates;
        final Offset dragStartCanvasPosition =
            originalEndPoint + const Offset(50.0, 40.0);
        const Offset dragDelta = Offset(12.0, -7.0);
        final Offset firstDragCanvasPosition =
            dragStartCanvasPosition + const Offset(1.0, 0.0);
        final Offset dragEndCanvasPosition =
            dragStartCanvasPosition + dragDelta;

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.altLeft,
        };

        await controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: controller.offsetCanvasToScreen(dragStartCanvasPosition),
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(firstDragCanvasPosition),
            delta: firstDragCanvasPosition - dragStartCanvasPosition,
            buttons: kPrimaryButton,
          ),
        );

        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.movingEndControlPoints,
        );

        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
            delta: dragEndCanvasPosition - firstDragCanvasPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(
            position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
          ),
        );

        final THLineSegment movedSegment = controller.th2File
            .lineByMPID(line.mpID)
            .getLineSegments(controller.th2File)
            .first;

        expect(
          movedSegment.endPoint.coordinates.dx,
          closeTo(originalEndPoint.dx + dragDelta.dx, 0.0001),
        );
        expect(
          movedSegment.endPoint.coordinates.dy,
          closeTo(originalEndPoint.dy + dragDelta.dy, 0.0001),
        );
      },
    );

    test(
      'entering moving end control points triggers immediate line-edit redraw',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;

        prepareSingleLineState(controller, line);

        final THLineSegment selectedSegment = line
            .getLineSegments(controller.th2File)
            .first;
        final int redrawBefore = controller.redrawTriggerEditLine;

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        controller.selectionController
            .setDragStartCoordinatesFromCanvasCoordinates(
              selectedSegment.endPoint.coordinates,
            );
        controller.stateController.setState(
          MPTH2FileEditStateType.movingEndControlPoints,
        );

        expect(controller.redrawTriggerEditLine, greaterThan(redrawBefore));
      },
    );

    test('Ctrl drag constrains selected control point to one axis', () async {
      final TH2FileEditController controller = await loadController(
        '2025-10-27-002-bezier_line.th2',
      );
      final THLine line = controller.th2File.getLines().first;

      prepareSingleLineState(controller, line);

      final THBezierCurveLineSegment bezierSegment = line
          .getLineSegments(controller.th2File)
          .whereType<THBezierCurveLineSegment>()
          .first;
      controller.selectionController.addSelectedEndPoint(bezierSegment);
      controller.selectionController.updateSelectableEndAndControlPoints();
      final MPSelectableEndControlPoint controlPoint = controller
          .selectionController
          .selectableEndControlPoints
          .firstWhere(
            (MPSelectableEndControlPoint selectablePoint) =>
                (selectablePoint.lineSegment.mpID == bezierSegment.mpID) &&
                (selectablePoint.type == MPEndControlPointType.controlPoint1),
          );
      final Offset originalControlPoint = controlPoint.position;

      controller.selectionController.setSelectedEndControlPoint(controlPoint);
      controller.selectionController
          .setDragStartCoordinatesFromCanvasCoordinates(originalControlPoint);
      controller.stateController.setState(
        MPTH2FileEditStateType.movingSingleControlPoint,
      );
      MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
        LogicalKeyboardKey.controlLeft,
      };

      final Offset dragEndCanvasPosition =
          originalControlPoint + const Offset(12.0, -8.0);

      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
          delta: dragEndCanvasPosition - originalControlPoint,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(
          position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
        ),
      );

      final THBezierCurveLineSegment movedSegment = controller.th2File
          .lineByMPID(line.mpID)
          .getLineSegments(controller.th2File)
          .whereType<THBezierCurveLineSegment>()
          .first;

      expect(
        movedSegment.controlPoint1.coordinates.dx,
        closeTo(originalControlPoint.dx + 12.0, 0.0001),
      );
      expect(
        movedSegment.controlPoint1.coordinates.dy,
        closeTo(originalControlPoint.dy, 0.0001),
      );
    });

    test(
      'Shift drag disables snapping while moving selected end point',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;

        prepareSingleLineState(controller, line);

        final THLineSegment selectedSegment = line
            .getLineSegments(controller.th2File)
            .first;
        final Offset explicitSnapTarget = const Offset(2800.0, -760.0);
        final Offset desiredUnsnappedPosition =
            explicitSnapTarget + const Offset(1.0, 1.0);

        controller.execute(
          MPCommandFactory.addPoint(
            screenPosition: controller.offsetCanvasToScreen(explicitSnapTarget),
            pointTypeString: 'station',
            pointSubtypeString: '',
            th2FileEditController: controller,
          ),
        );
        controller.snapController.setSnapTargets(
          pointTarget: MPSnapPointTarget.point,
          linePointTarget: MPSnapLinePointTarget.none,
        );

        final THPositionPart? snapTarget = controller.snapController
            .getCanvasSnapedPositionFromCanvasOffset(desiredUnsnappedPosition);

        expect(snapTarget, isNotNull);
        expect(snapTarget!.coordinates, explicitSnapTarget);

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        controller.selectionController
            .setDragStartCoordinatesFromCanvasCoordinates(
              selectedSegment.endPoint.coordinates,
            );
        controller.stateController.setState(
          MPTH2FileEditStateType.movingEndControlPoints,
        );
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.shiftLeft,
        };

        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(desiredUnsnappedPosition),
            delta:
                desiredUnsnappedPosition - selectedSegment.endPoint.coordinates,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(
            position: controller.offsetCanvasToScreen(desiredUnsnappedPosition),
          ),
        );

        final THLineSegment movedSegment = controller.th2File
            .lineByMPID(line.mpID)
            .getLineSegments(controller.th2File)
            .first;

        expect(
          movedSegment.endPoint.coordinates.dx,
          closeTo(desiredUnsnappedPosition.dx, 0.0001),
        );
        expect(
          movedSegment.endPoint.coordinates.dy,
          closeTo(desiredUnsnappedPosition.dy, 0.0001),
        );
      },
    );

    test(
      'Arrow moves selected end point by the configured nudge factor',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;
        final double originalSetting = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 3.0;

        prepareSingleLineState(controller, line);

        final THLineSegment selectedSegment = line
            .getLineSegments(controller.th2File)
            .first;
        final Offset originalEndPoint = selectedSegment.endPoint.coordinates;

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          sendArrowKeyDown(
            controller: controller,
            physicalKey: PhysicalKeyboardKey.arrowRight,
            logicalKey: LogicalKeyboardKey.arrowRight,
          );

          final THLineSegment movedSegment = controller.th2File
              .lineByMPID(line.mpID)
              .getLineSegments(controller.th2File)
              .first;

          expect(
            movedSegment.endPoint.coordinates.dx,
            closeTo(originalEndPoint.dx + nudgeFactor, 0.0001),
          );
          expect(
            movedSegment.endPoint.coordinates.dy,
            closeTo(originalEndPoint.dy, 0.0001),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalSetting,
          );
        }
      },
    );

    test(
      'Shift+Arrow moves selected end point by ten times the nudge factor',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;
        final double originalSetting = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 4.0;

        prepareSingleLineState(controller, line);

        final THLineSegment selectedSegment = line
            .getLineSegments(controller.th2File)
            .first;
        final Offset originalEndPoint = selectedSegment.endPoint.coordinates;

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.shiftLeft,
        };

        try {
          sendArrowKeyDown(
            controller: controller,
            physicalKey: PhysicalKeyboardKey.arrowDown,
            logicalKey: LogicalKeyboardKey.arrowDown,
          );

          final THLineSegment movedSegment = controller.th2File
              .lineByMPID(line.mpID)
              .getLineSegments(controller.th2File)
              .first;

          expect(
            movedSegment.endPoint.coordinates.dx,
            closeTo(originalEndPoint.dx, 0.0001),
          );
          expect(
            movedSegment.endPoint.coordinates.dy,
            closeTo(originalEndPoint.dy - (nudgeFactor * 10.0), 0.0001),
          );
        } finally {
          MPInteractionAux.debugPressedKeysOverride = null;
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalSetting,
          );
        }
      },
    );

    test('Alt+Arrow moves selected end point by one screen pixel', () async {
      final TH2FileEditController controller = await loadController(
        '2025-10-05-001-line.th2',
      );
      final THLine line = controller.th2File.getLines().first;

      prepareSingleLineState(controller, line);

      final THLineSegment selectedSegment = line
          .getLineSegments(controller.th2File)
          .first;
      final Offset originalEndPoint = selectedSegment.endPoint.coordinates;
      final double expectedCanvasStep = controller.scaleScreenToCanvas(1.0);

      controller.selectionController.setSelectedEndPoints(<THLineSegment>[
        selectedSegment,
      ]);
      controller.selectionController.updateSelectableEndAndControlPoints();
      MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
        LogicalKeyboardKey.altLeft,
      };

      try {
        sendArrowKeyDown(
          controller: controller,
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          logicalKey: LogicalKeyboardKey.arrowLeft,
        );

        final THLineSegment movedSegment = controller.th2File
            .lineByMPID(line.mpID)
            .getLineSegments(controller.th2File)
            .first;

        expect(
          movedSegment.endPoint.coordinates.dx,
          closeTo(originalEndPoint.dx - expectedCanvasStep, 0.0001),
        );
        expect(
          movedSegment.endPoint.coordinates.dy,
          closeTo(originalEndPoint.dy, 0.0001),
        );
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }
    });

    test(
      'Alt+Shift+Arrow moves selected end point by ten screen pixels',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-05-001-line.th2',
        );
        final THLine line = controller.th2File.getLines().first;

        prepareSingleLineState(controller, line);

        final THLineSegment selectedSegment = line
            .getLineSegments(controller.th2File)
            .first;
        final Offset originalEndPoint = selectedSegment.endPoint.coordinates;
        final double expectedCanvasStep = controller.scaleScreenToCanvas(10.0);

        controller.selectionController.setSelectedEndPoints(<THLineSegment>[
          selectedSegment,
        ]);
        controller.selectionController.updateSelectableEndAndControlPoints();
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.altLeft,
          LogicalKeyboardKey.shiftLeft,
        };

        try {
          sendArrowKeyDown(
            controller: controller,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            logicalKey: LogicalKeyboardKey.arrowUp,
          );

          final THLineSegment movedSegment = controller.th2File
              .lineByMPID(line.mpID)
              .getLineSegments(controller.th2File)
              .first;

          expect(
            movedSegment.endPoint.coordinates.dx,
            closeTo(originalEndPoint.dx, 0.0001),
          );
          expect(
            movedSegment.endPoint.coordinates.dy,
            closeTo(originalEndPoint.dy + expectedCanvasStep, 0.0001),
          );
        } finally {
          MPInteractionAux.debugPressedKeysOverride = null;
        }
      },
    );

    test(
      'Arrow moves selected control point by the configured nudge factor',
      () async {
        final TH2FileEditController controller = await loadController(
          '2025-10-27-002-bezier_line.th2',
        );
        final THLine line = controller.th2File.getLines().first;
        final double originalSetting = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 2.5;

        prepareSingleLineState(controller, line);

        final THBezierCurveLineSegment bezierSegment = line
            .getLineSegments(controller.th2File)
            .whereType<THBezierCurveLineSegment>()
            .first;

        controller.selectionController.addSelectedEndPoint(bezierSegment);
        controller.selectionController.updateSelectableEndAndControlPoints();

        final MPSelectableEndControlPoint controlPoint =
            getControlPoint1Selectable(
              controller: controller,
              bezierSegment: bezierSegment,
            );
        final Offset originalControlPoint = controlPoint.position;

        controller.selectionController.setSelectedEndControlPoint(controlPoint);
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );

        try {
          sendArrowKeyDown(
            controller: controller,
            physicalKey: PhysicalKeyboardKey.arrowRight,
            logicalKey: LogicalKeyboardKey.arrowRight,
          );

          final THBezierCurveLineSegment movedSegment = controller.th2File
              .lineByMPID(line.mpID)
              .getLineSegments(controller.th2File)
              .whereType<THBezierCurveLineSegment>()
              .first;

          expect(
            movedSegment.controlPoint1.coordinates.dx,
            closeTo(originalControlPoint.dx + nudgeFactor, 0.0001),
          );
          expect(
            movedSegment.controlPoint1.coordinates.dy,
            closeTo(originalControlPoint.dy, 0.0001),
          );
        } finally {
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_NudgeFactor,
            originalSetting,
          );
        }
      },
    );
  });
}
