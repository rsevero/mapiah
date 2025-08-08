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
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (isCtrlPressed && !isAltPressed && !isShiftPressed) {
          selectionController.selectAllElements();
        } else if (!isAltPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.addArea);
        }
      case LogicalKeyboardKey.keyC:
        if (isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.toggleToNextAvailableScrap();
        } else if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          selectionController.setSelectionState();
        }
      case LogicalKeyboardKey.keyI:
        if (isAltPressed && !isShiftPressed) {
          if (isCtrlPressed) {
            th2FileEditController.elementEditController.addImage();
          } else {
            th2FileEditController.overlayWindowController.toggleOverlayWindow(
              MPWindowType.changeImage,
            );
          }
        }
      case LogicalKeyboardKey.keyL:
        if (!isAltPressed && !isCtrlPressed && !isShiftPressed) {
          th2FileEditController.stateController
              .setState(MPTH2FileEditStateType.addLine);
        }
      case LogicalKeyboardKey.keyN:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isShiftPressed &&
            (th2FileEditController
                    .selectionController.mpSelectedElementsLogical.length ==
                1) &&
            (th2FileEditController
                .selectionController.mpSelectedElementsLogical.values
                .toList()
                .first is MPSelectedLine)) {
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
        print(
          'DEBUG (Mapiah): S pressed.',
        );
        if (isCtrlPressed &&
            !isAltPressed &&
            th2FileEditController.enableSaveButton) {
          print(
            'DEBUG (Mapiah): Ctrl-S pressed. Saving TH2 file: ${thFile.filename}',
          );
          if (isShiftPressed && !kIsWeb) {
            th2FileEditController.saveAsTH2File();
          } else {
            th2FileEditController.saveTH2File();
          }
        }
      case LogicalKeyboardKey.keyY:
        if (isCtrlPressed &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasRedo) {
          th2FileEditController.redo();
        }
      case LogicalKeyboardKey.keyZ:
        if (isCtrlPressed &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasUndo) {
          th2FileEditController.undo();
        }
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.delete:
        selectionController.removeSelected();
      case LogicalKeyboardKey.escape:
        selectionController.deselectAllElements();
        th2FileEditController.stateController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
    }

    switch (event.character) {
      case '1':
        th2FileEditController.zoomOneToOne();
      case '2':
        if (selectionController.mpSelectedElementsLogical.isNotEmpty) {
          th2FileEditController.zoomToFit(
              zoomFitToType: MPZoomToFitType.selection);
        }
      case '3':
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
      case '4':
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
      case '+':
        th2FileEditController.zoomIn(fineZoom: false);
      case '-':
        th2FileEditController.zoomOut(fineZoom: false);
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
