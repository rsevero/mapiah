import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/selection/mp_selectable.dart';
import 'package:mobx/mobx.dart';

part 'th_file_display_store.g.dart';

class THFileDisplayStore = THFileDisplayStoreBase with _$THFileDisplayStore;

abstract class THFileDisplayStoreBase with Store {
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

  @readonly
  TH2FileEditMode _mode = TH2FileEditMode.pan;

  final Map<int, MPSelectable> _selectableElements = {};

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  Rect _dataBoundingBox = Rect.zero;

  double _canvasCenterX = 0.0;
  double _canvasCenterY = 0.0;

  double lineThicknessOnCanvas = thDefaultLineThickness;

  double pointRadiusOnCanvas = thDefaultPointRadius;

  double selectionToleranceSquaredOnCanvas =
      thDefaultSelectionTolerance * thDefaultSelectionTolerance;

  void addSelectableElement(MPSelectableElement selectableElement) {
    _selectableElements[selectableElement.element.mapiahID] = selectableElement;
  }

  void clearSelectableElements() {
    _selectableElements.clear();
  }

  MPSelectableElement? selectableElementContains(Offset screenCoordinates) {
    final Offset canvasCoordinates = offsetScreenToCanvas(screenCoordinates);

    for (final MPSelectable selectable in _selectableElements.values) {
      if (offsetsInSelectionTolerance(selectable.position, canvasCoordinates)) {
        return selectable as MPSelectableElement;
      }
    }

    return null;
  }

  THPointPaint getPointPaint(THPoint point) {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaint1..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getLinePaint(THLine line) {
    return THLinePaint(
      paint: THPaints.thPaint2..strokeWidth = lineThicknessOnCanvas,
    );
  }

  bool offsetsInSelectionTolerance(Offset offset1, Offset offset2) {
    final double dx = offset1.dx - offset2.dx;
    final double dy = offset1.dy - offset2.dy;

    return ((dx * dx) + (dy * dy)) < selectionToleranceSquaredOnCanvas;
  }

  @action
  void updateScreenSize(Size newSize) {
    _screenSize = newSize;
    _canvasSize = newSize / _canvasScale;
  }

  Offset offsetScaleScreenToCanvas(Offset screenCoordinate) {
    return Offset(screenCoordinate.dx / _canvasScale,
        screenCoordinate.dy / (-_canvasScale));
  }

  Offset offsetScaleCanvasToScreen(Offset canvasCoordinate) {
    return Offset(canvasCoordinate.dx * _canvasScale,
        canvasCoordinate.dy * (-_canvasScale));
  }

  Offset offsetScreenToCanvas(Offset screenCoordinate) {
    // Apply the inverse of the translation
    final double canvasX =
        (screenCoordinate.dx / _canvasScale) - _canvasTranslation.dx;
    final double canvasY =
        _canvasTranslation.dy - (screenCoordinate.dy / _canvasScale);

    return Offset(canvasX, canvasY);
  }

  Offset offsetCanvasToScreen(Offset canvasCoordinate) {
    // Apply the translation and scaling
    final double screenX =
        (_canvasTranslation.dx + canvasCoordinate.dx) * _canvasScale;
    final double screenY =
        (_canvasTranslation.dy - canvasCoordinate.dy) * _canvasScale;

    return Offset(screenX, screenY);
  }

  double scaleScreenToCanvas(double screenValue) {
    return screenValue / _canvasScale;
  }

  double scaleCanvasToScreen(double canvasValue) {
    return canvasValue * _canvasScale;
  }

  @action
  void setTH2FileEditMode(TH2FileEditMode newMode) {
    _mode = newMode;
  }

  @action
  void onPanUpdate(DragUpdateDetails details) {
    _canvasTranslation += (details.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
  }

  void _setCanvasCenterFromCurrent() {
    // print("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX =
        -(_canvasTranslation.dx - (_screenSize.width / 2.0 / _canvasScale));
    _canvasCenterY =
        _canvasTranslation.dy - (_screenSize.height / 2.0 / _canvasScale);
    // print("New center: $_canvasCenterX, $_canvasCenterY");
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

  void transformCanvas(Canvas canvas) {
    // Transformations are applied on the order they are defined.
    canvas.scale(_canvasScale);
    // // Drawing canvas border
    // canvas.drawRect(
    //     Rect.fromPoints(
    //         Offset(0, 0),
    //         Offset(
    //           thFileController.canvasSize.width,
    //           thFileController.canvasSize.height,
    //         )),
    //     THPaints.thPaint7);
    canvas.translate(_canvasTranslation.dx, _canvasTranslation.dy);
    canvas.scale(1, -1);
  }
}
