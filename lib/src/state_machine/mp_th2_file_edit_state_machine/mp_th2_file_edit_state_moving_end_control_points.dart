part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingEndControlPoints extends MPTH2FileEditState
    with
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingEndControlPoints(
      {required super.th2FileEditController});

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    Set<THElement> clickedElements =
        th2FileEditController.selectableElementsClicked(event.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      clickedElements = getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );
      final bool clickedElementAlreadySelected =
          th2FileEditController.isElementSelected(clickedElements.first);

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          th2FileEditController.removeSelectedElement(clickedElements.first);
        }
      } else {
        if (shiftPressed) {
          th2FileEditController.addSelectedElement(
            clickedElements.first,
            setState: true,
          );
        } else {
          th2FileEditController.setSelectedElements(
            {clickedElements.first},
            setState: true,
          );
        }
      }

      return;
    } else {
      if (!shiftPressed) {
        th2FileEditController.clearSelectedElements();
        th2FileEditController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController
        .moveSelectedElementsToScreenCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
            th2FileEditController.dragStartCanvasCoordinates;
    final MPSelectedLine selected =
        th2FileEditController.selectedElements.values.first as MPSelectedLine;
    final THElement selectedElement = selected.originalElementClone;
    final LinkedHashMap<int, THLineSegment> newLineSegmentsMap =
        th2FileEditController.getLineSegmentsMap(selectedElement as THLine);
    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMapiahID: selectedElement.mapiahID,
      originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
      modifiedLineSegmentsMap: newLineSegmentsMap,
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
      MPTH2FileEditStateType.movingEndControlPoints;
}
