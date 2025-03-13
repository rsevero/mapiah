import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  static Rect? getWidgetRect(GlobalKey widgetKey) {
    if (widgetKey.currentContext == null) {
      return null;
    }

    final RenderBox renderBox =
        widgetKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = (renderBox.parentData! as BoxParentData).offset;
    final Size size = renderBox.size;

    return MPNumericAux.orderedRectFromLTWH(
      left: position.dx,
      top: position.dy,
      width: position.dx + size.width,
      height: position.dy + size.height,
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
