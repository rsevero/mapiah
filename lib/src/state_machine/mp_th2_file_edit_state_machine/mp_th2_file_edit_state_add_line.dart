// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddLine({required super.th2FileEditController});

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.precise);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddLineStatusBarMessage(
        elementEditController.lastUsedLineType,
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
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
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
    }

    _onKeyDownEvent(event);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLine;
}
