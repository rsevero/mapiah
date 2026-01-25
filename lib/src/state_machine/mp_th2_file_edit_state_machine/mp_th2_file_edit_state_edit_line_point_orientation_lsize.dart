part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateEditLinePointOrientationLSize extends MPTH2FileEditState
    with
        MPTH2FileEditPageSingleElementSelectedMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateLineSegmentOptionsEditMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateOptionsEditMixin {
  static const Set<MPTH2FileEditStateType> singleLineEditModes = {
    MPTH2FileEditStateType.editLinePointOrientationLSize,
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingEndControlPoints,
    MPTH2FileEditStateType.movingSingleControlPoint,
  };

  bool _hasDifferentOrientations = false;
  bool _hasDifferentLSizes = false;
  bool _valuesSetByUser = false;

  MPTH2FileEditStateEditLinePointOrientationLSize({
    required super.th2FileEditController,
  });

  @override
  void onSelectAll() {
    selectionController.selectAllEndPoints();
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    selectionController.updateAllSelectedElementsClones();
    selectionController.resetSelectedLineLineSegmentsMPIDs();
    selectionController.updateSelectableEndAndControlPoints();
    elementEditController.resetOriginalFileForLineSimplification();
    th2FileEditController.triggerEditLineRedraw();
    initializeOrientationLSize();
    setStatusBarMessage();
  }

  @override
  void setStatusBarMessage() {
    /// Ctrl/Meta forces orientation and Alt forces lsize to be set.
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String orientationString = _hasDifferentOrientations
        ? appLocalizations.mpChoiceMultipleValues
        : ((elementEditController.linePointOrientation == null)
              ? appLocalizations.mpChoiceUnset
              : elementEditController.linePointOrientation!.toStringAsFixed(1));
    final String lsizeString = _hasDifferentLSizes
        ? appLocalizations.mpChoiceMultipleValues
        : ((elementEditController.linePointLSize == null)
              ? appLocalizations.mpChoiceUnset
              : elementEditController.linePointLSize!.toStringAsFixed(1));
    final bool forceOrientation = _valuesSetByUser
        ? (isCtrlPressed || isMetaPressed)
        : false;
    final bool forceLSize = _valuesSetByUser ? isAltPressed : false;
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
          lsizeString,
          forcedLSizeString,
        );

    th2FileEditController.setStatusBarMessage(message);
  }

  void initializeOrientationLSize() {
    final Iterable<MPSelectedEndControlPoint> selectedEndPoints =
        selectionController.selectedEndControlPoints.values;

    bool isFirst = true;

    _hasDifferentOrientations = false;
    _hasDifferentLSizes = false;

    for (MPSelectedEndControlPoint selectedEndPoint in selectedEndPoints) {
      final THLineSegment lineSegment =
          selectedEndPoint.originalLineSegmentClone;
      final double? pointOrientation = MPCommandOptionAux.getOrientation(
        lineSegment,
      );
      final double? pointLSize = MPCommandOptionAux.getLSize(lineSegment);

      if (isFirst) {
        elementEditController.setLinePointOrientationValue(pointOrientation);
        elementEditController.setLinePointLSizeValue(pointLSize);
        isFirst = false;
        continue;
      }

      if (elementEditController.linePointOrientation != pointOrientation) {
        _hasDifferentOrientations = true;
        elementEditController.setLinePointOrientationValue(null);
      }

      if (elementEditController.linePointLSize != pointLSize) {
        _hasDifferentLSizes = true;
        elementEditController.setLinePointLSizeValue(null);
      }
    }
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    setStatusBarMessage();

    super.onKeyDownEvent(event);
  }

  @override
  void onKeyUpEvent(KeyUpEvent event) {
    setStatusBarMessage();

    super.onKeyUpEvent(event);
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (!_valuesSetByUser ||
        selectionController.selectedEndControlPoints.isEmpty) {
      return;
    }

    elementEditController.applySetLinePointOrientationLSize();
  }

  @override
  void onDeselectAll() {
    selectionController.deselectAllEndPoints();
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.editSingleLine,
    );
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

    // setClickedElementAtSingleLineEditPointerDown(null);

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

    if (clickedEndControlPoints.length == 1) {
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;

      // setClickedElementAtSingleLineEditPointerDown(
      //   clickedEndControlPoint.element,
      // );

      if (!shiftPressed) {
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
            break;
          }
        }
      }
      // setClickedElementAtSingleLineEditPointerDown(
      //   clickedEndControlPoints.first.element,
      // );
    }

    th2FileEditController.triggerEditLineRedraw();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {}

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    // final List<THLineSegment> endpointsInsideSelectionWindow =
    //     getEndPointsInsideSelectionWindow(event.localPosition);
    // final bool shiftPressed = MPInteractionAux.isShiftPressed();

    // selectionController.clearSelectionWindow();

    // if (shiftPressed) {
    //   if (endpointsInsideSelectionWindow.isNotEmpty) {
    //     selectionController.addSelectedEndPoints(
    //       endpointsInsideSelectionWindow,
    //     );
    //   }
    // } else {
    //   if (endpointsInsideSelectionWindow.isEmpty) {
    //     selectionController.clearSelectedLineSegments();
    //   } else {
    //     selectionController.setSelectedEndPoints(
    //       endpointsInsideSelectionWindow,
    //     );
    //   }
    // }

    // selectionController.updateSelectableEndAndControlPoints();
    // th2FileEditController.triggerEditLineRedraw();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.editLinePointOrientationLSize;
}
