// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
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

  group('state machine image operation preparation', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    Future<TH2FileEditController> loadController() async {
      final TH2FileParser parser = TH2FileParser();
      final String path = THTestAux.testPath('2025-10-26-001-with_image.th2');
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
      'prepareImageMoveState enters image move state with Mapiah image',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        final MPImageInsertConfig image = controller.elementEditController
            .prepareImageMoveState(imageMPID);

        expect(image.mpID, imageMPID);
        expect(controller.th2File.imageByMPID(imageMPID), same(image));
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageMove,
        );
        expect(controller.stateController.imageOperationImageMPID, imageMPID);
      },
    );

    test(
      'prepareImageRotateState switches image state context without replacing image again',
      () async {
        final TH2FileEditController controller = await loadController();
        final int imageMPID = controller.th2File.imageMPIDs.first;

        final MPImageInsertConfig movedImage = controller.elementEditController
            .prepareImageMoveState(imageMPID);
        final MPImageInsertConfig rotatedImage = controller
            .elementEditController
            .prepareImageRotateState(imageMPID);

        expect(rotatedImage, same(movedImage));
        expect(
          controller.stateController.state.type,
          MPTH2FileEditStateType.imageRotate,
        );
        expect(controller.stateController.imageOperationImageMPID, imageMPID);
      },
    );

    test('prepareImageScaleState enters image scale state', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;

      controller.elementEditController.prepareImageScaleState(imageMPID);

      expect(
        controller.stateController.state.type,
        MPTH2FileEditStateType.imageScale,
      );
      expect(controller.stateController.imageOperationImageMPID, imageMPID);
      expect(
        controller.th2File.imageByMPID(imageMPID),
        isA<MPImageInsertConfig>(),
      );
    });

    test('image move drag updates image position and is undoable', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final MPImageInsertConfig image = controller.elementEditController
          .prepareImageMoveState(imageMPID);
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

      final MPImageInsertConfig movedImage =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(movedImage.xx.value, closeTo(originalXX + 12.0, 0.0001));
      expect(movedImage.yy.value, closeTo(originalYY - 8.0, 0.0001));

      controller.undo();

      final MPImageInsertConfig undoneImage =
          controller.th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

      expect(undoneImage.xx.value, originalXX);
      expect(undoneImage.yy.value, originalYY);
    });

    test('image move drag exposes preview offset before commit', () async {
      final TH2FileEditController controller = await loadController();
      final int imageMPID = controller.th2File.imageMPIDs.first;
      final MPImageInsertConfig image = controller.elementEditController
          .prepareImageMoveState(imageMPID);
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
        mpLocator.appLocalizations.th2FileEditPageImageMoveOverlayLabel,
      );
    });
  });
}
