// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateElementRotate extends MPTH2FileEditState {
  Rect? _startBounds;
  MPSelectionHandleType? _rotationHandleType;
  Offset? _dragStartCanvasPosition;
  bool _ignoreNextClick = false;

  MPTH2FileEditStateElementRotate({required super.th2FileEditController});

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.elementRotate;

  @override
  void setCursor() {
    if (_rotationHandleType != null) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);

      return;
    }

    final MPSelectionHandleType? hoveredHandle = _hoveredCornerHandle(
      th2FileEditController.mousePosition,
    );

    if (hoveredHandle != null) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grab);

      return;
    }

    if (selectionController.selectedElementsBoundingBox.contains(
      th2FileEditController.offsetScreenToCanvas(
        th2FileEditController.mousePosition,
      ),
    )) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.click);

      return;
    }

    th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);
  }

  @override
  void updateStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageElementRotateStatusBarMessage,
    );
  }

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final MPSelectionHandleType? handleType = _hoveredCornerHandle(
      event.localPosition,
    );

    if (handleType == null) {
      return;
    }

    _startBounds = selectionController.selectedElementsBoundingBox;
    _rotationHandleType = handleType;
    _dragStartCanvasPosition = th2FileEditController
        .moveScaleRotateElementController
        .selectionHandlePointOnBounds(_startBounds!, handleType);
    _ignoreNextClick = true;
    setCursor();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    final Rect? startBounds = _startBounds;
    final MPSelectionHandleType? handleType = _rotationHandleType;
    final Offset? dragStartCanvasPosition = _dragStartCanvasPosition;

    if ((startBounds == null) ||
        (handleType == null) ||
        (dragStartCanvasPosition == null)) {
      return;
    }

    final Offset pivotCanvas = MPInteractionAux.isShiftPressed()
        ? th2FileEditController.moveScaleRotateElementController
              .selectionHandlePointOnBounds(
                startBounds,
                th2FileEditController.moveScaleRotateElementController
                    .oppositeSelectionHandleType(handleType),
              )
        : startBounds.center;
    final Offset currentCanvasPosition = th2FileEditController
        .offsetScreenToCanvas(event.localPosition);
    final double? angleDeltaInDeg = MPImageRotationPreviewMath.rotationDeltaDeg(
      pivotCanvas: pivotCanvas,
      dragStartCanvasPosition: dragStartCanvasPosition,
      currentCanvasPosition: currentCanvasPosition,
    );

    if (angleDeltaInDeg == null) {
      return;
    }

    double targetAngleInDeg = angleDeltaInDeg;

    if (MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed()) {
      final double snapAngle = mpLocator.mpSettingsController
          .getDoubleWithDefault(MPSettingID.TH2Edit_SnapAngle);

      targetAngleInDeg = MPImageRotationPreviewMath.snapRotationDeg(
        rotationDeg: targetAngleInDeg,
        snapAngleDeg: snapAngle,
      );
    }

    th2FileEditController.moveScaleRotateElementController
        .rotateSelectedElements(
          pivotCanvas: pivotCanvas,
          angleInDeg: targetAngleInDeg,
        );
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    if (_rotationHandleType == null) {
      return;
    }

    _resetPreview();
    th2FileEditController.moveScaleRotateElementController
        .finalizeSelectedElementsTransform();
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    if (_ignoreNextClick) {
      _ignoreNextClick = false;

      return Future.value();
    }

    final MPSelectionHandleType? handleType = _hoveredCornerHandle(
      event.localPosition,
    );

    if (handleType != null) {
      return Future.value();
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );

    if (!selectionController.selectedElementsBoundingBox.contains(
      canvasPosition,
    )) {
      return Future.value();
    }

    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );

    return Future.value();
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectNonEmptySelection,
        );
      case LogicalKeyboardKey.keyH:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          th2FileEditController.moveScaleRotateElementController
              .flipSelectedElementsHorizontally();
        }
      case LogicalKeyboardKey.keyV:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          th2FileEditController.moveScaleRotateElementController
              .flipSelectedElementsVertically();
        }
      default:
        return;
    }
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (_rotationHandleType != null) {
      th2FileEditController.moveScaleRotateElementController
          .restoreSelectedElementsFromClones(updateRedraw: false);
      _resetPreview();
    }

    th2FileEditController.setStatusBarMessage('');
  }

  MPSelectionHandleType? _hoveredCornerHandle(Offset screenPosition) {
    final MPSelectionHandleType? handleType = th2FileEditController
        .moveScaleRotateElementController
        .getSelectionHandleAtScreenPosition(screenPosition);

    switch (handleType) {
      case MPSelectionHandleType.topLeft:
      case MPSelectionHandleType.topRight:
      case MPSelectionHandleType.bottomLeft:
      case MPSelectionHandleType.bottomRight:
        return handleType;
      default:
        return null;
    }
  }

  void _resetPreview() {
    _startBounds = null;
    _rotationHandleType = null;
    _dragStartCanvasPosition = null;
    setCursor();
  }
}
