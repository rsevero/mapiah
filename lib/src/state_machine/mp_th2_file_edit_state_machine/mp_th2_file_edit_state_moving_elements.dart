part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingElements extends MPTH2FileEditState
    with
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditStateMovingElements({required super.th2FileEditController});

  /// 1. Clicked on an object?
  /// 1.1. Yes. Was the object already selected?
  /// 1.1.1. Yes. Is Shift pressed?
  /// 1.1.1.1. Yes. Remove the object from the selection. Is the selection empty?
  /// 1.1.1.1.1. Yes. Change to [MPTH2FileEditStateType.selectEmptySelection];
  /// 1.1.1.1.2. No. Do nothing;
  /// 1.1.1.2. No. Do nothing.
  /// 1.1.2. No. Is Shift pressed?
  /// 1.1.2.1. Yes. Add object to the selection;
  /// 1.1.2.2. No. Replace current selection with the clicked object.
  /// 1.2. No. Is Shift pressed?
  /// 1.2.1. Yes. Do nothing;
  /// 1.2.2. No. Clear selection. Change to
  /// [MPTH2FileEditStateType.selectEmptySelection];
  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final List<THElement> clickedElements =
        (await selectionController.getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
          canBeMultiple: true,
          presentMultipleElementsClickedWidget: true,
        )).values.toList();
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearClickedElementsAtPointerDown();

    if (clickedElements.isNotEmpty) {
      bool clickedElementAlreadySelected = true;

      for (final clickedElement in clickedElements) {
        if (!selectionController.isElementSelected(clickedElement)) {
          clickedElementAlreadySelected = false;
          break;
        }
      }

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          selectionController.removeSelectedElements(clickedElements);
        }

        return Future.value();
      } else {
        if (shiftPressed) {
          selectionController.addSelectedElements(
            clickedElements,
            setState: true,
          );
        } else {
          selectionController.setSelectedElements(
            clickedElements,
            setState: true,
          );
        }

        return Future.value();
      }
    } else {
      if (!shiftPressed) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      }
    }

    return Future.value();
  }

  /// 1. Moves all selected objects by the distance indicated by [event].
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController.moveSelectedElementsToScreenCoordinates(
      event.localPosition,
    );
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [event].
  /// 2. Update cloned copies inside TH2FileEditController.selectedElements.
  /// 3. Trigger redraw of selected elements.
  /// 4. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final int selectedCount =
        selectionController.mpSelectedElementsLogical.length;
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
        selectionController.dragStartCanvasCoordinates;
    late MPCommand moveCommand;

    if (selectedCount == 0) {
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );
      return;
    } else if (selectedCount == 1) {
      final MPSelectedElement selected =
          selectionController.mpSelectedElementsLogical.values.first;
      final THElement selectedElement = selected.originalElementClone;

      switch (selected) {
        case MPSelectedPoint _:
          moveCommand = MPMovePointCommand.fromDeltaOnCanvas(
            pointMPID: selectedElement.mpID,
            originalPosition: (selectedElement as THPoint).position,
            deltaOnCanvas: panDeltaOnCanvas,
            decimalPositions: th2FileEditController.currentDecimalPositions,
          );
        case MPSelectedLine _:
          moveCommand = MPMoveLineCommand.fromDeltaOnCanvas(
            lineMPID: selectedElement.mpID,
            originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
            deltaOnCanvas: panDeltaOnCanvas,
            decimalPositions: th2FileEditController.currentDecimalPositions,
          );
        case MPSelectedArea _:
          moveCommand = MPMoveAreaCommand.fromDeltaOnCanvas(
            areaMPID: selectedElement.mpID,
            originalLines: selected.originalLines,
            deltaOnCanvas: panDeltaOnCanvas,
            decimalPositions: th2FileEditController.currentDecimalPositions,
          );
      }

      th2FileEditController.execute(moveCommand);
      selectionController.updateSelectedElementClone(selectedElement.mpID);
    } else if (selectedCount > 1) {
      moveCommand =
          MPMultipleElementsCommandFactory.moveElementsFromDeltaOnCanvas(
            deltaOnCanvas: panDeltaOnCanvas,
            mpSelectedElements:
                selectionController.mpSelectedElementsLogical.values,
            decimalPositions: th2FileEditController.currentDecimalPositions,
          );

      th2FileEditController.execute(moveCommand);
      selectionController.updateSelectedElementsClones();
    }

    th2FileEditController.triggerSelectedElementsRedraw(setState: true);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.movingElements;
}
