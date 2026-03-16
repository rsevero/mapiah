// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateLineSegmentOptionsEditMixin on MPTH2FileEditState {
  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    /// Bézier curve line segment control points have no options.
    if (selectionController.getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.controlPoint) {
      th2FileEditController.overlayWindowController
          .perfomToggleLineSegmentOptionsOverlayWindow();
    }
  }
}
