import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mobx/mobx.dart';

part 'th_file_store.g.dart';

class THFileStore = THFileStoreBase with _$THFileStore;

abstract class THFileStoreBase with Store {
  // 'screen' is related to actual pixels on the screen.
  // 'canvas' is the virtual canvas used to draw.
  // 'data' is the actual data to be drawn.
  // 'canvas' and 'data' are on the same scale. They are both scaled and
  // translated to be shown on the screen.

  @readonly
  Size _screenSize = Size.zero;

  Size _canvasSize = Size.zero;

  @readonly
  double _canvasScale = 1.0;

  @readonly
  Offset _canvasTranslation = Offset.zero;

  @readonly
  bool _canvasScaleTranslationUndefined = true;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  Rect _dataBoundingBox = Rect.zero;

  double _canvasCenterX = 0.0;
  double _canvasCenterY = 0.0;

  @readonly
  bool _trigger = false;

  @readonly
  bool _shouldRepaint = false;

  @action
  void updateScreenSize(Size newSize) {
    _screenSize = newSize;
    _canvasSize = newSize / _canvasScale;
  }

  Offset screenToCanvas(Offset screenCoordinate) {
    // Apply the inverse of the translation
    final double canvasX =
        (screenCoordinate.dx / _canvasScale) - _canvasTranslation.dx;
    final double canvasY =
        -((screenCoordinate.dy / _canvasScale) - _canvasTranslation.dy);

    return Offset(canvasX, canvasY);
  }

  Offset canvasToScreen(Offset canvasCoordinate) {
    // Apply the translation and scaling
    final double screenX =
        (canvasCoordinate.dx - _canvasTranslation.dx) * _canvasScale;
    final double screenY =
        -((canvasCoordinate.dy - _canvasTranslation.dy) * _canvasScale);

    return Offset(screenX, screenY);
  }

  @action
  void onPanUpdate(DragUpdateDetails details) {
    _canvasTranslation += (details.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
    _shouldRepaint = true;
    _trigger = !_trigger;
  }

  @action
  void setShouldRepaint(bool value) {
    _shouldRepaint = value;
  }

  void _setCanvasCenterFromCurrent() {
    print("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX =
        -(_canvasTranslation.dx - (_screenSize.width / 2.0 / _canvasScale));
    _canvasCenterY =
        _canvasTranslation.dy - (_screenSize.height / 2.0 / _canvasScale);
    print("New center: $_canvasCenterX, $_canvasCenterY");
  }

  @action
  void updateCanvasScale(double newScale) {
    _canvasScale = newScale;
    _canvasSize = _screenSize / _canvasScale;
  }

  @action
  void updateCanvasOffsetDrawing(Offset newOffset) {
    _canvasTranslation = newOffset;
  }

  @action
  void setCanvasScaleTranslationUndefined(bool isUndefined) {
    _canvasScaleTranslationUndefined = isUndefined;
  }

  @action
  void zoomIn() {
    _canvasScale *= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
  }

  @action
  void zoomOut() {
    _canvasScale /= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
  }

  @action
  void _calculateCanvasOffset() {
    final double xOffset = (_canvasSize.width / 2.0) - _canvasCenterX;
    final double yOffset = (_canvasSize.height / 2.0) + _canvasCenterY;

    _canvasTranslation = Offset(xOffset, yOffset);
  }

  @action
  void updateDataWidth(double newWidth) {
    _dataWidth = newWidth;
  }

  @action
  void updateDataHeight(double newHeight) {
    _dataHeight = newHeight;
  }

  @action
  void updateDataBoundingBox(Rect newBoundingBox) {
    _dataBoundingBox = newBoundingBox;
  }

  void _getFileDrawingSize() {
    _dataWidth = (_dataBoundingBox.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : _dataBoundingBox.width;

    _dataHeight = (_dataBoundingBox.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : _dataBoundingBox.height;
  }

  void _setCanvasCenterToDrawingCenter() {
    // print("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX = (_dataBoundingBox.left + _dataBoundingBox.right) / 2.0;
    _canvasCenterY = (_dataBoundingBox.top + _dataBoundingBox.bottom) / 2.0;
    // print(
    //     "New center to center drawing in canvas: $_canvasCenterX, $_canvasCenterY");
  }

  @action
  void zoomShowAll() {
    final double screenWidth = _screenSize.width;
    final double screenHeight = _screenSize.height;

    _getFileDrawingSize();

    final double widthScale =
        (screenWidth * (1.0 - thCanvasVisibleMargin)) / _dataWidth;
    final double heightScale =
        (screenHeight * (1.0 - thCanvasVisibleMargin)) / _dataHeight;

    _canvasScale = (widthScale < heightScale) ? widthScale : heightScale;
    _canvasSize = _screenSize / _canvasScale;

    _setCanvasCenterToDrawingCenter();
    _calculateCanvasOffset();

    _canvasScaleTranslationUndefined = false;
  }
}
