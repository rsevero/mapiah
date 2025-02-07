part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMoving extends MPTH2FileEditState
    with MPTH2FileEditStateGetSelectedElementsMixin {
  MPTH2FileEditStateMoving({required super.th2FileEditStore});

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
        th2FileEditStore.selectableElementsClicked(event.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      clickedElements = getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );
      final bool clickedElementAlreadySelected =
          th2FileEditStore.getIsSelected(clickedElements.first);

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          th2FileEditStore.removeSelectedElement(clickedElements.first);
          if (th2FileEditStore.selectedElements.isEmpty) {
            th2FileEditStore
                .setState(MPTH2FileEditStateType.selectEmptySelection);
          } else {
            th2FileEditStore
                .setState(MPTH2FileEditStateType.selectNonEmptySelection);
          }
        } else {
          th2FileEditStore
              .setState(MPTH2FileEditStateType.selectNonEmptySelection);
        }
        return;
      } else {
        if (shiftPressed) {
          th2FileEditStore.addSelectedElement(clickedElements.first);
          th2FileEditStore
              .setState(MPTH2FileEditStateType.selectNonEmptySelection);
          return;
        } else {
          th2FileEditStore.setSelectedElements([clickedElements.first]);
          th2FileEditStore
              .setState(MPTH2FileEditStateType.selectNonEmptySelection);
          return;
        }
      }
    } else {
      if (!shiftPressed) {
        th2FileEditStore.clearSelectedElements();
        th2FileEditStore.setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }
  }

  /// 1. Moves all selected objects by the distance indicated by [event].
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditStore
        .moveSelectedElementsToScreenCoordinates(event.localPosition);
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [event].
  /// 2. Update cloned copies inside TH2FileEditStore.selectedElements.
  /// 3. Trigger redraw of selected elements.
  /// 4. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final int selectedCount = th2FileEditStore.selectedElements.length;
    final Offset panDeltaOnCanvas =
        th2FileEditStore.offsetScreenToCanvas(event.localPosition) -
            th2FileEditStore.dragStartCanvasCoordinates;
    late MPCommand moveCommand;

    if (selectedCount == 1) {
      final MPSelectedElement selected =
          th2FileEditStore.selectedElements.values.first;
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
          moveCommandOriginalParametersList = th2FileEditStore
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
    th2FileEditStore.execute(moveCommand);

    th2FileEditStore.updateSelectedElementsClones();

    th2FileEditStore.triggerSelectedElementsRedraw();

    th2FileEditStore.setState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.moving;
}
