import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/types/mp_point_shape_type.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

class MPInteractionAux {
  static const Map<
    MPPointShapeType,
    void Function(Canvas, Offset, double, Paint)
  >
  _pointShapeDrawMethods = {
    MPPointShapeType.arrow: _drawArrowPoint,
    MPPointShapeType.asterisk: _drawAsteriskPoint,
    MPPointShapeType.circle: _drawCirclePoint,
    MPPointShapeType.exclamation: _drawExclamationPoint,
    MPPointShapeType.horizontalDiamond: _drawHorizontalDiamondPoint,
    MPPointShapeType.invertedT: _drawInvertedTPoint,
    MPPointShapeType.invertedTriangle: _drawInvertedTrianglePoint,
    MPPointShapeType.plus: _drawPlusPoint,
    MPPointShapeType.square: _drawSquarePoint,
    MPPointShapeType.star: _drawStarPoint,
    MPPointShapeType.t: _drawTPoint,
    MPPointShapeType.triangle: _drawTrianglePoint,
    MPPointShapeType.triangleWithCenterCircle:
        _drawTriangleWithCenterCirclePoint,
    MPPointShapeType.verticalDiamond: _drawVerticalDiamondPoint,
    MPPointShapeType.x: _drawXPoint,
  };

  static bool isAltPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.altLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.altRight,
        );
  }

  static bool isCtrlPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.controlLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.controlRight,
        );
  }

  static bool isMetaPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.metaLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.metaRight,
        );
  }

  static bool isShiftPressed() {
    return HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftRight,
        );
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
    final RenderObject? ancestor = ancestorGlobalKey?.currentContext
        ?.findRenderObject();

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
    List<Widget> widgetsList,
    Widget newWidget,
  ) {
    widgetsList.add(const SizedBox(height: mpButtonSpace));
    widgetsList.add(newWidget);
  }

  static Offset getButtonOuterAnchor(
    MPGlobalKeyWidgetType buttonType,
    TH2FileEditController th2FileEditController,
  ) {
    final GlobalKey buttonGlobalKey = th2FileEditController
        .overlayWindowController
        .globalKeyWidgetKeyByType[buttonType]!;
    final Rect? buttonBoundingBox = MPInteractionAux.getWidgetRectFromGlobalKey(
      widgetGlobalKey: buttonGlobalKey,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );
    final Offset outerAnchorPosition = (buttonBoundingBox == null)
        ? Offset.zero
        : Offset(
            buttonBoundingBox.left - mpButtonSpace,
            buttonBoundingBox.center.dy,
          );

    return outerAnchorPosition;
  }

  static void drawPoint({
    required Canvas canvas,
    required Offset position,
    required THPointPaint pointPaint,
  }) {
    final void Function(Canvas, Offset, double, Paint) customDrawMethod =
        _pointShapeDrawMethods.containsKey(pointPaint.type)
        ? _pointShapeDrawMethods[pointPaint.type]!
        : _drawCirclePoint;

    _drawPoint(
      canvas: canvas,
      position: position,
      pointPaint: pointPaint,
      customDrawMethod: customDrawMethod,
    );
  }

  static void _drawStarPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double enlargedRadius = radius * 1.5;
    final double halfEnlargedRadius = enlargedRadius * 0.5;
    final double horizontalDistance = enlargedRadius * mpSqrt3Over2;

    // Vertices of the first triangle (upward)
    final Offset t1_1 = Offset(position.dx, position.dy - enlargedRadius);
    final Offset t1_2 = Offset(
      position.dx + horizontalDistance,
      position.dy + halfEnlargedRadius,
    );
    final Offset t1_3 = Offset(
      position.dx - horizontalDistance,
      position.dy + halfEnlargedRadius,
    );

    // Vertices of the second triangle (downward)
    final Offset t2_1 = Offset(position.dx, position.dy + enlargedRadius);
    final Offset t2_2 = Offset(
      position.dx + horizontalDistance,
      position.dy - halfEnlargedRadius,
    );
    final Offset t2_3 = Offset(
      position.dx - horizontalDistance,
      position.dy - halfEnlargedRadius,
    );

    final List<Offset> intersectionPoints = [];
    final List<List<Offset>> segmentsForIntersections = [
      [t1_1, t1_2, t2_2, t2_3],
      [t2_2, t2_1, t1_1, t1_2],
      [t1_2, t1_3, t2_1, t2_2],
      [t2_1, t2_3, t1_2, t1_3],
      [t1_3, t1_1, t2_3, t2_1],
      [t2_3, t2_2, t1_3, t1_1],
    ];

    // Find intersection points between pairs of sides
    for (final segments in segmentsForIntersections) {
      Offset? intersection = getLineSegmentIntersection(
        lineSegment1Point1: segments[0],
        lineSegment1Point2: segments[1],
        lineSegment2Point1: segments[2],
        lineSegment2Point2: segments[3],
      );
      if (intersection != null) {
        intersectionPoints.add(intersection);
      }
    }

    Path trianglePath = Path()
      ..moveTo(t1_1.dx, t1_1.dy)
      ..lineTo(intersectionPoints[0].dx, intersectionPoints[0].dy)
      ..lineTo(t2_2.dx, t2_2.dy)
      ..lineTo(intersectionPoints[1].dx, intersectionPoints[1].dy)
      ..lineTo(t1_2.dx, t1_2.dy)
      ..lineTo(intersectionPoints[2].dx, intersectionPoints[2].dy)
      ..lineTo(t2_1.dx, t2_1.dy)
      ..lineTo(intersectionPoints[3].dx, intersectionPoints[3].dy)
      ..lineTo(t1_3.dx, t1_3.dy)
      ..lineTo(intersectionPoints[4].dx, intersectionPoints[4].dy)
      ..lineTo(t2_3.dx, t2_3.dy)
      ..lineTo(intersectionPoints[5].dx, intersectionPoints[5].dy)
      ..close();

    canvas.drawPath(trianglePath, paint);
  }

  static Offset? getLineSegmentIntersection({
    required Offset lineSegment1Point1,
    required Offset lineSegment1Point2,
    required Offset lineSegment2Point1,
    required Offset lineSegment2Point2,
  }) {
    final double x1 = lineSegment1Point1.dx;
    final double y1 = lineSegment1Point1.dy;
    final double x2 = lineSegment1Point2.dx;
    final double y2 = lineSegment1Point2.dy;
    final double x3 = lineSegment2Point1.dx;
    final double y3 = lineSegment2Point1.dy;
    final double x4 = lineSegment2Point2.dx;
    final double y4 = lineSegment2Point2.dy;

    final double denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
      return null; // Lines are parallel or collinear
    }

    final double tNumerator = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4);
    final double uNumerator = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3));

    final double t = tNumerator / denominator;
    final double u = uNumerator / denominator;

    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      return Offset(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
    }

    return null; // No intersection within the line segments
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
    final double halfRadius = radius * 0.5;
    final double horizontalDistance = radius * mpSqrt3Over2;

    final Path trianglePath = Path()
      ..moveTo(position.dx, position.dy - radius)
      ..lineTo(position.dx + horizontalDistance, position.dy + halfRadius)
      ..lineTo(position.dx - horizontalDistance, position.dy + halfRadius)
      ..close();

    canvas.drawPath(trianglePath, paint);
  }

  static void _drawTriangleWithCenterCirclePoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    _drawTrianglePoint(canvas, position, radius, paint);

    _drawCirclePoint(
      canvas,
      position,
      radius * 0.2,
      THPaint.thPaintBlackBackground,
    );
  }

  static void _drawArrowPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double halfRadius = radius * 0.5;
    final double oneAndAHalfRadius = radius + halfRadius;

    final Path arrowPath = Path()
      ..moveTo(position.dx, position.dy + oneAndAHalfRadius)
      ..lineTo(position.dx + radius, position.dy - oneAndAHalfRadius)
      ..lineTo(position.dx, position.dy)
      ..lineTo(position.dx - radius, position.dy - oneAndAHalfRadius)
      ..close();

    canvas.drawPath(arrowPath, paint);
  }

  static void _drawTrianglePoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double halfRadius = radius * 0.5;
    final double horizontalDistance = radius * mpSqrt3Over2;

    final Path trianglePath = Path()
      ..moveTo(position.dx, position.dy + radius)
      ..lineTo(position.dx + horizontalDistance, position.dy - halfRadius)
      ..lineTo(position.dx - horizontalDistance, position.dy - halfRadius)
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
    if (pointPaint.highlightBorders.isNotEmpty) {
      int highlightBorderCount = pointPaint.highlightBorders.length;

      for (final Paint highlightBorder
          in pointPaint.highlightBorders.reversed) {
        customDrawMethod(
          canvas,
          position,
          pointPaint.radius,
          highlightBorder
            ..strokeWidth =
                highlightBorder.strokeWidth * ((highlightBorderCount * 2) + 1),
        );

        highlightBorderCount--;
      }
    }

    if (pointPaint.fill != null) {
      customDrawMethod(canvas, position, pointPaint.radius, pointPaint.fill!);
    }

    if (pointPaint.border != null) {
      customDrawMethod(canvas, position, pointPaint.radius, pointPaint.border!);
    }
  }

  static void _drawTPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(position.dx - radius, position.dy + radius),
      Offset(position.dx + radius, position.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - radius),
      Offset(position.dx, position.dy + radius),
      paint,
    );
  }

  static void _drawInvertedTPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(position.dx - radius, position.dy - radius),
      Offset(position.dx + radius, position.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - radius),
      Offset(position.dx, position.dy + radius),
      paint,
    );
  }

  static void _drawVerticalDiamondPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double verticalRadius = radius * mpDiamondLongerDiagonalRatio;
    final Path diamondPath = Path()
      ..moveTo(position.dx, position.dy - verticalRadius) // Top point
      ..lineTo(position.dx + radius, position.dy) // Right point
      ..lineTo(position.dx, position.dy + verticalRadius) // Bottom point
      ..lineTo(position.dx - radius, position.dy) // Left point
      ..close();

    canvas.drawPath(diamondPath, paint);
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

  static void _drawExclamationPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    // radius *= 2;
    final Path exclamationPath = Path()
      ..moveTo(position.dx, position.dy + radius) // Top point
      ..lineTo(position.dx, position.dy - radius * 0.1) // Low end bar
      ..moveTo(position.dx, position.dy - radius * 0.6) // Top point point
      ..lineTo(position.dx, position.dy - radius) // Low end point
      ..close();

    canvas.drawPath(exclamationPath, paint);
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

  static void _drawXPoint(
    Canvas canvas,
    Offset position,
    double radius,
    Paint paint,
  ) {
    final double radius45Degrees = radius * th45Degrees;

    canvas.drawLine(
      Offset(position.dx - radius45Degrees, position.dy - radius45Degrees),
      Offset(position.dx + radius45Degrees, position.dy + radius45Degrees),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx - radius45Degrees, position.dy + radius45Degrees),
      Offset(position.dx + radius45Degrees, position.dy - radius45Degrees),
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
    _drawXPoint(canvas, position, radius, paint);
  }

  static Rect getScrapBackgroundRect({
    required THScrap scrap,
    required TH2FileEditController th2FileEditController,
  }) {
    final Rect boundingBox = scrap.getBoundingBox(th2FileEditController)!;

    return MPNumericAux.orderedRectExpandedByDelta(
      rect: boundingBox,
      delta: th2FileEditController.getScrapBackgroundPaddingOnCanvas(),
    );
  }
}
