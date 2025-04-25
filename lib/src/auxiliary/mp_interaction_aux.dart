import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/painters/types/mp_point_shape_type.dart';
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

  static void drawPoint({
    required Canvas canvas,
    required Offset position,
    required THPointPaint pointPaint,
  }) {
    switch (pointPaint.type) {
      case MPPointShapeType.asterisk:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawAsteriskPoint,
        );
      case MPPointShapeType.circle:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawCirclePoint,
        );
      case MPPointShapeType.horizontalDiamond:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawHorizontalDiamondPoint,
        );
      case MPPointShapeType.invertedT:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawInvertedTPoint,
        );
      case MPPointShapeType.invertedTriangle:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawInvertedTrianglePoint,
        );
      case MPPointShapeType.plus:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawPlusPoint,
        );
      case MPPointShapeType.square:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawSquarePoint,
        );
      case MPPointShapeType.star:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawStarPoint,
        );
      default:
        _drawPoint(
          canvas: canvas,
          position: position,
          pointPaint: pointPaint,
          customDrawMethod: _drawCirclePoint,
        );
    }
  }

  static void _drawStarPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final Path starPath = Path()
      ..moveTo(position.dx, position.dy + radius) // Bottom point
      ..lineTo(position.dx - radius * th45Degrees,
          position.dy - radius * 0.9) // Left point
      ..lineTo(position.dx + radius,
          position.dy + radius * th45Degrees * 0.5) // Right point
      ..lineTo(position.dx - radius,
          position.dy + radius * th45Degrees * 0.5) // Left point
      ..lineTo(position.dx + radius * th45Degrees,
          position.dy - radius * 0.9) // Top point
      ..close();

    canvas.drawPath(starPath, paint);
  }

  static void _drawSquarePoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final Rect squareRect = Rect.fromCenter(
      center: position,
      width: radius * 2,
      height: radius * 2,
    );

    canvas.drawRect(squareRect, paint);
  }

  static void _drawInvertedTrianglePoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final Path trianglePath = Path()
      ..moveTo(position.dx, position.dy - radius) // Bottom point
      ..lineTo(position.dx - radius, position.dy + radius) // Left point
      ..lineTo(position.dx + radius, position.dy + radius) // Right point
      ..close();

    canvas.drawPath(trianglePath, paint);
  }

  static void _drawCirclePoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    canvas.drawCircle(position, radius, paint);
  }

  static void _drawPoint({
    required Canvas canvas,
    required Offset position,
    required THPointPaint pointPaint,
    required void Function(Canvas, Offset, double, Paint) customDrawMethod,
  }) {
    if (pointPaint.fill != null) {
      customDrawMethod(
        canvas,
        position,
        pointPaint.radius,
        pointPaint.fill!,
      );
    }

    if (pointPaint.border != null) {
      customDrawMethod(
        canvas,
        position,
        pointPaint.radius,
        pointPaint.border!,
      );
    }
  }

  static void _drawInvertedTPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(position.dx - radius, position.dy),
      Offset(position.dx + radius, position.dy),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy),
      Offset(position.dx, position.dy + (2 * radius)),
      paint,
    );
  }

  static void _drawHorizontalDiamondPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double horizontalRadius = radius * mpDiamondLongerDiagonalRatio;
    final Path diamondPath = Path()
      ..moveTo(position.dx, position.dy - radius) // Top point
      ..lineTo(position.dx + horizontalRadius, position.dy) // Right point
      ..lineTo(position.dx, position.dy + radius) // Bottom point
      ..lineTo(position.dx - horizontalRadius, position.dy) // Left point
      ..close();

    canvas.drawPath(diamondPath, paint);
  }

  static void _drawPlusPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(position.dx - radius, position.dy),
      Offset(position.dx + radius, position.dy),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - radius),
      Offset(position.dx, position.dy + radius),
      paint,
    );
  }

  static void _drawAsteriskPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    _drawPlusPoint(canvas, position, radius, paint);

    canvas.drawLine(
      Offset(
        position.dx - radius * th45Degrees,
        position.dy - radius * th45Degrees,
      ),
      Offset(
        position.dx + radius * th45Degrees,
        position.dy + radius * th45Degrees,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(
        position.dx - radius * th45Degrees,
        position.dy + radius * th45Degrees,
      ),
      Offset(
        position.dx + radius * th45Degrees,
        position.dy - radius * th45Degrees,
      ),
      paint,
    );
  }
}
