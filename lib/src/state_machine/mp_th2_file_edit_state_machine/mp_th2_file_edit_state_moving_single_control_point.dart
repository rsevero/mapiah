part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingSingleControlPoint extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingSingleControlPoint({
    required super.th2FileEditController,
  });

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.elementEditController.updateControlPointSmoothInfo();
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.mpMovingSingleControlPointStateBarMessage,
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    th2FileEditController.setStatusBarMessage('');

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

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController.moveSelectedControlPointToScreenCoordinates(
      event.localPosition,
    );
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final MPSelectedLine mpSelectedLine = selectionController
        .getMPSelectedLine();
    final THLine selectedLine = selectionController.getSelectedLine();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        mpSelectedLine.originalLineSegmentsMapClone;
    final Iterable<int> selectedControlPointLineSegmentMPIDs =
        selectionController.selectedEndControlPoints.keys;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMPID
        in selectedControlPointLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] = thFile
            .lineSegmentByMPID(selectedLineSegmentMPID);
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }
    }

    final MPMoveControlPointSmoothInfo moveControlPointSmoothInfo =
        elementEditController.moveControlPointSmoothInfo;

    if (moveControlPointSmoothInfo.shouldSmooth &&
        !moveControlPointSmoothInfo.isAdjacentStraight!) {
      final int smoothedLineSegmentMPID =
          moveControlPointSmoothInfo.adjacentLineSegment!.mpID;

      modifiedLineSegmentsMap[smoothedLineSegmentMPID] = thFile
          .lineSegmentByMPID(smoothedLineSegmentMPID);
      originalLineSegmentsMap[smoothedLineSegmentMPID] =
          originalLineSegmentsMapClone[smoothedLineSegmentMPID]!;
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      fromLineSegmentsMap: originalLineSegmentsMap,
      toLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editBezierCurve,
    );

    th2FileEditController.execute(lineEditCommand);
    elementEditController.updateControllersAfterLineSegmentChangesPerLine();
    elementEditController.updateControllersAfterElementChanges();
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.editSingleLine,
    );
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingSingleControlPoint;
}
