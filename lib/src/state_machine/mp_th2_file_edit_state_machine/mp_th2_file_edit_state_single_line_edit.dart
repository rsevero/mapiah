part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSingleLineEdit extends MPTH2FileEditState
    with
        MPTH2FileEditPageSimplifyLineMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateLineSegmentOptionsEditMixin,
        MPTH2FileEditStateMoveCanvasMixin {
  bool _dragShouldMovePoints = false;

  static const Set<MPTH2FileEditStateType> singleLineEditModes = {
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingSingleControlPoint,
    MPTH2FileEditStateType.movingEndControlPoints,
  };

  MPTH2FileEditStateSingleLineEdit({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    selectionController.resetSelectedLineLineSegmentsMPIDs();
    selectionController.updateSelectableEndAndControlPoints();
    elementEditController.setOriginalSimplifiedLines(null);
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    elementEditController.setOriginalSimplifiedLines(null);

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
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    bool keyProcessed = false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.delete:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          elementEditController.applyRemoveSelectedLineSegments();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyL:
        keyProcessed = onKeyLDownEvent(event);
    }

    /// The slash character can be produced with keyboard combinations
    /// (AltRght + Q) on one of my keyboards.
    switch (event.character) {
      case '/':
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          elementEditController
              .applyAddLineSegmentsBetweenSelectedLineSegments();
          keyProcessed = true;
        }
    }

    if (!keyProcessed) {
      _onKeyDownEvent(event);
    }
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final List<MPSelectableEndControlPoint> clickedEndControlPoints =
        await selectionController.selectableEndControlPointsClicked(
          screenCoordinates: event.localPosition,
          includeControlPoints: true,
          canBeMultiple: false,
          presentMultipleEndControlPointsClickedWidget: true,
        );

    _dragShouldMovePoints = false;
    if (clickedEndControlPoints.isNotEmpty) {
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;
      final THLineSegment clickedEndControlPointLineSegment =
          clickedEndControlPoint.element as THLineSegment;
      final bool clickedEndControlPointAlreadySelected = selectionController
          .isEndControlPointSelected(clickedEndControlPointLineSegment.mpID);

      if (shiftPressed) {
        if (clickedEndControlPointAlreadySelected) {
          selectionController.removeSelectedEndControlPoints([
            clickedEndControlPointLineSegment,
          ]);
        } else {
          selectionController.addSelectedEndControlPoint(
            clickedEndControlPoint,
          );
        }
      } else {
        selectionController.setSelectedEndControlPoint(clickedEndControlPoint);
      }

      selectionController.updateSelectableEndAndControlPoints();
      th2FileEditController.triggerEditLineRedraw();
      return;
    }

    Map<int, THElement> clickedElements = await selectionController
        .getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.lineSegment,
          canBeMultiple: false,
          presentMultipleElementsClickedWidget: true,
        );

    if (clickedElements.isNotEmpty) {
      final THLineSegment clickedLineSegment =
          clickedElements.values.first as THLineSegment;

      if (selectionController.isSelected.contains(
        clickedLineSegment.parentMPID,
      )) {
        final THLine line = thFile.lineByMPID(clickedLineSegment.parentMPID);
        final THLineSegment? previousLineSegment = line.getPreviousLineSegment(
          clickedLineSegment,
          thFile,
        );

        if (previousLineSegment == null) {
          throw Exception(
            'Error: previousLineSegment is null at TH2FileEditElementEditController.getRemoveLineSegmentCommand().',
          );
        }

        final bool isPreviousLineSegmentSelected = selectionController
            .isElementSelected(previousLineSegment);
        final bool isLineSegmentSelected = selectionController
            .isElementSelected(clickedLineSegment);

        if (!isLineSegmentSelected || !isPreviousLineSegmentSelected) {
          if (shiftPressed) {
            if (!isLineSegmentSelected) {
              selectionController.addSelectedEndPoint(clickedLineSegment);
            }

            if (!isPreviousLineSegmentSelected) {
              selectionController.addSelectedEndPoint(previousLineSegment);
            }
          } else {
            selectionController.setSelectedEndPoints([
              previousLineSegment,
              clickedLineSegment,
            ]);
          }

          selectionController.updateSelectableEndAndControlPoints();
          th2FileEditController.triggerEditLineRedraw();
        } else {
          if (shiftPressed) {
            selectionController.removeSelectedEndControlPoints([
              previousLineSegment,
              clickedLineSegment,
            ]);
          } else {
            selectionController.setSelectedEndPoints([
              previousLineSegment,
              clickedLineSegment,
            ]);
          }

          selectionController.updateSelectableEndAndControlPoints();
          th2FileEditController.triggerEditLineRedraw();
        }

        return;
      }
    }

    clickedElements = await selectionController
        .getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
          canBeMultiple: true,
          presentMultipleElementsClickedWidget: true,
        );

    selectionController.clearClickedElementsAtPointerDown();

    if (clickedElements.isEmpty) {
      selectionController.clearSelectedElements();
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );
    } else {
      selectionController.setSelectedElements(
        clickedElements.values,
        setState: true,
      );
    }

    return;
  }

  @override
  Future<void> onPrimaryButtonPointerDown(PointerDownEvent event) async {
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );
    elementEditController.setOriginalSimplifiedLines(null);

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final List<MPSelectableEndControlPoint> clickedEndControlPoints =
        await selectionController.selectableEndControlPointsClicked(
          screenCoordinates: event.localPosition,
          includeControlPoints: true,
          canBeMultiple: true,
          presentMultipleEndControlPointsClickedWidget: false,
        );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.isNotEmpty) {
      if (!shiftPressed) {
        for (final MPSelectableEndControlPoint clickedEndControlPoint
            in clickedEndControlPoints) {
          if (selectionController.isEndControlPointSelected(
            clickedEndControlPoint.lineSegment.mpID,
          )) {
            _dragShouldMovePoints = true;
            break;
          } else {
            selectionController.addSelectedEndControlPoint(
              clickedEndControlPoint,
            );
          }
        }
      }
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    if (_dragShouldMovePoints) {
      _dragShouldMovePoints = false;

      switch (selectionController
          .getCurrentSelectedEndControlPointPointType()) {
        case MPSelectedEndControlPointPointType.controlPoint:
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.movingSingleControlPoint,
          );
        case MPSelectedEndControlPointPointType.endPoint:
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.movingEndControlPoints,
          );
        default:
          throw UnimplementedError();
      }
    } else {
      selectionController.setSelectionWindowScreenEndCoordinates(
        event.localPosition,
      );
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
        selectionController.addSelectedEndPoints(
          endpointsInsideSelectionWindow,
        );
      }
    } else {
      if (endpointsInsideSelectionWindow.isEmpty) {
        selectionController.clearSelectedLineSegments();
      } else {
        selectionController.setSelectedEndPoints(
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
