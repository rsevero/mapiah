part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageAltClickMixin on MPTH2FileEditState {
  /// Search for a non active scrap under the pointer and select it when
  /// Alt+clicking. Returns true if a scrap was selected.
  bool onAltPrimaryButtonClick(PointerUpEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    if (isAltPressed && !isCtrlPressed && !isMetaPressed && !isShiftPressed) {
      th2FileEditController.onAltClickSelectScrap(event);

      return true;
    }

    return false;
  }
}
