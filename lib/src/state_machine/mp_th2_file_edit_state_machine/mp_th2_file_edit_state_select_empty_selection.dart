part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectEmptySelection extends MPTH2FileEditState {
  MPTH2FileEditStateSelectEmptySelection({required super.thFileEditStore});

  /// 1. Clicked on an object?
  /// 1.1. If yes, select object. Change to [MPTH2FileEditStateType.selectNonEmptySelection];
  /// 1.2. If no, do nothing.
  @override
  void onTapUp(TapUpDetails details) {
    final List<THElement> clickedElements =
        thFileEditStore.selectableElementsClicked(details.localPosition);

    if (clickedElements.isNotEmpty) {
      thFileEditStore.setSelectedElements(clickedElements);
    }

    thFileEditStore.setNewState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  /// Marks the start point of the pan.
  @override
  void onPanStart(DragStartDetails details) {
    thFileEditStore.setPanStartCoordinates(details.localPosition);
  }

  /// Draws the selection window.
  @override
  void onPanUpdate(DragUpdateDetails details) {
    /// TODO: Draw the selection window.
  }

  /// 1. Create a list of objects inside the selection window. Is the list empty?
  /// 1.1. Yes. Do nothing;
  /// 1.2. No. Add objects from the list inside the selection window to the current selection. Change to [MPTH2FileEditStateType.selectNonEmptySelection];
  /// 2. Reset the start point of the pan.
  @override
  void onPanEnd(DragEndDetails details) {}

  /// Change to [MPTH2FileEditStateType.pan].
  @override
  void onPanToolPressed() {
    /// Muda para [MPTH2FileEditStateType.pan];
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectEmptySelection;
}
