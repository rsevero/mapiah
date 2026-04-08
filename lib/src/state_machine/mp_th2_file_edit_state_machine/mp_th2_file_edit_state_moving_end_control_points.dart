// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingEndControlPoints extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateKeyDownMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateMoveModifiersMixin {
  MPTH2FileEditStateMovingEndControlPoints({
    required super.th2FileEditController,
  });

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    updateStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    th2FileEditController.setStatusBarMessage('');

    if (nextStateType != MPTH2FileEditStateType.selectionWindowZoom) {
      if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
          .contains(nextStateType)) {
        if (!MPTH2FileEditStateEditSingleLine.singleLineEditModes.contains(
          nextStateType,
        )) {
          selectionController.clearSelectedLineSegments();
        }
        return;
      } else {
        clearAllSelections();
      }
    }
  }

  @override
  void updateStatusBarMessage() {
    final int selectedEndControlPointsCount =
        selectionController.selectedEndControlPoints.length;

    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.mpMovingEndControlPointsStateBarMessage(
        selectedEndControlPointsCount,
      ),
    );
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    final Offset resolvedCanvasOffset = _resolvedMoveCanvasPosition(
      th2FileEditController.offsetScreenToCanvas(event.localPosition),
    );

    updateStatusBarMessage();

    th2FileEditController.moveScaleRotateElementController
        .moveSelectedEndControlPointsToCanvasCoordinates(resolvedCanvasOffset);
    th2FileEditController.setMovingMousePosition(resolvedCanvasOffset);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    updateStatusBarMessage();
    th2FileEditController.moveScaleRotateElementController
        .finalizeSelectedEndControlPointsMove();
    th2FileEditController.setMovingMousePosition(null);
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.editSingleLine,
    );
  }

  Offset _resolvedMoveCanvasPosition(Offset canvasOffset) {
    return resolveMoveCanvasOffset(
      canvasOffset: canvasOffset,
      dragStartCanvasCoordinates:
          selectionController.dragStartCanvasCoordinates,
    );
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingEndControlPoints;
}
