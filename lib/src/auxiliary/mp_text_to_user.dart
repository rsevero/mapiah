import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPTextToUser {
  static final Map<MPCommandDescriptionType, String> _commandTypeAsString = {};
  static final Map<THLengthUnitType, String> _lengthUnitTypeAsString = {};
  static final Map<THElementType, String> _elementTypeAsString = {};
  static final Map<THPointType, String> _pointTypeAsString = {};
  static final Map<THLineType, String> _lineTypeAsString = {};
  static final Map<THCommandOptionType, String> _commandOptionTypeAsString = {};
  static final Map<THOptionChoicesAdjustType, String>
      _multipleChoiceAdjustChoiceAsString = {};
  static final Map<THOptionChoicesAlignType, String>
      _multipleChoiceAlignChoiceAsString = {};
  static final Map<THOptionChoicesOnOffType, String>
      _multipleChoiceOnOffChoiceAsString = {};
  static final Map<THOptionChoicesOnOffAutoType, String>
      _multipleChoiceOnOffAutoChoiceAsString = {};
  static final Map<THOptionChoicesFlipType, String>
      _multipleChoiceFlipChoiceAsString = {};
  static final Map<THOptionChoicesArrowPositionType, String>
      _multipleChoiceArrowPositionChoiceAsString = {};
  static final Map<THOptionChoicesLineGradientType, String>
      _multipleChoiceLineGradientChoiceAsString = {};
  static final Map<THOptionChoicesLinePointDirectionType, String>
      _multipleChoiceLinePointDirectionChoiceAsString = {};
  static final Map<THOptionChoicesLinePointGradientType, String>
      _multipleChoiceLinePointGradientChoiceAsString = {};
  static final Map<THOptionChoicesOutlineType, String>
      _multipleChoiceOutlineChoiceAsString = {};
  static final Map<THOptionChoicesPlaceType, String>
      _multipleChoicePlaceChoiceAsString = {};
  static Locale _locale = mpLocator.mpSettingsController.locale;

  static void initialize() {
    _initializeCommandTypeAsString();
    _initializeLengthUnitTypeAsString();
    _initializeElementTypeAsString();
    _initializePointTypeAsString();
    _initializeLineTypeAsString();
    _initializeCommandOptionTypeAsString();
    _initializeMultipleChoiceAdjustChoiceAsString();
    _initializeMultipleChoiceAlignChoiceAsString();
    _initializeMultipleChoiceOnOffChoiceAsString();
    _initializeMultipleChoiceOnOffAutoChoiceAsString();
    _initializeMultipleChoiceFlipChoiceAsString();
    _initializeMultipleChoiceArrowPositionChoiceAsString();
    _initializeMultipleChoiceLineGradientChoiceAsString();
    _initializeMultipleChoiceLinePointDirectionChoiceAsString();
    _initializeMultipleChoiceLinePointGradientChoiceAsString();
    _initializeMultipleChoiceOutlineChoiceAsString();
    _initializeMultipleChoicePlaceChoiceAsString();
  }

  static void _initializeCommandTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _locale = mpLocator.mpSettingsController.locale;

    _commandTypeAsString[MPCommandDescriptionType.addElements] =
        localizations.mpCommandDescriptionAddElements;
    _commandTypeAsString[MPCommandDescriptionType.addLine] =
        localizations.mpCommandDescriptionAddLine;
    _commandTypeAsString[MPCommandDescriptionType.addLineSegment] =
        localizations.mpCommandDescriptionAddLineSegment;
    _commandTypeAsString[MPCommandDescriptionType.addPoint] =
        localizations.mpCommandDescriptionAddPoint;
    _commandTypeAsString[MPCommandDescriptionType.deleteElements] =
        localizations.mpCommandDescriptionDeleteElements;
    _commandTypeAsString[MPCommandDescriptionType.deleteLine] =
        localizations.mpCommandDescriptionDeleteLineSegment;
    _commandTypeAsString[MPCommandDescriptionType.deleteLineSegment] =
        localizations.mpCommandDescriptionDeleteLine;
    _commandTypeAsString[MPCommandDescriptionType.deletePoint] =
        localizations.mpCommandDescriptionDeletePoint;
    _commandTypeAsString[MPCommandDescriptionType.editBezierCurve] =
        localizations.mpCommandDescriptionEditBezierCurve;
    _commandTypeAsString[MPCommandDescriptionType.editLine] =
        localizations.mpCommandDescriptionEditLine;
    _commandTypeAsString[MPCommandDescriptionType.editLineSegment] =
        localizations.mpCommandDescriptionEditLineSegment;
    _commandTypeAsString[MPCommandDescriptionType.moveBezierLineSegment] =
        localizations.mpCommandDescriptionMoveBezierLineSegment;
    _commandTypeAsString[MPCommandDescriptionType.moveElements] =
        localizations.mpCommandDescriptionMoveElements;
    _commandTypeAsString[MPCommandDescriptionType.moveLine] =
        localizations.mpCommandDescriptionMoveLine;
    _commandTypeAsString[MPCommandDescriptionType.movePoint] =
        localizations.mpCommandDescriptionMovePoint;
    _commandTypeAsString[MPCommandDescriptionType.moveStraightLineSegment] =
        localizations.mpCommandDescriptionMoveStraightLineSegment;
  }

  static String getCommandDescription(
      MPCommandDescriptionType commandDescriptionType) {
    return _commandTypeAsString.containsKey(commandDescriptionType)
        ? _commandTypeAsString[commandDescriptionType]!
        : commandDescriptionType.name;
  }

  static void _initializeLengthUnitTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _lengthUnitTypeAsString[THLengthUnitType.centimeter] =
        localizations.mpLengthUnitCentimeterAbbreviation;
    _lengthUnitTypeAsString[THLengthUnitType.feet] =
        localizations.mpLengthUnitFootAbbreviation;
    _lengthUnitTypeAsString[THLengthUnitType.inch] =
        localizations.mpLengthUnitInchAbbreviation;
    _lengthUnitTypeAsString[THLengthUnitType.meter] =
        localizations.mpLengthUnitMeterAbbreviation;
    _lengthUnitTypeAsString[THLengthUnitType.yard] =
        localizations.mpLengthUnitYardAbbreviation;
  }

  static String getLengthUnitType(THLengthUnitType lengthUnitType) {
    return _lengthUnitTypeAsString.containsKey(lengthUnitType)
        ? _lengthUnitTypeAsString[lengthUnitType]!
        : lengthUnitType.name;
  }

  static void _initializeElementTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _elementTypeAsString[THElementType.area] = localizations.thElementArea;
    _elementTypeAsString[THElementType.areaBorderTHID] =
        localizations.thElementAreaBorderTHID;
    _elementTypeAsString[THElementType.bezierCurveLineSegment] =
        localizations.thElementBezierCurveLineSegment;
    _elementTypeAsString[THElementType.comment] =
        localizations.thElementComment;
    _elementTypeAsString[THElementType.emptyLine] =
        localizations.thElementEmptyLine;
    _elementTypeAsString[THElementType.encoding] =
        localizations.thElementEncoding;
    _elementTypeAsString[THElementType.endarea] =
        localizations.thElementEndArea;
    _elementTypeAsString[THElementType.endcomment] =
        localizations.thElementEndComment;
    _elementTypeAsString[THElementType.endline] =
        localizations.thElementEndLine;
    _elementTypeAsString[THElementType.endscrap] =
        localizations.thElementEndScrap;
    _elementTypeAsString[THElementType.line] = localizations.thElementLine;
    _elementTypeAsString[THElementType.lineSegment] =
        localizations.thElementLineSegment;
    _elementTypeAsString[THElementType.multilineCommentContent] =
        localizations.thElementMultilineCommentContent;
    _elementTypeAsString[THElementType.multilineComment] =
        localizations.thElementMultilineComment;
    _elementTypeAsString[THElementType.point] = localizations.thElementPoint;
    _elementTypeAsString[THElementType.scrap] = localizations.thElementScrap;
    _elementTypeAsString[THElementType.straightLineSegment] =
        localizations.thElementStraightLineSegment;
    _elementTypeAsString[THElementType.unrecognizedCommand] =
        localizations.thElementUnrecognized;
    _elementTypeAsString[THElementType.xTherionConfig] =
        localizations.thElementXTherionConfig;
  }

  static String getElementType(THElementType elementType) {
    return _elementTypeAsString.containsKey(elementType)
        ? _elementTypeAsString[elementType]!
        : elementType.name;
  }

  static void _initializePointTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _pointTypeAsString[THPointType.airDraught] =
        localizations.thPointAirDraught;
    _pointTypeAsString[THPointType.altar] = localizations.thPointAltar;
    _pointTypeAsString[THPointType.altitude] = localizations.thPointAltitude;
    _pointTypeAsString[THPointType.anastomosis] =
        localizations.thPointAnastomosis;
    _pointTypeAsString[THPointType.anchor] = localizations.thPointAnchor;
    _pointTypeAsString[THPointType.aragonite] = localizations.thPointAragonite;
    _pointTypeAsString[THPointType.archeoExcavation] =
        localizations.thPointArcheoExcavation;
    _pointTypeAsString[THPointType.archeoMaterial] =
        localizations.thPointArcheoMaterial;
    _pointTypeAsString[THPointType.audio] = localizations.thPointAudio;
    _pointTypeAsString[THPointType.bat] = localizations.thPointBat;
    _pointTypeAsString[THPointType.bedrock] = localizations.thPointBedrock;
    _pointTypeAsString[THPointType.blocks] = localizations.thPointBlocks;
    _pointTypeAsString[THPointType.bones] = localizations.thPointBones;
    _pointTypeAsString[THPointType.breakdownChoke] =
        localizations.thPointBreakdownChoke;
    _pointTypeAsString[THPointType.bridge] = localizations.thPointBridge;
    _pointTypeAsString[THPointType.camp] = localizations.thPointCamp;
    _pointTypeAsString[THPointType.cavePearl] = localizations.thPointCavePearl;
    _pointTypeAsString[THPointType.clay] = localizations.thPointClay;
    _pointTypeAsString[THPointType.clayChoke] = localizations.thPointClayChoke;
    _pointTypeAsString[THPointType.clayTree] = localizations.thPointClayTree;
    _pointTypeAsString[THPointType.continuation] =
        localizations.thPointContinuation;
    _pointTypeAsString[THPointType.crystal] = localizations.thPointCrystal;
    _pointTypeAsString[THPointType.curtain] = localizations.thPointCurtain;
    _pointTypeAsString[THPointType.curtains] = localizations.thPointCurtains;
    _pointTypeAsString[THPointType.danger] = localizations.thPointDanger;
    _pointTypeAsString[THPointType.date] = localizations.thPointDate;
    _pointTypeAsString[THPointType.debris] = localizations.thPointDebris;
    _pointTypeAsString[THPointType.dig] = localizations.thPointDig;
    _pointTypeAsString[THPointType.dimensions] =
        localizations.thPointDimensions;
    _pointTypeAsString[THPointType.discPillar] =
        localizations.thPointDiscPillar;
    _pointTypeAsString[THPointType.discPillars] =
        localizations.thPointDiscPillars;
    _pointTypeAsString[THPointType.discStalactite] =
        localizations.thPointDiscStalactite;
    _pointTypeAsString[THPointType.discStalactites] =
        localizations.thPointDiscStalactites;
    _pointTypeAsString[THPointType.discStalagmite] =
        localizations.thPointDiscStalagmite;
    _pointTypeAsString[THPointType.discStalagmites] =
        localizations.thPointDiscStalagmites;
    _pointTypeAsString[THPointType.disk] = localizations.thPointDisk;
    _pointTypeAsString[THPointType.electricLight] =
        localizations.thPointElectricLight;
    _pointTypeAsString[THPointType.entrance] = localizations.thPointEntrance;
    _pointTypeAsString[THPointType.extra] = localizations.thPointExtra;
    _pointTypeAsString[THPointType.exVoto] = localizations.thPointExVoto;
    _pointTypeAsString[THPointType.fixedLadder] =
        localizations.thPointFixedLadder;
    _pointTypeAsString[THPointType.flowstone] = localizations.thPointFlowstone;
    _pointTypeAsString[THPointType.flowstoneChoke] =
        localizations.thPointFlowstoneChoke;
    _pointTypeAsString[THPointType.flute] = localizations.thPointFlute;
    _pointTypeAsString[THPointType.gate] = localizations.thPointGate;
    _pointTypeAsString[THPointType.gradient] = localizations.thPointGradient;
    _pointTypeAsString[THPointType.guano] = localizations.thPointGuano;
    _pointTypeAsString[THPointType.gypsum] = localizations.thPointGypsum;
    _pointTypeAsString[THPointType.gypsumFlower] =
        localizations.thPointGypsumFlower;
    _pointTypeAsString[THPointType.handrail] = localizations.thPointHandrail;
    _pointTypeAsString[THPointType.height] = localizations.thPointHeight;
    _pointTypeAsString[THPointType.helictite] = localizations.thPointHelictite;
    _pointTypeAsString[THPointType.helictites] =
        localizations.thPointHelictites;
    _pointTypeAsString[THPointType.humanBones] =
        localizations.thPointHumanBones;
    _pointTypeAsString[THPointType.ice] = localizations.thPointIce;
    _pointTypeAsString[THPointType.icePillar] = localizations.thPointIcePillar;
    _pointTypeAsString[THPointType.iceStalactite] =
        localizations.thPointIceStalactite;
    _pointTypeAsString[THPointType.iceStalagmite] =
        localizations.thPointIceStalagmite;
    _pointTypeAsString[THPointType.karren] = localizations.thPointKarren;
    _pointTypeAsString[THPointType.label] = localizations.thPointLabel;
    _pointTypeAsString[THPointType.lowEnd] = localizations.thPointLowEnd;
    _pointTypeAsString[THPointType.mapConnection] =
        localizations.thPointMapConnection;
    _pointTypeAsString[THPointType.masonry] = localizations.thPointMasonry;
    _pointTypeAsString[THPointType.moonmilk] = localizations.thPointMoonmilk;
    _pointTypeAsString[THPointType.mud] = localizations.thPointMud;
    _pointTypeAsString[THPointType.mudcrack] = localizations.thPointMudcrack;
    _pointTypeAsString[THPointType.namePlate] = localizations.thPointNamePlate;
    _pointTypeAsString[THPointType.narrowEnd] = localizations.thPointNarrowEnd;
    _pointTypeAsString[THPointType.noEquipment] =
        localizations.thPointNoEquipment;
    _pointTypeAsString[THPointType.noWheelchair] =
        localizations.thPointNoWheelchair;
    _pointTypeAsString[THPointType.paleoMaterial] =
        localizations.thPointPaleoMaterial;
    _pointTypeAsString[THPointType.passageHeight] =
        localizations.thPointPassageHeight;
    _pointTypeAsString[THPointType.pebbles] = localizations.thPointPebbles;
    _pointTypeAsString[THPointType.pendant] = localizations.thPointPendant;
    _pointTypeAsString[THPointType.photo] = localizations.thPointPhoto;
    _pointTypeAsString[THPointType.pillar] = localizations.thPointPillar;
    _pointTypeAsString[THPointType.pillarsWithCurtains] =
        localizations.thPointPillarsWithCurtains;
    _pointTypeAsString[THPointType.pillarWithCurtains] =
        localizations.thPointPillarWithCurtains;
    _pointTypeAsString[THPointType.popcorn] = localizations.thPointPopcorn;
    _pointTypeAsString[THPointType.raft] = localizations.thPointRaft;
    _pointTypeAsString[THPointType.raftCone] = localizations.thPointRaftCone;
    _pointTypeAsString[THPointType.remark] = localizations.thPointRemark;
    _pointTypeAsString[THPointType.rimstoneDam] =
        localizations.thPointRimstoneDam;
    _pointTypeAsString[THPointType.rimstonePool] =
        localizations.thPointRimstonePool;
    _pointTypeAsString[THPointType.root] = localizations.thPointRoot;
    _pointTypeAsString[THPointType.rope] = localizations.thPointRope;
    _pointTypeAsString[THPointType.ropeLadder] =
        localizations.thPointRopeLadder;
    _pointTypeAsString[THPointType.sand] = localizations.thPointSand;
    _pointTypeAsString[THPointType.scallop] = localizations.thPointScallop;
    _pointTypeAsString[THPointType.section] = localizations.thPointSection;
    _pointTypeAsString[THPointType.seedGermination] =
        localizations.thPointSeedGermination;
    _pointTypeAsString[THPointType.sink] = localizations.thPointSink;
    _pointTypeAsString[THPointType.snow] = localizations.thPointSnow;
    _pointTypeAsString[THPointType.sodaStraw] = localizations.thPointSodaStraw;
    _pointTypeAsString[THPointType.spring] = localizations.thPointSpring;
    _pointTypeAsString[THPointType.stalactite] =
        localizations.thPointStalactite;
    _pointTypeAsString[THPointType.stalactites] =
        localizations.thPointStalactites;
    _pointTypeAsString[THPointType.stalactitesStalagmites] =
        localizations.thPointStalactitesStalagmites;
    _pointTypeAsString[THPointType.stalactiteStalagmite] =
        localizations.thPointStalactiteStalagmite;
    _pointTypeAsString[THPointType.stalagmite] =
        localizations.thPointStalagmite;
    _pointTypeAsString[THPointType.stalagmites] =
        localizations.thPointStalagmites;
    _pointTypeAsString[THPointType.station] = localizations.thPointStation;
    _pointTypeAsString[THPointType.stationName] =
        localizations.thPointStationName;
    _pointTypeAsString[THPointType.steps] = localizations.thPointSteps;
    _pointTypeAsString[THPointType.traverse] = localizations.thPointTraverse;
    _pointTypeAsString[THPointType.treeTrunk] = localizations.thPointTreeTrunk;
    _pointTypeAsString[THPointType.u] = localizations.thPointU;
    _pointTypeAsString[THPointType.vegetableDebris] =
        localizations.thPointVegetableDebris;
    _pointTypeAsString[THPointType.viaFerrata] =
        localizations.thPointViaFerrata;
    _pointTypeAsString[THPointType.volcano] = localizations.thPointVolcano;
    _pointTypeAsString[THPointType.walkway] = localizations.thPointWalkway;
    _pointTypeAsString[THPointType.wallCalcite] =
        localizations.thPointWallCalcite;
    _pointTypeAsString[THPointType.water] = localizations.thPointWater;
    _pointTypeAsString[THPointType.waterDrip] = localizations.thPointWaterDrip;
    _pointTypeAsString[THPointType.waterFlow] = localizations.thPointWaterFlow;
    _pointTypeAsString[THPointType.wheelchair] =
        localizations.thPointWheelchair;
  }

  static String getPointType(THPointType pointType) {
    return _pointTypeAsString.containsKey(pointType)
        ? _pointTypeAsString[pointType]!
        : pointType.name;
  }

  static void _initializeLineTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _lineTypeAsString[THLineType.abyssEntrance] =
        localizations.thLineAbyssEntrance;
    _lineTypeAsString[THLineType.arrow] = localizations.thLineArrow;
    _lineTypeAsString[THLineType.border] = localizations.thLineBorder;
    _lineTypeAsString[THLineType.ceilingMeander] =
        localizations.thLineCeilingMeander;
    _lineTypeAsString[THLineType.ceilingStep] = localizations.thLineCeilingStep;
    _lineTypeAsString[THLineType.chimney] = localizations.thLineChimney;
    _lineTypeAsString[THLineType.contour] = localizations.thLineContour;
    _lineTypeAsString[THLineType.dripline] = localizations.thLineDripline;
    _lineTypeAsString[THLineType.fault] = localizations.thLineFault;
    _lineTypeAsString[THLineType.fixedLadder] = localizations.thLineFixedLadder;
    _lineTypeAsString[THLineType.floorMeander] =
        localizations.thLineFloorMeander;
    _lineTypeAsString[THLineType.floorStep] = localizations.thLineFloorStep;
    _lineTypeAsString[THLineType.flowstone] = localizations.thLineFlowstone;
    _lineTypeAsString[THLineType.gradient] = localizations.thLineGradient;
    _lineTypeAsString[THLineType.handrail] = localizations.thLineHandrail;
    _lineTypeAsString[THLineType.joint] = localizations.thLineJoint;
    _lineTypeAsString[THLineType.label] = localizations.thLineLabel;
    _lineTypeAsString[THLineType.lowCeiling] = localizations.thLineLowCeiling;
    _lineTypeAsString[THLineType.mapConnection] =
        localizations.thLineMapConnection;
    _lineTypeAsString[THLineType.moonmilk] = localizations.thLineMoonmilk;
    _lineTypeAsString[THLineType.overhang] = localizations.thLineOverhang;
    _lineTypeAsString[THLineType.pit] = localizations.thLinePit;
    _lineTypeAsString[THLineType.pitch] = localizations.thLinePitch;
    _lineTypeAsString[THLineType.pitChimney] = localizations.thLinePitChimney;
    _lineTypeAsString[THLineType.rimstoneDam] = localizations.thLineRimstoneDam;
    _lineTypeAsString[THLineType.rimstonePool] =
        localizations.thLineRimstonePool;
    _lineTypeAsString[THLineType.rockBorder] = localizations.thLineRockBorder;
    _lineTypeAsString[THLineType.rockEdge] = localizations.thLineRockEdge;
    _lineTypeAsString[THLineType.rope] = localizations.thLineRope;
    _lineTypeAsString[THLineType.ropeLadder] = localizations.thLineRopeLadder;
    _lineTypeAsString[THLineType.section] = localizations.thLineSection;
    _lineTypeAsString[THLineType.slope] = localizations.thLineSlope;
    _lineTypeAsString[THLineType.steps] = localizations.thLineSteps;
    _lineTypeAsString[THLineType.survey] = localizations.thLineSurvey;
    _lineTypeAsString[THLineType.u] = localizations.thLineU;
    _lineTypeAsString[THLineType.viaFerrata] = localizations.thLineViaFerrata;
    _lineTypeAsString[THLineType.walkWay] = localizations.thLineWalkWay;
    _lineTypeAsString[THLineType.wall] = localizations.thLineWall;
    _lineTypeAsString[THLineType.waterFlow] = localizations.thLineWaterFlow;
  }

  static String getLineType(THLineType lineType) {
    return _lineTypeAsString.containsKey(lineType)
        ? _lineTypeAsString[lineType]!
        : lineType.name;
  }

  static void _initializeCommandOptionTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _commandOptionTypeAsString[THCommandOptionType.adjust] =
        localizations.thCommandOptionAdjust;
    _commandOptionTypeAsString[THCommandOptionType.align] =
        localizations.thCommandOptionAlign;
    _commandOptionTypeAsString[THCommandOptionType.altitude] =
        localizations.thCommandOptionAltitude;
    _commandOptionTypeAsString[THCommandOptionType.altitudeValue] =
        localizations.thCommandOptionAltitudeValue;
    _commandOptionTypeAsString[THCommandOptionType.anchors] =
        localizations.thCommandOptionAnchors;
    _commandOptionTypeAsString[THCommandOptionType.author] =
        localizations.thCommandOptionAuthor;
    _commandOptionTypeAsString[THCommandOptionType.border] =
        localizations.thCommandOptionBorder;
    _commandOptionTypeAsString[THCommandOptionType.clip] =
        localizations.thCommandOptionClip;
    _commandOptionTypeAsString[THCommandOptionType.close] =
        localizations.thCommandOptionClose;
    _commandOptionTypeAsString[THCommandOptionType.context] =
        localizations.thCommandOptionContext;
    _commandOptionTypeAsString[THCommandOptionType.copyright] =
        localizations.thCommandOptionCopyright;
    _commandOptionTypeAsString[THCommandOptionType.cs] =
        localizations.thCommandOptionCs;
    _commandOptionTypeAsString[THCommandOptionType.dateValue] =
        localizations.thCommandOptionDateValue;
    _commandOptionTypeAsString[THCommandOptionType.dimensionsValue] =
        localizations.thCommandOptionDimensionsValue;
    _commandOptionTypeAsString[THCommandOptionType.dist] =
        localizations.thCommandOptionDist;
    _commandOptionTypeAsString[THCommandOptionType.explored] =
        localizations.thCommandOptionExplored;
    _commandOptionTypeAsString[THCommandOptionType.extend] =
        localizations.thCommandOptionExtend;
    _commandOptionTypeAsString[THCommandOptionType.flip] =
        localizations.thCommandOptionFlip;
    _commandOptionTypeAsString[THCommandOptionType.from] =
        localizations.thCommandOptionFrom;
    _commandOptionTypeAsString[THCommandOptionType.head] =
        localizations.thCommandOptionHead;
    _commandOptionTypeAsString[THCommandOptionType.id] =
        localizations.thCommandOptionId;
    _commandOptionTypeAsString[THCommandOptionType.lineDirection] =
        localizations.thCommandOptionLineDirection;
    _commandOptionTypeAsString[THCommandOptionType.lineGradient] =
        localizations.thCommandOptionLineGradient;
    _commandOptionTypeAsString[THCommandOptionType.lineHeight] =
        localizations.thCommandOptionLineHeight;
    _commandOptionTypeAsString[THCommandOptionType.linePointDirection] =
        localizations.thCommandOptionLinePointDirection;
    _commandOptionTypeAsString[THCommandOptionType.linePointGradient] =
        localizations.thCommandOptionLinePointGradient;
    _commandOptionTypeAsString[THCommandOptionType.lineScale] =
        localizations.thCommandOptionLineScale;
    _commandOptionTypeAsString[THCommandOptionType.lSize] =
        localizations.thCommandOptionLSize;
    _commandOptionTypeAsString[THCommandOptionType.mark] =
        localizations.thCommandOptionMark;
    _commandOptionTypeAsString[THCommandOptionType.name] =
        localizations.thCommandOptionName;
    _commandOptionTypeAsString[THCommandOptionType.outline] =
        localizations.thCommandOptionOutline;
    _commandOptionTypeAsString[THCommandOptionType.orientation] =
        localizations.thCommandOptionOrientation;
    _commandOptionTypeAsString[THCommandOptionType.passageHeightValue] =
        localizations.thCommandOptionPassageHeightValue;
    _commandOptionTypeAsString[THCommandOptionType.place] =
        localizations.thCommandOptionPlace;
    _commandOptionTypeAsString[THCommandOptionType.pointHeightValue] =
        localizations.thCommandOptionPointHeightValue;
    _commandOptionTypeAsString[THCommandOptionType.pointScale] =
        localizations.thCommandOptionPointScale;
    _commandOptionTypeAsString[THCommandOptionType.projection] =
        localizations.thCommandOptionProjection;
    _commandOptionTypeAsString[THCommandOptionType.rebelays] =
        localizations.thCommandOptionRebelays;
    _commandOptionTypeAsString[THCommandOptionType.reverse] =
        localizations.thCommandOptionReverse;
    _commandOptionTypeAsString[THCommandOptionType.scrap] =
        localizations.thCommandOptionScrap;
    _commandOptionTypeAsString[THCommandOptionType.scrapScale] =
        localizations.thCommandOptionScrapScale;
    _commandOptionTypeAsString[THCommandOptionType.sketch] =
        localizations.thCommandOptionSketch;
    _commandOptionTypeAsString[THCommandOptionType.smooth] =
        localizations.thCommandOptionSmooth;
    _commandOptionTypeAsString[THCommandOptionType.stationNames] =
        localizations.thCommandOptionStationNames;
    _commandOptionTypeAsString[THCommandOptionType.stations] =
        localizations.thCommandOptionStations;
    _commandOptionTypeAsString[THCommandOptionType.subtype] =
        localizations.thCommandOptionSubtype;
    _commandOptionTypeAsString[THCommandOptionType.text] =
        localizations.thCommandOptionText;
    _commandOptionTypeAsString[THCommandOptionType.title] =
        localizations.thCommandOptionTitle;
    _commandOptionTypeAsString[THCommandOptionType.unrecognizedCommandOption] =
        localizations.thCommandOptionUnrecognizedCommandOption;
    _commandOptionTypeAsString[THCommandOptionType.visibility] =
        localizations.thCommandOptionVisibility;
    _commandOptionTypeAsString[THCommandOptionType.walls] =
        localizations.thCommandOptionWalls;
  }

  static String getCommandOptionType(THCommandOptionType commandOptionType) {
    return _commandOptionTypeAsString.containsKey(commandOptionType)
        ? _commandOptionTypeAsString[commandOptionType]!
        : commandOptionType.name;
  }

  static void _initializeMultipleChoiceAdjustChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceAdjustChoiceAsString[THOptionChoicesAdjustType.horizontal] =
        localizations.thMultipleChoiceAdjustHorizontal;
    _multipleChoiceAdjustChoiceAsString[THOptionChoicesAdjustType.vertical] =
        localizations.thMultipleChoiceAdjustVertical;
  }

  static String getMultipleChoiceAdjustChoice(THOptionChoicesAdjustType type) {
    return _multipleChoiceAdjustChoiceAsString.containsKey(type)
        ? _multipleChoiceAdjustChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceAlignChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.bottom] =
        localizations.thMultipleChoiceAlignBottom;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.bottomLeft] =
        localizations.thMultipleChoiceAlignBottomLeft;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.bottomRight] =
        localizations.thMultipleChoiceAlignBottomRight;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.center] =
        localizations.thMultipleChoiceAlignCenter;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.left] =
        localizations.thMultipleChoiceAlignLeft;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.right] =
        localizations.thMultipleChoiceAlignRight;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.top] =
        localizations.thMultipleChoiceAlignTop;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.topLeft] =
        localizations.thMultipleChoiceAlignTopLeft;
    _multipleChoiceAlignChoiceAsString[THOptionChoicesAlignType.topRight] =
        localizations.thMultipleChoiceAlignTopRight;
  }

  static String getMultipleChoiceAlignChoice(THOptionChoicesAlignType type) {
    return _multipleChoiceAlignChoiceAsString.containsKey(type)
        ? _multipleChoiceAlignChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceOnOffChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceOnOffChoiceAsString[THOptionChoicesOnOffType.off] =
        localizations.thMultipleChoiceOnOffOff;
    _multipleChoiceOnOffChoiceAsString[THOptionChoicesOnOffType.on] =
        localizations.thMultipleChoiceOnOffOn;
  }

  static String getMultipleChoiceOnOffChoice(THOptionChoicesOnOffType type) {
    return _multipleChoiceOnOffChoiceAsString.containsKey(type)
        ? _multipleChoiceOnOffChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceOnOffAutoChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceOnOffAutoChoiceAsString[THOptionChoicesOnOffAutoType.off] =
        localizations.thMultipleChoiceOnOffOff;
    _multipleChoiceOnOffAutoChoiceAsString[THOptionChoicesOnOffAutoType.on] =
        localizations.thMultipleChoiceOnOffOn;
    _multipleChoiceOnOffAutoChoiceAsString[THOptionChoicesOnOffAutoType.auto] =
        localizations.thMultipleChoiceOnOffAutoAuto;
  }

  static String getMultipleChoiceOnOffAutoChoice(
    THOptionChoicesOnOffAutoType type,
  ) {
    return _multipleChoiceOnOffAutoChoiceAsString.containsKey(type)
        ? _multipleChoiceOnOffAutoChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceFlipChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceFlipChoiceAsString[THOptionChoicesFlipType.horizontal] =
        localizations.thMultipleChoiceAdjustHorizontal;
    _multipleChoiceFlipChoiceAsString[THOptionChoicesFlipType.none] =
        localizations.thMultipleChoiceFlipNone;
    _multipleChoiceFlipChoiceAsString[THOptionChoicesFlipType.vertical] =
        localizations.thMultipleChoiceAdjustVertical;
  }

  static String getMultipleChoiceFlipChoice(THOptionChoicesFlipType type) {
    return _multipleChoiceFlipChoiceAsString.containsKey(type)
        ? _multipleChoiceFlipChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceArrowPositionChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
        .begin] = localizations.thMultipleChoiceArrowPositionBegin;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
        .both] = localizations.thMultipleChoiceArrowPositionBoth;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
        .end] = localizations.thMultipleChoiceArrowPositionEnd;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
        .none] = localizations.thMultipleChoiceFlipNone;
  }

  static String getMultipleChoiceArrowPositionChoice(
    THOptionChoicesArrowPositionType type,
  ) {
    return _multipleChoiceArrowPositionChoiceAsString.containsKey(type)
        ? _multipleChoiceArrowPositionChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceLineGradientChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceLineGradientChoiceAsString[THOptionChoicesLineGradientType
        .center] = localizations.thMultipleChoiceAlignCenter;
    _multipleChoiceLineGradientChoiceAsString[THOptionChoicesLineGradientType
        .none] = localizations.thMultipleChoiceFlipNone;
  }

  static String getMultipleChoiceLineGradientChoice(
    THOptionChoicesLineGradientType type,
  ) {
    return _multipleChoiceLineGradientChoiceAsString.containsKey(type)
        ? _multipleChoiceLineGradientChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceLinePointDirectionChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceLinePointDirectionChoiceAsString[
            THOptionChoicesLinePointDirectionType.begin] =
        localizations.thMultipleChoiceArrowPositionBegin;
    _multipleChoiceLinePointDirectionChoiceAsString[
            THOptionChoicesLinePointDirectionType.both] =
        localizations.thMultipleChoiceArrowPositionBoth;
    _multipleChoiceLinePointDirectionChoiceAsString[
            THOptionChoicesLinePointDirectionType.end] =
        localizations.thMultipleChoiceArrowPositionEnd;
    _multipleChoiceLinePointDirectionChoiceAsString[
            THOptionChoicesLinePointDirectionType.none] =
        localizations.thMultipleChoiceFlipNone;
  }

  static String getMultipleChoiceLinePointDirectionChoice(
    THOptionChoicesLinePointDirectionType type,
  ) {
    return _multipleChoiceLinePointDirectionChoiceAsString.containsKey(type)
        ? _multipleChoiceLinePointDirectionChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceLinePointGradientChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceLinePointGradientChoiceAsString[
            THOptionChoicesLinePointGradientType.center] =
        localizations.thMultipleChoiceAlignCenter;
    _multipleChoiceLinePointGradientChoiceAsString[
            THOptionChoicesLinePointGradientType.none] =
        localizations.thMultipleChoiceFlipNone;
    _multipleChoiceLinePointGradientChoiceAsString[
            THOptionChoicesLinePointGradientType.point] =
        localizations.thMultipleChoiceLinePointGradientPoint;
  }

  static String getMultipleChoiceLinePointGradientChoice(
      THOptionChoicesLinePointGradientType type) {
    return _multipleChoiceLinePointGradientChoiceAsString.containsKey(type)
        ? _multipleChoiceLinePointGradientChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoiceOutlineChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoiceOutlineChoiceAsString[THOptionChoicesOutlineType.inChoice] =
        localizations.thMultipleChoiceOutlineIn;
    _multipleChoiceOutlineChoiceAsString[THOptionChoicesOutlineType.none] =
        localizations.thMultipleChoiceFlipNone;
    _multipleChoiceOutlineChoiceAsString[THOptionChoicesOutlineType.out] =
        localizations.thMultipleChoiceOutlineOut;
  }

  static String getMultipleChoiceOutlineChoice(
      THOptionChoicesOutlineType type) {
    return _multipleChoiceOutlineChoiceAsString.containsKey(type)
        ? _multipleChoiceOutlineChoiceAsString[type]!
        : type.name;
  }

  static void _initializeMultipleChoicePlaceChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _multipleChoicePlaceChoiceAsString[THOptionChoicesPlaceType.bottom] =
        localizations.thMultipleChoiceAlignBottom;
    _multipleChoicePlaceChoiceAsString[THOptionChoicesPlaceType.defaultChoice] =
        localizations.thMultipleChoicePlaceDefault;
    _multipleChoicePlaceChoiceAsString[THOptionChoicesPlaceType.top] =
        localizations.thMultipleChoiceAlignTop;
  }

  static String getMultipleChoicePlaceChoice(THOptionChoicesPlaceType type) {
    return _multipleChoicePlaceChoiceAsString.containsKey(type)
        ? _multipleChoicePlaceChoiceAsString[type]!
        : type.name;
  }

  static removeDiacritics(String text) {
    const Map<String, String> diacritics = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ĩ': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ũ': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    for (final entry in diacritics.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    return text;
  }

  static int compareStringsNoDiacritics(final String a, final String b) {
    if (a == b) {
      return 0;
    }

    final String aSpaceNormalized = a.replaceAll(RegExp(r'\s+'), ' ').trim();
    final String bSpaceNormalized = b.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (aSpaceNormalized == bSpaceNormalized) {
      return a.compareTo(b);
    }

    final String aLower = a.toLowerCase();
    final String bLower = b.toLowerCase();

    if (aLower == bLower) {
      return aSpaceNormalized.compareTo(bSpaceNormalized);
    }

    final String aNoDiacritic = removeDiacritics(aLower);
    final String bNoDiacritic = removeDiacritics(bLower);

    if (aNoDiacritic == bNoDiacritic) {
      return aLower.compareTo(bLower);
    }

    return aNoDiacritic.compareTo(bNoDiacritic);
  }

  static int compareStringsUsingLocale(
    final String a,
    final String b,
  ) {
    switch (_locale.toLanguageTag()) {
      default:
        return compareStringsNoDiacritics(a, b);
    }
  }
}
