import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
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
    String? title,
    required List<Widget> children,
    required MPOverlayWindowBlockType overlayWindowBlockType,
    EdgeInsetsGeometry? padding,
  }) {
    return [
      const SizedBox(height: mpButtonSpace),
      MPOverlayWindowBlockWidget(
        children: children,
        title: title,
        overlayWindowBlockType: overlayWindowBlockType,
        padding: padding,
      ),
    ];
  }

  static double calculateTextFieldWidth(int maxDigits) {
    return (maxDigits * 10.0) + 24;
  }

  static double calculateWarningMessageWidth(int messageLength) {
    return (messageLength * 6.5) + 24;
  }

  static int insideRange({
    required int value,
    required int min,
    required int max,
  }) {
    if (value < min) {
      return min;
    } else if (value > max) {
      return max;
    }

    return value;
  }

  static bool isValidID(String id) {
    final RegExp validIDRegex = RegExp(r'^[A-Za-z0-9_/][A-Za-z0-9_\-/]*$');

    return validIDRegex.hasMatch(id);
  }

  static void addWidgetWithTopSpace(
      List<Widget> widgetsList, Widget newWidget) {
    widgetsList.add(const SizedBox(height: mpButtonSpace));
    widgetsList.add(newWidget);
  }

  static Offset getScrapsButtonOuterAnchor(
    TH2FileEditController th2FileEditController,
  ) {
    Offset outerAnchorPosition = Offset.zero;

    final GlobalKey changeScrapButtonGlobalKey = th2FileEditController
        .overlayWindowController
        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeScrapButton]!;
    final Rect? changeScrapButtonBoundingBox =
        MPInteractionAux.getWidgetRectFromGlobalKey(
      widgetGlobalKey: changeScrapButtonGlobalKey,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    if (changeScrapButtonBoundingBox != null) {
      outerAnchorPosition = Offset(
          changeScrapButtonBoundingBox.left - mpButtonSpace,
          changeScrapButtonBoundingBox.center.dy);
    }
    return outerAnchorPosition;
  }
}
