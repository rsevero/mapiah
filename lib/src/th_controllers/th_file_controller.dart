import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_definitions/th_definitions.dart';

class THFileController extends GetxController {
  // Reactive canvas size
  var canvasSize = Size.zero.obs;

  var canvasScale = 1.0;

  var canvasOffsetDrawing = Offset.zero;

  var canvasScaleOffsetUndefined = true;

  var dataWidth = 0.0;
  var dataHeight = 0.0;

  var dataBoundingBox = Rect.zero;

  var xCenter = 0.0;
  var yCenter = 0.0;

  var trigger = false.obs;
  var shouldRepaint = false;

  // Method to update the canvas size
  void updateCanvasSize(Size newSize) {
    canvasSize.value = newSize;
  }

  void onPanUpdate(DragUpdateDetails details) {
    // print(
    //     "canvasOffsetDrawing pre: $canvasOffsetDrawing - delta: ${details.delta} - ${DateTime.now()}\n");
    canvasOffsetDrawing += (details.delta / canvasScale);
    shouldRepaint = true;
    trigger.value = !trigger.value;
  }

  void updateCanvasScale(double newScale) {
    canvasScale = newScale;
  }

  void updateCanvasOffsetDrawing(Offset newOffset) {
    canvasOffsetDrawing = newOffset;
  }

  void updateCanvasScaleOffsetUndefined(bool newValue) {
    canvasScaleOffsetUndefined = newValue;
  }

  void zoomIn() {
    _setCenterFromCurrent();
    canvasScale *= thZoomFactor;
    _calculateCanvasOffset();
  }

  void zoomOut() {
    _setCenterFromCurrent();
    canvasScale /= thZoomFactor;
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
    final xOffset = -(xCenter - (canvasSize.value.width / 2.0 / canvasScale));
    final yOffset = -(yCenter - (canvasSize.value.height / 2.0 / canvasScale));

    canvasOffsetDrawing = Offset(xOffset, yOffset);
  }

  void _setCenterFromDrawing() {
    xCenter = dataBoundingBox.left + (dataBoundingBox.width / 2.0);
    yCenter = dataBoundingBox.top + (dataBoundingBox.height / 2.0);
  }

  void _setCenterFromCurrent() {
    xCenter = -(canvasOffsetDrawing.dx -
        (canvasSize.value.width / 2.0 / canvasScale));
    yCenter = -(canvasOffsetDrawing.dy -
        (canvasSize.value.height / 2.0 / canvasScale));
  }

  void zoomShowAll() {
    final double canvasWidth = canvasSize.value.width;
    final double canvasHeight = canvasSize.value.height;

    _getFileDrawingSize();

    final double widthScale =
        (canvasWidth * (1.0 - thCanvasVisibleMargin)) / dataWidth;
    final double heightScale =
        (canvasHeight * (1.0 - thCanvasVisibleMargin)) / dataHeight;
    final scale = (widthScale < heightScale) ? widthScale : heightScale;
    canvasScale = scale;

    _setCenterFromDrawing();
    _calculateCanvasOffset();

    canvasScaleOffsetUndefined = false;
  }
}
