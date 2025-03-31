import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

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
    GlobalKey? ancestorGlobalKey,
  }) {
    if (widgetGlobalKey.currentContext == null) {
      return null;
    }

    return getWidgetRectFromContext(
      widgetContext: widgetGlobalKey.currentContext!,
      ancestorGlobalKey: ancestorGlobalKey,
    );
  }

  static Rect? getWidgetRectFromContext({
    required BuildContext widgetContext,
    GlobalKey? ancestorGlobalKey,
  }) {
    final RenderObject? ancestor =
        ancestorGlobalKey?.currentContext?.findRenderObject();

    final RenderBox renderBox = widgetContext.findRenderObject() as RenderBox;
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

  static List<Widget> getOverlayWindowBlockWithTopSpace({
    required BuildContext context,
    required List<Widget> children,
    required MPOverlayWindowBlockType overlayWindowBlockType,
    EdgeInsetsGeometry? padding,
  }) {
    return [
      const SizedBox(height: mpButtonSpace),
      MPOverlayWindowBlockWidget(
        children: children,
        overlayWindowBlockType: overlayWindowBlockType,
        padding: padding,
      ),
    ];
  }
}
