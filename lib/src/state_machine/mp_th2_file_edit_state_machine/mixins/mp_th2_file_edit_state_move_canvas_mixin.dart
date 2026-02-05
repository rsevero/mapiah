part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveCanvasMixin on MPTH2FileEditState {
  /// Moves the canvas
  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController.onPointerMoveUpdateMoveCanvasMode(event);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    _onKeyDownEvent(event);
  }

  void _onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    bool handled = false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addArea,
          );
          handled = true;
        }
      case LogicalKeyboardKey.keyC:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          selectionController.setSelectionState();
          handled = true;
        }
      case LogicalKeyboardKey.keyK:
        if (!isCtrlPressed && !isMetaPressed && !isShiftPressed) {
          if (isAltPressed) {
            th2FileEditController.toggleToNextAvailableScrap();
          } else {
            th2FileEditController.elementEditController.addScrap();
          }
          handled = true;
        }
      case LogicalKeyboardKey.keyI:
        if (!isShiftPressed && !isCtrlPressed && !isMetaPressed) {
          if (isAltPressed) {
            th2FileEditController.overlayWindowController.toggleOverlayWindow(
              MPWindowType.changeImage,
            );
          } else {
            th2FileEditController.elementEditController.addImage();
          }
          handled = true;
        }
      case LogicalKeyboardKey.keyL:
        if (!isAltPressed &&
            !isMetaPressed &&
            !isShiftPressed &&
            !isCtrlPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addLine,
          );
          handled = true;
        }
      case LogicalKeyboardKey.keyN:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed &&
            (th2FileEditController
                    .selectionController
                    .mpSelectedElementsLogical
                    .length ==
                1) &&
            (th2FileEditController
                    .selectionController
                    .mpSelectedElementsLogical
                    .values
                    .toList()
                    .first
                is MPSelectedLine)) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.editSingleLine,
          );
          handled = true;
        }
      case LogicalKeyboardKey.keyP:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addPoint,
          );
          handled = true;
        }
      case LogicalKeyboardKey.keyS:
        if ((isCtrlPressed || isMetaPressed) && !isAltPressed) {
          if (th2FileEditController.enableSaveButton) {
            if (isShiftPressed && !kIsWeb) {
              th2FileEditController.saveAsTH2File();
            } else {
              th2FileEditController.saveTH2File();
            }
            handled = true;
          }
        }
      case LogicalKeyboardKey.keyY:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasRedo) {
          th2FileEditController.redo();
          handled = true;
        }
      case LogicalKeyboardKey.keyZ:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasUndo) {
          th2FileEditController.undo();
          handled = true;
        }
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.delete:
        selectionController.removeSelected();
        handled = true;
      case LogicalKeyboardKey.escape:
        selectionController.deselectAllElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        handled = true;
    }

    if (!handled) {
      switch (event.character) {
        case '1':
          th2FileEditController.zoomOneToOne();
        case '2':
          if (selectionController.mpSelectedElementsLogical.isNotEmpty) {
            th2FileEditController.zoomToFit(
              zoomFitToType: MPZoomToFitType.selection,
            );
          }
        case '3':
          th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        case '4':
          th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        case '+':
          th2FileEditController.zoomIn(fineZoom: false);
        case '-':
          th2FileEditController.zoomOut(fineZoom: false);
      }
    }
  }

  @override
  void onTertiaryButtonScroll(PointerScrollEvent event) {
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();

    if (isShiftPressed && !isCtrlPressed) {
      th2FileEditController.moveCanvasHorizontally(
        left: event.scrollDelta.dy < 0,
      );
    } else if (isCtrlPressed && !isShiftPressed) {
      th2FileEditController.moveCanvasVertically(up: event.scrollDelta.dy < 0);
    } else {
      if (event.scrollDelta.dy < 0) {
        th2FileEditController.zoomIn(
          fineZoom: true,
          zoomCenter: event.localPosition,
        );
      } else if (event.scrollDelta.dy > 0) {
        th2FileEditController.zoomOut(
          fineZoom: true,
          zoomCenter: event.localPosition,
        );
      }
    }
    th2FileEditController.triggerAllElementsRedraw();
  }
}
