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
          type: MPLinePaintType.longDot,
        );
      case THLineType.arrow:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.dot,
        );
      case THLineType.border:
        if (line.hasOption(THCommandOptionType.subtype)) {
          final String subtype = (line.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype;

          switch (subtype) {
            case 'invisible':
              return THLinePaint(
                primaryPaint: THPaints.thPaint5
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.dot,
              );
            case 'presumed':
              return THLinePaint(
                primaryPaint: THPaints.thPaint5
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.long,
              );
            case 'temporary':
              return THLinePaint(
                primaryPaint: THPaints.thPaint5
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.medium2Dots,
              );
            case 'visible':
              return THLinePaint(
                primaryPaint: THPaints.thPaint5
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
              );
            default:
              return THLinePaint(
                primaryPaint: THPaints.thPaint5
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.shortMediumShort,
              );
          }
        } else {
          return THLinePaint(
            primaryPaint: THPaints.thPaint5
              ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
            type: MPLinePaintType.continuous,
          );
        }
      case THLineType.ceilingMeander:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.shortMediumShort,
        );
      case THLineType.ceilingStep:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.shortDot,
        );
      case THLineType.chimney:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium2Dots,
        );
      case THLineType.contour:
        return THLinePaint(
          primaryPaint: THPaints.thPaint7
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.dot,
        );
      case THLineType.dripline:
        return THLinePaint(
          primaryPaint: THPaints.thPaint7
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.mediumDot,
        );
      case THLineType.fault:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.dot,
        );
      case THLineType.fixedLadder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.dot,
        );
      case THLineType.floorMeander:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium2Dots,
        );
      case THLineType.floorStep:
        return THLinePaint(
          primaryPaint: THPaints.thPaint6
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long3Dots,
        );
      case THLineType.flowstone:
        return THLinePaint(
          primaryPaint: THPaints.thPaint11
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.shortMediumShort,
        );
      case THLineType.gradient:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long,
        );
      case THLineType.handrail:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long,
        );
      case THLineType.joint:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.mediumDot,
        );
      case THLineType.label:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long,
        );
      case THLineType.lowCeiling:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.short3Dots,
        );
      case THLineType.mapConnection:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.short2Dots,
        );
      case THLineType.moonmilk:
        return THLinePaint(
          primaryPaint: THPaints.thPaint11
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long3Dots,
        );
      case THLineType.overhang:
        return THLinePaint(
          primaryPaint: THPaints.thPaint11
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium2Dots,
        );
      case THLineType.pit:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.shortLongShort,
        );
      case THLineType.pitch:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.short2Dots,
        );
      case THLineType.pitChimney:
        return THLinePaint(
          primaryPaint: THPaints.thPaint14
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          secondaryPaint: THPaints.thPaint12
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium,
        );
      case THLineType.rimstoneDam:
        return THLinePaint(
          primaryPaint: THPaints.thPaint8
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long,
        );
      case THLineType.rimstonePool:
        return THLinePaint(
          primaryPaint: THPaints.thPaint8
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.short3Dots,
        );
      case THLineType.rockBorder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint9
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.rockEdge:
        return THLinePaint(
          primaryPaint: THPaints.thPaint9
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium,
        );
      case THLineType.rope:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.ropeLadder:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.short,
        );
      case THLineType.section:
        return THLinePaint(
          primaryPaint: THPaints.thPaint10
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.mediumDot,
        );
      case THLineType.slope:
        return THLinePaint(
          primaryPaint: THPaints.thPaint13
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.steps:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.long3Dots,
        );
      case THLineType.survey:
        if (line.hasOption(THCommandOptionType.subtype)) {
          final String subtype = (line.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype;

          switch (subtype) {
            case 'cave':
              return THLinePaint(
                primaryPaint: THPaints.thPaint15
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
              );
            case 'surface':
              return THLinePaint(
                primaryPaint: THPaints.thPaint15
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.dot,
              );
            default:
              return THLinePaint(
                primaryPaint: THPaints.thPaint15
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.shortMediumShort,
              );
          }
        } else {
          return THLinePaint(
            primaryPaint: THPaints.thPaint15
              ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          );
        }

      case THLineType.u:
        return THLinePaint(
          primaryPaint: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      case THLineType.viaFerrata:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium2Dots,
        );
      case THLineType.walkWay:
        return THLinePaint(
          primaryPaint: THPaints.thPaint3
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          type: MPLinePaintType.medium,
        );
      case THLineType.wall:
        final Paint primaryPaint = THPaints.thPaint1
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas;

        if (line.hasOption(THCommandOptionType.subtype)) {
          final String subtype = (line.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype;

          switch (subtype) {
            case 'bedrock':
              return THLinePaint(
                primaryPaint: primaryPaint,
              );
            case 'blocks':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.dot,
              );
            case 'clay':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.long,
              );
            case 'debris':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.long2Dots,
              );
            case 'flowstone':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.long3Dots,
              );
            case 'ice':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.longDot,
              );
            case 'invisible':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.mediumLongMedium,
              );
            case 'moonmilk':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.shortLongShort,
              );
            case 'overlying':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.medium,
              );
            case 'pebbles':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.medium2Dots,
              );
            case 'pit':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.medium3Dots,
              );
            case 'presumed':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.mediumDot,
              );
            case 'sand':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.shortDot,
              );
            case 'underlying':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.short,
              );
            case 'unsurveyed':
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.short2Dots,
              );
            default:
              return THLinePaint(
                primaryPaint: primaryPaint,
                type: MPLinePaintType.shortMediumShort,
              );
          }
        } else {
          return THLinePaint(
            primaryPaint: primaryPaint,
          );
        }
      case THLineType.waterFlow:
        if (line.hasOption(THCommandOptionType.subtype)) {
          final String subtype = (line.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype;
          switch (subtype) {
            case 'conjectural':
              return THLinePaint(
                primaryPaint: THPaints.thPaint4
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.longDot,
              );
            case 'intermittent':
              return THLinePaint(
                primaryPaint: THPaints.thPaint4
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.medium2Dots,
              );
            case 'permanent':
              return THLinePaint(
                primaryPaint: THPaints.thPaint4
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
              );
            default:
              return THLinePaint(
                primaryPaint: THPaints.thPaint4
                  ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
                type: MPLinePaintType.shortMediumShort,
              );
          }
        } else {
          return THLinePaint(
            primaryPaint: THPaints.thPaint4
              ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          );
        }
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
