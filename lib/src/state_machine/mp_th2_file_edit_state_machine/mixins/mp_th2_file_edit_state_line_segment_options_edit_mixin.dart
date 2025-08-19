part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateLineSegmentOptionsEditMixin on MPTH2FileEditState {
  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    /// Bèzier curve line segment control points have no options.
    if (selectionController.getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.controlPoint) {
      th2FileEditController.overlayWindowController
          .perfomToggleLineSegmentOptionsOverlayWindow();
    }
  }
}
