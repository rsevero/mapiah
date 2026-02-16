part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditPageSimplifyLineMixin,
        MPTH2FileEditPageSingleElementSelectedMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateLineSegmentOptionsEditMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateOptionsEditMixin {
  bool _dragShouldMovePoints = false;
  bool _hasDifferentOrientations = false;
  bool _hasDifferentLSizes = false;
  bool _valuesSetByUser = false;
  bool _isLSizeOrientationEdit = false;

  static const Set<MPTH2FileEditStateType> singleLineEditModes = {
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingEndControlPoints,
    MPTH2FileEditStateType.movingSingleControlPoint,
  };

  MPTH2FileEditStateEditSingleLine({required super.th2FileEditController});

  @override
  void onSelectAll() {
    selectionController.selectAllEndPoints();
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    if (previousState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      setClickedElementAtSingleLineEditPointerDown(null);
      selectionController.updateAllSelectedElementsClones();
      selectionController.resetSelectedLineLineSegmentsMPIDs();
      selectionController.updateSelectableEndAndControlPoints();
      elementEditController.resetOriginalFileForLineSimplification();
      th2FileEditController.triggerEditLineRedraw();
    }
    setStatusBarMessage();
  }

  @override
  void setStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(
      _isLSizeOrientationEdit
          ? _getLSizeOrientationStatusBarMessage()
          : _getStatusBarMessageForSingleSelectedElement(),
    );
  }

  String _getLSizeOrientationStatusBarMessage() {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    String getOptionValueString({
      required bool hasDifferentValues,
      required double? value,
    }) {
      if (hasDifferentValues) {
        return appLocalizations.mpChoiceMultipleValues;
      }

      if (value == null) {
        return appLocalizations.mpChoiceUnset;
      }

      return value.toStringAsFixed(1);
    }

    final String orientationString = getOptionValueString(
      hasDifferentValues: _hasDifferentOrientations,
      value: elementEditController.linePointOrientation,
    );
    final String lSizeString = getOptionValueString(
      hasDifferentValues: _hasDifferentLSizes,
      value: elementEditController.linePointLSize,
    );

    // Determine whether orientation/lSize should be "forced".
    // If the current option being edited is the corresponding option,
    // force it. Otherwise, if the user has already set values, use the
    // modifier keys to decide.
    final bool forceOrientation;

    if (elementEditController.currentOptionTypeBeingEdited ==
        THCommandOptionType.orientation) {
      forceOrientation = true;
    } else if (_valuesSetByUser) {
      forceOrientation =
          MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed();
    } else {
      forceOrientation = false;
    }

    final bool forceLSize;

    if (elementEditController.currentOptionTypeBeingEdited ==
        THCommandOptionType.lSize) {
      forceLSize = true;
    } else if (_valuesSetByUser) {
      forceLSize = MPInteractionAux.isAltPressed();
    } else {
      forceLSize = false;
    }

    final String forcedOrientationString = forceOrientation
        ? appLocalizations.mpStatusBarMessageEditLinePointOrientationLSizeForced
        : '';
    final String forcedLSizeString = forceLSize
        ? appLocalizations.mpStatusBarMessageEditLinePointOrientationLSizeForced
        : '';
    final String message = appLocalizations
        .mpStatusBarMessageEditLinePointOrientationLSize(
          orientationString,
          forcedOrientationString,
          lSizeString,
          forcedLSizeString,
        );

    return message;
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    final MPTH2FileEditStateType nextStateType = nextState.type;

    _saveLSizeOrientation(
      th2FileEditController.elementEditController.currentOptionTypeBeingEdited,
    );

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
    if (_isLSizeOrientationEdit) {
      setStatusBarMessage();
    }

    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();
    final LogicalKeyboardKey logicalKey = event.logicalKey;

    bool keyProcessed = false;

    switch (logicalKey) {
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
      case LogicalKeyboardKey.keyO:
        keyProcessed = onKeyODownEvent(event);
      case LogicalKeyboardKey.keyR:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.elementEditController
              .toggleSelectedLinesReverseOption();
          keyProcessed = true;
        }
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

    /// The slash character can be produced with keyboard combinations, for
    /// example (AltRght + Q) on one of my keyboards.
    switch (event.character) {
      case '/':
        elementEditController.applyAddLineSegmentsBetweenSelectedLineSegments();
        keyProcessed = true;
    }

    if (keyProcessed) {
      return;
    }

    _onKeyDownEvent(event);
  }

  @override
  void onKeyUpEvent(KeyUpEvent event) {
    if (_isLSizeOrientationEdit) {
      setStatusBarMessage();
    }

    super.onKeyUpEvent(event);
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    if (onAltPrimaryButtonClick(event)) {
      return;
    } else if (_isLSizeOrientationEdit) {
      _setOrientationLSizeFromLocalPosition(event.localPosition);

      _valuesSetByUser = true;

      return;
    }

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
      final bool clickedEndControlPointAlreadySelected = selectionController
          .isEndControlPointSelected(clickedEndControlPoint);

      if (shiftPressed) {
        if (clickedEndControlPointAlreadySelected) {
          selectionController.removeSelectedEndControlPointsByMPID([
            clickedEndControlPoint.lineSegment.mpID,
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
          selectionController.removeSelectedEndControlPointsByMPID([
            previousLineSegment.mpID,
            clickedLineSegment.mpID,
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
    if (_isLSizeOrientationEdit) {
      _setOrientationLSizeFromLocalPosition(event.localPosition);

      return;
    }

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
    if (_isLSizeOrientationEdit) {
      _setOrientationLSizeFromLocalPosition(event.localPosition);

      return;
    }

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
    if (_isLSizeOrientationEdit) {
      _setOrientationLSizeFromLocalPosition(event.localPosition);

      _valuesSetByUser = true;

      return;
    }

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

  void initializeLSizeOrientation() {
    final Iterable<MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints.values;

    bool isFirst = true;
    double? orientationAll;
    double? lSizeAll;

    _hasDifferentOrientations = false;
    _hasDifferentLSizes = false;
    _valuesSetByUser = false;

    for (MPSelectedEndControlPoint selectedEndPoint in selectedEndPoints) {
      final THLineSegment lineSegment =
          selectedEndPoint.originalLineSegmentClone;
      final double? pointOrientation = MPCommandOptionAux.getOrientation(
        lineSegment,
      );
      final double? pointLSize = MPCommandOptionAux.getLSize(lineSegment);

      if (isFirst) {
        orientationAll = pointOrientation;
        lSizeAll = pointLSize;
        isFirst = false;

        continue;
      }

      if (orientationAll != pointOrientation) {
        _hasDifferentOrientations = true;
        orientationAll = null;
      }

      if (lSizeAll != pointLSize) {
        _hasDifferentLSizes = true;
        lSizeAll = null;
      }
    }

    elementEditController.setLinePointOrientationValue(orientationAll);
    elementEditController.setLinePointLSizeValue(lSizeAll);
  }

  @override
  void onChangeCommandOptionTypeEdited({
    required THCommandOptionType? previousOptionType,
    required THCommandOptionType? newOptionType,
  }) {
    _saveLSizeOrientation(previousOptionType);

    _isLSizeOrientationEdit = _isLSizeOrientation(newOptionType);

    if (_isLSizeOrientationEdit) {
      initializeLSizeOrientation();
    }
  }

  bool _isLSizeOrientation(THCommandOptionType? optionType) {
    return (optionType == THCommandOptionType.orientation) ||
        (optionType == THCommandOptionType.lSize);
  }

  void _saveLSizeOrientation(
    THCommandOptionType? previousOptionTypeBeingEdited,
  ) {
    if (!_isLSizeOrientation(previousOptionTypeBeingEdited)) {
      return;
    }

    if (!_valuesSetByUser ||
        selectionController.selectedEndControlPoints.isEmpty) {
      return;
    }

    elementEditController.applySetLinePointOrientationLSize();

    _valuesSetByUser = false;
  }

  void _setOrientationLSizeFromLocalPosition(Offset clickScreenCoordinates) {
    if (selectionController.selectedEndControlPoints.length != 1) {
      return;
    }

    final MPSelectedEndControlPoint mpSelectedEndControlPoint =
        selectionController.selectedEndControlPoints.values.first;

    if ((mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointBezierCurve) &&
        (mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointStraight)) {
      return;
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      clickScreenCoordinates,
    );
    final THLineSegment selectedLineSegment =
        mpSelectedEndControlPoint.originalLineSegmentClone;
    final double centerX = selectedLineSegment.x;
    final double centerY = selectedLineSegment.y;
    final double deltaX = canvasPosition.dx - centerX;
    final double deltaY = canvasPosition.dy - centerY;
    final Offset directionOffset = Offset(deltaX, deltaY);
    final double orientation = MPNumericAux.directionOffsetToDegrees(
      directionOffset,
    );

    elementEditController.setLinePointOrientationValue(orientation);

    final double distanceFromCenter = math.sqrt(
      (deltaX * deltaX) + (deltaY * deltaY),
    );
    final double lSize = distanceFromCenter * mpLSizeCanvasSizeFactor;

    elementEditController.setLinePointLSizeValue(lSize);

    setStatusBarMessage();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
