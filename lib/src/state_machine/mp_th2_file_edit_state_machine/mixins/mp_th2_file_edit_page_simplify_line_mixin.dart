// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageSimplifyLineMixin on MPTH2FileEditState {
  bool onKeyLDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isMetaPressed = MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    bool cleanOriginalSimplifiedLines = true;
    bool keyProcessed = false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyL:
        if (isCtrlPressed || isMetaPressed) {
          cleanOriginalSimplifiedLines = false;
          if (isAltPressed && isShiftPressed) {
            th2FileEditController.openInteractiveLineSimplificationDialog();
          } else {
            final MPLineSimplificationMethod newLineSimplificationMethod;

            if (isAltPressed) {
              newLineSimplificationMethod =
                  MPLineSimplificationMethod.forceBezier;
            } else if (isShiftPressed) {
              newLineSimplificationMethod =
                  MPLineSimplificationMethod.forceStraight;
            } else {
              newLineSimplificationMethod =
                  MPLineSimplificationMethod.keepOriginalTypes;
            }

            elementEditController.setLineSimplificationMethod(
              newLineSimplificationMethod,
            );

            elementEditController.simplifySelectedLines();
          }
          keyProcessed = true;
        }
    }

    if (cleanOriginalSimplifiedLines) {
      elementEditController.resetOriginalFileForLineSimplification();
    }

    return keyProcessed;
  }
}
