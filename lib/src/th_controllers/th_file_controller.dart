import 'dart:ui';
import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_definitions/th_definitions.dart';

class THFileController extends GetxController {
  // Reactive canvas size
  var canvasSize = Size.zero.obs;

  var canvasScale = 1.0.obs;

  var canvasOffsetDrawing = Offset.zero.obs;

  var canvasScaleOffsetUndefined = true;

  var dataWidth = 0.0.obs;
  var dataHeight = 0.0.obs;

  var dataBoundingBox = Rect.zero.obs;

  var xCenter = 0.0;
  var yCenter = 0.0;

  // Method to update the canvas size
  void updateCanvasSize(Size newSize) {
    canvasSize.value = newSize;
  }

  void onPanUpdate(DragUpdateDetails details) {
    print(
        "canvasOffsetDrawing pre: ${canvasOffsetDrawing.value} - delta: ${details.delta}\n");
    canvasOffsetDrawing.value += details.delta;
  }

  void updateCanvasScale(double newScale) {
    canvasScale.value = newScale;
  }

  void updateCanvasOffsetDrawing(Offset newOffset) {
    canvasOffsetDrawing.value = newOffset;
  }

  void updateCanvasScaleOffsetUndefined(bool newValue) {
    canvasScaleOffsetUndefined = newValue;
  }

  void zoomIn() {
    _setCenterFromCurrent();
    canvasScale.value *= thZoomFactor;
    _calculateCanvasOffset();
  }

  void zoomOut() {
    _setCenterFromCurrent();
    canvasScale.value /= thZoomFactor;
    _calculateCanvasOffset();
  }

  void updateDataWidth(double newWidth) {
    dataWidth.value = newWidth;
  }

  void updateDataHeight(double newHeight) {
    dataHeight.value = newHeight;
  }

  void updateDataBoundingBox(Rect newBoundingBox) {
    dataBoundingBox.value = newBoundingBox;
  }

  void _getFileDrawingSize() {
    dataWidth.value = (dataBoundingBox.value.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.value.width;

    dataHeight.value = (dataBoundingBox.value.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.value.height;
  }

  void _calculateCanvasOffset() {
    final xOffset =
        -(xCenter - (canvasSize.value.width / 2.0 / canvasScale.value));
    final yOffset =
        -(yCenter - (canvasSize.value.height / 2.0 / canvasScale.value));

    canvasOffsetDrawing.value = Offset(xOffset, yOffset);
  }

  void _setCenterFromDrawing() {
    xCenter = dataBoundingBox.value.left + (dataBoundingBox.value.width / 2.0);
    yCenter = dataBoundingBox.value.top + (dataBoundingBox.value.height / 2.0);
  }

  void _setCenterFromCurrent() {
    xCenter = -(canvasOffsetDrawing.value.dx -
        (canvasSize.value.width / 2.0 / canvasScale.value));
    yCenter = -(canvasOffsetDrawing.value.dy -
        (canvasSize.value.height / 2.0 / canvasScale.value));
  }

  void zoomShowAll() {
    final double canvasWidth = canvasSize.value.width;
    final double canvasHeight = canvasSize.value.height;

    _getFileDrawingSize();

    final double widthScale =
        (canvasWidth * (1.0 - thCanvasVisibleMargin)) / dataWidth.value;
    final double heightScale =
        (canvasHeight * (1.0 - thCanvasVisibleMargin)) / dataHeight.value;
    final scale = (widthScale < heightScale) ? widthScale : heightScale;
    canvasScale.value = scale;

    _setCenterFromDrawing();
    _calculateCanvasOffset();

    canvasScaleOffsetUndefined = false;
  }
}
