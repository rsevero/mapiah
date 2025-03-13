part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingEndControlPoints extends MPTH2FileEditState
    with MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingEndControlPoints(
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
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController
        .moveSelectedEndControlPointsToScreenCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
            selectionController.dragStartCanvasCoordinates;
    final MPSelectedLine selected =
        selectionController.selectedElements.values.first as MPSelectedLine;
    final THLine selectedLine = selected.originalElementClone as THLine;
    final List<int> lineLineSegmentsMapiahIDs =
        selectionController.getSelectedLineLineSegmentsMapiahIDs();
    final List<int> selectedLineSegmentMapiahIDs =
        selectionController.selectedLineSegments.keys.toList();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        selected.originalLineSegmentsMapClone;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMapiahID
        in selectedLineSegmentMapiahIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMapiahID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMapiahID] =
            th2FileEditController.thFile
                    .elementByMapiahID(selectedLineSegmentMapiahID)
                as THLineSegment;
        originalLineSegmentsMap[selectedLineSegmentMapiahID] =
            originalLineSegmentsMapClone[selectedLineSegmentMapiahID]!;
      }

      final int? nextLineSegmentMapiahID =
          selectionController.getNextLineSegmentMapiahID(
              selectedLineSegmentMapiahID, lineLineSegmentsMapiahIDs);

      if ((nextLineSegmentMapiahID != null) &&
          !modifiedLineSegmentsMap.containsKey(nextLineSegmentMapiahID)) {
        final THLineSegment nextLineSegment = th2FileEditController.thFile
            .elementByMapiahID(nextLineSegmentMapiahID) as THLineSegment;

        if (nextLineSegment is THBezierCurveLineSegment) {
          modifiedLineSegmentsMap[nextLineSegmentMapiahID] = nextLineSegment;
          originalLineSegmentsMap[nextLineSegmentMapiahID] =
              originalLineSegmentsMapClone[nextLineSegmentMapiahID]!;
        }
      }
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMapiahID: selectedLine.mapiahID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      modifiedLineSegmentsMap: modifiedLineSegmentsMap,
      deltaOnCanvas: panDeltaOnCanvas,
      descriptionType: MPCommandDescriptionType.editLine,
    );

    th2FileEditController.execute(lineEditCommand);
    selectionController.updateSelectedElementsClones();
    th2FileEditController.triggerEditLineRedraw();
    selectionController.setSelectionState();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingEndControlPoints;
}
