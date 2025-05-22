part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingSingleControlPoint extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingSingleControlPoint(
      {required super.th2FileEditController});

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
        .contains(nextStateType)) {
      if (!MPTH2FileEditStateEditSingleLine.singleLineEditModes
          .contains(nextStateType)) {
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
    selectionController
        .moveSelectedControlPointToScreenCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final MPSelectedLine selected = selectionController
        .mpSelectedElementsLogical.values.first as MPSelectedLine;
    final THLine selectedLine = selected.originalElementClone as THLine;
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        selected.originalLineSegmentsMapClone;
    // final List<int> lineLineSegmentsMPIDs =
    //     originalLineSegmentsMapClone.keys.toList();
    final Iterable<int> selectedControlPointLineSegmentMPIDs =
        selectionController.selectedEndControlPoints.keys;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMPID
        in selectedControlPointLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] =
            thFile.lineSegmentByMPID(selectedLineSegmentMPID);
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }

      // final int? nextLineSegmentMPID =
      //     selectionController.getNextLineSegmentMPID(
      //         selectedLineSegmentMPID, lineLineSegmentsMPIDs);

      // if ((nextLineSegmentMPID != null) &&
      //     !modifiedLineSegmentsMap.containsKey(nextLineSegmentMPID)) {
      //   final THLineSegment nextLineSegment =
      //       thFile.lineSegmentByMPID(nextLineSegmentMPID);

      //   if (nextLineSegment is THBezierCurveLineSegment) {
      //     modifiedLineSegmentsMap[nextLineSegmentMPID] = nextLineSegment;
      //     originalLineSegmentsMap[nextLineSegmentMPID] =
      //         originalLineSegmentsMapClone[nextLineSegmentMPID]!;
      //   }
      // }
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      modifiedLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editBezierCurve,
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
      MPTH2FileEditStateType.movingSingleControlPoint;
}
