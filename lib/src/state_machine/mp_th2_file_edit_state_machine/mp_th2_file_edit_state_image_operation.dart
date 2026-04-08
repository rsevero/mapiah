// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

abstract class MPTH2FileEditStateImageOperation extends MPTH2FileEditState {
  final int imageMPID;

  MPTH2FileEditStateImageOperation({
    required super.th2FileEditController,
    required this.imageMPID,
  });

  String get statusBarMessage;

  String get overlayLabel;

  Offset get previewOffset => Offset.zero;

  MPRuntimeImageInsertConfigMixin? get renderedImageConfig => null;

  MPRuntimeImageInsertConfigMixin get imageConfig =>
      th2File.imageByMPID(imageMPID);

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    updateStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void updateStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(statusBarMessage);
  }

  @override
  bool get keepOverlayOpenOnCanvasClick => true;

  @override
  bool shouldKeepOverlayOpenOnCanvasPointerUp(
    PointerUpEvent event, {
    required bool wasDragging,
  }) {
    if (wasDragging) {
      return true;
    }

    final MPImageTransformGeometry? geometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if (geometry == null) {
      return false;
    }

    if (geometry.hitTestHandle(event.localPosition) != null) {
      return true;
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );

    return geometry.containsCanvasPosition(canvasPosition);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    if (isAltPressed || isCtrlPressed || isMetaPressed || isShiftPressed) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      }

      return;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      case LogicalKeyboardKey.keyH:
        th2FileEditController.stateController.onButtonPressed(
          MPButtonType.flipImageHorizontally,
        );
      case LogicalKeyboardKey.keyV:
        th2FileEditController.stateController.onButtonPressed(
          MPButtonType.flipImageVertically,
        );
    }
  }
}
