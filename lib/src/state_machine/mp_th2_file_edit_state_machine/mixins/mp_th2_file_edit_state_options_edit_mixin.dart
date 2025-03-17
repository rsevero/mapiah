part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateOptionsEditMixin on MPTH2FileEditState {
  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    th2FileEditController.overlayWindowController
        .toggleOverlayWindow(MPOverlayWindowType.commandOptions);
  }
}
