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
  bool _isLSizeOrientationEdit = false;
  MPLSizeOrientationDragStartState? _lSizeOrientationDragStartState;
  MPLSizeOrientationDragUpdateResult? _lastLSizeOrientationDragUpdateResult;

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

    String getOptionValueString({required double? value}) {
      if (value == null) {
        return appLocalizations.mpChoiceUnset;
      }

      return value.toStringAsFixed(1);
    }

    final String orientationString = getOptionValueString(
      value: elementEditController.linePointOrientation,
    );
    final String lSizeString = getOptionValueString(
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
    } else if (_lastLSizeOrientationDragUpdateResult != null) {
      forceOrientation =
          MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed();
    } else {
      forceOrientation = false;
    }

    final bool forceLSize;

    if (elementEditController.currentOptionTypeBeingEdited ==
        THCommandOptionType.lSize) {
      forceLSize = true;
    } else if (_lastLSizeOrientationDragUpdateResult != null) {
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
      _lSizeOrientationDragUpdate(event.localPosition);
      _saveLSizeOrientation(
        th2FileEditController
            .elementEditController
            .currentOptionTypeBeingEdited,
      );

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
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );

    if (_isLSizeOrientationEdit) {
      _lSizeOrientationStartDrag(event.localPosition);

      return;
    }

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
      _lSizeOrientationDragUpdate(event.localPosition);

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
      _lSizeOrientationDragUpdate(event.localPosition);
      _saveLSizeOrientation(
        th2FileEditController
            .elementEditController
            .currentOptionTypeBeingEdited,
      );

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

  void _lSizeOrientationStartDrag(Offset mouseScreen) {
    final Iterable<MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints.values;

    if (selectedEndPoints.length != 1) {
      return;
    }

    final THLineSegment lineSegment =
        selectedEndPoints.first.originalLineSegmentClone;
    final double? pointLSize = MPCommandOptionAux.getLSize(lineSegment);
    final double? pointOrientation = MPCommandOptionAux.getOrientation(
      lineSegment,
    );

    _lSizeOrientationDragStartState =
        MPLSizeOrientationAux.startLinePointLSizeOrientationDrag(
          pointCanvas: lineSegment.endPoint.coordinates,
          mouseScreen: mouseScreen,
          initialLSize: pointLSize,
          initialOrientation: pointOrientation,
          th2FileEditController: th2FileEditController,
          lineSegmentMPID: lineSegment.mpID,
        );
  }

  @override
  void onChangeCommandOptionTypeEdited({
    required THCommandOptionType? previousOptionType,
    required THCommandOptionType? newOptionType,
  }) {
    _saveLSizeOrientation(previousOptionType);

    _isLSizeOrientationEdit = _isLSizeOrientation(newOptionType);

    _lSizeOrientationInitialization();
    setStatusBarMessage();
  }

  void _lSizeOrientationInitialization() {
    if (!_isLSizeOrientationEdit) {
      return;
    }

    final Iterable<MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints.values;

    if (selectedEndPoints.length != 1) {
      _isLSizeOrientationEdit = false;
      return;
    }

    final THLineSegment lineSegment =
        selectedEndPoints.first.originalLineSegmentClone;
    final double pointLSize =
        MPCommandOptionAux.getLSize(lineSegment) ??
        mpSlopeLinePointDefaultLSize;
    final double pointOrientation =
        MPCommandOptionAux.getOrientation(lineSegment) ??
        MPNumericAux.segmentNormalFromTHFile(lineSegment.mpID, thFile);

    elementEditController.setLinePointLSizeAndOrientation(
      lSize: pointLSize,
      orientation: pointOrientation,
    );
  }

  bool _isLSizeOrientation(THCommandOptionType? optionType) {
    return (optionType == THCommandOptionType.orientation) ||
        (optionType == THCommandOptionType.lSize);
  }

  void _saveLSizeOrientation(
    THCommandOptionType? previousOptionTypeBeingEdited,
  ) {
    if (!_isLSizeOrientation(previousOptionTypeBeingEdited) ||
        (_lSizeOrientationDragStartState == null) ||
        (_lastLSizeOrientationDragUpdateResult == null)) {
      return;
    }

    final Map<int, MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints;

    if (selectedEndPoints.length != 1) {
      throw StateError(
        'Error: selectedEndPoints length is different from 1 at MPTH2FileEditStateEditSingleLine._setOrientationLSizeFromLocalPosition().',
      );
    }

    final MPSelectedEndControlPoint mpSelectedEndControlPoint =
        selectedEndPoints.values.first;

    if ((mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointBezierCurve) &&
        (mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointStraight)) {
      throw StateError(
        'Error: selectedEndControlPoint type is different from endPointBezierCurve and endPointStraight at MPTH2FileEditStateEditSingleLine._setOrientationLSizeFromLocalPosition().',
      );
    }

    elementEditController.applySetLinePointOrientationLSize(
      lSize:
          (_lSizeOrientationDragStartState!.lSizeEnabled ||
              MPInteractionAux.isAltPressed())
          ? _lastLSizeOrientationDragUpdateResult!.lSize
          : null,
      orientation:
          (_lSizeOrientationDragStartState!.orientationEnabled ||
              MPInteractionAux.isCtrlPressed() ||
              MPInteractionAux.isMetaPressed())
          ? _lastLSizeOrientationDragUpdateResult!.orientation
          : null,
    );

    _lSizeOrientationDragStartState = null;
    _lastLSizeOrientationDragUpdateResult = null;
  }

  void _lSizeOrientationDragUpdate(Offset clickScreenCoordinates) {
    final Map<int, MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints;

    if (selectedEndPoints.length != 1) {
      throw StateError(
        'Error: selectedEndPoints length is different from 1 at MPTH2FileEditStateEditSingleLine._setOrientationLSizeFromLocalPosition().',
      );
    }

    final MPSelectedEndControlPoint mpSelectedEndControlPoint =
        selectedEndPoints.values.first;

    if ((mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointBezierCurve) &&
        (mpSelectedEndControlPoint.type !=
            MPEndControlPointType.endPointStraight)) {
      throw StateError(
        'Error: selectedEndControlPoint type is different from endPointBezierCurve and endPointStraight at MPTH2FileEditStateEditSingleLine._setOrientationLSizeFromLocalPosition().',
      );
    }

    if (_lSizeOrientationDragStartState == null) {
      throw StateError(
        'Error: _lSizeOrientationDragStartState is null at MPTH2FileEditStateEditSingleLine._setOrientationLSizeFromLocalPosition().',
      );
    }

    _lastLSizeOrientationDragUpdateResult =
        MPLSizeOrientationAux.updateLinePointLSizeOrientationDrag(
          drag: _lSizeOrientationDragStartState!,
          pointCanvas: mpSelectedEndControlPoint
              .originalLineSegmentClone
              .endPoint
              .coordinates,
          mouseScreen: clickScreenCoordinates,
          th2FileEditController: th2FileEditController,
        );

    final double lSize =
        _lastLSizeOrientationDragUpdateResult!.lSize ??
        _lSizeOrientationDragStartState!.originalLSize;
    final double orientation =
        _lastLSizeOrientationDragUpdateResult!.orientation ??
        _lSizeOrientationDragStartState!.originalOrientation;

    elementEditController.setLinePointLSizeAndOrientation(
      orientation: orientation,
      lSize: lSize,
    );

    setStatusBarMessage();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
