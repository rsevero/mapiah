import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mobx/mobx.dart';

part 'mp_visual_controller.g.dart';

class MPVisualController = MPVisualControllerBase with _$MPVisualController;

abstract class MPVisualControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  MPVisualControllerBase(TH2FileEditController th2FileEditController)
      : _th2FileEditController = th2FileEditController,
        _thFile = th2FileEditController.thFile;

  THLinePaint getControlLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getNewLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getEditLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint7
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getUnselectedPointPaint(THPoint point) {
    final Paint paint = _th2FileEditController.isFromActiveScrap(point)
        ? THPaints.thPaint5
        : THPaints.thPaint16;
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: paint..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getUnselectedLinePaint(THLine line) {
    final Paint paint = _th2FileEditController.isFromActiveScrap(line)
        ? THPaints.thPaint4
        : THPaints.thPaint16;
    return THLinePaint(
      paint: paint..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getControlPointLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
    );
  }

  THPointPaint getNewLinePointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor *
          thSelectedEndControlPointFactor,
      paint: THPaints.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectedControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor,
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedEndPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thSelectedEndControlPointFactor,
      paint: THPaints.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectablePointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }
}
