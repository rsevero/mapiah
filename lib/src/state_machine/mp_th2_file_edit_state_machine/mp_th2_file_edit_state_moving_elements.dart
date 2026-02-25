part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMovingElements extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin {
  final TH2FileEditSnapController snapController;
  THElement? _clickedElementAtPointerDown;
  bool _searchedForClickedElementAtPointerDown = false;

  MPTH2FileEditStateMovingElements({required super.th2FileEditController})
    : snapController = th2FileEditController.snapController;

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    setStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (nextState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      onStateExitClearSelectionOnExit(nextState);
    }
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void setStatusBarMessage() {
    final List<int> selectedElementsCount = getSelectedElementsCount();

    final String statusBarMessage = mpLocator.appLocalizations
        .mpMovingElementsStateAreasLinesAndPointsStatusBarMessage(
          selectedElementsCount[0],
          selectedElementsCount[1],
          selectedElementsCount[2],
        );

    th2FileEditController.setStatusBarMessage(statusBarMessage);
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
    if (onAltPrimaryButtonClick(event)) {
      return Future.value();
    }

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
          selectionController.removeSelectedElementsByElements(clickedElements);
        }

        return;
      } else {
        if (shiftPressed) {
          selectionController.addSelectedElements(
            clickedElements,
            setState: true,
          );
        } else {
          selectionController.setSelectedElements(
            clickedElements,
            setState: true,
          );
        }

        return;
      }
    } else {
      if (!shiftPressed) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      }
    }

    return;
  }

  /// 1. Moves all selected objects by the distance indicated by [event].
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    final Offset canvasOffset = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final Offset snapedCanvasOffset = snapController
        .getCanvasSnapedOffsetFromCanvasOffset(canvasOffset);

    if (!_searchedForClickedElementAtPointerDown) {
      _searchedForClickedElementAtPointerDown = true;
      _clickedElementAtPointerDown = snapController.getNearerSelectedElement(
        canvasOffset,
      );
      if (_clickedElementAtPointerDown != null) {
        switch (_clickedElementAtPointerDown) {
          case THPoint _:
            selectionController.setDragStartCoordinatesFromCanvasCoordinates(
              (_clickedElementAtPointerDown as THPoint).position.coordinates,
            );
          case THLineSegment _:
            selectionController.setDragStartCoordinatesFromCanvasCoordinates(
              (_clickedElementAtPointerDown as THLineSegment)
                  .endPoint
                  .coordinates,
            );
        }
      }
    }

    selectionController.moveSelectedElementsToCanvasCoordinates(
      snapedCanvasOffset,
    );
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [event].
  /// 2. Update cloned copies inside TH2FileEditController.selectedElements.
  /// 3. Trigger redraw of selected elements.
  /// 4. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final int selectedCount =
        selectionController.mpSelectedElementsLogical.length;
    final Offset canvasOffset = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final THPositionPart snapedPosition =
        snapController.getCanvasSnapedPositionFromCanvasOffset(canvasOffset) ??
        THPositionPart(
          coordinates: canvasOffset,
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );
    late MPCommand moveCommand;

    if (selectedCount == 0) {
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );

      return;
    } else if (selectedCount == 1) {
      final MPSelectedElement selected =
          selectionController.mpSelectedElementsLogical.values.first;
      final THElement selectedElement = selected.originalElementClone;

      switch (selected) {
        case MPSelectedPoint _:
          moveCommand = MPMovePointCommand(
            pointMPID: selectedElement.mpID,
            fromPosition: (selectedElement as THPoint).position,
            toPosition: snapedPosition,
            fromOriginalLineInTH2File: selectedElement.originalLineInTH2File,
            toOriginalLineInTH2File: '',
          );
        case MPSelectedLine _:
          moveCommand = MPMoveLineCommand.fromLineSegmentExactPosition(
            lineMPID: selectedElement.mpID,
            fromLineSegmentsMap: selected.originalLineSegmentsMapClone,
            referenceLineSegment: _clickedElementAtPointerDown as THLineSegment,
            referenceLineSegmentFinalPosition: snapedPosition,
          );
        case MPSelectedArea _:
          moveCommand = MPMoveAreaCommand.fromLineSegmentExactPosition(
            areaMPID: selectedElement.mpID,
            originalLines: selected.originalLines,
            referenceLineSegment: _clickedElementAtPointerDown as THLineSegment,
            referenceLineSegmentFinalPosition: snapedPosition,
          );
      }

      th2FileEditController.execute(moveCommand);
      selectionController.updateSelectedElementLogicalClone(
        selectedElement.mpID,
      );
    } else if (selectedCount > 1) {
      moveCommand =
          MPCommandFactory.moveElementsFromReferenceElementExactPosition(
            mpSelectedElements:
                selectionController.mpSelectedElementsLogical.values,
            referenceElement: _clickedElementAtPointerDown!,
            referenceElementFinalPosition: snapedPosition,
          );

      th2FileEditController.execute(moveCommand);
      selectionController.updateAllSelectedElementsClones();
    }

    th2FileEditController.triggerSelectedElementsRedraw(setState: true);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.movingElements;
}
