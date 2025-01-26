part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectNonEmptySelection extends MPTH2FileEditState
    with MPTH2FileEditStateGetObjectsInsideSelectionWindowMixin {
  MPTH2FileEditStateSelectNonEmptySelection({required super.th2FileEditStore});

  @override
  void setVisualMode() {
    th2FileEditStore.setVisualMode(TH2FileEditMode.select);
  }

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
  void onTapUp(TapUpDetails details) {
    final List<THElement> clickedElements =
        th2FileEditStore.selectableElementsClicked(details.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      final bool clickedElementAlreadySelected =
          th2FileEditStore.isSelected(clickedElements.first);

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          th2FileEditStore.removeSelectedElement(clickedElements.first);
          if (th2FileEditStore.selectedElements.isEmpty) {
            th2FileEditStore
                .setState(MPTH2FileEditStateType.selectEmptySelection);
          }
        }
        return;
      } else {
        if (shiftPressed) {
          th2FileEditStore.addSelectedElement(clickedElements.first);
          return;
        } else {
          th2FileEditStore.setSelectedElements([clickedElements.first]);
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

  /// 1. Mark the start point of the pan.
  /// 2. Did the pan start click on an object?
  /// 2.1. Yes. Is Shift pressed?
  /// 2.1.1. Yes. Do nothing.
  /// 2.1.2. No. Was the object already selected?
  /// 2.1.2.1. Yes. Change to [MPTH2FileEditStateType.moving];
  /// 2.1.2.2. No. Clear current selection; include clicked object in the
  /// selection. Change to [MPTH2FileEditStateType.moving];
  /// 2.2. No. Do nothing.
  @override
  void onPanStart(DragStartDetails details) {
    th2FileEditStore.setPanStartCoordinates(details.localPosition);
    final List<THElement> clickedElements =
        th2FileEditStore.selectableElementsClicked(details.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      if (!shiftPressed) {
        final bool clickedElementAlreadySelected =
            th2FileEditStore.isSelected(clickedElements.first);
        if (clickedElementAlreadySelected) {
          th2FileEditStore.setState(MPTH2FileEditStateType.moving);
        } else {
          th2FileEditStore.setSelectedElements([clickedElements.first]);
        }
      }
    }
  }

  /// Draw the selection window.
  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// TODO: Draw the selection window.
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Reset the start point of the pan/selection window.
  /// 3. Is Shift pressed?
  /// 3.1. Yes. Include objects not yet selected in the selection;
  /// 3.2. No. Clear current selection. Is the list of objects inside the
  /// selection window empty?
  /// 3.2.1. Yes. Change to [MPTH2FileEditStateType.selectEmptySelection];
  /// 3.2.2. No. Include objects from the list inside the selection window in
  /// the current selection.

  @override
  void onPanEnd(DragEndDetails details) {
    final List<THElement> elementsInsideSelectionWindow =
        _getObjectsInsideSelectionWindow(details.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    th2FileEditStore.setPanStartCoordinates(Offset.zero);

    if (shiftPressed) {
      th2FileEditStore.addSelectedElements(elementsInsideSelectionWindow);
    } else {
      th2FileEditStore.clearSelectedElements();
      if (elementsInsideSelectionWindow.isEmpty) {
        th2FileEditStore.setState(MPTH2FileEditStateType.selectEmptySelection);
      } else {
        th2FileEditStore.setSelectedElements(elementsInsideSelectionWindow);
      }
    }
  }

  /// 1. Clear selection.
  /// 2. Change to [MPTH2FileEditStateType.pan].
  @override
  void onPanToolPressed() {
    th2FileEditStore.clearSelectedElements();
    th2FileEditStore.setState(MPTH2FileEditStateType.pan);
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectNonEmptySelection;
}
