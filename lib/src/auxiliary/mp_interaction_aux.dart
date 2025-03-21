import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';

class MPInteractionAux {
  static bool isShiftPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.shiftRight);
  }

  static bool isCtrlPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.controlRight);
  }

  static bool isAltPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.altLeft) ||
        HardwareKeyboard.instance.logicalKeysPressed
            .contains(LogicalKeyboardKey.altRight);
  }

  static Rect? getWidgetRectFromGlobalKey({
    required GlobalKey widgetGlobalKey,
    required GlobalKey ancestorGlobalKey,
  }) {
    if (widgetGlobalKey.currentContext == null) {
      return null;
    }

    final RenderObject? ancestor =
        ancestorGlobalKey.currentContext?.findRenderObject();

    final RenderBox renderBox =
        widgetGlobalKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(
      Offset.zero,
      ancestor: ancestor,
    );
    final Size size = renderBox.size;

    return MPNumericAux.orderedRectFromLTWH(
      top: position.dy,
      left: position.dx,
      width: size.width,
      height: size.height,
    );
  }

  static bool ignoreClick(
    Map<int, Rect> overlayWindowRects,
    int zOrder,
    Offset position,
  ) {
    for (final entry in overlayWindowRects.entries) {
      if (zOrder >= entry.key) {
        continue;
      }

      if (entry.value.contains(position)) {
        return true;
      }
    }

    return false;
  }
}
