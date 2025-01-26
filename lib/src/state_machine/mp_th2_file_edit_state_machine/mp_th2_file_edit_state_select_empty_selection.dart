part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectEmptySelection extends MPTH2FileEditState
    with MPTH2FileEditStateGetObjectsInsideSelectionWindowMixin {
  MPTH2FileEditStateSelectEmptySelection({required super.th2FileEditStore});

  /// 1. Clicked on an object?
  /// 1.1. If yes, select object. Change to [MPTH2FileEditStateType.selectNonEmptySelection];
  /// 1.2. If no, do nothing.
  @override
  void onTapUp(TapUpDetails details) {
    final List<THElement> clickedElements =
        th2FileEditStore.selectableElementsClicked(details.localPosition);

    if (clickedElements.isNotEmpty) {
      th2FileEditStore.setSelectedElements(clickedElements);
    }

    th2FileEditStore
        .setNewState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  /// Marks the start point of the pan.
  @override
  void onPanStart(DragStartDetails details) {
    th2FileEditStore.setPanStartCoordinates(details.localPosition);
  }

  /// Draws the selection window.
  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// TODO: Draw the selection window.
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Reset the start point of the pan/selection window.
  /// 3. Is the list empty?
  /// 3.1. Yes. Do nothing;
  /// 3.2. No. Add objects from the list inside the selection window to the
  /// current selection. Change to
  /// [MPTH2FileEditStateType.selectNonEmptySelection];
  @override
  void onPanEnd(DragEndDetails details) {
    final List<THElement> elementsInsideSelectionWindow =
        _getObjectsInsideSelectionWindow(details.localPosition);

    th2FileEditStore.setPanStartCoordinates(Offset.zero);

    if (elementsInsideSelectionWindow.isNotEmpty) {
      th2FileEditStore.setSelectedElements(elementsInsideSelectionWindow);
      th2FileEditStore
          .setNewState(MPTH2FileEditStateType.selectNonEmptySelection);
    }
  }

  /// Change to [MPTH2FileEditStateType.pan].
  @override
  void onPanToolPressed() {
    th2FileEditStore.setNewState(MPTH2FileEditStateType.pan);
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectEmptySelection;
}
