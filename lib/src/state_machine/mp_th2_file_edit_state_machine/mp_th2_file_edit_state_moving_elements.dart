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
  void onPrimaryButtonClick(PointerUpEvent event) {
    List<THElement> clickedElements =
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
        } else {
          th2FileEditController.setSelectionState();
        }

        return;
      } else {
        if (shiftPressed) {
          th2FileEditController.addSelectedElement(
            clickedElements.first,
            setState: true,
          );
        } else {
          th2FileEditController.setSelectedElements(
            [clickedElements.first],
            setState: true,
          );
        }

        return;
      }
    } else {
      if (!shiftPressed) {
        th2FileEditController.clearSelectedElements();
        th2FileEditController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }
  }

  /// 1. Moves all selected objects by the distance indicated by [event].
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController
        .moveSelectedElementsToScreenCoordinates(event.localPosition);
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [event].
  /// 2. Update cloned copies inside TH2FileEditController.selectedElements.
  /// 3. Trigger redraw of selected elements.
  /// 4. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final int selectedCount = th2FileEditController.selectedElements.length;
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
            th2FileEditController.dragStartCanvasCoordinates;
    late MPCommand moveCommand;

    if (selectedCount == 1) {
      final MPSelectedElement selected =
          th2FileEditController.selectedElements.values.first;
      final THElement selectedElement = selected.originalElementClone;

      switch (selected) {
        case MPSelectedPoint _:
          moveCommand = MPMovePointCommand.fromDelta(
            pointMapiahID: selectedElement.mapiahID,
            originalCoordinates:
                (selectedElement as THPoint).position.coordinates,
            deltaOnCanvas: panDeltaOnCanvas,
          );
          break;
        case MPSelectedLine _:
          moveCommand = MPMoveLineCommand.fromDelta(
            lineMapiahID: selectedElement.mapiahID,
            originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
            deltaOnCanvas: panDeltaOnCanvas,
          );
          break;
      }
    } else if (selectedCount > 1) {
      final List<MPMoveCommandOriginalParams>
          moveCommandOriginalParametersList = th2FileEditController
              .selectedElements.values
              .map<MPMoveCommandOriginalParams>((MPSelectedElement selected) {
        final THElement selectedElement = selected.originalElementClone;
        switch (selected) {
          case MPSelectedPoint _:
            return MPMoveCommandPointOriginalParams(
              mapiahID: selectedElement.mapiahID,
              coordinates: (selectedElement as THPoint).position.coordinates,
            );
          case MPSelectedLine _:
            return MPMoveCommandLineOriginalParams(
              mapiahID: selectedElement.mapiahID,
              lineSegmentsMap: selected.originalLineSegmentsMapClone,
            );
          default:
            throw UnimplementedError();
        }
      }).toList();

      moveCommand = MPMoveElementsCommand.fromDelta(
        moveCommandOriginalParametersList: moveCommandOriginalParametersList,
        deltaOnCanvas: panDeltaOnCanvas,
      );
    }

    th2FileEditController.execute(moveCommand);
    th2FileEditController.updateSelectedElementsClones();
    th2FileEditController.triggerSelectedElementsRedraw(setState: true);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.movingElements;
}
