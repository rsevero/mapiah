part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingSingleControlPoint extends MPTH2FileEditState
    with MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingSingleControlPoint(
      {required super.fileEditController});

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
    final Offset panDeltaOnCanvas =
        fileEditController.offsetScreenToCanvas(event.localPosition) -
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
            fileEditController.thFile.elementByMapiahID(
                selectedLineSegmentMapiahID) as THLineSegment;
        originalLineSegmentsMap[selectedLineSegmentMapiahID] =
            originalLineSegmentsMapClone[selectedLineSegmentMapiahID]!;
      }

      final int? nextLineSegmentMapiahID =
          selectionController.getNextLineSegmentMapiahID(
              selectedLineSegmentMapiahID, lineLineSegmentsMapiahIDs);

      if ((nextLineSegmentMapiahID != null) &&
          !modifiedLineSegmentsMap.containsKey(nextLineSegmentMapiahID)) {
        final THLineSegment nextLineSegment = fileEditController.thFile
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
      descriptionType: MPCommandDescriptionType.editBezierCurve,
    );

    fileEditController.execute(lineEditCommand);
    selectionController.clearSelectedControlPoint();
    selectionController.updateSelectedElementsClones();
    fileEditController.triggerEditLineRedraw();
    selectionController.setSelectionState();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingSingleControlPoint;
}
