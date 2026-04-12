// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLine extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateKeyDownMixin,
        MPTH2FileEditStateMoveModifiersMixin {
  MPTH2FileEditStateAddLine({required super.th2FileEditController});

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.precise);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    final MPPLATypeSubtype lineTypeSubtype = elementEditController
        .getLineTypeAndSubtypeForNewLine();

    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddLineStatusBarMessage(
        lineTypeSubtype.typeSubtypeID,
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (nextState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      th2FileEditController.areaLineCreationController
          .finalizeNewLineCreation();
    }
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final Offset snapedScreenOffset = snapController
        .getScreenSnapedOffsetFromScreenOffset(event.localPosition);

    th2FileEditController.areaLineCreationController.addNewLineLineSegment(
      snapedScreenOffset,
    );
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);
    th2FileEditController.areaLineCreationController.updateBezierLineSegment(
      event.localPosition,
    );
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    setCursor();
    th2FileEditController.areaLineCreationController.endNewLineDrag();
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

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          if (th2FileEditController.areaLineCreationController
              .canCancelUnfinishedXTherionLineCreation()) {
            th2FileEditController.areaLineCreationController
                .cancelUnfinishedXTherionLineCreation();

            return;
          }

          if (th2FileEditController.areaLineCreationController
              .canCancelUnfinishedQuadraticLineCreation()) {
            th2FileEditController.areaLineCreationController
                .cancelUnfinishedQuadraticLineCreation();

            return;
          }
        }
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.delete:
        if (_canRemoveLastCreatedInteractiveLineNode(
          isAltPressed: isAltPressed,
          isCtrlPressed: isCtrlPressed,
          isMetaPressed: isMetaPressed,
          isShiftPressed: isShiftPressed,
        )) {
          th2FileEditController.areaLineCreationController
              .removeLastCreatedLineNode();

          return;
        }
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          th2FileEditController.areaLineCreationController
              .finalizeNewLineCreation();

          return;
        }
      case LogicalKeyboardKey.keyL:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            isShiftPressed) {
          if (th2FileEditController.areaLineCreationController
              .canChangeLastSegmentToStraight()) {
            th2FileEditController.areaLineCreationController
                .changeLastSegmentToStraight();

            return;
          }
        }
      case LogicalKeyboardKey.keyU:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            isShiftPressed) {
          if (th2FileEditController.areaLineCreationController
              .canChangeLastSegmentToCurve()) {
            th2FileEditController.areaLineCreationController
                .changeLastSegmentToCurve();

            return;
          }
        }
    }

    _onKeyDownEvent(event);
  }

  @override
  void onKeyRepeatEvent(KeyRepeatEvent event) {
    _handleArrowMoveKey(event.logicalKey);
  }

  bool _handleArrowMoveKey(LogicalKeyboardKey logicalKey) {
    if (!th2FileEditController.areaLineCreationController
        .canNudgeLastCreatedLineNode()) {
      return false;
    }

    return handleArrowMoveKey(
      logicalKey: logicalKey,
      onMove: (Offset deltaOnCanvas) {
        th2FileEditController.areaLineCreationController
            .nudgeLastCreatedLineNodeByDeltaOnCanvas(deltaOnCanvas);
      },
    );
  }

  bool _canRemoveLastCreatedInteractiveLineNode({
    required bool isAltPressed,
    required bool isCtrlPressed,
    required bool isMetaPressed,
    required bool isShiftPressed,
  }) {
    if (isAltPressed || isCtrlPressed || isMetaPressed || isShiftPressed) {
      return false;
    }

    if (!th2FileEditController.areaLineCreationController
        .canRemoveLastCreatedLineNode()) {
      return false;
    }

    return true;
  }

  @override
  void onSelectAll() {
    selectionController.selectAllElements();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLine;
}
