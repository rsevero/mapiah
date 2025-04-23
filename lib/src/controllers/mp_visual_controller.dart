import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
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

  Paint getControlLinePaint() {
    return THPaints.thPaintBlackBorder
      ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas;
  }

  THPointPaint getSelectedPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedLinePaint() {
    return THLinePaint(
      primaryPaint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedAreaFillPaint() {
    final Paint paint = THPaints.thPaint1002;

    return THLinePaint(primaryPaint: paint);
  }

  THLinePaint getSelectedAreaBorderPaint() {
    final Paint paint = THPaints.thPaint2;

    paint.strokeWidth = _th2FileEditController.lineThicknessOnCanvas;

    return THLinePaint(primaryPaint: paint);
  }

  THLinePaint getMultipleElementsClickedHighlightedFillPaint() {
    return THLinePaint(primaryPaint: THPaints.thPaint1002);
  }

  THLinePaint getMultipleElementsClickedHighlightedBorderPaint() {
    return THLinePaint(
      primaryPaint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getNewLinePaint() {
    return THLinePaint(
      primaryPaint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getEditLinePaint() {
    return THLinePaint(
      primaryPaint: THPaints.thPaint2
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

  THLinePaint getUnselectedAreaFillPaint(THArea area) {
    final bool isFromActiveScrap =
        _th2FileEditController.isFromActiveScrap(area);
    final Paint paint =
        isFromActiveScrap ? THPaints.thPaint1004 : THPaints.thPaint1016;

    return THLinePaint(primaryPaint: paint);
  }

  THLinePaint getUnselectedAreaBorderPaint(THArea area) {
    final Paint paint = _th2FileEditController.isFromActiveScrap(area)
        ? THPaints.thPaint4
        : THPaints.thPaint16;

    paint.strokeWidth = _th2FileEditController.lineThicknessOnCanvas;

    return THLinePaint(primaryPaint: paint);
  }

  THLinePaint getUnselectedLinePaint(THLine line) {
    if (!_th2FileEditController.isFromActiveScrap(line)) {
      return THLinePaint(
        primaryPaint: THPaints.thPaint16
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      );
    }

    final THLineType linetype = line.lineType;

    switch (linetype) {
      case THLineType.abyssEntrance:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.arrow:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.border:
        return THLinePaint(
          primaryPaint: THPaints.thPaint5
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.ceilingMeander:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.ceilingStep:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.chimney:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.contour:
        return THLinePaint(
          primaryPaint: THPaints.thPaint7
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.dripline:
        return THLinePaint(
          primaryPaint: THPaints.thPaint7
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.fault:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.fixedLadder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.floorMeander:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.floorStep:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.flowstone:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.gradient:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.handrail:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.joint:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.label:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.lowCeiling:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.mapConnection:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.moonmilk:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.overhang:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint12
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.pit:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.pitch:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.pitChimney:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint12
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.rimstoneDam:
        return THLinePaint(
          primaryPaint: THPaints.thPaint8
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.rimstonePool:
        return THLinePaint(
          primaryPaint: THPaints.thPaint8
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.rockBorder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint9
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.rockEdge:
        return THLinePaint(
          primaryPaint: THPaints.thPaint9
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.rope:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint11
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.ropeLadder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.section:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.slope:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint12
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.steps:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint9
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.survey:
        return THLinePaint(
          primaryPaint: THPaints.thPaint12
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.u:
        return THLinePaint(
          primaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.viaFerrata:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint8
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.walkWay:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint7
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: LinePaintType.dashed,
        );
      case THLineType.wall:
        return THLinePaint(
          primaryPaint: THPaints.thPaint1
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.waterFlow:
        return THLinePaint(
          primaryPaint: THPaints.thPaint4
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
    }
  }

  Paint getControlPointLinePaint() {
    return THPaints.thPaintBlackBorder
      ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas;
  }

  THPointPaint getNewLinePointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getHighligthtedEndControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaint2
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

  THPointPaint getUnselectedEndPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      paint: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }
}
