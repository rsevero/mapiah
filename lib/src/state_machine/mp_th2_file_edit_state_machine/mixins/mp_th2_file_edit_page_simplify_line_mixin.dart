import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';

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
            /// TODO open line simplification dialog box.
          } else {
            final MPLineSimplificationMethod newLineSimplificationMethod;

            if (isAltPressed) {
              newLineSimplificationMethod =
                  MPLineSimplificationMethod.forceStraight;
            } else if (isShiftPressed) {
              newLineSimplificationMethod =
                  MPLineSimplificationMethod.forceBezier;
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
