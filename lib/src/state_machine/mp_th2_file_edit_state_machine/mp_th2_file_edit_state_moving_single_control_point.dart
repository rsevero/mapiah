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
        th2FileEditController.clearSelectedLineSegments();
      }
      return;
    } else {
      clearAllSelections();
    }
    th2FileEditController.clearSelectedControlPoint();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController
        .moveSelectedControlPointToScreenCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
            th2FileEditController.dragStartCanvasCoordinates;
    final MPSelectedLine selected =
        th2FileEditController.selectedElements.values.first as MPSelectedLine;
    final THLine selectedLine = selected.originalElementClone as THLine;
    final List<int> lineLineSegmentsMapiahIDs =
        th2FileEditController.getSelectedLineLineSegmentsMapiahIDs();
    final List<int> selectedLineSegmentMapiahIDs =
        th2FileEditController.selectedLineSegments.keys.toList();
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
          th2FileEditController.getNextLineSegmentMapiahID(
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
    th2FileEditController.updateSelectedElementsClones();
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.setSelectionState();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingSingleControlPoint;
}
