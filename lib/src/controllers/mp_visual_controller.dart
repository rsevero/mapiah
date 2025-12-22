import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/constants/tk_color_map.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
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
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.altitude: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint7,
    ),
    THPointType.anastomosis: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint1,
    ),
    THPointType.anchor: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint10,
    ),
    THPointType.aragonite: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.archeoExcavation: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint16,
    ),
    THPointType.archeoMaterial: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint16,
      fill: THPaint.thPaint1016,
    ),
    THPointType.audio: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.bat: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint8,
    ),
    THPointType.bedrock: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.blocks: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.bones: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint8,
      fill: THPaint.thPaint1008,
    ),
    THPointType.breakdownChoke: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint1,
    ),
    THPointType.bridge: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.camp: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.cavePearl: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint12,
    ),
    THPointType.clay: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.clayChoke: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint1,
    ),
    THPointType.clayTree: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint5,
    ),
    THPointType.continuation: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.crystal: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.curtain: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint5,
      fill: THPaint.thPaint1005,
    ),
    THPointType.curtains: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint5,
      fill: THPaint.thPaint1005,
    ),
    THPointType.danger: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint0,
    ),
    THPointType.date: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint7,
    ),
    THPointType.debris: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.dig: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint16,
    ),
    THPointType.dimensions: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint7,
      fill: THPaint.thPaint1007,
    ),
    THPointType.discPillar: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint11,
    ),
    THPointType.discPillars: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint11,
    ),
    THPointType.discStalactite: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint13,
      fill: THPaint.thPaint1013,
    ),
    THPointType.discStalagmite: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint13,
      fill: THPaint.thPaint1013,
    ),
    THPointType.disk: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.electricLight: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint10,
    ),
    THPointType.entrance: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint2,
      fill: THPaint.thPaint1002,
    ),
    THPointType.extra: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint0,
    ),
    THPointType.exVoto: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.fixedLadder: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint10,
    ),
    THPointType.flowstone: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.flute: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint12,
    ),
    THPointType.gate: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.gradient: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.guano: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint8,
      fill: THPaint.thPaint1008,
    ),
    THPointType.gypsum: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint12,
    ),
    THPointType.gypsumFlower: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint12,
    ),
    THPointType.handrail: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.height: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint7,
    ),
    THPointType.helictite: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint5,
      fill: THPaint.thPaint1005,
    ),
    THPointType.humanBones: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint8,
      fill: THPaint.thPaint1008,
    ),
    THPointType.ice: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint6,
      fill: THPaint.thPaint1006,
    ),
    THPointType.icePillar: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint6,
      fill: THPaint.thPaint1006,
    ),
    THPointType.iceStalactite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint6,
    ),
    THPointType.iceStalagmite: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint6,
    ),
    THPointType.karren: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint1,
    ),
    THPointType.label: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.lowEnd: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint2,
      fill: THPaint.thPaint1002,
    ),
    THPointType.mapConnection: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint0,
    ),
    THPointType.masonry: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint10,
    ),
    THPointType.moonmilk: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.mud: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.mudcrack: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.namePlate: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.narrowEnd: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint2,
      fill: THPaint.thPaint1002,
    ),
    THPointType.noEquipment: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.noWheelchair: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.paleoMaterial: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint16,
      fill: THPaint.thPaint1016,
    ),
    THPointType.passageHeight: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint7,
      fill: THPaint.thPaint1007,
    ),
    THPointType.pebbles: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint1,
    ),
    THPointType.pendant: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.photo: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.pillar: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint11,
      fill: THPaint.thPaint1011,
    ),
    THPointType.pillarWithCurtains: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint11,
    ),
    THPointType.pillarsWithCurtains: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint11,
      fill: THPaint.thPaint1011,
    ),
    THPointType.popcorn: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.raft: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint5,
    ),
    THPointType.raftCone: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint5,
    ),
    THPointType.remark: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint0,
    ),
    THPointType.rimstoneDam: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint12,
      fill: THPaint.thPaint1012,
    ),
    THPointType.root: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint8,
    ),
    THPointType.rope: THPointPaint(
      type: MPPointShapeType.verticalDiamond,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.ropeLadder: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint10,
    ),
    THPointType.sand: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.scallop: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.section: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.seedGermination: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint8,
    ),
    THPointType.sink: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint3,
    ),
    THPointType.snow: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint6,
    ),
    THPointType.sodaStraw: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint5,
    ),
    THPointType.spring: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint3,
    ),
    THPointType.stalactite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint13,
    ),
    THPointType.stalactites: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint13,
      fill: THPaint.thPaint1013,
    ),
    THPointType.stalactiteStalagmite: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint13,
      fill: THPaint.thPaint1013,
    ),
    THPointType.stalagmite: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint13,
    ),
    THPointType.stalagmites: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint13,
      fill: THPaint.thPaint1013,
    ),
    THPointType.stationName: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
    THPointType.steps: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.traverse: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint1,
      fill: THPaint.thPaint1001,
    ),
    THPointType.treeTrunk: THPointPaint(
      type: MPPointShapeType.plus,
      border: THPaint.thPaint8,
    ),
    THPointType.u: THPointPaint(
      type: MPPointShapeType.x,
      border: THPaint.thPaint15,
    ),
    THPointType.vegetableDebris: THPointPaint(
      type: MPPointShapeType.square,
      border: THPaint.thPaint8,
      fill: THPaint.thPaint1008,
    ),
    THPointType.viaFerrata: THPointPaint(
      type: MPPointShapeType.circle,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.volcano: THPointPaint(
      type: MPPointShapeType.asterisk,
      border: THPaint.thPaint5,
    ),
    THPointType.walkway: THPointPaint(
      type: MPPointShapeType.horizontalDiamond,
      border: THPaint.thPaint10,
      fill: THPaint.thPaint1010,
    ),
    THPointType.wallCalcite: THPointPaint(
      type: MPPointShapeType.t,
      border: THPaint.thPaint12,
    ),
    THPointType.water: THPointPaint(
      type: MPPointShapeType.star,
      border: THPaint.thPaint3,
      fill: THPaint.thPaint1003,
    ),
    THPointType.waterDrip: THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint3,
    ),
    THPointType.wheelchair: THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint0,
      fill: THPaint.thPaint1000,
    ),
  };

  static final Map<String, THPointPaint> waterFlowPointSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint14,
    ),
    'intermittent': THPointPaint(
      type: MPPointShapeType.invertedT,
      border: THPaint.thPaint14,
    ),
    'paleo': THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint14,
    ),
    'permanent': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint14,
    ),
  };

  static final Map<String, THPointPaint> stationSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint4,
    ),
    'fixed': THPointPaint(
      type: MPPointShapeType.triangleWithCenterCircle,
      border: THPaint.thPaint4,
    ),
    'natural': THPointPaint(
      type: MPPointShapeType.invertedTriangle,
      border: THPaint.thPaint4,
    ),
    'painted': THPointPaint(
      type: MPPointShapeType.triangle,
      fill: THPaint.thPaint4,
    ),
    'temporary': THPointPaint(
      type: MPPointShapeType.triangle,
      border: THPaint.thPaint4,
    ),
  };

  static final Map<String, THPointPaint> airDraughtSubtypesPaints = {
    mpNoSubtypeID: THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint9,
    ),
    'summer': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint9,
      fill: THPaint.thPaint1,
    ),
    'undefined': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint9,
    ),
    'winter': THPointPaint(
      type: MPPointShapeType.arrow,
      border: THPaint.thPaint9,
      fill: THPaint.thPaint5,
    ),
  };

  static final Map<THLineType, THLinePaint> lineTypePaints = {
    THLineType.abyssEntrance: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      type: MPLinePaintType.longDot,
    ),
    THLineType.arrow: THLinePaint(
      primaryPaint: THPaint.thPaint9,
      type: MPLinePaintType.dot,
    ),
    THLineType.ceilingMeander: THLinePaint(
      primaryPaint: THPaint.thPaint5,
      type: MPLinePaintType.shortMediumShort,
    ),
    THLineType.ceilingStep: THLinePaint(
      primaryPaint: THPaint.thPaint5,
      type: MPLinePaintType.shortDot,
    ),
    THLineType.chimney: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.contour: THLinePaint(
      primaryPaint: THPaint.thPaint6,
      type: MPLinePaintType.dot,
    ),
    THLineType.dripline: THLinePaint(
      primaryPaint: THPaint.thPaint6,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.fault: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      type: MPLinePaintType.dot,
    ),
    THLineType.fixedLadder: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.dot,
    ),
    THLineType.floorMeander: THLinePaint(
      primaryPaint: THPaint.thPaint5,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.floorStep: THLinePaint(
      primaryPaint: THPaint.thPaint5,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.flowstone: THLinePaint(
      primaryPaint: THPaint.thPaint10,
      type: MPLinePaintType.shortMediumShort,
    ),
    THLineType.gradient: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      type: MPLinePaintType.long,
    ),
    THLineType.handrail: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.long,
    ),
    THLineType.joint: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.label: THLinePaint(
      primaryPaint: THPaint.thPaint9,
      type: MPLinePaintType.long,
    ),
    THLineType.lowCeiling: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      type: MPLinePaintType.short3Dots,
    ),
    THLineType.mapConnection: THLinePaint(
      primaryPaint: THPaint.thPaint9,
      type: MPLinePaintType.short2Dots,
    ),
    THLineType.moonmilk: THLinePaint(
      primaryPaint: THPaint.thPaint10,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.overhang: THLinePaint(
      primaryPaint: THPaint.thPaint10,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.pit: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      type: MPLinePaintType.shortLongShort,
    ),
    THLineType.pitch: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      type: MPLinePaintType.short2Dots,
    ),
    THLineType.pitChimney: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      type: MPLinePaintType.medium,
    ),
    THLineType.rimstoneDam: THLinePaint(
      primaryPaint: THPaint.thPaint7,
      type: MPLinePaintType.long,
    ),
    THLineType.rimstonePool: THLinePaint(
      primaryPaint: THPaint.thPaint7,
      type: MPLinePaintType.short3Dots,
    ),
    THLineType.rockBorder: THLinePaint(
      primaryPaint: THPaint.thPaint8,
      type: MPLinePaintType.continuous,
    ),
    THLineType.rockEdge: THLinePaint(
      primaryPaint: THPaint.thPaint8,
      type: MPLinePaintType.medium,
    ),
    THLineType.rope: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.continuous,
    ),
    THLineType.ropeLadder: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.short,
    ),
    THLineType.section: THLinePaint(
      primaryPaint: THPaint.thPaint9,
      type: MPLinePaintType.mediumDot,
    ),
    THLineType.slope: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      type: MPLinePaintType.continuous,
    ),
    THLineType.steps: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.long3Dots,
    ),
    THLineType.u: THLinePaint(
      primaryPaint: THPaint.thPaint15,
      type: MPLinePaintType.continuous,
    ),
    THLineType.viaFerrata: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.medium2Dots,
    ),
    THLineType.walkway: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      type: MPLinePaintType.medium,
    ),
  };

  static final Map<String, THLinePaint> borderSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.continuous,
    ),
    'invisible': THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.dot,
    ),
    'presumed': THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.long,
    ),
    'temporary': THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.medium2Dots,
    ),
    'visible': THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.continuous,
    ),
  };

  static final Map<String, THLinePaint> surveySubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaint.thPaint14,
      type: MPLinePaintType.continuous,
    ),
    'cave': THLinePaint(
      primaryPaint: THPaint.thPaint14,
      type: MPLinePaintType.continuous,
    ),
    'surface': THLinePaint(
      primaryPaint: THPaint.thPaint14,
      type: MPLinePaintType.dot,
    ),
  };

  static final Map<String, THLinePaint> wallSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.continuous,
    ),
    'bedrock': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.continuous,
    ),
    'blocks': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.dot,
    ),
    'clay': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.long,
    ),
    'debris': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.long2Dots,
    ),
    'flowstone': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.long3Dots,
    ),
    'ice': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.longDot,
    ),
    'invisible': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.mediumLongMedium,
    ),
    'moonmilk': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.shortLongShort,
    ),
    'overlying': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.medium,
    ),
    'pebbles': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.medium2Dots,
    ),
    'pit': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.medium3Dots,
    ),
    'presumed': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.mediumDot,
    ),
    'sand': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.shortDot,
    ),
    'underlying': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.short,
    ),
    'unsurveyed': THLinePaint(
      primaryPaint: THPaint.thPaint0,
      type: MPLinePaintType.short2Dots,
    ),
  };

  static final Map<String, THLinePaint> waterFlowLineSubtypesPaints = {
    mpNoSubtypeID: THLinePaint(
      primaryPaint: THPaint.thPaint3,
      type: MPLinePaintType.continuous,
    ),
    'conjectural': THLinePaint(
      primaryPaint: THPaint.thPaint3,
      type: MPLinePaintType.longDot,
    ),
    'intermittent': THLinePaint(
      primaryPaint: THPaint.thPaint3,
      type: MPLinePaintType.medium2Dots,
    ),
    'permanent': THLinePaint(
      primaryPaint: THPaint.thPaint3,
      type: MPLinePaintType.continuous,
    ),
  };

  static final Map<bool, THLinePaint> lineDirectionTickPaints = {
    true: THLinePaint(
      primaryPaint: THPaint.thPaint16,
      type: MPLinePaintType.continuous,
    ),
    false: THLinePaint(
      primaryPaint: THPaint.thPaint4,
      type: MPLinePaintType.continuous,
    ),
  };

  static final Map<THAreaType, THLinePaint> areaTypePaints = {
    THAreaType.bedrock: THLinePaint(
      primaryPaint: THPaint.thPaint0,
      fillPaint: THPaint.thPaint3000,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.blocks: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      fillPaint: THPaint.thPaint3012,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.clay: THLinePaint(
      primaryPaint: THPaint.thPaint10,
      fillPaint: THPaint.thPaint3010,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.debris: THLinePaint(
      primaryPaint: THPaint.thPaint12,
      fillPaint: THPaint.thPaint3010,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.flowstone: THLinePaint(
      primaryPaint: THPaint.thPaint6,
      fillPaint: THPaint.thPaint3006,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.ice: THLinePaint(
      primaryPaint: THPaint.thPaint9,
      fillPaint: THPaint.thPaint3009,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.moonmilk: THLinePaint(
      primaryPaint: THPaint.thPaint6,
      fillPaint: THPaint.thPaint3005,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.mudcrack: THLinePaint(
      primaryPaint: THPaint.thPaint10,
      fillPaint: THPaint.thPaint3002,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.pebbles: THLinePaint(
      primaryPaint: THPaint.thPaint5,
      fillPaint: THPaint.thPaint3005,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.pillar: THLinePaint(
      primaryPaint: THPaint.thPaint1,
      fillPaint: THPaint.thPaint3001,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.pillarWithCurtains: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      fillPaint: THPaint.thPaint3002,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.pillars: THLinePaint(
      primaryPaint: THPaint.thPaint1,
      fillPaint: THPaint.thPaint3002,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.pillarsWithCurtains: THLinePaint(
      primaryPaint: THPaint.thPaint2,
      fillPaint: THPaint.thPaint3001,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.sand: THLinePaint(
      primaryPaint: THPaint.thPaint13,
      fillPaint: THPaint.thPaint3013,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.snow: THLinePaint(
      primaryPaint: THPaint.thPaint7,
      fillPaint: THPaint.thPaint3007,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.stalactite: THLinePaint(
      primaryPaint: THPaint.thPaint4,
      fillPaint: THPaint.thPaint3008,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.stalactiteStalagmite: THLinePaint(
      primaryPaint: THPaint.thPaint4,
      fillPaint: THPaint.thPaint3004,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.stalagmite: THLinePaint(
      primaryPaint: THPaint.thPaint4,
      fillPaint: THPaint.thPaint3003,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.sump: THLinePaint(
      primaryPaint: THPaint.thPaint14,
      fillPaint: THPaint.thPaint3014,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.u: THLinePaint(
      primaryPaint: THPaint.thPaint15,
      fillPaint: THPaint.thPaint3015,
      type: MPLinePaintType.continuous,
    ),
    THAreaType.water: THLinePaint(
      primaryPaint: THPaint.thPaint3,
      fillPaint: THPaint.thPaint3003,
      type: MPLinePaintType.continuous,
    ),
  };

  Paint getControlLinePaint() {
    return THPaint.thPaintBlackBorder
      ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas;
  }

  THPointPaint getSelectedPointPaint(THPoint point) {
    THPointPaint pointPaint = getDefaultPointPaint(
      point,
    ).copyWith(radius: _th2FileEditController.pointRadiusOnCanvas);

    if (pointPaint.border != null) {
      pointPaint = pointPaint.copyWith(
        border: THPaint.thPaint1
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      );
    }
    if (pointPaint.fill != null) {
      pointPaint = pointPaint.copyWith(fill: THPaint.thPaint1001);
    }
    return pointPaint;
  }

  THLinePaint getSelectedLinePaint({
    required THLineType lineType,
    String? subtype,
  }) {
    final THLinePaint linePaint = getDefaultLinePaintByTypeSubtype(
      lineType: lineType,
      subtype: subtype,
    );

    return linePaint.copyWith(
      primaryPaint: THPaint.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      makeSecondaryPaintNull: true,
    );
  }

  THLinePaint getSelectedAreaPaint(THArea area) {
    final THLinePaint areaPaint = getDefaultAreaPaint(areaType: area.areaType)
        .copyWith(
          primaryPaint: THPaint.thPaint1
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
          fillPaint: THPaint.thPaint3001,
        );

    return areaPaint;
  }

  THLinePaint getMultipleElementsClickedHighlightedFillPaint() {
    return THLinePaint(primaryPaint: THPaint.thPaint3001);
  }

  THLinePaint getMultipleElementsClickedHighlightedBorderPaint(THLine line) {
    final THLinePaint linePaint = getDefaultLinePaint(line);

    return linePaint.copyWith(
      primaryPaint: THPaint.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
      makeSecondaryPaintNull: true,
    );
  }

  THLinePaint getNewLinePaint() {
    return THLinePaint(
      primaryPaint: THPaint.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getEditLinePaint() {
    return THLinePaint(
      primaryPaint: THPaint.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  List<Paint> getHighlightBorders({
    required bool isTHInvisible,
    required bool hasID,
  }) {
    final List<Paint> highlightBorders = [];

    if (isTHInvisible) {
      highlightBorders.add(
        Paint.from(
          THPaint.thPaint16
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        ),
      );
    }

    if (hasID) {
      highlightBorders.add(
        Paint.from(
          THPaint.thPaint17
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        ),
      );
    }

    return highlightBorders;
  }

  THPointPaint getUnselectedPointPaint({
    required THPoint point,
    required bool isFromActiveScrap,
  }) {
    THPointPaint pointPaint = getDefaultPointPaint(
      point,
    ).copyWith(radius: _th2FileEditController.pointRadiusOnCanvas);

    if (isFromActiveScrap) {
      final bool pointIsTHInvisible = !MPCommandOptionAux.isTHVisible(point);
      final bool pointHasID = MPCommandOptionAux.hasID(point);

      if (pointIsTHInvisible || pointHasID) {
        final List<Paint> highlightBorders = (pointIsTHInvisible || pointHasID)
            ? getHighlightBorders(
                isTHInvisible: pointIsTHInvisible,
                hasID: pointHasID,
              )
            : const [];

        pointPaint = pointPaint.copyWith(highlightBorders: highlightBorders);
      }
    } else {
      if (pointPaint.border != null) {
        pointPaint = pointPaint.copyWith(
          border: THPaint.thPaint15
            ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        );
      }

      if (pointPaint.fill != null) {
        pointPaint = pointPaint.copyWith(fill: THPaint.thPaint1015);
      }
    }

    return pointPaint;
  }

  THLinePaint getDefaultAreaPaint({required THAreaType areaType}) {
    return areaTypePaints[areaType] ??
        THLinePaint(
          primaryPaint: THPaint.thPaint0,
          fillPaint: THPaint.thPaint3001,
          type: MPLinePaintType.medium,
        );
  }

  THLinePaint getUnselectedAreaPaint({
    required THAreaType areaType,
    String? subtype,
    bool areaIsTHInvisible = false,
    bool areaHasID = false,
    required bool isFromActiveScrap,
  }) {
    THLinePaint areaPaint = getDefaultAreaPaint(areaType: areaType);

    if (isFromActiveScrap) {
      final List<Paint> highlightBorders = (areaIsTHInvisible || areaHasID)
          ? getHighlightBorders(
              isTHInvisible: areaIsTHInvisible,
              hasID: areaHasID,
            )
          : const [];

      areaPaint = areaPaint.copyWith(
        primaryPaint: areaPaint.primaryPaint!
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        highlightBorders: highlightBorders,
      );
    } else {
      areaPaint = areaPaint.copyWith(
        primaryPaint: THPaint.thPaint15
          ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
        fillPaint: THPaint.thPaint3015,
      );
    }

    return areaPaint;
  }

  THPointPaint getDefaultPointPaint(THPoint point) {
    final THPointType pointType = point.pointType;

    THPointPaint pointPaint;

    if (pointTypePaints.containsKey(pointType)) {
      pointPaint = pointTypePaints[pointType]!;
    } else {
      final String pointSubtype = point.hasOption(THCommandOptionType.subtype)
          ? (point.getOption(THCommandOptionType.subtype)
                    as THSubtypeCommandOption)
                .subtype
          : mpNoSubtypeID;

      switch (pointType) {
        case THPointType.airDraught:
          pointPaint =
              airDraughtSubtypesPaints[pointSubtype] ??
              airDraughtSubtypesPaints[mpNoSubtypeID]!;
        case THPointType.station:
          pointPaint =
              stationSubtypesPaints[pointSubtype] ??
              stationSubtypesPaints[mpNoSubtypeID]!;
        case THPointType.unknown:
          pointPaint = THPointPaint(
            type: MPPointShapeType.exclamation,
            border: THPaint.thPaint0,
            fill: THPaint.thPaint1000,
          );
        case THPointType.waterFlow:
          pointPaint =
              waterFlowPointSubtypesPaints[pointSubtype] ??
              waterFlowPointSubtypesPaints[mpNoSubtypeID]!;
        default:
          pointPaint = THPointPaint(
            type: MPPointShapeType.exclamation,
            border: THPaint.thPaint0,
            fill: THPaint.thPaint1000,
          );
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
    final String? lineSubtype =
        (line.getOption(THCommandOptionType.subtype) as THSubtypeCommandOption?)
            ?.subtype;

    return getDefaultLinePaintByTypeSubtype(
      lineType: lineType,
      subtype: lineSubtype,
    );
  }

  THLinePaint getDefaultLinePaintByTypeSubtype({
    required THLineType lineType,
    String? subtype,
  }) {
    final THLinePaint linePaint;

    if (lineTypePaints.containsKey(lineType)) {
      linePaint = lineTypePaints[lineType]!;
    } else {
      final String lineSubtype = subtype ?? mpNoSubtypeID;

      switch (lineType) {
        case THLineType.border:
          linePaint =
              borderSubtypesPaints[lineSubtype] ??
              borderSubtypesPaints[mpNoSubtypeID]!;
        case THLineType.survey:
          linePaint =
              surveySubtypesPaints[lineSubtype] ??
              surveySubtypesPaints[mpNoSubtypeID]!;
        case THLineType.unknown:
          linePaint = THLinePaint(
            primaryPaint: THPaint.thPaint0,
            type: MPLinePaintType.continuous,
          );
        case THLineType.wall:
          linePaint =
              wallSubtypesPaints[lineSubtype] ??
              wallSubtypesPaints[mpNoSubtypeID]!;
        case THLineType.waterFlow:
          linePaint =
              waterFlowLineSubtypesPaints[lineSubtype] ??
              waterFlowLineSubtypesPaints[mpNoSubtypeID]!;
        default:
          throw Exception(
            'Line type $lineType not found in lineTypePaints map.',
          );
      }
    }

    return linePaint.copyWith(
      primaryPaint: linePaint.primaryPaint!
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getLineDirectionTickPaint({
    required THLine line,
    required bool reverse,
  }) {
    final THLinePaint linePaint = lineDirectionTickPaints[reverse]!;
    final double lineThickness =
        _th2FileEditController.selectionController.isSelected.contains(
          line.mpID,
        )
        ? _th2FileEditController.lineThicknessOnCanvas * 2
        : _th2FileEditController.lineThicknessOnCanvas;

    return linePaint.copyWith(
      primaryPaint:
          (_th2FileEditController.isFromActiveScrap(line)
                ? linePaint.primaryPaint!
                : THPaint.thPaint15)
            ..strokeWidth = lineThickness,
      makeSecondaryPaintNull: true,
    );
  }

  THLinePaint getUnselectedLinePaint({
    required THLineType lineType,
    String? subtype,
    bool lineIsTHInvisible = false,
    bool lineHasID = false,
    required bool isFromActiveScrap,
  }) {
    final THLinePaint linePaintDefault = getDefaultLinePaintByTypeSubtype(
      lineType: lineType,
      subtype: subtype,
    );

    if (isFromActiveScrap) {
      final List<Paint> highlightBorders = (lineIsTHInvisible || lineHasID)
          ? getHighlightBorders(
              isTHInvisible: lineIsTHInvisible,
              hasID: lineHasID,
            )
          : const [];
      final THLinePaint linePaintCopy = linePaintDefault.copyWith(
        primaryPaint: linePaintDefault.primaryPaint == null
            ? null
            : (linePaintDefault.primaryPaint!
                ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas),
        secondaryPaint: linePaintDefault.secondaryPaint == null
            ? null
            : (linePaintDefault.secondaryPaint!
                ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas),
        highlightBorders: highlightBorders,
      );

      return linePaintCopy;
    } else {
      return linePaintDefault.copyWith(
        primaryPaint: THPaint.thPaint15
          ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
        makeSecondaryPaintNull: true,
      );
    }
  }

  Paint getControlPointLinePaint() {
    return THPaint.thPaintBlackBorder
      ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas;
  }

  THPointPaint getNewLinePointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaint.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getHighligthtedEndControlPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaint.thPaint1
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedControlPointPaint() {
    return THPointPaint(
      radius:
          _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor *
          thSelectedEndControlPointFactor,
      border: THPaint.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectedControlPointPaint() {
    return THPointPaint(
      radius:
          _th2FileEditController.pointRadiusOnCanvas *
          thControlPointRadiusFactor,
      border: THPaint.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.controlLineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedEndPointPaint() {
    return THPointPaint(
      radius:
          _th2FileEditController.pointRadiusOnCanvas *
          thSelectedEndControlPointFactor,
      border: THPaint.thPaintBlackBackground,
    );
  }

  THPointPaint getUnselectedEndPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas,
      border: THPaint.thPaintBlackBorder
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THLinePaint getXVIGridLinePaint() {
    return THLinePaint(
      primaryPaint: THPaint.thPaintXVIGridLine
        ..strokeWidth = _th2FileEditController.xviLineThicknessOnCanvas,
    );
  }

  THLinePaint getXVIShotLinePaint() {
    return THLinePaint(
      primaryPaint: THPaint.thPaintXVIShotLine
        ..strokeWidth = _th2FileEditController.lineThicknessOnCanvas,
    );
  }

  THPointPaint getXVIStationPointPaint() {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas * xviPointFactor,
      border: THPaint.thPaintBlackBackground,
    );
  }

  THLinePaint getXVISketchLinePaint(String tkColorName) {
    return THLinePaint(
      primaryPaint: Paint()
        ..color = TKColorMap.getColor(tkColorName)
        ..strokeWidth = _th2FileEditController.xviLineThicknessOnCanvas
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  THPointPaint getXVISketchPointPaint(String tkColorName) {
    return THPointPaint(
      radius: _th2FileEditController.pointRadiusOnCanvas * xviPointFactor,
      border: Paint()
        ..color = TKColorMap.getColor(tkColorName)
        ..strokeWidth = _th2FileEditController.xviLineThicknessOnCanvas
        ..style = PaintingStyle.stroke,
      type: MPPointShapeType.square,
    );
  }
}
