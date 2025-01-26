import 'package:flutter/services.dart';

class MPInteractionAux {
  static bool isShiftPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
  }
}
