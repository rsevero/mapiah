part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingSingleControlPoint extends MPTH2FileEditState
    with MPTH2FileEditStateClearSelectionOnExitMixin {
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
    selectionController.clearSelectedControlPoint();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController
        .moveSelectedControlPointToScreenCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final MPSelectedLine selected =
        selectionController.selectedElements.values.first as MPSelectedLine;
    final THLine selectedLine = selected.originalElementClone as THLine;
    final List<int> lineLineSegmentsMPIDs =
        selectionController.getSelectedLineLineSegmentsMPIDs();
    final List<int> selectedLineSegmentMPIDs =
        selectionController.selectedLineSegments.keys.toList();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        selected.originalLineSegmentsMapClone;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMPID in selectedLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] =
            th2FileEditController.thFile.elementByMPID(selectedLineSegmentMPID)
                as THLineSegment;
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }

      final int? nextLineSegmentMPID =
          selectionController.getNextLineSegmentMPID(
              selectedLineSegmentMPID, lineLineSegmentsMPIDs);

      if ((nextLineSegmentMPID != null) &&
          !modifiedLineSegmentsMap.containsKey(nextLineSegmentMPID)) {
        final THLineSegment nextLineSegment = th2FileEditController.thFile
            .elementByMPID(nextLineSegmentMPID) as THLineSegment;

        if (nextLineSegment is THBezierCurveLineSegment) {
          modifiedLineSegmentsMap[nextLineSegmentMPID] = nextLineSegment;
          originalLineSegmentsMap[nextLineSegmentMPID] =
              originalLineSegmentsMapClone[nextLineSegmentMPID]!;
        }
      }
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      modifiedLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editBezierCurve,
    );

    th2FileEditController.execute(lineEditCommand);
    selectionController.clearSelectedControlPoint();
    selectionController.updateSelectedElementsClones();
    th2FileEditController.triggerEditLineRedraw();
    selectionController.setSelectionState();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingSingleControlPoint;
}
