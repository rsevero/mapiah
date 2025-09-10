part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingEndControlPoints extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  final TH2FileEditSnapController snapController;
  THElement? _clickedElementAtPointerDown;
  bool _searchedForClickedElementAtPointerDown = false;

  MPTH2FileEditStateMovingEndControlPoints({
    required super.th2FileEditController,
  }) : snapController = th2FileEditController.snapController;

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
        .contains(nextStateType)) {
      if (!MPTH2FileEditStateSingleLineEdit.singleLineEditModes.contains(
        nextStateType,
      )) {
        selectionController.clearSelectedLineSegments();
      }
      return;
    } else {
      clearAllSelections();
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    final Offset canvasOffset = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final Offset snapedCanvasOffset = snapController
        .getCanvasSnapedOffsetFromCanvasOffset(canvasOffset);

    if (!_searchedForClickedElementAtPointerDown) {
      _searchedForClickedElementAtPointerDown = true;
      _clickedElementAtPointerDown = snapController
          .getNearerSelectedLineSegment(canvasOffset);
      if (_clickedElementAtPointerDown != null) {
        selectionController.setDragStartCoordinatesFromCanvasCoordinates(
          (_clickedElementAtPointerDown as THLineSegment).endPoint.coordinates,
        );
      }
    }

    selectionController.moveSelectedEndControlPointsToCanvasCoordinates(
      snapedCanvasOffset,
    );
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final MPSelectedLine mpSelectedLine =
        selectionController.mpSelectedElementsLogical.values.first
            as MPSelectedLine;
    final THLine selectedLine = mpSelectedLine.originalElementClone as THLine;
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        mpSelectedLine.originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMPIDs = selectionController
        .getSelectedLineLineSegmentsMPIDs();
    final List<int> selectedLineSegmentMPIDs = selectionController
        .selectedEndControlPoints
        .keys
        .toList();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final int referenceLineSegmentMPID = _clickedElementAtPointerDown!.mpID;
    final THPositionPart snapedPosition =
        snapController.getCanvasSnapedPositionFromScreenOffset(
          event.localPosition,
        ) ??
        THPositionPart(
          coordinates: th2FileEditController.offsetScreenToCanvas(
            event.localPosition,
          ),
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );

    for (final int selectedLineSegmentMPID in selectedLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] =
            (selectedLineSegmentMPID == referenceLineSegmentMPID)
            ? thFile
                  .lineSegmentByMPID(selectedLineSegmentMPID)
                  .copyWith(endPoint: snapedPosition)
            : thFile.lineSegmentByMPID(selectedLineSegmentMPID);
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }

      final int? nextLineSegmentMPID = selectionController
          .getNextLineSegmentMPID(
            selectedLineSegmentMPID,
            lineLineSegmentsMPIDs,
          );

      if ((nextLineSegmentMPID != null) &&
          !modifiedLineSegmentsMap.containsKey(nextLineSegmentMPID)) {
        final THLineSegment nextLineSegment = thFile.lineSegmentByMPID(
          nextLineSegmentMPID,
        );

        if (nextLineSegment is THBezierCurveLineSegment) {
          modifiedLineSegmentsMap[nextLineSegmentMPID] =
              (nextLineSegmentMPID == referenceLineSegmentMPID)
              ? nextLineSegment.copyWith(endPoint: snapedPosition)
              : nextLineSegment;
          originalLineSegmentsMap[nextLineSegmentMPID] =
              originalLineSegmentsMapClone[nextLineSegmentMPID]!;
        }
      }
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      modifiedLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editLine,
    );

    th2FileEditController.execute(lineEditCommand);
    selectionController.updateSelectedElementClone(selectedLine.mpID);
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.editSingleLine,
    );
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingEndControlPoints;
}
