part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectEmptySelection extends MPTH2FileEditState
    with
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateOptionsEditMixin {
  MPTH2FileEditStateSelectEmptySelection(
      {required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    selectionController.clearSelectedElements();
    selectionController.clearSelectedEndControlPoints();
    selectionController.clearSelectedLineSegments();
    th2FileEditController.setStatusBarMessage(mpLocator
        .appLocalizations.th2FileEditPageEmptySelectionStatusBarMessage);
  }

  /// 1. Clicked on an object?
  /// 1.1. If yes, select object. Change to [MPTH2FileEditStateType.selectNonEmptySelection];
  /// 1.2. If no, do nothing.
  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final Map<int, THElement> clickedElements =
        await selectionController.getSelectableElementsClickedWithDialog(
      screenCoordinates: event.localPosition,
      selectionType: THSelectionType.pla,
      canBeMultiple: true,
      presentMultipleElementsClickedWidget: true,
    );

    selectionController.clearClickedElementsAtPointerDown();

    if (clickedElements.isNotEmpty) {
      selectionController.setSelectedElements(
        clickedElements.values,
        setState: true,
      );
    }

    return Future.value();
  }

  /// Marks the start point of the pan.
  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    selectionController.setDragStartCoordinates(event.localPosition);
  }

  /// Draws the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController
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

    selectionController.clearSelectionWindow();

    if (elementsInsideSelectionWindow.isNotEmpty) {
      selectionController.setSelectedElements(
        getSelectedElementsWithLineSegmentsConvertedToLines(
          elementsInsideSelectionWindow,
        ),
        setState: true,
      );
    }
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectEmptySelection;
}
