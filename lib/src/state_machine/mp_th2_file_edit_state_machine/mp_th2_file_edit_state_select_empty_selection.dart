part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectEmptySelection extends MPTH2FileEditState
    with MPTH2FileEditStateGetObjectsInsideSelectionWindowMixin {
  MPTH2FileEditStateSelectEmptySelection({required super.th2FileEditStore});

  @override
  void setVisualMode() {
    th2FileEditStore.setVisualMode(TH2FileEditMode.select);
  }

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

    th2FileEditStore.setState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  /// Marks the start point of the pan.
  @override
  void onPanStart(DragStartDetails details) {
    th2FileEditStore.setPanStartCoordinates(details.localPosition);
  }

  /// Draws the selection window.
  @override
  void onPanUpdate(DragUpdateDetails details) {
    th2FileEditStore
        .setSelectionWindowScreenEndCoordinates(details.localPosition);
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Clear the selection window.
  /// 3. Is the list empty?
  /// 3.1. Yes. Do nothing;
  /// 3.2. No. Add objects from the list inside the selection window to the
  /// current selection. Change to
  /// [MPTH2FileEditStateType.selectNonEmptySelection];
  @override
  void onPanEnd(DragEndDetails details) {
    final List<THElement> elementsInsideSelectionWindow =
        _getObjectsInsideSelectionWindow(details.localPosition);

    th2FileEditStore.clearSelectionWindow();

    if (elementsInsideSelectionWindow.isNotEmpty) {
      th2FileEditStore.setSelectedElements(elementsInsideSelectionWindow);
      th2FileEditStore.setState(MPTH2FileEditStateType.selectNonEmptySelection);
    }
  }

  /// Change to [MPTH2FileEditStateType.pan].
  @override
  void onPanToolPressed() {
    th2FileEditStore.setState(MPTH2FileEditStateType.pan);
  }

  @override
  void onUndoPressed() {
    th2FileEditStore.undo();
  }

  @override
  void onRedoPressed() {
    th2FileEditStore.redo();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectEmptySelection;
}
