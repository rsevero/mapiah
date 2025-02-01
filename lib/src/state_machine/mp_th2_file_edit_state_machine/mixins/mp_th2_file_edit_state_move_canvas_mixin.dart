part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveCanvasMixin on MPTH2FileEditState {
  /// Moves the canvas
  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditStore.onPointerMoveUpdateMoveCanvasMode(event);
    th2FileEditStore.triggerAllElementsRedraw();
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        if (isCtrlPressed) {
          th2FileEditStore.zoomOut(fineZoom: false);
        }
        break;
      case LogicalKeyboardKey.add:
      case LogicalKeyboardKey.numpadAdd:
        if (isCtrlPressed) {
          th2FileEditStore.zoomIn(fineZoom: false);
        }
        break;
    }
  }

  @override
  void onTertiaryButtonScroll(PointerScrollEvent event) {
    bool isShiftPressed = MPInteractionAux.isShiftPressed();
    bool isCtrlPressed = MPInteractionAux.isCtrlPressed();

    if (isShiftPressed && isCtrlPressed) {
      return;
    }

    if (isShiftPressed) {
      th2FileEditStore.moveCanvasHorizontally(left: event.scrollDelta.dy < 0);
    } else if (isCtrlPressed) {
      th2FileEditStore.moveCanvasVertically(up: event.scrollDelta.dy < 0);
    } else {
      if (event.scrollDelta.dy < 0) {
        th2FileEditStore.zoomIn(fineZoom: true);
      } else if (event.scrollDelta.dy > 0) {
        th2FileEditStore.zoomOut(fineZoom: true);
      }
    }
    th2FileEditStore.triggerAllElementsRedraw();
  }
}
