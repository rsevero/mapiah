part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin {
  MPTH2FileEditPageStateEditSingleLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.updateSelectableEndAndControlPoints();
  }

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
          th2FileEditController.getIsSelected(clickedElements.first);

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          th2FileEditController.removeSelectedElement(clickedElements.first);
          if (th2FileEditController.selectedElements.isEmpty) {
            th2FileEditController
                .setState(MPTH2FileEditStateType.selectEmptySelection);
          }
        }
        return;
      } else {
        if (shiftPressed) {
          th2FileEditController.addSelectedElement(clickedElements.first);
          th2FileEditController
              .setState(MPTH2FileEditStateType.selectNonEmptySelection);
          return;
        } else {
          th2FileEditController.setSelectedElements([clickedElements.first]);
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
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
