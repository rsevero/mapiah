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
