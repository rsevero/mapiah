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
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (isCtrlPressed) {
          th2FileEditStore.selectAllElements();
        }
        break;
      case LogicalKeyboardKey.keyC:
        if (isAltPressed) {
          th2FileEditStore.toggleToNextAvailableScrap();
        }
        break;
      case LogicalKeyboardKey.keyS:
        if (isCtrlPressed) {
          if (isShiftPressed) {
            th2FileEditStore.saveAsTH2File();
          } else {
            th2FileEditStore.saveTH2File();
          }
        }
        break;
      case LogicalKeyboardKey.keyY:
        if (isCtrlPressed) {
          th2FileEditStore.redo();
        }
        break;
      case LogicalKeyboardKey.keyZ:
        if (isCtrlPressed) {
          th2FileEditStore.undo();
        }
        break;
      case LogicalKeyboardKey.numpad1:
      case LogicalKeyboardKey.digit1:
        th2FileEditStore.zoomOneToOne();
        break;
      case LogicalKeyboardKey.numpad2:
      case LogicalKeyboardKey.digit2:
        if (th2FileEditStore.selectedElements.isNotEmpty) {
          th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.selection);
        }
        break;
      case LogicalKeyboardKey.numpad3:
      case LogicalKeyboardKey.digit3:
        th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        break;
      case LogicalKeyboardKey.numpad4:
      case LogicalKeyboardKey.digit4:
        th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        break;
      case LogicalKeyboardKey.add:
      case LogicalKeyboardKey.numpadAdd:
        th2FileEditStore.zoomIn(fineZoom: false);

        break;
      case LogicalKeyboardKey.escape:
        th2FileEditStore.deselectAllElements();
        break;
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        th2FileEditStore.zoomOut(fineZoom: false);

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
