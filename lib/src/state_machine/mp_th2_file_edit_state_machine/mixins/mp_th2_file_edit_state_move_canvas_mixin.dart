part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveCanvasMixin on MPTH2FileEditState {
  /// Moves the canvas
  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController.onPointerMoveUpdateMoveCanvasMode(event);
    th2FileEditController.triggerAllElementsRedraw();
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (isCtrlPressed && !isAltPressed && !isShiftPressed) {
          selectionController.selectAllElements();
        } else if (!isAltPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.addArea);
        }
        break;
      case LogicalKeyboardKey.keyC:
        if (isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.toggleToNextAvailableScrap();
        } else if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          selectionController.setSelectionState();
        }
        break;
      case LogicalKeyboardKey.keyL:
        if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.addLine);
        }
      case LogicalKeyboardKey.keyN:
        if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.editSingleLine);
        }
      case LogicalKeyboardKey.keyO:
        if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.optionsEdit);
        }
      case LogicalKeyboardKey.keyP:
        if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.addPoint);
        }
      case LogicalKeyboardKey.keyS:
        if (isCtrlPressed && !isAltPressed) {
          if (isShiftPressed) {
            th2FileEditController.saveAsTH2File();
          } else {
            th2FileEditController.saveTH2File();
          }
        }
        break;
      case LogicalKeyboardKey.keyY:
        if (isCtrlPressed && !isAltPressed && !isShiftPressed) {
          th2FileEditController.redo();
        }
        break;
      case LogicalKeyboardKey.keyZ:
        if (isCtrlPressed && !isAltPressed && !isShiftPressed) {
          th2FileEditController.undo();
        }
        break;
      case LogicalKeyboardKey.numpad1:
      case LogicalKeyboardKey.digit1:
        th2FileEditController.zoomOneToOne();
        break;
      case LogicalKeyboardKey.numpad2:
      case LogicalKeyboardKey.digit2:
        if (selectionController.selectedElements.isNotEmpty) {
          th2FileEditController.zoomToFit(
              zoomFitToType: MPZoomToFitType.selection);
        }
        break;
      case LogicalKeyboardKey.numpad3:
      case LogicalKeyboardKey.digit3:
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        break;
      case LogicalKeyboardKey.numpad4:
      case LogicalKeyboardKey.digit4:
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        break;
      case LogicalKeyboardKey.add:
      case LogicalKeyboardKey.numpadAdd:
        th2FileEditController.zoomIn(fineZoom: false);
        break;
      case LogicalKeyboardKey.delete:
        selectionController.deleteSelected();
        break;
      case LogicalKeyboardKey.escape:
        selectionController.deselectAllElements();
        break;
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        th2FileEditController.zoomOut(fineZoom: false);

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
      th2FileEditController.moveCanvasHorizontally(
          left: event.scrollDelta.dy < 0);
    } else if (isCtrlPressed) {
      th2FileEditController.moveCanvasVertically(up: event.scrollDelta.dy < 0);
    } else {
      if (event.scrollDelta.dy < 0) {
        th2FileEditController.zoomIn(fineZoom: true);
      } else if (event.scrollDelta.dy > 0) {
        th2FileEditController.zoomOut(fineZoom: true);
      }
    }
    th2FileEditController.triggerAllElementsRedraw();
  }
}
