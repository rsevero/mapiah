part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateOptionEdit extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  bool _dragShouldMovePoints = false;
  final List<MPSelectableEndControlPoint> _selectedEndControlPointsOnDragStart =
      [];

  static const Set<MPTH2FileEditStateType> singleLineEditModes = {
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingSingleControlPoint,
    MPTH2FileEditStateType.movingEndControlPoints,
  };

  MPTH2FileEditStateOptionEdit({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    selectionController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.setStatusBarMessage('');
    selectionController.resetSelectedLineLineSegmentsMPIDs();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    _selectedEndControlPointsOnDragStart.clear();
    if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
        .contains(nextStateType)) {
      if (!singleLineEditModes.contains(nextStateType)) {
        selectionController.clearSelectedLineSegments();
      }
      return;
    } else {
      clearAllSelections();
    }
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final List<MPSelectableEndControlPoint> clickedEndControlPoints =
        selectionController.selectableEndControlPointsClicked(
      event.localPosition,
      false,
    );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.isNotEmpty) {
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;
      final THLineSegment clickedEndControlPointLineSegment =
          clickedEndControlPoint.element as THLineSegment;
      final bool clickedEndControlPointAlreadySelected = selectionController
          .isEndpointSelected(clickedEndControlPointLineSegment);

      if (shiftPressed) {
        if (clickedEndControlPointAlreadySelected) {
          selectionController
              .removeSelectedLineSegments([clickedEndControlPointLineSegment]);
        } else {
          selectionController
              .addSelectedLineSegments([clickedEndControlPointLineSegment]);
        }
      } else {
        selectionController
            .setSelectedLineSegments([clickedEndControlPointLineSegment]);
      }

      selectionController.updateSelectableEndAndControlPoints();
      th2FileEditController.triggerEditLineRedraw();
      return Future.value();
    }

    final List<THElement> clickedElements =
        await selectionController.selectablePLClicked(event.localPosition);

    if (clickedElements.isNotEmpty) {
      final List<THElement> clickedPointsLines =
          getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );
      final bool clickedElementAlreadySelected =
          selectionController.isElementSelected(
        clickedElements.first,
      );

      if (clickedElementAlreadySelected) {
        final THLineSegment clickedLineSegment =
            clickedElements.first as THLineSegment;
        final List<THLineSegment> lineSegments =
            selectionController.getLineSegmentAndPrevious(clickedLineSegment);

        if (shiftPressed) {
          final bool firstLineSegmentSelected =
              selectionController.isEndpointSelected(lineSegments.first);
          final bool secondLineSegmentSelected =
              selectionController.isEndpointSelected(lineSegments.last);

          if (firstLineSegmentSelected && secondLineSegmentSelected) {
            selectionController.removeSelectedLineSegments(lineSegments);
          } else {
            selectionController.addSelectedLineSegments(lineSegments);
          }
        } else {
          selectionController.setSelectedLineSegments(lineSegments);
        }
        selectionController.updateSelectableEndAndControlPoints();
        th2FileEditController.triggerEditLineRedraw();

        return Future.value();
      } else {
        late bool stateChanged;

        selectionController.clearSelectedLineSegments();

        if (shiftPressed) {
          stateChanged = selectionController.addSelectedElements(
            clickedPointsLines,
            setState: true,
          );
        } else {
          stateChanged = selectionController.setSelectedElements(
            clickedPointsLines,
            setState: true,
          );
        }

        if (!stateChanged) {
          selectionController.updateSelectableEndAndControlPoints();
          th2FileEditController.triggerEditLineRedraw();
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

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    selectionController.setDragStartCoordinates(event.localPosition);

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final List<MPSelectableEndControlPoint> clickedEndControlPoints =
        selectionController.selectableEndControlPointsClicked(
      event.localPosition,
      true,
    );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.isNotEmpty) {
      if (!shiftPressed) {
        _selectedEndControlPointsOnDragStart.clear();
        for (final MPSelectableEndControlPoint endControlPoint
            in clickedEndControlPoints) {
          switch (endControlPoint) {
            case MPSelectableControlPoint _:
              _selectedEndControlPointsOnDragStart.add(endControlPoint);
            case MPSelectableEndPoint _:
              final THLineSegment element =
                  endControlPoint.element as THLineSegment;

              if (!selectionController.isEndpointSelected(element)) {
                _selectedEndControlPointsOnDragStart.add(endControlPoint);
              }
          }
          _dragShouldMovePoints = true;
        }
      }
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    if (_dragShouldMovePoints) {
      _dragShouldMovePoints = false;
      if (_selectedEndControlPointsOnDragStart.isEmpty) {
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.movingEndControlPoints,
        );
      } else {
        final MPSelectableEndControlPoint clickedEndControlPoint =
            _selectedEndControlPointsOnDragStart.first;

        switch (clickedEndControlPoint) {
          case MPSelectableControlPoint _:
            selectionController.setSelectedControlPoint(clickedEndControlPoint);
            selectionController.moveSelectedControlPointToScreenCoordinates(
              event.localPosition,
            );
            th2FileEditController.stateController.setState(
              MPTH2FileEditStateType.movingSingleControlPoint,
            );
          case MPSelectableEndPoint _:
            selectionController.setSelectedLineSegments(
              [clickedEndControlPoint.element as THLineSegment],
            );
            th2FileEditController.stateController.setState(
              MPTH2FileEditStateType.movingEndControlPoints,
            );
          default:
            throw UnimplementedError();
        }
      }
    } else {
      selectionController
          .setSelectionWindowScreenEndCoordinates(event.localPosition);
    }
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final List<THLineSegment> endpointsInsideSelectionWindow =
        getEndPointsInsideSelectionWindow(event.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearSelectionWindow();

    if (shiftPressed) {
      if (endpointsInsideSelectionWindow.isNotEmpty) {
        selectionController.addSelectedLineSegments(
          endpointsInsideSelectionWindow,
        );
      }
    } else {
      if (endpointsInsideSelectionWindow.isEmpty) {
        selectionController.clearSelectedLineSegments();
      } else {
        selectionController.setSelectedLineSegments(
          endpointsInsideSelectionWindow,
        );
      }
    }
    selectionController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
  }

  List<THLineSegment> getEndPointsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow =
        selectionController.dragStartCanvasCoordinates;
    final Offset endSelectionWindow = th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = MPNumericAux.orderedRectFromLTRB(
      left: startSelectionWindow.dx,
      top: startSelectionWindow.dy,
      right: endSelectionWindow.dx,
      bottom: endSelectionWindow.dy,
    );
    final List<THLineSegment> lineSegmentsInsideSelectionWindow =
        selectionController.selectableEndPointsInsideWindow(selectionWindow);

    return lineSegmentsInsideSelectionWindow;
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
