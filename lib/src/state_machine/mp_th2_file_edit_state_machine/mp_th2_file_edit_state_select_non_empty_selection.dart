part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectNonEmptySelection extends MPTH2FileEditState
    with
        MPTH2FileEditPageSimplifyLineMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateOptionsEditMixin {
  MPTH2FileEditStateSelectNonEmptySelection({
    required super.th2FileEditController,
  });

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    selectionController.clearSelectedEndControlPoints();
    selectionController.clearSelectedLineSegments();
    elementEditController.resetOriginalFileForLineSimplification();
    setStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    elementEditController.resetOriginalFileForLineSimplification();
    onStateExitClearSelectionOnExit(nextState);
    th2FileEditController.setStatusBarMessage('');
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
        (await selectionController.getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
          canBeMultiple: true,
          presentMultipleElementsClickedWidget: true,
        )).values.toList();
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearClickedElementsAtPointerDown();

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
          setStatusBarMessage();
        }

        return Future.value();
      }
    } else {
      if (!shiftPressed) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
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
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    Map<int, THElement> clickedElements = selectionController
        .getSelectableElementsClickedWithoutDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
        );

    elementEditController.resetOriginalFileForLineSimplification();
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );

    if (clickedElements.isNotEmpty) {
      if (!shiftPressed) {
        bool alreadySelected = false;

        for (final THElement element in clickedElements.values) {
          if (selectionController.isElementSelected(element)) {
            alreadySelected = true;
            break;
          }
        }

        selectionController.setClickedElementsAtPointerDown(
          alreadySelected ? {} : clickedElements.values,
        );
      }
    }
  }

  /// Draw the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController.setSelectionWindowScreenEndCoordinates(
      event.localPosition,
    );

    if (selectionController.clickedElementsAtPointerDown.isNotEmpty) {
      selectionController.substituteSelectedElementsByClickedElements();
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.movingElements,
      );
    } else {
      final bool shiftPressed = MPInteractionAux.isShiftPressed();

      if (!shiftPressed) {
        final List<THElement> clickedElements =
            (selectionController.getSelectableElementsClickedWithoutDialog(
              screenCoordinates: event.localPosition,
              selectionType: THSelectionType.pla,
            )).values.toList();

        bool clickedOnSelectedElement = false;

        for (final THElement clickedElement in clickedElements) {
          if (selectionController.isElementSelected(clickedElement)) {
            clickedOnSelectedElement = true;
            break;
          }
        }

        if (clickedOnSelectedElement) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.movingElements,
          );
        }
      }
    }
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
          getObjectsInsideSelectionWindow(event.localPosition),
        );
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearSelectionWindow();

    if (shiftPressed) {
      final bool stateChanged = selectionController.addSelectedElements(
        elementsInsideSelectionWindow,
        setState: true,
      );

      if (!stateChanged) {
        setStatusBarMessage();
      }
    } else {
      if (elementsInsideSelectionWindow.isEmpty) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      } else {
        final bool stateChanged = selectionController.setSelectedElements(
          elementsInsideSelectionWindow,
          setState: true,
        );

        if (!stateChanged) {
          setStatusBarMessage();
        }
      }
    }
  }

  @override
  void setStatusBarMessage() {
    final List<int> selectedElementsCount = getSelectedElementsCount();
    final String statusBarMessage = mpLocator.appLocalizations
        .mpNonEmptySelectionStateAreasLinesAndPointsStatusBarMessage(
          selectedElementsCount[0],
          selectedElementsCount[1],
          selectedElementsCount[2],
        );

    th2FileEditController.setStatusBarMessage(statusBarMessage);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    if (!onKeyLDownEvent(event)) {
      _onKeyDownEvent(event);
    }
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectNonEmptySelection;
}
