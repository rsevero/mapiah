part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditPageSimplifyLineMixin,
        MPTH2FileEditPageSingleElementSelectedMixin,
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

  MPTH2FileEditStateEditSingleLine({required super.th2FileEditController});

  @override
  void onSelectAll() {
    selectionController.selectAllEndPoints();
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    setClickedElementAtSingleLineEditPointerDown(null);
    selectionController.updateSelectedElementsClones();
    selectionController.resetSelectedLineLineSegmentsMPIDs();
    selectionController.updateSelectableEndAndControlPoints();
    elementEditController.resetOriginalFileForLineSimplification();
    th2FileEditController.triggerEditLineRedraw();
    setStatusBarMessage();
  }

  @override
  void setStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(
      getStatusBarMessageForSingleSelectedElement(),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    elementEditController.resetOriginalFileForLineSimplification();
    th2FileEditController.setStatusBarMessage('');

    if (MPTH2FileEditStateClearSelectionOnExitMixin.selectionStatesTypes
        .contains(nextStateType)) {
      if (!singleLineEditModes.contains(nextStateType)) {
        selectionController.clearSelectedLineSegments();
        selectionController.updateSelectableEndAndControlPoints();
        elementEditController.resetOriginalFileForLineSimplification();
      }
    } else {
      clearAllSelections();
    }
  }

  @override
  void onDeselectAll() {
    selectionController.deselectAllEndPoints();
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
      case LogicalKeyboardKey.escape:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          onDeselectAll();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyA:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          onSelectAll();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyL:
        keyProcessed = onKeyLDownEvent(event);
      case LogicalKeyboardKey.keyS:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.elementEditController
              .toggleSelectedLinePointsSmoothOption();
          keyProcessed = true;
        }
    }

    if (keyProcessed) {
      return;
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

    if (keyProcessed) {
      return;
    }

    _onKeyDownEvent(event);
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
    setClickedElementAtSingleLineEditPointerDown(null);

    if (clickedEndControlPoints.isNotEmpty) {
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;
      final THLineSegment clickedEndControlPointLineSegment =
          clickedEndControlPoint.element as THLineSegment;
      final bool clickedEndControlPointAlreadySelected = selectionController
          .isEndControlPointSelected(clickedEndControlPoint);

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
        if (!clickedEndControlPointAlreadySelected) {
          selectionController.setSelectedEndControlPoint(
            clickedEndControlPoint,
          );
        }
      }

      selectionController.updateSelectableEndAndControlPoints();
      th2FileEditController.triggerEditLineRedraw();

      return;
    }

    final THLine currentLine = selectionController.getSelectedLine();

    Map<int, THElement> clickedElements = await selectionController
        .getSelectableLineSegmentsOfLineClickedWithDialog(
          screenCoordinates: event.localPosition,
          referenceLineMPID: currentLine.mpID,
          canBeMultiple: false,
          presentMultipleElementsClickedWidget: true,
        );

    if (clickedElements.isNotEmpty) {
      final THLineSegment clickedLineSegment =
          clickedElements.values.first as THLineSegment;
      final THLineSegment? previousLineSegment = currentLine
          .getPreviousLineSegment(clickedLineSegment, thFile);

      if (previousLineSegment == null) {
        throw Exception(
          'Error: previousLineSegment is null at TH2FileEditElementEditController.getRemoveLineSegmentCommand().',
        );
      }

      final bool isPreviousLineSegmentSelected = selectionController
          .isElementSelected(previousLineSegment);
      final bool isLineSegmentSelected = selectionController.isElementSelected(
        clickedLineSegment,
      );

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

    /// If the user haven't clicked on the selected line (either some
    /// end/control point of some its line segments), we are not in 'single line
    /// edit' mode anymore, so we change to 'select non empty selection' mode
    /// and pass the event to its onPrimaryButtonClick() method to deal with the
    /// click in the appropriate way.
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );
    th2FileEditController.stateController.onPrimaryButtonClick(event);
  }

  void setClickedElementAtSingleLineEditPointerDown(THElement? clickedElement) {
    selectionController.clickedElementAtSingleLineEditPointerDown =
        clickedElement;

    if (clickedElement != null) {
      selectionController.setDragStartCoordinatesFromCanvasCoordinates(
        (clickedElement as THLineSegment).endPoint.coordinates,
      );
    }
  }

  @override
  Future<void> onPrimaryButtonPointerDown(PointerDownEvent event) async {
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );
    elementEditController.resetOriginalFileForLineSimplification();

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final List<MPSelectableEndControlPoint> clickedEndControlPoints =
        await selectionController.selectableEndControlPointsClicked(
          screenCoordinates: event.localPosition,
          includeControlPoints: true,
          canBeMultiple: true,
          presentMultipleEndControlPointsClickedWidget: false,
        );

    _dragShouldMovePoints = false;

    if (clickedEndControlPoints.length == 1) {
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;

      setClickedElementAtSingleLineEditPointerDown(
        clickedEndControlPoint.element,
      );

      if (!shiftPressed) {
        _dragShouldMovePoints = true;
        if (!selectionController.isEndControlPointSelected(
          clickedEndControlPoint,
        )) {
          selectionController.setSelectedEndControlPoint(
            clickedEndControlPoint,
          );
        }
      }
    } else if (clickedEndControlPoints.length > 1) {
      if (!shiftPressed) {
        for (final MPSelectableEndControlPoint clickedEndControlPoint
            in clickedEndControlPoints) {
          if (selectionController.isEndControlPointSelected(
            clickedEndControlPoint,
          )) {
            _dragShouldMovePoints = true;
            break;
          }
        }
      }
      setClickedElementAtSingleLineEditPointerDown(
        clickedEndControlPoints.first.element,
      );
    }

    th2FileEditController.triggerEditLineRedraw();
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
          throw StateError(
            'Error: Unknown MPSelectedEndControlPointPointType at MPTH2FileEditStateEditSingleLine.onPrimaryButtonDragUpdate().',
          );
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

    setClickedElementAtSingleLineEditPointerDown(null);
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
