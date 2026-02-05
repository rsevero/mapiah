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

    bool keyProcessed = false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyA:
        if (!isCtrlPressed &&
            !isMetaPressed &&
            !isAltPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addArea,
          );
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyC:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          selectionController.setSelectionState();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyK:
        if (!isCtrlPressed && !isMetaPressed && !isShiftPressed) {
          if (isAltPressed) {
            th2FileEditController.toggleToNextAvailableScrap();
          } else {
            th2FileEditController.elementEditController.addScrap();
          }
          keyProcessed = true;
        } else if (isCtrlPressed || isMetaPressed) {
          if (!isAltPressed && !isShiftPressed) {
            final BuildContext? context = th2FileEditController
                .getTHFileWidgetGlobalKey()
                .currentContext;

            if (context == null) {
              throw Exception(
                'At MPTH2FileEditStateMoveCanvasMixin._onKeyDownEvent() keyK: unable to get TH file widget context to show help dialog.',
              );
            }

            final AppLocalizations appLocalizations =
                mpLocator.appLocalizations;

            MPDialogAux.showHelpDialog(
              context,
              mpHelpPageKeyboardShortcutsEdit,
              appLocalizations.mapiahKeyboardShortcutsTitle,
            );
            keyProcessed = true;
          }
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
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyL:
        if (!isAltPressed &&
            !isMetaPressed &&
            !isShiftPressed &&
            !isCtrlPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addLine,
          );
          keyProcessed = true;
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
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyP:
        if (!isAltPressed &&
            !isCtrlPressed &&
            !isMetaPressed &&
            !isShiftPressed) {
          th2FileEditController.stateController.setState(
            MPTH2FileEditStateType.addPoint,
          );
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyS:
        if ((isCtrlPressed || isMetaPressed) && !isAltPressed) {
          if (th2FileEditController.enableSaveButton) {
            if (isShiftPressed && !kIsWeb) {
              th2FileEditController.saveAsTH2File();
            } else {
              th2FileEditController.saveTH2File();
            }
            keyProcessed = true;
          }
        }
      case LogicalKeyboardKey.keyY:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasRedo) {
          th2FileEditController.redo();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.keyZ:
        if ((isCtrlPressed || isMetaPressed) &&
            !isAltPressed &&
            !isShiftPressed &&
            th2FileEditController.hasUndo) {
          th2FileEditController.undo();
          keyProcessed = true;
        }
      case LogicalKeyboardKey.backspace:
      case LogicalKeyboardKey.delete:
        selectionController.removeSelected();
        keyProcessed = true;
      case LogicalKeyboardKey.escape:
        selectionController.deselectAllElements();
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.selectEmptySelection,
        );
        keyProcessed = true;
    }

    if (!keyProcessed) {
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
