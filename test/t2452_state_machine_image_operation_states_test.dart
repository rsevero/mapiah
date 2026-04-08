// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
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
