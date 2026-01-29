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

    /// Ctrl/Meta forces orientation and Alt forces lsize to be set.
    final bool forceOrientation =
        (elementEditController.linePointOrientationLSizeSettingMode ==
            MPLinePointInteractiveOrientationLSizeSettingMode.orientation)
        ? true
        : (_valuesSetByUser
              ? (MPInteractionAux.isCtrlPressed() ||
                    MPInteractionAux.isMetaPressed())
              : false);
    final bool forceLSize =
        (elementEditController.linePointOrientationLSizeSettingMode ==
            MPLinePointInteractiveOrientationLSizeSettingMode.lsize)
        ? true
        : (_valuesSetByUser ? MPInteractionAux.isAltPressed() : false);
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
    _valuesSetByUser = true;
  }

  @override
  Future<void> onPrimaryButtonPointerDown(PointerDownEvent event) async {
    _setOrientationLSizeFromLocalPosition(event.localPosition);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    _setOrientationLSizeFromLocalPosition(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    _setOrientationLSizeFromLocalPosition(event.localPosition);
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
    final double lsize = distanceFromCenter * mpLSizeCanvasSizeFactor;

    elementEditController.setLinePointLSizeValue(lsize);

    setStatusBarMessage();
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.editLinePointOrientationLSize;
}
