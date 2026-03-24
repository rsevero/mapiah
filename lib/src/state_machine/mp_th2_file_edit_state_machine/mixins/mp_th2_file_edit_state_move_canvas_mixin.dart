// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateMoveCanvasMixin on MPTH2FileEditState {
  /// Moves the canvas
  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController.onPointerMoveUpdateMoveCanvasMode(event);
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
