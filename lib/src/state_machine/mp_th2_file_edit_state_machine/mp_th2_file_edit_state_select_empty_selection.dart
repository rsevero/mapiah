part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectEmptySelection extends MPTH2FileEditState
    with
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateSelectEmptySelection(
      {required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.clearSelectedElements();
  }

  /// 1. Clicked on an object?
  /// 1.1. If yes, select object. Change to [MPTH2FileEditStateType.selectNonEmptySelection];
  /// 1.2. If no, do nothing.
  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final List<THElement> clickedElements =
        th2FileEditController.selectableElementsClicked(event.localPosition);

    if (clickedElements.isNotEmpty) {
      th2FileEditController.setSelectedElements(
        getSelectedElementsWithLineSegmentsConvertedToLines(
          clickedElements,
        ),
      );
    }

    th2FileEditController
        .setState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  /// Marks the start point of the pan.
  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    th2FileEditController.setDragStartCoordinates(event.localPosition);
  }

  /// Draws the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController
        .setSelectionWindowScreenEndCoordinates(event.localPosition);
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Clear the selection window.
  /// 3. Is the list empty?
  /// 3.1. Yes. Do nothing;
  /// 3.2. No. Add objects from the list inside the selection window to the
  /// current selection. Change to
  /// [MPTH2FileEditStateType.selectNonEmptySelection];
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final List<THElement> elementsInsideSelectionWindow =
        getObjectsInsideSelectionWindow(event.localPosition);

    th2FileEditController.clearSelectionWindow();

    if (elementsInsideSelectionWindow.isNotEmpty) {
      th2FileEditController.setSelectedElements(
        getSelectedElementsWithLineSegmentsConvertedToLines(
          elementsInsideSelectionWindow,
        ),
      );
      th2FileEditController
          .setState(MPTH2FileEditStateType.selectNonEmptySelection);
    }
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectEmptySelection;
}
