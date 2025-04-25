import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';
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

  static final Map<THLineType, THLinePaint> lineTypePaints = {
    THLineType.abyssEntrance: THLinePaint(
      primaryPaint: THPaints.thPaint14,
      type: MPLinePaintType.longDot,
    ),
    THLineType.arrow: THLinePaint(
      primaryPaint: THPaints.thPaint10,
      type: MPLinePaintType.dot,
    ),
    THLineType.ceilingMeander: THLinePaint(
      primaryPaint: THPaints.thPaint6,
      type: MPLinePaintType.shortMediumShort,
    ),
    THLineType.ceilingStep: THLinePaint(
      primaryPaint: THPaints.thPaint6,
      type: MPLinePaintType.shortDot,
    ),
    THLineType.chimney: THLinePaint(
      primaryPaint: THPaints.thPaint14,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.contour: THLinePaint(
      primaryPaint: THPaints.thPaint7,
      type: MPLinePaintType.dot,
    ),
    THLineType.dripline: THLinePaint(
      primaryPaint: THPaints.thPaint7,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.fault: THLinePaint(
      primaryPaint: THPaints.thPaint13,
      type: MPLinePaintType.dot,
    ),
    THLineType.fixedLadder: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.dot,
    ),
    THLineType.floorMeander: THLinePaint(
      primaryPaint: THPaints.thPaint6,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.floorStep: THLinePaint(
      primaryPaint: THPaints.thPaint6,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.flowstone: THLinePaint(
      primaryPaint: THPaints.thPaint11,
      type: MPLinePaintType.shortMediumShort,
    ),
    THLineType.gradient: THLinePaint(
      primaryPaint: THPaints.thPaint13,
      type: MPLinePaintType.long,
    ),
    THLineType.handrail: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.long,
    ),
    THLineType.joint: THLinePaint(
      primaryPaint: THPaints.thPaint13,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.label: THLinePaint(
      primaryPaint: THPaints.thPaint10,
      type: MPLinePaintType.long,
    ),
    THLineType.lowCeiling: THLinePaint(
      primaryPaint: THPaints.thPaint14,
      type: MPLinePaintType.short3Dots,
    ),
    THLineType.mapConnection: THLinePaint(
      primaryPaint: THPaints.thPaint10,
      type: MPLinePaintType.short2Dots,
    ),
    THLineType.moonmilk: THLinePaint(
      primaryPaint: THPaints.thPaint11,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.overhang: THLinePaint(
      primaryPaint: THPaints.thPaint11,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.pit: THLinePaint(
      primaryPaint: THPaints.thPaint14,
      type: MPLinePaintType.shortLongShort,
    ),
    THLineType.pitch: THLinePaint(
      primaryPaint: THPaints.thPaint13,
      type: MPLinePaintType.short2Dots,
    ),
    THLineType.pitChimney: THLinePaint(
      primaryPaint: THPaints.thPaint14,
      type: MPLinePaintType.medium,
    ),
    THLineType.rimstoneDam: THLinePaint(
      primaryPaint: THPaints.thPaint8,
      type: MPLinePaintType.long,
    ),
    THLineType.rimstonePool: THLinePaint(
      primaryPaint: THPaints.thPaint8,
      type: MPLinePaintType.short3Dots,
    ),
    THLineType.rockBorder: THLinePaint(
      primaryPaint: THPaints.thPaint9,
      type: MPLinePaintType.continuous,
    ),
    THLineType.rockEdge: THLinePaint(
      primaryPaint: THPaints.thPaint9,
      type: MPLinePaintType.medium,
    ),
    THLineType.rope: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.continuous,
    ),
    THLineType.ropeLadder: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.short,
    ),
    THLineType.section: THLinePaint(
      primaryPaint: THPaints.thPaint10,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.slope: THLinePaint(
      primaryPaint: THPaints.thPaint13,
      type: MPLinePaintType.continuous,
    ),
    THLineType.steps: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.u: THLinePaint(
      primaryPaint: THPaints.thPaint16,
      type: MPLinePaintType.continuous,
    ),
    THLineType.viaFerrata: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.walkWay: THLinePaint(
      primaryPaint: THPaints.thPaint3,
      type: MPLinePaintType.medium,
    ),
  };

  static final Map<String, THLinePaint> borderSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaints.thPaint5,
      type: MPLinePaintType.continuous,
    ),
    'invisible': THLinePaint(
      primaryPaint: THPaints.thPaint5,
      type: MPLinePaintType.dot,
    ),
    'presumed': THLinePaint(
      primaryPaint: THPaints.thPaint5,
      type: MPLinePaintType.long,
    ),
    'temporary': THLinePaint(
      primaryPaint: THPaints.thPaint5,
      type: MPLinePaintType.medium2Dots,
    ),
    'visible': THLinePaint(
      primaryPaint: THPaints.thPaint5,
      type: MPLinePaintType.continuous,
    ),
  };

  static final Map<String, THLinePaint> surveySubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaints.thPaint15,
      type: MPLinePaintType.continuous,
    ),
    'cave': THLinePaint(
      primaryPaint: THPaints.thPaint15,
      type: MPLinePaintType.continuous,
    ),
    'surface': THLinePaint(
      primaryPaint: THPaints.thPaint15,
      type: MPLinePaintType.dot,
    ),
  };

  static final Map<String, THLinePaint> wallSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.continuous,
    ),
    'bedrock': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.continuous,
    ),
    'blocks': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.dot,
    ),
    'clay': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.long,
    ),
    'debris': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.long2Dots,
    ),
    'flowstone': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.long3Dots,
    ),
    'ice': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.longDot,
    ),
    'invisible': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.mediumLongMedium,
    ),
    'moonmilk': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.shortLongShort,
    ),
    'overlying': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.medium,
    ),
    'pebbles': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.medium2Dots,
    ),
    'pit': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.medium3Dots,
    ),
    'presumed': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.mediumDot,
    ),
    'sand': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.shortDot,
    ),
    'underlying': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.short,
    ),
    'unsurveyed': THLinePaint(
      primaryPaint: THPaints.thPaint1,
      type: MPLinePaintType.short2Dots,
    ),
  };

  static final Map<String, THLinePaint> waterFlowSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaints.thPaint4,
      type: MPLinePaintType.continuous,
    ),
    'conjectural': THLinePaint(
      primaryPaint: THPaints.thPaint4,
      type: MPLinePaintType.longDot,
    ),
    'intermittent': THLinePaint(
      primaryPaint: THPaints.thPaint4,
      type: MPLinePaintType.medium2Dots,
    ),
    'permanent': THLinePaint(
      primaryPaint: THPaints.thPaint4,
      type: MPLinePaintType.continuous,
    ),
  };

  Paint getControlLinePaint() {
    return THPaints.thPaintBlackBorder
      ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas;
  }

  THPointPaint getSelectedPointPaint(THPoint point) {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedLinePaint(THLine line) {
    final THLinePaint linePaint = getDefaultLinePaint(line);

    return linePaint.copyWith(
      primaryPaint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      makeSecondaryPaintNull: true,
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

  THLinePaint getMultipleElementsClickedHighlightedBorderPaint(THLine line) {
    final THLinePaint linePaint = getDefaultLinePaint(line);

    return linePaint.copyWith(
      primaryPaint: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      makeSecondaryPaintNull: true,
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
      border: paint..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
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

  THLinePaint getDefaultLinePaint(THLine line) {
    final THLineType lineType = line.lineType;
    final THLinePaint linePaint;

    if (lineTypePaints.containsKey(lineType)) {
      linePaint = lineTypePaints[lineType]!;
    } else {
      final String lineSubtype = line.hasOption(THCommandOptionType.subtype)
          ? (line.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype
          : mpNoSubtypeID;

      switch (lineType) {
        case THLineType.border:
          linePaint = borderSubtypesPaints[lineSubtype] ??
              borderSubtypesPaints[mpNoSubtypeID]!;
        case THLineType.survey:
          linePaint = surveySubtypesPaints[lineSubtype] ??
              surveySubtypesPaints[mpNoSubtypeID]!;
        case THLineType.wall:
          linePaint = wallSubtypesPaints[lineSubtype] ??
              wallSubtypesPaints[mpNoSubtypeID]!;
        case THLineType.waterFlow:
          linePaint = waterFlowSubtypesPaints[lineSubtype] ??
              waterFlowSubtypesPaints[mpNoSubtypeID]!;
        default:
          throw Exception(
              'Line type $lineType not found in lineTypePaints map.');
      }
    }

    return linePaint.copyWith(
      primaryPaint: linePaint.primaryPaint!
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getUnselectedLinePaint(THLine line) {
    final THLinePaint linePaint = getDefaultLinePaint(line);

    if (_th2FileEditController.isFromActiveScrap(line)) {
      return linePaint.copyWith(
        primaryPaint: linePaint.primaryPaint == null
            ? null
            : (linePaint.primaryPaint!
              ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas),
        secondaryPaint: linePaint.secondaryPaint == null
            ? null
            : (linePaint.secondaryPaint!
              ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas),
      );
    } else {
      return linePaint.copyWith(
        primaryPaint: THPaints.thPaint16
          ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
        makeSecondaryPaintNull: true,
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
      border: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getHighligthtedEndControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaints.thPaint2
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor *
          thSelectedEndControlPointFactor,
      border: THPaints.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectedControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor,
      border: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedEndPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas *
          thSelectedEndControlPointFactor,
      border: THPaints.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectedEndPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaints.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }
}
