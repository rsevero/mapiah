part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateEditSingleLine extends MPTH2FileEditState
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

  MPTH2FileEditStateEditSingleLine({required super.th2FileEditController});

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

    /// TODO: deal with multiple end points returned on same click.
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
      return;
    }

    final Map<int, THElement> clickedElements =
        await selectionController.selectableElementsClicked(
      screenCoordinates: event.localPosition,
      selectionType: THSelectionType.lineSegment,
      canBeMultiple: false,
    );
    final THLineSegment clickedLineSegment =
        clickedElements.values.first as THLineSegment;

    if (clickedElements.isNotEmpty) {
      if (selectionController.isElementSelected(clickedLineSegment)) {
        final List<THLineSegment> lineSegments =
            selectionController.getLineSegmentAndPrevious(clickedLineSegment);

        if (shiftPressed) {
          if (selectionController.isEndpointSelected(lineSegments.first) &&
              selectionController.isEndpointSelected(lineSegments.last)) {
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
        final THLine line = thFile.lineByMPID(
          clickedLineSegment.parentMPID,
        );

        selectionController.clearSelectedLineSegments();

        if (shiftPressed) {
          stateChanged = selectionController.addSelectedElement(
            line,
            setState: true,
          );
        } else {
          stateChanged = selectionController.setSelectedElements(
            [line],
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
                /// TODO: deal with multiple end/control points returned on same
                /// click.
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
