part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddLineStatusBarMessage(
            elementEditController.lastAddedLineType.name));
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    elementEditController.finalizeNewLineCreation();
  }

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    elementEditController.addNewLineLineSegment(event.localPosition);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    elementEditController.updateBezierLineSegment(event.localPosition);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
        if (!isCtrlPressed && !isAltPressed && !isShiftPressed) {
          elementEditController.finalizeNewLineCreation();
          return;
        }
    }

    _onKeyDownEvent(event);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLine;
}
