// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateOptionsEditMixin on MPTH2FileEditState {
  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    openOptionEditOverlayWindowOnSelected();
  }

  void openOptionEditOverlayWindowOnSelected() {
    if (th2FileEditController.optionEditController.currentOptionElementsType ==
        MPOptionElementType.lineSegment) {
      openLineSegmentOptionsOverlayWindow();
    } else {
      if (selectionController.mpSelectedElementsLogical.isEmpty) {
        th2FileEditController.optionEditController
            .showDefaultOptionsOverlayWindow();
      } else {
        openOptionEditOverlayWindow();
      }
    }
  }

  void openOptionEditOverlayWindow() {
    th2FileEditController.optionEditController.showOptionsOverlayWindow();
  }

  void openLineSegmentOptionsOverlayWindow() {
    th2FileEditController.overlayWindowController
        .perfomToggleLineSegmentOptionsOverlayWindow();
  }

  bool onKeyODownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    bool keyProcessed = false;

    if (event.logicalKey == LogicalKeyboardKey.keyO) {
      if (!isAltPressed &&
          !isCtrlPressed &&
          !isMetaPressed &&
          !isShiftPressed) {
        openOptionEditOverlayWindowOnSelected();
        keyProcessed = true;
      }
    }

    return keyProcessed;
  }
}
