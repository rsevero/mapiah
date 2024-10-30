import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_definitions/th_definitions.dart';

class THFileController extends GetxController {
  // 'screen' is related to actual pixels on the screen.
  // 'canvas' is the virtual canvas used to draw.
  // 'data' is the actual data to be drawn.
  // 'canvas' and 'data' are on the same scale. They are both scaled and
  // translated to be shown on the screen.

  Rx<Size> screenSize = Size.zero.obs;

  Size canvasSize = Size.zero;

  double canvasScale = 1.0;

  Offset canvasTranslation = Offset.zero;

  bool canvasScaleTranslationUndefined = true;

  double dataWidth = 0.0;
  double dataHeight = 0.0;

  Rect dataBoundingBox = Rect.zero;

  double canvasCenterX = 0.0;
  double canvasCenterY = 0.0;

  RxBool trigger = false.obs;
  bool shouldRepaint = false;

  void updateScreenSize(Size newSize) {
    screenSize.value = newSize;
    canvasSize = newSize / canvasScale;
  }

  Offset screenToCanvas(Offset screenCoordinate) {
    // Apply the inverse of the translation
    final double canvasX =
        (screenCoordinate.dx / canvasScale) - canvasTranslation.dx;
    final double canvasY =
        -((screenCoordinate.dy / canvasScale) - canvasTranslation.dy);

    return Offset(canvasX, canvasY);
  }

  Offset canvasToScreen(Offset canvasCoordinate) {
    // Apply the translation and scaling
    final double screenX =
        (canvasCoordinate.dx - canvasTranslation.dx) * canvasScale;
    final double screenY =
        -((canvasCoordinate.dy - canvasTranslation.dy) * canvasScale);

    return Offset(screenX, screenY);
  }

  void onPanUpdate(DragUpdateDetails details) {
    canvasTranslation += (details.delta / canvasScale);
    _setCanvasCenterFromCurrent();
    shouldRepaint = true;
    trigger.value = !trigger.value;
  }

  void updateCanvasScale(double newScale) {
    canvasScale = newScale;
    canvasSize = screenSize.value / canvasScale;
  }

  void updateCanvasOffsetDrawing(Offset newOffset) {
    canvasTranslation = newOffset;
  }

  void updateCanvasScaleOffsetUndefined(bool newValue) {
    canvasScaleTranslationUndefined = newValue;
  }

  void zoomIn() {
    // _setCenterFromCurrent();
    canvasScale *= thZoomFactor;
    canvasSize = screenSize.value / canvasScale;
    _calculateCanvasOffset();
  }

  void zoomOut() {
    // _setCenterFromCurrent();
    canvasScale /= thZoomFactor;
    canvasSize = screenSize.value / canvasScale;
    _calculateCanvasOffset();
  }

  void updateDataWidth(double newWidth) {
    dataWidth = newWidth;
  }

  void updateDataHeight(double newHeight) {
    dataHeight = newHeight;
  }

  void updateDataBoundingBox(Rect newBoundingBox) {
    dataBoundingBox = newBoundingBox;
  }

  void _getFileDrawingSize() {
    dataWidth = (dataBoundingBox.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.width;

    dataHeight = (dataBoundingBox.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.height;
  }

  void _calculateCanvasOffset() {
    final xOffset = (canvasSize.width / 2.0) - canvasCenterX;
    final yOffset = (canvasSize.height / 2.0) + canvasCenterY;

    canvasTranslation = Offset(xOffset, yOffset);
  }

  void _setCanvasCenterToDrawingCenter() {
    print("Current center: $canvasCenterX, $canvasCenterY");
    canvasCenterX = (dataBoundingBox.left + dataBoundingBox.right) / 2.0;
    canvasCenterY = (dataBoundingBox.top + dataBoundingBox.bottom) / 2.0;
    print(
        "New center to center drawing in canvas: $canvasCenterX, $canvasCenterY");
  }

  void _setCanvasCenterFromCurrent() {
    print("Current center: $canvasCenterX, $canvasCenterY");
    canvasCenterX =
        -(canvasTranslation.dx - (screenSize.value.width / 2.0 / canvasScale));
    canvasCenterY =
        canvasTranslation.dy - (screenSize.value.height / 2.0 / canvasScale);
    print("New center: $canvasCenterX, $canvasCenterY");
  }

  void zoomShowAll() {
    final double screenWidth = screenSize.value.width;
    final double screenHeight = screenSize.value.height;

    _getFileDrawingSize();

    final double widthScale =
        (screenWidth * (1.0 - thCanvasVisibleMargin)) / dataWidth;
    final double heightScale =
        (screenHeight * (1.0 - thCanvasVisibleMargin)) / dataHeight;
    final scale = (widthScale < heightScale) ? widthScale : heightScale;
    canvasScale = scale;
    canvasSize = screenSize.value / canvasScale;

    _setCanvasCenterToDrawingCenter();
    _calculateCanvasOffset();

    canvasScaleTranslationUndefined = false;
  }
}
