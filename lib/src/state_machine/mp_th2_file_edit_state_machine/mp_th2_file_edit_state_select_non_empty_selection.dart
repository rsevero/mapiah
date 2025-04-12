part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectNonEmptySelection extends MPTH2FileEditState
    with
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateOptionsEditMixin {
  MPTH2FileEditStateSelectNonEmptySelection(
      {required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    _updateStatusBarMessage();
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
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final List<THElement> clickedElements =
        (await selectionController.getSelectableElementsClicked(
      screenCoordinates: event.localPosition,
      selectionType: THSelectionType.pla,
      canBeMultiple: true,
      presentMultipleElementsClickedWidget: true,
    ))
            .values
            .toList();
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      bool clickedElementAlreadySelected = true;

      for (final clickedElement in clickedElements) {
        if (!selectionController.isElementSelected(clickedElement)) {
          clickedElementAlreadySelected = false;
          break;
        }
      }

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          selectionController.removeSelectedElements(clickedElements);
        }

        return Future.value();
      } else {
        late bool stateChanged;

        if (shiftPressed) {
          stateChanged = selectionController.addSelectedElements(
            clickedElements,
            setState: true,
          );
        } else {
          stateChanged = selectionController.setSelectedElements(
            clickedElements,
            setState: true,
          );
        }
        if (!stateChanged) {
          _updateStatusBarMessage();
        }

        return Future.value();
      }
    } else {
      if (!shiftPressed) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }

    return Future.value();
  }

  /// 1. Mark the start point of the pan.
  /// 2. Did the pan start click on an object?
  /// 2.1. Yes. Is Shift pressed?
  /// 2.1.1. Yes. Do nothing.
  /// 2.1.2. No. Was the object already selected?
  /// 2.1.2.1. Yes. Change to [MPTH2FileEditStateType.movingElements];
  /// 2.1.2.2. No. Clear current selection; include clicked object in the
  /// selection. Change to [MPTH2FileEditStateType.movingElements];
  /// 2.2. No. Do nothing.
  @override
  Future<void> onPrimaryButtonDragStart(PointerDownEvent event) async {
    selectionController.setDragStartCoordinates(event.localPosition);
    Map<int, THElement> clickedElements =
        await selectionController.getSelectableElementsClicked(
      screenCoordinates: event.localPosition,
      selectionType: THSelectionType.pla,
      canBeMultiple: true,
      presentMultipleElementsClickedWidget: false,
    );
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    if (clickedElements.isNotEmpty) {
      if (!shiftPressed) {
        bool alreadySelected = false;

        for (final THElement element in clickedElements.values) {
          if (selectionController.isElementSelected(element)) {
            alreadySelected = true;
            break;
          }
        }

        if (!alreadySelected) {
          selectionController.setSelectedElements(clickedElements.values);
        }
        th2FileEditController.stateController
            .setState(MPTH2FileEditStateType.movingElements);
      }
    }
  }

  /// Draw the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController
        .setSelectionWindowScreenEndCoordinates(event.localPosition);
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Clear the selection window.
  /// 3. Is Shift pressed?
  /// 3.1. Yes. Include objects not yet selected in the selection;
  /// 3.2. No. Clear current selection. Is the list of objects inside the
  /// selection window empty?
  /// 3.2.1. Yes. Change to [MPTH2FileEditStateType.selectEmptySelection];
  /// 3.2.2. No. Include objects from the list inside the selection window in
  /// the current selection.

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final List<THElement> elementsInsideSelectionWindow =
        getSelectedElementsWithLineSegmentsConvertedToLines(
      getObjectsInsideSelectionWindow(
        event.localPosition,
      ),
    );
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearSelectionWindow();

    if (shiftPressed) {
      final bool stateChanged = selectionController.addSelectedElements(
        elementsInsideSelectionWindow,
        setState: true,
      );
      if (!stateChanged) {
        _updateStatusBarMessage();
      }
    } else {
      if (elementsInsideSelectionWindow.isEmpty) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      } else {
        final stateChanged = selectionController.setSelectedElements(
          elementsInsideSelectionWindow,
          setState: true,
        );
        if (!stateChanged) {
          _updateStatusBarMessage();
        }
      }
    }
  }

  void _updateStatusBarMessage() {
    int pointCount = 0;
    int lineCount = 0;

    final selectedElements = selectionController.mpSelectedElements.values;

    for (final selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedLine _:
          lineCount++;
          break;
        case MPSelectedPoint _:
          pointCount++;
          break;
      }
    }

    String statusBarMessage = '';

    if ((lineCount > 0) && (pointCount > 0)) {
      statusBarMessage = mpLocator.appLocalizations
          .th2FileEditPageNonEmptySelectionPointsAndLinesStatusBarMessage(
        pointCount,
        lineCount,
      );
    } else if (lineCount > 0) {
      statusBarMessage = mpLocator.appLocalizations
          .th2FileEditPageNonEmptySelectionOnlyLinesStatusBarMessage(
        lineCount,
      );
    } else {
      statusBarMessage = mpLocator.appLocalizations
          .th2FileEditPageNonEmptySelectionOnlyPointsStatusBarMessage(
        pointCount,
      );
    }

    th2FileEditController.setStatusBarMessage(statusBarMessage);
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectNonEmptySelection;
}
