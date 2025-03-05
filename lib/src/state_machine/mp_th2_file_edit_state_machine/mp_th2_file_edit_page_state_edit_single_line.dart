part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  bool _dragShouldMovePoints = false;

  MPTH2FileEditPageStateEditSingleLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
        .contains(nextState.type)) {
      if (nextState is! MPTH2FileEditStateMovingEndControlPoints) {
        th2FileEditController.clearSelectedLineSegments();
      }
      return;
    } else {
      clearAllSelections();
    }
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final Set<MPSelectableEndControlPoint> clickedEndControlPoints =
        th2FileEditController.selectableEndControlPointsClicked(
      event.localPosition,
      false,
    );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.isNotEmpty) {
      /// TODO: deal with multiple end points returned on same click.
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;
      final THLineSegment clickedEndControlPointLineSegment =
          clickedEndControlPoint.element as THLineSegment;
      final bool clickedEndControlPointAlreadySelected = th2FileEditController
          .isEndpointSelected(clickedEndControlPointLineSegment);

      if (shiftPressed) {
        if (clickedEndControlPointAlreadySelected) {
          th2FileEditController
              .removeSelectedLineSegments({clickedEndControlPointLineSegment});
        } else {
          th2FileEditController
              .addSelectedLineSegments({clickedEndControlPointLineSegment});
        }
      } else {
        th2FileEditController
            .setSelectedLineSegments({clickedEndControlPointLineSegment});
      }

      th2FileEditController.updateSelectableEndAndControlPoints();
      th2FileEditController.triggerEditLineRedraw();
      return;
    }

    final Set<THElement> clickedElements =
        th2FileEditController.selectableElementsClicked(event.localPosition);

    if (clickedElements.isNotEmpty) {
      final Set<THElement> clickedPointsLines =
          getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );

      /// TODO: deal with multiple end points returned on same click.
      final bool clickedElementAlreadySelected =
          th2FileEditController.isElementSelected(clickedPointsLines.first);

      if (clickedElementAlreadySelected) {
        final THLineSegment clickedLineSegment =
            clickedElements.first as THLineSegment;
        final Set<THLineSegment> lineSegments =
            th2FileEditController.getLineSegmentAndPrevious(clickedLineSegment);

        if (shiftPressed) {
          final bool firstLineSegmentSelected =
              th2FileEditController.isEndpointSelected(lineSegments.first);
          final bool secondLineSegmentSelected =
              th2FileEditController.isEndpointSelected(lineSegments.last);

          if (firstLineSegmentSelected && secondLineSegmentSelected) {
            th2FileEditController.removeSelectedLineSegments(lineSegments);
          } else {
            th2FileEditController.addSelectedLineSegments(lineSegments);
          }
        } else {
          th2FileEditController.setSelectedLineSegments(lineSegments);
        }
        th2FileEditController.updateSelectableEndAndControlPoints();
        th2FileEditController.triggerEditLineRedraw();
        return;
      } else {
        late bool stateChanged;

        th2FileEditController.clearSelectedLineSegments();

        if (shiftPressed) {
          /// TODO: deal with multiple end points returned on same click.
          stateChanged = th2FileEditController.addSelectedElement(
            clickedPointsLines.first,
            setState: true,
          );
        } else {
          /// TODO: deal with multiple end points returned on same click.
          stateChanged = th2FileEditController.setSelectedElements(
            {clickedPointsLines.first},
            setState: true,
          );
        }

        if (!stateChanged) {
          th2FileEditController.updateSelectableEndAndControlPoints();
          th2FileEditController.triggerEditLineRedraw();
        }

        return;
      }
    } else {
      if (!shiftPressed) {
        th2FileEditController.clearSelectedElements();
        th2FileEditController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }
  }

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    th2FileEditController.setDragStartCoordinates(event.localPosition);

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final Set<MPSelectableEndControlPoint> clickedEndControlPoints =
        th2FileEditController.selectableEndControlPointsClicked(
      event.localPosition,
      false,
    );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.isNotEmpty) {
      if (!shiftPressed) {
        bool alreadySelected = false;
        final Set<THLineSegment> newlySelectedEndPoints = {};

        for (final MPSelectableEndControlPoint endControlPoint
            in clickedEndControlPoints) {
          final THLineSegment element =
              endControlPoint.element as THLineSegment;

          if (th2FileEditController.isEndpointSelected(element)) {
            alreadySelected = true;
          } else {
            newlySelectedEndPoints.add(element);
          }
        }
        if (!alreadySelected) {
          th2FileEditController.setSelectedLineSegments(newlySelectedEndPoints);
        }
        _dragShouldMovePoints = true;
      }
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    if (_dragShouldMovePoints) {
      th2FileEditController
          .setState(MPTH2FileEditStateType.movingEndControlPoints);
    } else {
      th2FileEditController
          .setSelectionWindowScreenEndCoordinates(event.localPosition);
    }
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Set<THLineSegment> endpointsInsideSelectionWindow =
        getEndPointsInsideSelectionWindow(event.localPosition);
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    th2FileEditController.clearSelectionWindow();

    if (shiftPressed) {
      if (endpointsInsideSelectionWindow.isNotEmpty) {
        th2FileEditController.addSelectedLineSegments(
          endpointsInsideSelectionWindow,
        );
      }
    } else {
      if (endpointsInsideSelectionWindow.isEmpty) {
        th2FileEditController.clearSelectedLineSegments();
      } else {
        th2FileEditController.setSelectedLineSegments(
          endpointsInsideSelectionWindow,
        );
      }
    }
    th2FileEditController.updateSelectableEndAndControlPoints();
  }

  Set<THLineSegment> getEndPointsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow =
        th2FileEditController.dragStartCanvasCoordinates;
    final Offset endSelectionWindow = th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = MPNumericAux.orderedRectFromLTRB(
      left: startSelectionWindow.dx,
      top: startSelectionWindow.dy,
      right: endSelectionWindow.dx,
      bottom: endSelectionWindow.dy,
    );
    final Set<THLineSegment> lineSegmentsInsideSelectionWindow =
        th2FileEditController.selectableEndPointsInsideWindow(selectionWindow);

    return lineSegmentsInsideSelectionWindow;
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
