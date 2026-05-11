// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:mapiah/src/painters/mp_image_operation_overlay_painter.dart';
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

  group('image rotation handle geometry', () {
    test('rotation handle base path keeps square proportions', () {
      final Path basePath =
          MPImageRotationGeometry.baseRotationHandlePathForTesting();
      final Rect bounds = basePath.getBounds();

      expect(bounds.width, closeTo(bounds.height, 0.0001));
    });

    test('rotation handle angle compensates curved arrow orientation', () {
      final double angleInRad =
          MPImageRotationGeometry.rotationHandleAngleForTesting(
            const Offset(1.0, 0.0),
          );

      expect(angleInRad, closeTo(mp45DegreesInRad, 0.0001));
    });

    test('rotation preview math resolves angle delta from drag vectors', () {
      final double? angleDeltaInDeg =
          MPImageRotationPreviewMath.rotationDeltaDeg(
            pivotCanvas: Offset.zero,
            dragStartCanvasPosition: const Offset(1.0, 0.0),
            currentCanvasPosition: const Offset(0.0, 1.0),
          );

      expect(angleDeltaInDeg, closeTo(90.0, 0.0001));
    });

    test('rotation preview math snaps rotation to configured angle', () {
      final double snappedRotation = MPImageRotationPreviewMath.snapRotationDeg(
        rotationDeg: 13.0,
        snapAngleDeg: 15.0,
      );

      expect(snappedRotation, closeTo(15.0, 0.0001));
    });
  });

  group('state machine image operation preparation', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<TH2FileEditController> loadController({
      String filename = '2025-10-26-001-with_image.th2',
    }) async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath(filename);
      final (_, isSuccessful, errors) = await parser.parse(
        path,
        forceNewController: true,
      );

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

      return mpLocator.mpGeneralController.getTH2FileEditController(
        filename: path,
      );
    }

    test(
      'prepareImageMoveState preserves XTherion image for plain move',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        final MPRuntimeImageInsertConfigMixin image = controller
            .moveScaleRotateElementController
            .prepareImageMoveState(imageMPID);

        expect(image.mpID, imageMPID);
        expect(controller.th2File.imageByMPID(imageMPID), same(image));
        expect(image, isA<THXVIXTherionImageInsertConfig>());
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageMoveScale,
        );
        expect(controller.stateController.imageOperationImageMPID, imageMPID);
      },
    );

    test(
      'prepareImageRotateState switches image state context without replacing image again',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        final MPRuntimeImageInsertConfigMixin movedImage = controller
            .moveScaleRotateElementController
            .prepareImageMoveState(imageMPID);
        final MPImageInsertConfig rotatedImage = controller
            .moveScaleRotateElementController
            .prepareImageRotateState(imageMPID);

        expect(movedImage, isA<THXVIXTherionImageInsertConfig>());
        expect(rotatedImage, isA<MPImageInsertConfig>());
        expect(rotatedImage.mpID, movedImage.mpID);
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageRotate,
        );
        expect(controller.stateController.imageOperationImageMPID, imageMPID);
      },
    );

    test(
      'clicking image toggles between move scale and rotate states',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final Rect boundingBox = image.getBoundingBox(controller)!;
        final Offset clickScreenPosition = controller.offsetCanvasToScreen(
          boundingBox.center,
        );

        await controller.stateController.onPrimaryButtonClick(
          PointerUpEvent(position: clickScreenPosition),
        );

        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageRotate,
        );
        expect(
          controller.th2File.imageByMPID(imageMPID),
          isA<MPImageInsertConfig>(),
        );

        await controller.stateController.onPrimaryButtonClick(
          PointerUpEvent(position: clickScreenPosition),
        );

        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageMoveScale,
        );
      },
    );

    test(
      'image overlay painter repaints when transform state changes without mouse movement',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        controller.moveScaleRotateElementController.prepareImageMoveState(
          imageMPID,
        );

        final MPImageOperationOverlayPainter movePainter =
            MPImageOperationOverlayPainter(
              th2FileEditController: controller,
              image: controller.th2File.imageByMPID(imageMPID),
              hoverScreenPosition: Offset.zero,
              isRotateMode: false,
            );

        controller.moveScaleRotateElementController.prepareImageRotateState(
          imageMPID,
        );

        final MPImageOperationOverlayPainter rotatePainter =
            MPImageOperationOverlayPainter(
              th2FileEditController: controller,
              image: controller.th2File.imageByMPID(imageMPID),
              hoverScreenPosition: Offset.zero,
              isRotateMode: true,
            );

        expect(rotatePainter.shouldRepaint(movePainter), isTrue);
      },
    );

    test(
      'prepareImageScaleState enters merged image transform state',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        controller.moveScaleRotateElementController.prepareImageScaleState(
          imageMPID,
        );

        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageMoveScale,
        );
        expect(controller.stateController.imageOperationImageMPID, imageMPID);
        expect(
          controller.th2File.imageByMPID(imageMPID),
          isA<THXVIXTherionImageInsertConfig>(),
        );
      },
    );

    test('image move drag updates image position and is undoable', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final THXTherionImageInsertConfig image =
          controller.moveScaleRotateElementController.prepareImageMoveState(
                imageMPID,
              )
              as THXTherionImageInsertConfig;
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final Offset dragStartCanvasPosition = originalBoundingBox.center;
      const Offset deltaOnCanvas = Offset(12.0, -8.0);
      final Offset dragEndCanvasPosition =
          dragStartCanvasPosition + deltaOnCanvas;
      final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
        dragStartCanvasPosition,
      );
      final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
        dragEndCanvasPosition,
      );
      final double originalXX = image.xx.value;
      final double originalYY = image.yy.value;

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragEndScreenPosition,
          delta: dragEndScreenPosition - dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(position: dragEndScreenPosition),
      );

      final THXTherionImageInsertConfig movedImage =
          controller.th2File.imageByMPID(imageMPID)
              as THXTherionImageInsertConfig;

      expect(movedImage, isA<THXVIXTherionImageInsertConfig>());
      expect(movedImage.xx.value, closeTo(originalXX + 12.0, 0.0001));
      expect(movedImage.yy.value, closeTo(originalYY - 8.0, 0.0001));

      controller.undo();

      final THXTherionImageInsertConfig undoneImage =
          controller.th2File.imageByMPID(imageMPID)
              as THXTherionImageInsertConfig;

      expect(undoneImage.xx.value, originalXX);
      expect(undoneImage.yy.value, originalYY);
    });

    test('Arrow moves selected image by the configured nudge factor', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final double originalSetting = mpLocator.mpSettingsController
          .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
      const double nudgeFactor = 3.0;

      mpLocator.mpSettingsController.setDouble(
        MPSettingID.TH2Edit_NudgeFactor,
        nudgeFactor,
      );

      try {
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final double originalXX = image.xx.value;
        final double originalYY = image.yy.value;

        controller.stateController.onKeyDownEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.arrowRight,
            logicalKey: LogicalKeyboardKey.arrowRight,
            timeStamp: Duration.zero,
          ),
        );

        final THXTherionImageInsertConfig movedImage =
            controller.th2File.imageByMPID(imageMPID)
                as THXTherionImageInsertConfig;

        expect(movedImage.xx.value, closeTo(originalXX + nudgeFactor, 0.0001));
        expect(movedImage.yy.value, closeTo(originalYY, 0.0001));
      } finally {
        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          originalSetting,
        );
      }
    });

    test('H flips selected image horizontally', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final MPRuntimeImageInsertConfigMixin image = controller
          .moveScaleRotateElementController
          .prepareImageMoveState(imageMPID);
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final double originalXX = image.xx.value;
      final double originalYY = image.yy.value;

      controller.stateController.onKeyDownEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyH,
          logicalKey: LogicalKeyboardKey.keyH,
          timeStamp: Duration.zero,
        ),
      );

      final MPImageInsertConfig flippedImage =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(flippedImage.xScale.value, closeTo(-1.0, 0.0001));
      expect(flippedImage.yScale.value, closeTo(1.0, 0.0001));
      expect(flippedImage.xx.value, isNot(closeTo(originalXX, 0.0001)));
      expect(flippedImage.yy.value, closeTo(originalYY, 0.0001));
      expect(
        flippedImage.getBoundingBox(controller)!.center.dx,
        closeTo(originalBoundingBox.center.dx, 0.0001),
      );
      expect(
        flippedImage.getBoundingBox(controller)!.center.dy,
        closeTo(originalBoundingBox.center.dy, 0.0001),
      );

      controller.undo();

      final MPImageInsertConfig undoneScale =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(undoneScale.xScale.value, closeTo(1.0, 0.0001));
      expect(undoneScale.yScale.value, closeTo(1.0, 0.0001));

      controller.undo();

      expect(
        controller.th2File.imageByMPID(imageMPID),
        isA<THXVIXTherionImageInsertConfig>(),
      );
    });

    test('V flips selected image vertically', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final MPRuntimeImageInsertConfigMixin image = controller
          .moveScaleRotateElementController
          .prepareImageMoveState(imageMPID);
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final double originalXX = image.xx.value;
      final double originalYY = image.yy.value;

      controller.stateController.onKeyDownEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyV,
          logicalKey: LogicalKeyboardKey.keyV,
          timeStamp: Duration.zero,
        ),
      );

      final MPImageInsertConfig flippedImage =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(flippedImage.xScale.value, closeTo(1.0, 0.0001));
      expect(flippedImage.yScale.value, closeTo(-1.0, 0.0001));
      expect(flippedImage.xx.value, closeTo(originalXX, 0.0001));
      expect(flippedImage.yy.value, isNot(closeTo(originalYY, 0.0001)));
      expect(
        flippedImage.getBoundingBox(controller)!.center.dx,
        closeTo(originalBoundingBox.center.dx, 0.0001),
      );
      expect(
        flippedImage.getBoundingBox(controller)!.center.dy,
        closeTo(originalBoundingBox.center.dy, 0.0001),
      );

      controller.undo();

      final MPImageInsertConfig undoneScale =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(undoneScale.xScale.value, closeTo(1.0, 0.0001));
      expect(undoneScale.yScale.value, closeTo(1.0, 0.0001));

      controller.undo();

      expect(
        controller.th2File.imageByMPID(imageMPID),
        isA<THXVIXTherionImageInsertConfig>(),
      );
    });

    test(
      'Shift+Arrow moves selected image by ten times the nudge factor',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final double originalSetting = mpLocator.mpSettingsController
            .getDoubleWithDefault(MPSettingID.TH2Edit_NudgeFactor);
        const double nudgeFactor = 4.0;

        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_NudgeFactor,
          nudgeFactor,
        );
        MPInteractionAux.debugPressedKeysOverride = {
          LogicalKeyboardKey.shiftLeft,
        };

        try {
          final THXTherionImageInsertConfig image =
              controller.moveScaleRotateElementController.prepareImageMoveState(
                    imageMPID,
                  )
                  as THXTherionImageInsertConfig;
          final double originalXX = image.xx.value;
          final double originalYY = image.yy.value;

          controller.stateController.onKeyDownEvent(
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.arrowDown,
              logicalKey: LogicalKeyboardKey.arrowDown,
              timeStamp: Duration.zero,
            ),
          );

          final THXTherionImageInsertConfig movedImage =
              controller.th2File.imageByMPID(imageMPID)
                  as THXTherionImageInsertConfig;

          expect(movedImage.xx.value, closeTo(originalXX, 0.0001));
          expect(
            movedImage.yy.value,
            closeTo(originalYY - (nudgeFactor * 10.0), 0.0001),
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

    test('Alt+Arrow moves selected image by one screen pixel', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;

      MPInteractionAux.debugPressedKeysOverride = {LogicalKeyboardKey.altLeft};

      try {
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final double originalXX = image.xx.value;
        final double originalYY = image.yy.value;
        final double expectedCanvasStep = controller.scaleScreenToCanvas(1.0);

        controller.stateController.onKeyDownEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.arrowLeft,
            logicalKey: LogicalKeyboardKey.arrowLeft,
            timeStamp: Duration.zero,
          ),
        );

        final THXTherionImageInsertConfig movedImage =
            controller.th2File.imageByMPID(imageMPID)
                as THXTherionImageInsertConfig;

        expect(
          movedImage.xx.value,
          closeTo(originalXX - expectedCanvasStep, 0.0001),
        );
        expect(movedImage.yy.value, closeTo(originalYY, 0.0001));
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }
    });

    test('Alt+Shift+Arrow moves selected image by ten screen pixels', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;

      MPInteractionAux.debugPressedKeysOverride = {
        LogicalKeyboardKey.altLeft,
        LogicalKeyboardKey.shiftLeft,
      };

      try {
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final double originalXX = image.xx.value;
        final double originalYY = image.yy.value;
        final double expectedCanvasStep = controller.scaleScreenToCanvas(10.0);

        controller.stateController.onKeyDownEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.arrowUp,
            logicalKey: LogicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        final THXTherionImageInsertConfig movedImage =
            controller.th2File.imageByMPID(imageMPID)
                as THXTherionImageInsertConfig;

        expect(movedImage.xx.value, closeTo(originalXX, 0.0001));
        expect(
          movedImage.yy.value,
          closeTo(originalYY + expectedCanvasStep, 0.0001),
        );
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }
    });

    test('image move state keeps undo redo buttons visible', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;

      controller.moveScaleRotateElementController.prepareImageMoveState(
        imageMPID,
      );

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.imageMoveScale,
      );
      expect(controller.showUndoRedoButtons, isTrue);
    });

    test(
      'image move keeps XTherion raster image class when only moving',
      () async {
        final TH2FileEditController controller = await loadController(
          filename: '2026-04-07-003-mixed_image_insert_styles.th2',
        );
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final THRasterXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THRasterXTherionImageInsertConfig;
        final ui.Image decodedImage = await _createTestImage(
          width: 40,
          height: 20,
        );

        image.setRasterImage(decodedImage);
        final Rect visibleBoundingBox = Rect.fromLTRB(
          image.xx.value,
          image.yy.value - decodedImage.height.toDouble(),
          image.xx.value + decodedImage.width.toDouble(),
          image.yy.value,
        );
        final Offset dragStartCanvasPosition = visibleBoundingBox.center;
        const Offset deltaOnCanvas = Offset(7.0, -11.0);
        final Offset dragEndCanvasPosition =
            dragStartCanvasPosition + deltaOnCanvas;
        final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
          dragStartCanvasPosition,
        );
        final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
          dragEndCanvasPosition,
        );
        final double originalXX = image.xx.value;
        final double originalYY = image.yy.value;

        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );

        final THRasterXTherionImageInsertConfig movedImage =
            controller.th2File.imageByMPID(imageMPID)
                as THRasterXTherionImageInsertConfig;

        expect(movedImage, isA<THRasterXTherionImageInsertConfig>());
        expect(movedImage.xx.value, closeTo(originalXX + 7.0, 0.0001));
        expect(movedImage.yy.value, closeTo(originalYY - 11.0, 0.0001));
      },
    );

    test('image move drag exposes preview offset before commit', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final THXTherionImageInsertConfig image =
          controller.moveScaleRotateElementController.prepareImageMoveState(
                imageMPID,
              )
              as THXTherionImageInsertConfig;
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final Offset dragStartCanvasPosition = originalBoundingBox.center;
      const Offset deltaOnCanvas = Offset(-5.0, 9.0);
      final Offset dragEndCanvasPosition =
          dragStartCanvasPosition + deltaOnCanvas;
      final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
        dragStartCanvasPosition,
      );
      final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
        dragEndCanvasPosition,
      );

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragEndScreenPosition,
          delta: dragEndScreenPosition - dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );

      expect(
        controller.stateController.getImageOperationPreviewOffsetForImage(
          imageMPID,
        ),
        deltaOnCanvas,
      );
      expect(
        controller.stateController.getImageOperationOverlayLabelForImage(
          imageMPID,
        ),
        '',
      );
    });

    test('Alt drag moves image even when drag starts outside image', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final THXTherionImageInsertConfig image =
          controller.moveScaleRotateElementController.prepareImageMoveState(
                imageMPID,
              )
              as THXTherionImageInsertConfig;
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final Offset dragStartCanvasPosition =
          originalBoundingBox.center + const Offset(120.0, 90.0);
      const Offset deltaOnCanvas = Offset(14.0, -9.0);
      final Offset dragEndCanvasPosition =
          dragStartCanvasPosition + deltaOnCanvas;
      final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
        dragStartCanvasPosition,
      );
      final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
        dragEndCanvasPosition,
      );
      final double originalXX = image.xx.value;
      final double originalYY = image.yy.value;

      MPInteractionAux.debugPressedKeysOverride = {LogicalKeyboardKey.altLeft};

      try {
        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }

      final THXTherionImageInsertConfig movedImage =
          controller.th2File.imageByMPID(imageMPID)
              as THXTherionImageInsertConfig;

      expect(movedImage.xx.value, closeTo(originalXX + 14.0, 0.0001));
      expect(movedImage.yy.value, closeTo(originalYY - 9.0, 0.0001));
    });

    test('Ctrl drag constrains image move to one axis', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final THXTherionImageInsertConfig image =
          controller.moveScaleRotateElementController.prepareImageMoveState(
                imageMPID,
              )
              as THXTherionImageInsertConfig;
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final Offset dragStartCanvasPosition = originalBoundingBox.center;
      const Offset deltaOnCanvas = Offset(12.0, -8.0);
      final Offset dragEndCanvasPosition =
          dragStartCanvasPosition + deltaOnCanvas;
      final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
        dragStartCanvasPosition,
      );
      final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
        dragEndCanvasPosition,
      );
      final double originalXX = image.xx.value;
      final double originalYY = image.yy.value;

      MPInteractionAux.debugPressedKeysOverride = {
        LogicalKeyboardKey.controlLeft,
      };

      try {
        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }

      final THXTherionImageInsertConfig movedImage =
          controller.th2File.imageByMPID(imageMPID)
              as THXTherionImageInsertConfig;

      expect(movedImage.xx.value, closeTo(originalXX + 12.0, 0.0001));
      expect(movedImage.yy.value, closeTo(originalYY, 0.0001));
    });

    test('Shift drag disables snapping while moving image', () async {
      final TH2FileEditController controller = await loadController();
      controller.elementEditController.createScrap(thID: 'snap_test');
      controller.snapController.setSnapTargets(
        pointTarget: MPSnapPointTarget.none,
        linePointTarget: MPSnapLinePointTarget.none,
        xviTargets: <MPSnapXVIFileTarget>[MPSnapXVIFileTarget.shot],
      );

      final int imageMPID = controller.th2File.imageMPIDs.first;
      final THXVIXTherionImageInsertConfig image =
          controller.moveScaleRotateElementController.prepareImageMoveState(
                imageMPID,
              )
              as THXVIXTherionImageInsertConfig;
      final Rect originalBoundingBox = image.getBoundingBox(controller)!;
      final Offset originalTopLeft = originalBoundingBox.topLeft;
      final MPRuntimeXVIImageInsertConfigMixin xviImage = image.asXVIImage;
      final XVIFile xviFile = xviImage.getXVIFile(controller)!;
      final Offset imageOffset =
          Offset(xviImage.xviRootedXX, xviImage.xviRootedYY) -
          Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);
      final Offset snapTargetCanvas =
          xviFile.shots.first.start.coordinates + imageOffset;
      final Offset desiredUnsnappedTopLeft =
          snapTargetCanvas + const Offset(1.0, 1.0);
      final Offset dragStartCanvasPosition = originalBoundingBox.center;
      final Offset dragEndCanvasPosition =
          dragStartCanvasPosition + (desiredUnsnappedTopLeft - originalTopLeft);
      final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
        dragStartCanvasPosition,
      );
      final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
        dragEndCanvasPosition,
      );

      expect(
        controller.snapController
            .getCanvasSnapedPositionFromCanvasOffset(desiredUnsnappedTopLeft)
            ?.coordinates,
        snapTargetCanvas,
      );

      MPInteractionAux.debugPressedKeysOverride = {
        LogicalKeyboardKey.shiftLeft,
      };

      try {
        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );
      } finally {
        MPInteractionAux.debugPressedKeysOverride = null;
      }

      final THXTherionImageInsertConfig movedImage =
          controller.th2File.imageByMPID(imageMPID)
              as THXTherionImageInsertConfig;
      final Rect movedBoundingBox = movedImage.getBoundingBox(controller)!;

      expect(
        movedBoundingBox.topLeft.dx,
        closeTo(desiredUnsnappedTopLeft.dx, 0.0001),
      );
      expect(
        movedBoundingBox.topLeft.dy,
        closeTo(desiredUnsnappedTopLeft.dy, 0.0001),
      );
      expect(
        movedBoundingBox.topLeft.dx,
        isNot(closeTo(snapTargetCanvas.dx, 0.0001)),
      );
      expect(
        movedBoundingBox.topLeft.dy,
        isNot(closeTo(snapTargetCanvas.dy, 0.0001)),
      );
    });

    test(
      'image scale handle drag converts legacy raster image and is undoable',
      () async {
        final TH2FileEditController controller = await loadController(
          filename: '2026-04-07-003-mixed_image_insert_styles.th2',
        );
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final THRasterXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THRasterXTherionImageInsertConfig;
        final ui.Image decodedImage = await _createTestImage(
          width: 40,
          height: 20,
        );

        image.setRasterImage(decodedImage);

        final MPImageTransformGeometry geometry =
            MPImageTransformGeometry.forImage(
              th2FileEditController: controller,
              image: image,
            )!;
        final Offset dragStartScreenPosition = geometry
            .screenHandleRects[MPImageTransformHandleType.centerRight]!
            .center;
        final Offset dragStartCanvasPosition = geometry
            .canvasHandleCenters[MPImageTransformHandleType.centerRight]!;
        final Offset dragEndCanvasPosition =
            dragStartCanvasPosition + const Offset(20.0, 0.0);
        final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
          dragEndCanvasPosition,
        );

        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );

        final MPImageInsertConfig scaledImage =
            controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

        expect(scaledImage, isA<MPRasterImageInsertConfig>());
        expect(scaledImage.xScale.value, closeTo(1.5, 0.0001));
        expect(scaledImage.yScale.value, closeTo(1.0, 0.0001));
        expect(scaledImage.xx.value, closeTo(image.xx.value, 0.0001));

        controller.undo();

        final MPImageInsertConfig undoneScale =
            controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

        expect(undoneScale.xScale.value, closeTo(1.0, 0.0001));
        expect(undoneScale.yScale.value, closeTo(1.0, 0.0001));

        controller.undo();

        expect(
          controller.th2File.imageByMPID(imageMPID),
          isA<THRasterXTherionImageInsertConfig>(),
        );
      },
    );

    test(
      'image rotate handle drag converts legacy image and is undoable',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final Rect originalBoundingBox = image.getBoundingBox(controller)!;
        final Offset clickScreenPosition = controller.offsetCanvasToScreen(
          originalBoundingBox.center,
        );

        await controller.stateController.onPrimaryButtonClick(
          PointerUpEvent(position: clickScreenPosition),
        );

        final MPImageInsertConfig rotatedImage =
            controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;
        final MPImageRotationGeometry geometry =
            MPImageRotationGeometry.forImage(
              th2FileEditController: controller,
              image: rotatedImage,
            )!;
        final Offset dragStartScreenPosition = geometry
            .screenHandleRects[MPImageRotationHandleType.topRight]!
            .center;
        final Offset dragEndScreenPosition =
            dragStartScreenPosition + const Offset(0.0, 40.0);

        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );

        final MPImageInsertConfig committedImage =
            controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

        expect(committedImage.rotationDeg.value.abs(), greaterThan(1.0));

        controller.undo();

        final MPImageInsertConfig undoneRotation =
            controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

        expect(undoneRotation.rotationDeg.value, closeTo(0.0, 0.0001));

        controller.undo();

        expect(
          controller.th2File.imageByMPID(imageMPID),
          isA<THXVIXTherionImageInsertConfig>(),
        );
      },
    );

    test('image rotation pivot drag is undoable', () async {
      final TH2FileEditController controller = await loadController(
        filename: '2026-04-07-003-mixed_image_insert_styles.th2',
      );
      final int imageMPID = controller.th2File.imageMPIDs[2];
      final MPRasterImageInsertConfig image =
          controller.th2File.imageByMPID(imageMPID)
              as MPRasterImageInsertConfig;
      final ui.Image decodedImage = await _createTestImage(
        width: 40,
        height: 20,
      );

      image.setRasterImage(decodedImage);
      controller.moveScaleRotateElementController.prepareImageRotateState(
        imageMPID,
      );

      final MPRasterImageInsertConfig startImage =
          controller.th2File.imageByMPID(imageMPID)
              as MPRasterImageInsertConfig;
      expect(startImage.pivotSet, isFalse);
      final MPImageRotationGeometry geometry = MPImageRotationGeometry.forImage(
        th2FileEditController: controller,
        image: startImage,
      )!;
      final Offset dragStartScreenPosition = geometry.screenPivotCenter;
      final Offset dragEndScreenPosition =
          dragStartScreenPosition + const Offset(16.0, -12.0);

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragEndScreenPosition,
          delta: dragEndScreenPosition - dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(position: dragEndScreenPosition),
      );

      final MPRasterImageInsertConfig movedPivotImage =
          controller.th2File.imageByMPID(imageMPID)
              as MPRasterImageInsertConfig;

      expect(movedPivotImage.pivotSet, isTrue);

      expect(
        movedPivotImage.rotationCenterDx.value,
        isNot(closeTo(startImage.rotationCenterDx.value, 0.0001)),
      );
      expect(
        movedPivotImage.rotationCenterDy.value,
        isNot(closeTo(startImage.rotationCenterDy.value, 0.0001)),
      );

      controller.undo();

      final MPRasterImageInsertConfig undonePivot =
          controller.th2File.imageByMPID(imageMPID)
              as MPRasterImageInsertConfig;

      expect(undonePivot.pivotSet, isFalse);

      expect(
        undonePivot.rotationCenterDx.value,
        closeTo(startImage.rotationCenterDx.value, 0.0001),
      );
      expect(
        undonePivot.rotationCenterDy.value,
        closeTo(startImage.rotationCenterDy.value, 0.0001),
      );
    });

    test('xvi image with xviRoot keeps pivot fixed on drag attempt', () async {
      final TH2FileEditController controller = await loadController(
        filename: '2026-04-07-003-mixed_image_insert_styles.th2',
      );
      final int imageMPID = controller.th2File.imageMPIDs[1];
      final MPXVIImageInsertConfig image =
          controller.th2File.imageByMPID(imageMPID) as MPXVIImageInsertConfig;
      final XVIFileParser parser = XVIFileParser();
      final (XVIFile? xviFile, bool isSuccessful, List<String> errors) = parser
          .parse(THTestAux.testPath('xvi/2025-07-09-002-xvi-xvistations.xvi'));

      expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
      expect(xviFile, isNotNull);

      image.setXVIFile(xviFile);
      image.xviRoot = 'A1';
      controller.moveScaleRotateElementController.prepareImageRotateState(
        imageMPID,
      );

      final MPXVIImageInsertConfig startImage =
          controller.th2File.imageByMPID(imageMPID) as MPXVIImageInsertConfig;
      expect(startImage.pivotSet, isTrue);
      final MPImageRotationGeometry geometry = MPImageRotationGeometry.forImage(
        th2FileEditController: controller,
        image: startImage,
      )!;
      final Offset dragStartScreenPosition = geometry.screenPivotCenter;
      final Offset dragEndScreenPosition =
          dragStartScreenPosition + const Offset(20.0, 10.0);

      controller.stateController.onPrimaryButtonPointerDown(
        PointerDownEvent(
          position: dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragUpdate(
        PointerMoveEvent(
          position: dragEndScreenPosition,
          delta: dragEndScreenPosition - dragStartScreenPosition,
          buttons: kPrimaryButton,
        ),
      );
      controller.stateController.onPrimaryButtonDragEnd(
        PointerUpEvent(position: dragEndScreenPosition),
      );

      final MPXVIImageInsertConfig unchangedImage =
          controller.th2File.imageByMPID(imageMPID) as MPXVIImageInsertConfig;

      expect(
        unchangedImage.rotationCenterDx.value,
        closeTo(startImage.rotationCenterDx.value, 0.0001),
      );
      expect(
        unchangedImage.rotationCenterDy.value,
        closeTo(startImage.rotationCenterDy.value, 0.0001),
      );
    });

    test(
      'image move keeps top-level image order in saved TH2 output',
      () async {
        final TH2FileEditController controller = await loadController(
          filename: 'th_file_parser-00040-adding_several_xtherionsettings.th2',
        );
        final TH2FileWriter writer = TH2FileWriter();
        final int imageMPID = controller.th2File.imageMPIDs.first;
        final THXTherionImageInsertConfig image =
            controller.moveScaleRotateElementController.prepareImageMoveState(
                  imageMPID,
                )
                as THXTherionImageInsertConfig;
        final Rect originalBoundingBox = image.getBoundingBox(controller)!;
        final Offset dragStartCanvasPosition = originalBoundingBox.center;
        const Offset deltaOnCanvas = Offset(3.0, -4.0);
        final Offset dragEndCanvasPosition =
            dragStartCanvasPosition + deltaOnCanvas;
        final Offset dragStartScreenPosition = controller.offsetCanvasToScreen(
          dragStartCanvasPosition,
        );
        final Offset dragEndScreenPosition = controller.offsetCanvasToScreen(
          dragEndCanvasPosition,
        );

        controller.stateController.onPrimaryButtonPointerDown(
          PointerDownEvent(
            position: dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragUpdate(
          PointerMoveEvent(
            position: dragEndScreenPosition,
            delta: dragEndScreenPosition - dragStartScreenPosition,
            buttons: kPrimaryButton,
          ),
        );
        controller.stateController.onPrimaryButtonDragEnd(
          PointerUpEvent(position: dragEndScreenPosition),
        );

        final String serialized = writer.serialize(
          controller.th2File,
          includeEmptyLines: true,
          useOriginalRepresentation: true,
        );
        final int firstImageIndex = serialized.indexOf(
          'croquis/croqui-006.jpg',
        );
        final int secondImageIndex = serialized.indexOf(
          'croquis/croqui-007.jpg',
        );

        expect(firstImageIndex, isNonNegative);
        expect(secondImageIndex, isNonNegative);
        expect(firstImageIndex, lessThan(secondImageIndex));
      },
    );
  });
}

Future<ui.Image> _createTestImage({
  required int width,
  required int height,
}) async {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  final Uint8List pixels = Uint8List(width * height * 4);

  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = 0xFF;
    pixels[i + 1] = 0x00;
    pixels[i + 2] = 0x00;
    pixels[i + 3] = 0xFF;
  }

  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );

  return completer.future;
}
