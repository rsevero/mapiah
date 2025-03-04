part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingEndControlPoints extends MPTH2FileEditState
    with MPTH2FileEditStateGetSelectedElementsMixin {
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
          if (th2FileEditController.selectedElements.isEmpty) {
            th2FileEditController
                .setState(MPTH2FileEditStateType.selectEmptySelection);
          } else {
            th2FileEditController.setNonEmptySelectionState();
          }
        } else {
          th2FileEditController.setNonEmptySelectionState();
        }
        return;
      } else {
        if (shiftPressed) {
          th2FileEditController.addSelectedElement(clickedElements.first);
          th2FileEditController.setNonEmptySelectionState();
          return;
        } else {
          th2FileEditController.setSelectedElements({clickedElements.first});
          th2FileEditController.setNonEmptySelectionState();
          return;
        }
      }
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

    th2FileEditController.triggerSelectedElementsRedraw();

    th2FileEditController.setNonEmptySelectionState();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.movingEndControlPoints;
}
