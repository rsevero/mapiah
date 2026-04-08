// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingSingleControlPoint extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateKeyDownMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateMoveModifiersMixin {
  MPTH2FileEditStateMovingSingleControlPoint({
    required super.th2FileEditController,
  });

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    if (previousState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      th2FileEditController.moveScaleRotateElementController
          .updateControlPointSmoothInfo();
    }
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.mpMovingSingleControlPointStateBarMessage,
    );
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
      selectionController.clearSelectedEndControlPoints();
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    final MPSelectedEndControlPoint selectedControlPoint =
        selectionController.selectedEndControlPoints.values.first;
    final Offset canvasOffset = _resolvedControlPointCanvasPosition(
      screenPosition: event.localPosition,
      selectedControlPoint: selectedControlPoint,
    );

    th2FileEditController.moveScaleRotateElementController
        .moveSelectedControlPointToCanvasCoordinates(canvasOffset);
    th2FileEditController.setMovingMousePosition(canvasOffset);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    th2FileEditController.moveScaleRotateElementController
        .finalizeSelectedControlPointMove();
    th2FileEditController.setMovingMousePosition(null);
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.editSingleLine,
    );
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingSingleControlPoint;

  Offset _resolvedControlPointCanvasPosition({
    required Offset screenPosition,
    required MPSelectedEndControlPoint selectedControlPoint,
  }) {
    final Offset canvasOffset = th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );
    final Offset dragDelta =
        canvasOffset - selectionController.dragStartCanvasCoordinates;
    final Offset startControlPointPosition =
        _selectedControlPointCanvasPosition(selectedControlPoint);
    final Offset unconstrainedCanvasOffset =
        startControlPointPosition + dragDelta;
    return resolveMoveCanvasOffset(
      canvasOffset: unconstrainedCanvasOffset,
      dragStartCanvasCoordinates: startControlPointPosition,
    );
  }

  Offset _selectedControlPointCanvasPosition(
    MPSelectedEndControlPoint selectedControlPoint,
  ) {
    final THBezierCurveLineSegment lineSegment =
        selectedControlPoint.originalLineSegmentClone
            as THBezierCurveLineSegment;

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        return lineSegment.controlPoint1.coordinates;
      case MPEndControlPointType.controlPoint2:
        return lineSegment.controlPoint2.coordinates;
      default:
        throw Exception(
          'Unsupported selected control point type ${selectedControlPoint.type} in MPTH2FileEditStateMovingSingleControlPoint._selectedControlPointCanvasPosition().',
        );
    }
  }
}
