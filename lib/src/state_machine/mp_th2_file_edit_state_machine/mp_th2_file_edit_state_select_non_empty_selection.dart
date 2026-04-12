// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

enum _MPSelectedElementsTransformDragMode { none, scale }

class MPTH2FileEditStateSelectNonEmptySelection extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditPageSimplifyLineMixin,
        MPTH2FileEditPageSingleElementSelectedMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveModifiersMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateKeyDownMixin,
        MPTH2FileEditStateOptionsEditMixin,
        MPTH2FileEditStateResetAreaBorderCtrlMetaCycleMixin {
  _MPSelectedElementsTransformDragMode _dragMode =
      _MPSelectedElementsTransformDragMode.none;
  Rect? _scaleStartBounds;
  Offset? _dragStartCanvasPosition;
  Offset? _scaleStartScreenHandleCenter;
  MPSelectionHandleType? _scaleHandleType;
  bool _ignoreNextClick = false;

  MPTH2FileEditStateSelectNonEmptySelection({
    required super.th2FileEditController,
  });

  @override
  void setCursor() {
    if (_dragMode == _MPSelectedElementsTransformDragMode.scale) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);

      return;
    }

    if (!th2FileEditController
        .moveScaleRotateElementController
        .shouldShowElementTransformHandles) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);

      return;
    }

    final MPSelectionHandleType? hoveredHandle = th2FileEditController
        .moveScaleRotateElementController
        .getSelectionHandleAtScreenPosition(
          th2FileEditController.mousePosition,
        );

    if (hoveredHandle != null) {
      final MPImageTransformHandleType imageHandleType = th2FileEditController
          .moveScaleRotateElementController
          .toImageTransformHandleType(hoveredHandle);

      switch (imageHandleType) {
        case MPImageTransformHandleType.topLeft:
        case MPImageTransformHandleType.bottomRight:
          th2FileEditController.setCanvasCursor(
            SystemMouseCursors.resizeUpRightDownLeft,
          );
        case MPImageTransformHandleType.topRight:
        case MPImageTransformHandleType.bottomLeft:
          th2FileEditController.setCanvasCursor(
            SystemMouseCursors.resizeUpLeftDownRight,
          );
        case MPImageTransformHandleType.topCenter:
        case MPImageTransformHandleType.bottomCenter:
          th2FileEditController.setCanvasCursor(
            SystemMouseCursors.resizeUpDown,
          );
        case MPImageTransformHandleType.centerLeft:
        case MPImageTransformHandleType.centerRight:
          th2FileEditController.setCanvasCursor(
            SystemMouseCursors.resizeLeftRight,
          );
      }

      return;
    }

    th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);
  }

  @override
  void onSelectAll() {
    selectionController.selectAllElements();
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    if (previousState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      selectionController.clearSelectedEndControlPoints();
      selectionController.clearSelectedLineSegments();
      elementEditController.resetOriginalFileForLineSimplification();
    }
    updateStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (_dragMode == _MPSelectedElementsTransformDragMode.scale) {
      th2FileEditController.moveScaleRotateElementController
          .restoreSelectedElementsFromClones(updateRedraw: false);
      _resetScalePreview();
    }

    if (nextState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      elementEditController.resetOriginalFileForLineSimplification();
      onStateExitClearSelectionOnExit(nextState);
    }
    th2FileEditController.setStatusBarMessage('');
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
    if (_ignoreNextClick) {
      _ignoreNextClick = false;

      return Future.value();
    }

    if (onAltPrimaryButtonClick(event)) {
      return Future.value();
    }

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final bool ctrlOrMetaOnlyPressed =
        (MPInteractionAux.isCtrlPressed() ||
            MPInteractionAux.isMetaPressed()) &&
        !shiftPressed &&
        !MPInteractionAux.isAltPressed();

    // Fast path: if transforms are enabled and no modifiers are pressed, check
    // without a dialog whether all elements at this position are already
    // selected. If so, switch to rotate mode immediately — no dialog needed.
    if (th2FileEditController
            .moveScaleRotateElementController
            .shouldShowElementTransformHandles &&
        !shiftPressed &&
        !ctrlOrMetaOnlyPressed) {
      final List<THElement> quickClicked = selectionController
          .getSelectableElementsClickedWithoutDialog(
            screenCoordinates: event.localPosition,
            selectionType: THSelectionType.pla,
          )
          .values
          .toList();

      if (quickClicked.isNotEmpty &&
          quickClicked.every(selectionController.isElementSelected)) {
        selectionController.clearClickedElementsAtPointerDown();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.elementRotate,
        );

        return Future.value();
      }
    }

    final List<THElement> clickedElements =
        (await selectionController.getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
          canBeMultiple: true,
          presentMultipleElementsClickedWidget: true,
        )).values.toList();

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
        } else if (ctrlOrMetaOnlyPressed) {
          selectionController.setSelectedElements(
            clickedElements,
            setState: true,
          );
        }

        return Future.value();
      } else {
        late bool stateChanged;

        if (shiftPressed) {
          stateChanged = selectionController.addSelectedElements(
            clickedElements,
            setState: true,
          );
        } else {
          stateChanged = selectionController.setSelectedElements(
            clickedElements,
            setState: true,
          );
        }

        if (!stateChanged) {
          updateStatusBarMessage();
        }

        return Future.value();
      }
    } else {
      if (!shiftPressed) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      }
    }

    return Future.value();
  }

  @override
  Future<void> onPrimaryButtonDoubleClick(PointerUpEvent event) async {
    final Map<int, THElement> clickedLineSegments = selectionController
        .getSelectableElementsClickedWithoutDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.lineSegment,
        );

    if (clickedLineSegments.isNotEmpty) {
      final THLineSegment clickedLineSegment =
          clickedLineSegments.values.first as THLineSegment;
      final THLine parentLine = th2File.lineByMPID(
        clickedLineSegment.parentMPID,
      );

      selectionController.setSelectedElements(<THElement>[parentLine]);
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );

      return;
    }

    final Map<int, THElement> clickedElements = selectionController
        .getSelectableElementsClickedWithoutDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
        );

    for (final THElement clickedElement in clickedElements.values) {
      if (clickedElement is! THLine) {
        continue;
      }

      selectionController.setSelectedElements(<THElement>[clickedElement]);
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.editSingleLine,
      );

      return;
    }
  }

  /// 1. Mark the start point of the pan.
  /// 2. Did the pan start click on an object?
  /// 2.1. Yes. Is Shift pressed?
  /// 2.1.1. Yes. Do nothing.
  /// 2.1.2. No. Was the object already selected?
  /// 2.1.2.1. Yes. Change to [MPTH2FileEditStateType.movingElements];
  /// 2.1.2.2. No. Clear current selection; include clicked object in the
  /// selection. Change to [MPTH2FileEditStateType.movingElements];
  /// 2.2. No. Do nothing.
  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final bool altPressed = MPInteractionAux.isAltPressed();
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final bool ctrlOrMetaOnlyPressed =
        (MPInteractionAux.isCtrlPressed() ||
            MPInteractionAux.isMetaPressed()) &&
        !shiftPressed &&
        !altPressed;

    elementEditController.resetOriginalFileForLineSimplification();
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );
    selectionController.clearClickedElementsAtPointerDown();

    final MPSelectionHandleType? handleType =
        th2FileEditController
            .moveScaleRotateElementController
            .shouldShowElementTransformHandles
        ? th2FileEditController.moveScaleRotateElementController
              .getSelectionHandleAtScreenPosition(event.localPosition)
        : null;

    if (handleType != null) {
      _startScaleDrag(handleType: handleType);

      return;
    }

    // When cycling area-border lines, skip drag-start detection to avoid
    // advancing the cycle index twice (pointer-down + pointer-up).
    if (ctrlOrMetaOnlyPressed || altPressed) {
      return;
    }

    final Map<int, THElement> clickedElements = selectionController
        .getSelectableElementsClickedWithoutDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.pla,
        );

    if (clickedElements.isNotEmpty) {
      if (!shiftPressed) {
        bool alreadySelected = false;

        for (final THElement element in clickedElements.values) {
          if (selectionController.isElementSelected(element)) {
            alreadySelected = true;
            break;
          }
        }

        selectionController.setClickedElementsAtPointerDown(
          alreadySelected ? {} : clickedElements.values,
        );
      }
    }
  }

  /// Draw the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    if (_dragMode == _MPSelectedElementsTransformDragMode.scale) {
      _updateScalePreview(event);

      return;
    }

    selectionController.setSelectionWindowScreenEndCoordinates(
      event.localPosition,
    );
    final bool altPressed = MPInteractionAux.isAltPressed();

    if (altPressed) {
      selectionController.clearSelectionWindow();
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.movingElements,
      );
      return;
    }

    if (selectionController.clickedElementsAtPointerDown.isNotEmpty) {
      selectionController.substituteSelectedElementsByClickedElements();
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.movingElements,
      );
    } else {
      final bool shiftPressed = MPInteractionAux.isShiftPressed();

      if (!shiftPressed) {
        final List<THElement> clickedElements =
            (selectionController.getSelectableElementsClickedWithoutDialog(
              screenCoordinates: event.localPosition,
              selectionType: THSelectionType.pla,
            )).values.toList();

        bool clickedOnSelectedElement = false;

        for (final THElement clickedElement in clickedElements) {
          if (selectionController.isElementSelected(clickedElement)) {
            clickedOnSelectedElement = true;
            break;
          }
        }

        if (clickedOnSelectedElement) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.movingElements,
          );
        }
      }
    }
  }

  /// 1. Create a list of objects inside the selection window.
  /// 2. Clear the selection window.
  /// 3. Is Shift pressed?
  /// 3.1. Yes. Include objects not yet selected in the selection;
  /// 3.2. No. Clear current selection. Is the list of objects inside the
  /// selection window empty?
  /// 3.2.1. Yes. Change to [MPTH2FileEditStateType.selectEmptySelection];
  /// 3.2.2. No. Include objects from the list inside the selection window in
  /// the current selection.

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    if (_dragMode == _MPSelectedElementsTransformDragMode.scale) {
      _commitScalePreview();

      return;
    }

    final List<THElement> elementsInsideSelectionWindow =
        getSelectedElementsWithLineSegmentsConvertedToLines(
          getObjectsInsideSelectionWindow(event.localPosition),
        );
    final bool shiftPressed = MPInteractionAux.isShiftPressed();

    selectionController.clearSelectionWindow();

    if (shiftPressed) {
      final bool stateChanged = selectionController.addSelectedElements(
        elementsInsideSelectionWindow,
        setState: true,
      );

      if (!stateChanged) {
        updateStatusBarMessage();
      }
    } else {
      if (elementsInsideSelectionWindow.isEmpty) {
        selectionController.clearSelectedElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
      } else {
        final bool stateChanged = selectionController.setSelectedElements(
          elementsInsideSelectionWindow,
          setState: true,
        );

        if (!stateChanged) {
          updateStatusBarMessage();
        }
      }
    }
  }

  @override
  void updateStatusBarMessage() {
    final int selectedElementsCount =
        selectionController.mpSelectedElementsLogical.length;
    final String message;

    if (selectedElementsCount == 1) {
      message = _getStatusBarMessageForSingleSelectedElement();
    } else {
      final List<int> selectedElementsCounts = getSelectedElementsCount();

      message = mpLocator.appLocalizations
          .mpNonEmptySelectionStateAreasLinesAndPointsStatusBarMessage(
            selectedElementsCounts[0],
            selectedElementsCounts[1],
            selectedElementsCounts[2],
          );
    }

    th2FileEditController.setStatusBarMessage(message);
  }

  @override
  void onDeselectAll() {
    th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectEmptySelection,
    );
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    if (_handleArrowMoveKey(event.logicalKey)) {
      return;
    }

    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    bool keyProcessed = false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          onSelectAll();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyC:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.copyPasteController.copySelectedElements();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyD:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.copyPasteController.duplicateSelectedElements();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyJ:
        if (!isCtrlPressed && !isMetaPressed && !isAltPressed) {
          if (th2FileEditController.hasSelectedLines) {
            th2FileEditController.stateController.onButtonPressed(
              isShiftPressed
                  ? MPButtonType.convertLineSegmentsToStraight
                  : MPButtonType.convertLineSegmentsToBezier,
            );
          }
          keyProcessed = true;
        } else if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.onButtonPressed(
            MPButtonType.joinLinesAtCoincidingExtremities,
          );
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyM:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.onButtonPressed(
            MPButtonType.mergeAreas,
          );
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyL:
        keyProcessed = onKeyLDownEvent(event);
      case LogicalKeyboardKey.keyO:
        keyProcessed = onKeyODownEvent(event);
      case LogicalKeyboardKey.keyS:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.elementEditController
              .toggleSelectedLinesSmoothOption();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyR:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.elementEditController
              .toggleSelectedLinesReverseOption();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyH:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController
                .moveScaleRotateElementController
                .isElementTransformsEnabled) {
          th2FileEditController.moveScaleRotateElementController
              .flipSelectedElementsHorizontally();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyV:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController
                .moveScaleRotateElementController
                .isElementTransformsEnabled) {
          th2FileEditController.moveScaleRotateElementController
              .flipSelectedElementsVertically();
          keyProcessed = true;
        } else if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.copyPasteController.pasteElements();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyX:
        if ((isCtrlPressed || isMetaPressed) &&
            isShiftPressed &&
            !isAltPressed) {
          th2FileEditController.stateController.onButtonPressed(
            MPButtonType.splitLinesAtCrossings,
          );
          keyProcessed = true;
        } else if ((isCtrlPressed || isMetaPressed) && !isShiftPressed) {
          if (isAltPressed) {
            th2FileEditController.areaLineCreationController
                .createMapConnectionLines();
            keyProcessed = true;
          } else {
            th2FileEditController.copyPasteController.cutSelectedElements();
            keyProcessed = true;
          }
        }
    }

    if (keyProcessed) {
      return;
    }

    _onKeyDownEvent(event);
  }

  @override
  void onKeyRepeatEvent(KeyRepeatEvent event) {
    _handleArrowMoveKey(event.logicalKey);
  }

  @override
  MPTH2FileEditStateType get type =>
      MPTH2FileEditStateType.selectNonEmptySelection;

  bool _handleArrowMoveKey(LogicalKeyboardKey logicalKey) {
    return handleArrowMoveKey(
      logicalKey: logicalKey,
      onMove: (Offset deltaOnCanvas) {
        final MPCommand moveCommand =
            MPCommandFactory.moveElementsFromDeltaOnCanvas(
              mpSelectedElements:
                  selectionController.mpSelectedElementsLogical.values,
              deltaOnCanvas: deltaOnCanvas,
              decimalPositions: th2FileEditController.currentDecimalPositions,
            );

        th2FileEditController.execute(moveCommand);
        selectionController.updateAllSelectedElementsClones();
        th2FileEditController.triggerSelectedElementsRedraw(setState: true);
      },
    );
  }

  void _startScaleDrag({required MPSelectionHandleType handleType}) {
    _dragMode = _MPSelectedElementsTransformDragMode.scale;
    _scaleHandleType = handleType;
    _scaleStartBounds = selectionController.selectedElementsBoundingBox;
    _dragStartCanvasPosition = th2FileEditController
        .moveScaleRotateElementController
        .selectionHandlePointOnBounds(_scaleStartBounds!, handleType);
    _scaleStartScreenHandleCenter = th2FileEditController.offsetCanvasToScreen(
      selectionController.getSelectionHandleCenters()[handleType]!,
    );
    _ignoreNextClick = true;
    setCursor();
  }

  void _updateScalePreview(PointerMoveEvent event) {
    final Rect? startBounds = _scaleStartBounds;
    final MPSelectionHandleType? handleType = _scaleHandleType;
    final Offset? dragStartCanvasPosition = _dragStartCanvasPosition;
    final Offset? scaleStartScreenHandleCenter = _scaleStartScreenHandleCenter;

    if ((startBounds == null) ||
        (handleType == null) ||
        (dragStartCanvasPosition == null) ||
        (scaleStartScreenHandleCenter == null)) {
      return;
    }

    final bool isShiftPressed = MPInteractionAux.isShiftPressed();
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final Offset dragDeltaOnScreen =
        event.localPosition - scaleStartScreenHandleCenter;
    final Offset rawCanvasPosition =
        dragStartCanvasPosition +
        (th2FileEditController.offsetScreenToCanvas(dragDeltaOnScreen) -
            th2FileEditController.offsetScreenToCanvas(Offset.zero));
    final Offset canvasPosition = isAltPressed
        ? dragStartCanvasPosition +
              ((rawCanvasPosition - dragStartCanvasPosition) *
                  mpCanvasMovementFactor)
        : rawCanvasPosition;
    final Offset anchorCanvas = isShiftPressed
        ? startBounds.center
        : th2FileEditController.moveScaleRotateElementController
              .selectionHandlePointOnBounds(
                startBounds,
                th2FileEditController.moveScaleRotateElementController
                    .oppositeSelectionHandleType(handleType),
              );
    final Offset handleCanvas = th2FileEditController
        .moveScaleRotateElementController
        .selectionHandlePointOnBounds(startBounds, handleType);
    final ({double xScale, double yScale}) resolvedScales = _resolveScales(
      startBounds: startBounds,
      handleType: handleType,
      anchorCanvas: anchorCanvas,
      handleCanvas: handleCanvas,
      currentCanvasPosition: canvasPosition,
      preserveAspectRatio:
          MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed(),
    );

    th2FileEditController.moveScaleRotateElementController
        .scaleSelectedElements(
          anchorCanvas: anchorCanvas,
          xScaleFactor: resolvedScales.xScale,
          yScaleFactor: resolvedScales.yScale,
        );
  }

  ({double xScale, double yScale}) _resolveScales({
    required Rect startBounds,
    required MPSelectionHandleType handleType,
    required Offset anchorCanvas,
    required Offset handleCanvas,
    required Offset currentCanvasPosition,
    required bool preserveAspectRatio,
  }) {
    double xScale = 1.0;
    double yScale = 1.0;
    final MPImageTransformHandleType imageHandleType = th2FileEditController
        .moveScaleRotateElementController
        .toImageTransformHandleType(handleType);

    if (imageHandleType.affectsX) {
      final double denominator = handleCanvas.dx - anchorCanvas.dx;

      if (denominator.abs() >= mpDoubleComparisonEpsilon) {
        xScale = th2FileEditController.moveScaleRotateElementController
            .avoidZeroScale(
              (currentCanvasPosition.dx - anchorCanvas.dx) / denominator,
            );
      }
    }

    if (imageHandleType.affectsY) {
      final double denominator = handleCanvas.dy - anchorCanvas.dy;

      if (denominator.abs() >= mpDoubleComparisonEpsilon) {
        yScale = th2FileEditController.moveScaleRotateElementController
            .avoidZeroScale(
              (currentCanvasPosition.dy - anchorCanvas.dy) / denominator,
            );
      }
    }

    if (!preserveAspectRatio) {
      return (xScale: xScale, yScale: yScale);
    }

    final double ratio = _resolveAspectRatio(
      imageHandleType: imageHandleType,
      xScale: xScale,
      yScale: yScale,
    );

    return (
      xScale: th2FileEditController.moveScaleRotateElementController
          .avoidZeroScale(ratio),
      yScale: th2FileEditController.moveScaleRotateElementController
          .avoidZeroScale(ratio),
    );
  }

  double _resolveAspectRatio({
    required MPImageTransformHandleType imageHandleType,
    required double xScale,
    required double yScale,
  }) {
    if (imageHandleType.affectsX && !imageHandleType.affectsY) {
      return xScale;
    }

    if (imageHandleType.affectsY && !imageHandleType.affectsX) {
      return yScale;
    }

    return ((xScale - 1.0).abs() >= (yScale - 1.0).abs()) ? xScale : yScale;
  }

  void _commitScalePreview() {
    _resetScalePreview();
    th2FileEditController.moveScaleRotateElementController
        .finalizeSelectedElementsTransform();
  }

  void _resetScalePreview() {
    _dragMode = _MPSelectedElementsTransformDragMode.none;
    _scaleStartBounds = null;
    _dragStartCanvasPosition = null;
    _scaleStartScreenHandleCenter = null;
    _scaleHandleType = null;
    _ignoreNextClick = false;
    setCursor();
  }
}
