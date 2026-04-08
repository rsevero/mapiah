// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveModifiersMixin on MPTH2FileEditState {
  bool get isMoveAxisConstraintEnabled {
    return MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed();
  }

  bool get isMoveSnappingDisabled {
    return MPInteractionAux.isShiftPressed();
  }

  double getArrowMoveBaseStepOnCanvas() {
    if (MPInteractionAux.isAltPressed()) {
      return th2FileEditController.scaleScreenToCanvas(1.0);
    }

    return mpLocator.mpSettingsController.getDoubleWithDefault(
      MPSettingID.TH2Edit_NudgeFactor,
    );
  }

  double getArrowMoveStepOnCanvas() {
    final double baseStep = getArrowMoveBaseStepOnCanvas();

    if (MPInteractionAux.isShiftPressed()) {
      return baseStep * 10.0;
    }

    return baseStep;
  }

  Offset? deltaOnCanvasForArrowKey(LogicalKeyboardKey logicalKey) {
    final double step = getArrowMoveStepOnCanvas();

    switch (logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        return Offset(-step, 0.0);
      case LogicalKeyboardKey.arrowRight:
        return Offset(step, 0.0);
      case LogicalKeyboardKey.arrowUp:
        return Offset(0.0, step);
      case LogicalKeyboardKey.arrowDown:
        return Offset(0.0, -step);
      default:
        return null;
    }
  }

  bool handleArrowMoveKey({
    required LogicalKeyboardKey logicalKey,
    required void Function(Offset deltaOnCanvas) onMove,
  }) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();

    if (isCtrlPressed || isMetaPressed) {
      return false;
    }

    final Offset? deltaOnCanvas = deltaOnCanvasForArrowKey(logicalKey);

    if (deltaOnCanvas == null) {
      return false;
    }

    if (deltaOnCanvas == Offset.zero) {
      return true;
    }

    onMove(deltaOnCanvas);

    return true;
  }

  Offset constrainCanvasOffsetToDominantAxis({
    required Offset canvasOffset,
    required Offset dragStartCanvasCoordinates,
  }) {
    final Offset dragDelta = canvasOffset - dragStartCanvasCoordinates;
    final Offset constrainedDelta = constrainCanvasDeltaToDominantAxis(
      dragDelta,
    );

    return dragStartCanvasCoordinates + constrainedDelta;
  }

  Offset constrainCanvasDeltaToDominantAxis(Offset dragDelta) {
    if (dragDelta.dx.abs() >= dragDelta.dy.abs()) {
      return Offset(dragDelta.dx, 0.0);
    }

    return Offset(0.0, dragDelta.dy);
  }

  Offset resolveMoveCanvasOffset({
    required Offset canvasOffset,
    required Offset dragStartCanvasCoordinates,
  }) {
    final Offset constrainedCanvasOffset = isMoveAxisConstraintEnabled
        ? constrainCanvasOffsetToDominantAxis(
            canvasOffset: canvasOffset,
            dragStartCanvasCoordinates: dragStartCanvasCoordinates,
          )
        : canvasOffset;

    if (isMoveSnappingDisabled) {
      return constrainedCanvasOffset;
    }

    return snapController.getCanvasSnapedOffsetFromCanvasOffset(
      constrainedCanvasOffset,
    );
  }

  THPositionPart resolveMoveCanvasPosition({
    required Offset canvasOffset,
    required int decimalPositions,
  }) {
    if (isMoveSnappingDisabled) {
      return THPositionPart(
        coordinates: canvasOffset,
        decimalPositions: decimalPositions,
      );
    }

    return snapController.getCanvasSnapedPositionFromCanvasOffset(
          canvasOffset,
        ) ??
        THPositionPart(
          coordinates: canvasOffset,
          decimalPositions: decimalPositions,
        );
  }
}
