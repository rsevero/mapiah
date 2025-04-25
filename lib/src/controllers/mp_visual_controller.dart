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
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';
import 'package:mapiah/src/painters/types/mp_point_shape_type.dart';
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

  static final Map<THPointType, THPointPaint> pointTypePaints = {
    THPointType.altar: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint11,
    ),
    THPointType.altitude: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint8,
    ),
    THPointType.anastomosis: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint2,
    ),
    THPointType.anchor: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint11,
    ),
    THPointType.aragonite: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint13,
    ),
    THPointType.archeoExcavation: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint17,
    ),
    THPointType.archeoMaterial: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaints.thPaint17,
    ),
    THPointType.audio: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaints.thPaint1,
    ),
    THPointType.bat: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint9,
    ),
    THPointType.bedrock: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaints.thPaint2,
    ),
    THPointType.blocks: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint2,
    ),
    THPointType.bones: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint9,
    ),
    THPointType.breakdownChoke: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint2,
    ),
    THPointType.bridge: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaints.thPaint11,
    ),
    THPointType.camp: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint11,
    ),
    THPointType.cavePearl: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint13,
    ),
    THPointType.clay: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint2,
    ),
    THPointType.clayChoke: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint2,
    ),
    THPointType.clayTree: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint6,
    ),
    THPointType.continuation: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint1,
    ),
    THPointType.crystal: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint13,
    ),
    THPointType.curtain: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint6,
    ),
    THPointType.curtains: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint6,
    ),
    THPointType.danger: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint1,
    ),
    THPointType.date: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint8,
    ),
    THPointType.debris: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint2,
    ),
    THPointType.dig: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint17,
    ),
    THPointType.dimensions: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint8,
    ),
    THPointType.discPillar: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint12,
    ),
    THPointType.discPillars: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint12,
    ),
    THPointType.discStalactite: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint14,
    ),
    THPointType.discStalagmite: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint14,
    ),
    THPointType.disk: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaints.thPaint13,
    ),
    THPointType.electricLight: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint11,
    ),
    THPointType.entrance: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint3,
    ),
    THPointType.extra: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint1,
    ),
    THPointType.exVoto: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint11,
    ),
    THPointType.fixedLadder: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint11,
    ),
    THPointType.flowstone: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint13,
    ),
    THPointType.flute: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint13,
    ),
    THPointType.gate: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint11,
    ),
    THPointType.gradient: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint2,
    ),
    THPointType.guano: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint9,
    ),
    THPointType.gypsum: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint13,
    ),
    THPointType.gypsumFlower: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint13,
    ),
    THPointType.handrail: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint11,
    ),
    THPointType.height: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint8,
    ),
    THPointType.helictite: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint6,
    ),
    THPointType.humanBones: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint9,
    ),
    THPointType.ice: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint7,
    ),
    THPointType.icePillar: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint7,
    ),
    THPointType.iceStalactite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint7,
    ),
    THPointType.iceStalagmite: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint7,
    ),
    THPointType.karren: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint2,
    ),
    THPointType.label: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint1,
    ),
    THPointType.mapConnection: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint1,
    ),
    THPointType.masonry: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint11,
    ),
    THPointType.moonmilk: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint13,
    ),
    THPointType.mud: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint2,
    ),
    THPointType.mudcrack: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint2,
    ),
    THPointType.namePlate: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint11,
    ),
    THPointType.noEquipment: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint1,
    ),
    THPointType.noWheelchair: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint1,
    ),
    THPointType.paleoMaterial: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint17,
    ),
    THPointType.passageHeight: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint8,
    ),
    THPointType.pebbles: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint2,
    ),
    THPointType.pendant: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint2,
    ),
    THPointType.photo: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint1,
    ),
    THPointType.pillar: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint12,
    ),
    THPointType.pillarsWithCurtains: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint12,
    ),
    THPointType.popcorn: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint13,
    ),
    THPointType.raft: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint6,
    ),
    THPointType.raftCone: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint6,
    ),
    THPointType.remark: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint1,
    ),
    THPointType.rimstoneDam: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaints.thPaint13,
    ),
    THPointType.root: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint9,
    ),
    THPointType.rope: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaints.thPaint11,
    ),
    THPointType.ropeLadder: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint11,
    ),
    THPointType.sand: THPointPaint(
      type: MPPointShapeType.triangle,
      fill: THPaints.thPaint2002,
    ),
    THPointType.scallop: THPointPaint(
      type: MPPointShapeType.star,
      fill: THPaints.thPaint2002,
    ),
    THPointType.section: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint1,
    ),
    THPointType.seedGermination: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint9,
    ),
    THPointType.sink: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint4,
    ),
    THPointType.snow: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint7,
    ),
    THPointType.sodaStraw: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint6,
    ),
    THPointType.spring: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint4,
    ),
    THPointType.stalactite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint14,
    ),
    THPointType.stalactites: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint14,
    ),
    THPointType.stalactiteStalagmite: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint14,
    ),
    THPointType.stalagmite: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint14,
    ),
    THPointType.stalagmites: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint14,
    ),
    THPointType.stationName: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint1,
    ),
    THPointType.steps: THPointPaint(
      type: MPPointShapeType.arrow,
      fill: THPaints.thPaint2011,
    ),
    THPointType.traverse: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint2,
    ),
    THPointType.treeTrunk: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaints.thPaint9,
    ),
    THPointType.u: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaints.thPaint16,
    ),
    THPointType.vegetableDebris: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaints.thPaint9,
    ),
    THPointType.viaFerrata: THPointPaint(
      type: MPPointShapeType.circle,
      fill: THPaints.thPaint2011,
    ),
    THPointType.volcano: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaints.thPaint6,
    ),
    THPointType.walkway: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      fill: THPaints.thPaint2011,
    ),
    THPointType.wallCalcite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaints.thPaint13,
    ),
    THPointType.water: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaints.thPaint4,
    ),
    THPointType.waterDrip: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint4,
    ),
    THPointType.wheelchair: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      fill: THPaints.thPaint2001,
    ),
  };

  static final Map<String, THPointPaint> waterFlowPointSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint15,
    ),
    'intermittent': THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaints.thPaint15,
    ),
    'paleo': THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint15,
    ),
    'permanent': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint15,
    ),
  };

  static final Map<String, THPointPaint> stationSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint5,
    ),
    'fixed': THPointPaint(
      type: MPPointShapeType.triangleWithCenterCircle,
      border: THPaints.thPaint5,
    ),
    'natural': THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaints.thPaint5,
    ),
    'painted': THPointPaint(
      type: MPPointShapeType.triangle,
      fill: THPaints.thPaint5,
    ),
    'temporary': THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaints.thPaint5,
    ),
  };

  static final Map<String, THPointPaint> airDraughtSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint10,
    ),
    'summer': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint10,
      fill: THPaints.thPaint2,
    ),
    'undefined': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint10,
    ),
    'winter': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaints.thPaint10,
      fill: THPaints.thPaint6,
    ),
  };

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

  static final Map<String, THLinePaint> waterFlowLineSubtypesPaints = {
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
    return getDefaultPointPaint(point).copyWith(
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
    THPointPaint pointPaint = getDefaultPointPaint(point).copyWith(
      radius: _th2FileEditController.pointRadiusOnCanvas,
    );

    if (!_th2FileEditController.isFromActiveScrap(point)) {
      if (pointPaint.border != null) {
        pointPaint = pointPaint.copyWith(
          border: THPaints.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      }

      if (pointPaint.fill != null) {
        pointPaint = pointPaint.copyWith(
          fill: THPaints.thPaint1016,
        );
      }
    }

    return pointPaint;
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

  THPointPaint getDefaultPointPaint(THPoint point) {
    final THPointType pointType = point.pointType;

    THPointPaint pointPaint;

    if (pointTypePaints.containsKey(pointType)) {
      pointPaint = pointTypePaints[pointType]!;
    } else {
      final String pointSubtype = point.hasOption(THCommandOptionType.subtype)
          ? (point.optionByType(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype
          : mpNoSubtypeID;

      switch (pointType) {
        case THPointType.airDraught:
          pointPaint = airDraughtSubtypesPaints[pointSubtype] ??
              airDraughtSubtypesPaints[mpNoSubtypeID]!;
        case THPointType.station:
          pointPaint = stationSubtypesPaints[pointSubtype] ??
              stationSubtypesPaints[mpNoSubtypeID]!;
        case THPointType.waterFlow:
          pointPaint = waterFlowPointSubtypesPaints[pointSubtype] ??
              waterFlowPointSubtypesPaints[mpNoSubtypeID]!;
        default:
          throw Exception(
              'Point type $pointType not found in pointTypePaints map.');
      }
    }

    if (pointPaint.border != null) {
      pointPaint = pointPaint.copyWith(
        border: pointPaint.border!
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      );
    }

    return pointPaint;
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
          linePaint = waterFlowLineSubtypesPaints[lineSubtype] ??
              waterFlowLineSubtypesPaints[mpNoSubtypeID]!;
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
