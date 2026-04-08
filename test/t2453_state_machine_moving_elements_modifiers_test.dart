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
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
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

  group('moving elements modifiers', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      MPInteractionAux.debugPressedKeysOverride = null;
    });

    tearDown(() {
      MPInteractionAux.debugPressedKeysOverride = null;
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

      controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

      return controller;
    }

    test(
      'Alt drag moves selected elements even when drag starts outside',
      () async {
        final TH2FileEditController controller = await loadController();
        final THPoint point = controller.th2File.getPoints().first;
        final Offset originalPosition = point.position.coordinates;
        final Offset dragStartCanvasPosition =
            originalPosition + const Offset(80.0, 60.0);
        const Offset dragDelta = Offset(15.0, -9.0);
        final double dragThreshold = controller.selectionToleranceOnCanvas;
        final Offset firstDragCanvasPosition =
            dragStartCanvasPosition + Offset(dragThreshold * 2.0, 0.0);
        final Offset dragEndCanvasPosition =
            dragStartCanvasPosition + dragDelta;

        controller.selectionController.setSelectedElements(<THElement>[point]);
        controller.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.altLeft,
        };

        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: controller.offsetCanvasToScreen(dragStartCanvasPosition),
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(firstDragCanvasPosition),
            delta: const Offset(1.0, 0.0),
            buttons: kPrimaryButton,
          ),
        );

        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.movingElements,
        );

        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
            delta:
                controller.offsetCanvasToScreen(dragEndCanvasPosition) -
                controller.offsetCanvasToScreen(firstDragCanvasPosition),
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(
            position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
          ),
        );

        final THPoint movedPoint = controller.th2File.pointByMPID(point.mpID);

        expect(
          movedPoint.position.coordinates.dx,
          closeTo(originalPosition.dx + dragDelta.dx, 0.0001),
        );
        expect(
          movedPoint.position.coordinates.dy,
          closeTo(originalPosition.dy + dragDelta.dy, 0.0001),
        );
      },
    );

    test('Ctrl drag constrains selected elements to one axis', () async {
      final TH2FileEditController controller = await loadController();
      final THPoint point = controller.th2File.getPoints().first;
      final Offset originalPosition = point.position.coordinates;
      final Offset dragStartCanvasPosition = originalPosition;
      const Offset dragDelta = Offset(12.0, -8.0);
      final Offset dragEndCanvasPosition = dragStartCanvasPosition + dragDelta;

      controller.selectionController.setSelectedElements(<THElement>[point]);
      controller.selectionController
          .setDragStartCoordinatesFromCanvasCoordinates(
            dragStartCanvasPosition,
          );
      controller.stateController.setState(
        MPTH2FileEditStateType.movingElements,
      );
      MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
        LogicalKeyboardKey.controlLeft,
      };

      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
          delta: dragDelta,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(
          position: controller.offsetCanvasToScreen(dragEndCanvasPosition),
        ),
      );

      final THPoint movedPoint = controller.th2File.pointByMPID(point.mpID);

      expect(
        movedPoint.position.coordinates.dx,
        closeTo(originalPosition.dx + dragDelta.dx, 0.0001),
      );
      expect(
        movedPoint.position.coordinates.dy,
        closeTo(originalPosition.dy, 0.0001),
      );
    });

    test(
      'Shift drag disables snapping while moving selected elements',
      () async {
        final TH2FileEditController controller = await loadController();
        final THPoint point = controller.th2File.getPoints().first;
        final Offset dragStartCanvasPosition = point.position.coordinates;
        final Offset explicitSnapTarget = const Offset(350.0, 350.0);
        final Offset desiredUnsnappedPosition = const Offset(351.0, 351.0);

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

        controller.selectionController.setSelectedElements(<THElement>[point]);
        controller.selectionController
            .setDragStartCoordinatesFromCanvasCoordinates(
              dragStartCanvasPosition,
            );
        controller.stateController.setState(
          MPTH2FileEditStateType.movingElements,
        );
        MPInteractionAux.debugPressedKeysOverride = <LogicalKeyboardKey>{
          LogicalKeyboardKey.shiftLeft,
        };

        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: controller.offsetCanvasToScreen(desiredUnsnappedPosition),
            delta: desiredUnsnappedPosition - dragStartCanvasPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(
            position: controller.offsetCanvasToScreen(desiredUnsnappedPosition),
          ),
        );

        final THPoint movedPoint = controller.th2File.pointByMPID(point.mpID);

        expect(
          movedPoint.position.coordinates.dx,
          closeTo(desiredUnsnappedPosition.dx, 0.0001),
        );
        expect(
          movedPoint.position.coordinates.dy,
          closeTo(desiredUnsnappedPosition.dy, 0.0001),
        );
      },
    );
  });
}
