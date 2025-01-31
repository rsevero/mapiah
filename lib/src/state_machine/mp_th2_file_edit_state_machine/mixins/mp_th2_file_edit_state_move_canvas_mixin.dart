part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveCanvasMixin on MPTH2FileEditState {
  /// Moves the canvas
  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditStore.onPointerMoveUpdateMoveCanvasMode(event);
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
  }
}
