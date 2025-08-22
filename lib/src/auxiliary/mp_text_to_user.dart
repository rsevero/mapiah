import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_scale_multiple_choice_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPTextToUser {
  static final Map<MPCommandDescriptionType, String>
  _commandDescriptionTypeAsString = {};
  static final Map<THLengthUnitType, String> _lengthUnitTypeAsString = {};
  static final Map<THLengthUnitType, String>
  _lengthUnitTypeAbbreviationAsString = {};
  static final Map<THElementType, String> _elementTypeAsString = {};
  static final Map<THPointType, String> _pointTypeAsString = {};
  static final Map<THLineType, String> _lineTypeAsString = {};
  static final Map<THAreaType, String> _areaTypeAsString = {};
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
  static final Map<THPLScaleCommandOptionType, String>
  _plScaleCommandOptionTypeAsString = {};
  static final Map<THPassageHeightModes, String>
  _passageHeightModesChoiceAsString = {};
  static final Map<THPointHeightValueMode, String>
  _pointHeightValueModeAsString = {};
  static final Map<THProjectionModeType, String> _projectionModeTypeAsString =
      {};
  static final Map<THAngleUnitType, String> _angleUnitTypeAsString = {};
  static final Map<String, String> _namedScaleOptionsAsString = {};
  static final Map<String, String> _subtypeAsString = {};
  static Locale _locale = mpLocator.mpSettingsController.locale;

  static void initialize() {
    _initializeCommandDescriptionTypeAsString();
    _initializeLengthUnitTypeAsString();
    _initializeLengthUnitTypeAbbreviationAsString();
    _initializeElementTypeAsString();
    _initializePointTypeAsString();
    _initializeLineTypeAsString();
    _initializeAreaTypeAsString();
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
    _initializePLScaleCommandOptionTypeAsString();
    _initializePassageHeightModesChoiceAsString();
    _initializePointHeightValueModeAsString();
    _initializeProjectionModeTypeAsString();
    _initializeAngleUnitTypeAsString();
    _initializeNamedScaleOptionsAsString();
    _initializeSubtypeAsString();
  }

  static void _initializeSubtypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _subtypeAsString['point|air-draught|winter'] =
        localizations.mpSubtypePointAirDraughtWinter;
    _subtypeAsString['point|air-draught|summer'] =
        localizations.mpSubtypePointAirDraughtSummer;
    _subtypeAsString['point|air-draught|undefined'] =
        localizations.mpSubtypePointAirDraughtUndefined;
    _subtypeAsString['point|station|temporary'] =
        localizations.mpSubtypePointStationTemporary;
    _subtypeAsString['point|station|painted'] =
        localizations.mpSubtypePointStationPainted;
    _subtypeAsString['point|station|natural'] =
        localizations.mpSubtypePointStationNatural;
    _subtypeAsString['point|station|fixed'] =
        localizations.mpSubtypePointStationFixed;
    _subtypeAsString['point|water-flow|permanent'] =
        localizations.mpSubtypePointWaterFlowPermanent;
    _subtypeAsString['point|water-flow|intermittent'] =
        localizations.mpSubtypePointWaterFlowIntermittent;
    _subtypeAsString['point|water-flow|paleo'] =
        localizations.mpSubtypePointWaterFlowPaleo;
    _subtypeAsString['line|border|invisible'] =
        localizations.mpSubtypeLineBorderInvisible;
    _subtypeAsString['line|border|presumed'] =
        localizations.mpSubtypeLineBorderPresumed;
    _subtypeAsString['line|border|temporary'] =
        localizations.mpSubtypeLineBorderTemporary;
    _subtypeAsString['line|border|visible'] =
        localizations.mpSubtypeLineBorderVisible;
    _subtypeAsString['line|survey|cave'] =
        localizations.mpSubtypeLineSurveyCave;
    _subtypeAsString['line|survey|surface'] =
        localizations.mpSubtypeLineSurveySurface;
    _subtypeAsString['line|wall|bedrock'] =
        localizations.mpSubtypeLineWallBedrock;
    _subtypeAsString['line|wall|blocks'] =
        localizations.mpSubtypeLineWallBlocks;
    _subtypeAsString['line|wall|clay'] = localizations.mpSubtypeLineWallClay;
    _subtypeAsString['line|wall|debris'] =
        localizations.mpSubtypeLineWallDebris;
    _subtypeAsString['line|wall|flowstone'] =
        localizations.mpSubtypeLineWallFlowstone;
    _subtypeAsString['line|wall|ice'] = localizations.mpSubtypeLineWallIce;
    _subtypeAsString['line|wall|invisible'] =
        localizations.mpSubtypeLineWallInvisible;
    _subtypeAsString['line|wall|moonmilk'] =
        localizations.mpSubtypeLineWallMoonmilk;
    _subtypeAsString['line|wall|overlying'] =
        localizations.mpSubtypeLineWallOverlying;
    _subtypeAsString['line|wall|pebbles'] =
        localizations.mpSubtypeLineWallPebbles;
    _subtypeAsString['line|wall|pit'] = localizations.mpSubtypeLineWallPit;
    _subtypeAsString['line|wall|presumed'] =
        localizations.mpSubtypeLineWallPresumed;
    _subtypeAsString['line|wall|sand'] = localizations.mpSubtypeLineWallSand;
    _subtypeAsString['line|wall|underlying'] =
        localizations.mpSubtypeLineWallUnderlying;
    _subtypeAsString['line|wall|unsurveyed'] =
        localizations.mpSubtypeLineWallUnsurveyed;
    _subtypeAsString['line|water-flow|permanent'] =
        localizations.mpSubtypeLineWaterFlowPermanent;
    _subtypeAsString['line|water-flow|conjectural'] =
        localizations.mpSubtypeLineWaterFlowConjectural;
    _subtypeAsString['line|water-flow|intermittent'] =
        localizations.mpSubtypeLineWaterFlowIntermittent;
  }

  static String getSubtypeAsString(String subtype) {
    return _subtypeAsString.containsKey(subtype)
        ? _subtypeAsString[subtype]!
        : subtype;
  }

  static void _initializeProjectionModeTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _projectionModeTypeAsString[THProjectionModeType.elevation] =
        localizations.mpProjectionModeElevation;
    _projectionModeTypeAsString[THProjectionModeType.extended] =
        localizations.mpProjectionModeExtended;
    _projectionModeTypeAsString[THProjectionModeType.none] =
        localizations.mpProjectionModeNone;
    _projectionModeTypeAsString[THProjectionModeType.plan] =
        localizations.mpProjectionModePlan;
  }

  static String getProjectionModeType(THProjectionModeType projectionModeType) {
    return _projectionModeTypeAsString.containsKey(projectionModeType)
        ? _projectionModeTypeAsString[projectionModeType]!
        : projectionModeType.name;
  }

  static void _initializeAngleUnitTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _angleUnitTypeAsString[THAngleUnitType.degree] =
        localizations.mpAngleUnitDegree;
    _angleUnitTypeAsString[THAngleUnitType.grad] =
        localizations.mpAngleUnitGrad;
    _angleUnitTypeAsString[THAngleUnitType.mil] = localizations.mpAngleUnitMil;
    _angleUnitTypeAsString[THAngleUnitType.minute] =
        localizations.mpAngleUnitMinute;
  }

  static String getAngleUnitType(THAngleUnitType angleUnitType) {
    return _angleUnitTypeAsString.containsKey(angleUnitType)
        ? _angleUnitTypeAsString[angleUnitType]!
        : angleUnitType.name;
  }

  static void _initializePointHeightValueModeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _pointHeightValueModeAsString[THPointHeightValueMode.chimney] =
        localizations.mpPointHeightChimney;
    _pointHeightValueModeAsString[THPointHeightValueMode.pit] =
        localizations.mpPointHeightPit;
    _pointHeightValueModeAsString[THPointHeightValueMode.step] =
        localizations.mpPointHeightStep;
  }

  static String getPointHeightValueMode(
    THPointHeightValueMode pointHeightValueMode,
  ) {
    return _pointHeightValueModeAsString.containsKey(pointHeightValueMode)
        ? _pointHeightValueModeAsString[pointHeightValueMode]!
        : pointHeightValueMode.name;
  }

  static void _initializePassageHeightModesChoiceAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _passageHeightModesChoiceAsString[THPassageHeightModes.depth] =
        localizations.mpPassageHeightDepth;
    _passageHeightModesChoiceAsString[THPassageHeightModes
            .distanceBetweenFloorAndCeiling] =
        localizations.mpPassageHeightDistanceBetweenFloorAndCeiling;
    _passageHeightModesChoiceAsString[THPassageHeightModes
            .distanceToCeilingAndDistanceToFloor] =
        localizations.mpPassageHeightDistanceToCeilingAndDistanceToFloor;
    _passageHeightModesChoiceAsString[THPassageHeightModes.height] =
        localizations.mpPassageHeightHeight;
  }

  static String getPassageHeightModesChoice(
    THPassageHeightModes passageHeightModes,
  ) {
    return _passageHeightModesChoiceAsString.containsKey(passageHeightModes)
        ? _passageHeightModesChoiceAsString[passageHeightModes]!
        : passageHeightModes.name;
  }

  static void _initializePLScaleCommandOptionTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _plScaleCommandOptionTypeAsString[THPLScaleCommandOptionType.named] =
        localizations.mpPLScaleCommandOptionNamed;
    _plScaleCommandOptionTypeAsString[THPLScaleCommandOptionType.numeric] =
        localizations.mpPLScaleCommandOptionNumeric;
  }

  static String getPLScaleCommandOptionType(
    THPLScaleCommandOptionType plScaleCommandOptionType,
  ) {
    return _plScaleCommandOptionTypeAsString.containsKey(
          plScaleCommandOptionType,
        )
        ? _plScaleCommandOptionTypeAsString[plScaleCommandOptionType]!
        : plScaleCommandOptionType.name;
  }

  static void _initializeNamedScaleOptionsAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _namedScaleOptionsAsString['xs'] = localizations.mpNamedScaleTiny;
    _namedScaleOptionsAsString['s'] = localizations.mpNamedScaleSmall;
    _namedScaleOptionsAsString['m'] = localizations.mpNamedScaleNormal;
    _namedScaleOptionsAsString['l'] = localizations.mpNamedScaleLarge;
    _namedScaleOptionsAsString['xl'] = localizations.mpNamedScaleHuge;
  }

  static String getNamedScaleOption(String namedScaleOption) {
    return _namedScaleOptionsAsString.containsKey(namedScaleOption)
        ? _namedScaleOptionsAsString[namedScaleOption]!
        : namedScaleOption;
  }

  static void _initializeCommandDescriptionTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _locale = mpLocator.mpSettingsController.locale;

    _commandDescriptionTypeAsString[MPCommandDescriptionType.addArea] =
        localizations.mpCommandDescriptionAddArea;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .addAreaBorderTHID] =
        localizations.mpCommandDescriptionAddAreaBorderTHID;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.addElements] =
        localizations.mpCommandDescriptionAddElements;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.addLine] =
        localizations.mpCommandDescriptionAddLine;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.addLineSegment] =
        localizations.mpCommandDescriptionAddLineSegment;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.addPoint] =
        localizations.mpCommandDescriptionAddPoint;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .addXTherionImageInsertConfig] =
        localizations.mpCommandDescriptionAddXTherionImageInsertConfig;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editAreasType] =
        localizations.mpCommandDescriptionEditAreasType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editAreaType] =
        localizations.mpCommandDescriptionEditAreaType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editBezierCurve] =
        localizations.mpCommandDescriptionEditBezierCurve;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editLine] =
        localizations.mpCommandDescriptionEditLine;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editLineSegment] =
        localizations.mpCommandDescriptionEditLineSegment;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .editLineSegmentsType] =
        localizations.mpCommandDescriptionEditLineSegmentsType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .editLineSegmentType] =
        localizations.mpCommandDescriptionEditLineSegmentType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editLinesType] =
        localizations.mpCommandDescriptionEditLinesType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editLineType] =
        localizations.mpCommandDescriptionEditLineType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editPointsType] =
        localizations.mpCommandDescriptionEditPointsType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.editPointType] =
        localizations.mpCommandDescriptionEditPointType;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.moveArea] =
        localizations.mpCommandDescriptionMoveArea;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .moveBezierLineSegment] =
        localizations.mpCommandDescriptionMoveBezierLineSegment;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.moveElements] =
        localizations.mpCommandDescriptionMoveElements;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.moveLine] =
        localizations.mpCommandDescriptionMoveLine;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.moveLines] =
        localizations.mpCommandDescriptionMoveLines;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.moveLineSegments] =
        localizations.mpCommandDescriptionMoveLineSegments;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.movePoint] =
        localizations.mpCommandDescriptionMovePoint;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .moveStraightLineSegment] =
        localizations.mpCommandDescriptionMoveStraightLineSegment;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.multipleElements] =
        localizations.mpCommandDescriptionMultipleElements;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.removeArea] =
        localizations.mpCommandDescriptionRemoveArea;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeAreaBorderTHID] =
        localizations.mpCommandDescriptionRemoveAreaBorderTHID;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.removeElements] =
        localizations.mpCommandDescriptionRemoveElements;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.removeLine] =
        localizations.mpCommandDescriptionRemoveLine;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeLineSegment] =
        localizations.mpCommandDescriptionRemoveLineSegment;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeLineSegments] =
        localizations.mpCommandDescriptionRemoveLineSegments;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeOptionFromElement] =
        localizations.mpCommandDescriptionRemoveOptionFromElement;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeOptionFromElements] =
        localizations.mpCommandDescriptionRemoveOptionFromElements;
    _commandDescriptionTypeAsString[MPCommandDescriptionType.removePoint] =
        localizations.mpCommandDescriptionRemovePoint;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .removeXTherionImageInsertConfig] =
        localizations.mpCommandDescriptionRemoveXTherionImageInsertConfig;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .setOptionToElement] =
        localizations.mpCommandDescriptionSetOptionToElement;
    _commandDescriptionTypeAsString[MPCommandDescriptionType
            .setOptionToElements] =
        localizations.mpCommandDescriptionSetOptionToElements;
  }

  static String getCommandDescription(
    MPCommandDescriptionType commandDescriptionType,
  ) {
    return _commandDescriptionTypeAsString.containsKey(commandDescriptionType)
        ? _commandDescriptionTypeAsString[commandDescriptionType]!
        : commandDescriptionType.name;
  }

  static void _initializeLengthUnitTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _lengthUnitTypeAsString[THLengthUnitType.centimeter] =
        localizations.mpLengthUnitCentimeter;
    _lengthUnitTypeAsString[THLengthUnitType.feet] =
        localizations.mpLengthUnitFoot;
    _lengthUnitTypeAsString[THLengthUnitType.inch] =
        localizations.mpLengthUnitInch;
    _lengthUnitTypeAsString[THLengthUnitType.meter] =
        localizations.mpLengthUnitMeter;
    _lengthUnitTypeAsString[THLengthUnitType.yard] =
        localizations.mpLengthUnitYard;
  }

  static String getLengthUnitType(THLengthUnitType lengthUnitType) {
    return _lengthUnitTypeAsString.containsKey(lengthUnitType)
        ? _lengthUnitTypeAsString[lengthUnitType]!
        : lengthUnitType.name;
  }

  static void _initializeLengthUnitTypeAbbreviationAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _lengthUnitTypeAbbreviationAsString[THLengthUnitType.centimeter] =
        localizations.mpLengthUnitCentimeterAbbreviation;
    _lengthUnitTypeAbbreviationAsString[THLengthUnitType.feet] =
        localizations.mpLengthUnitFootAbbreviation;
    _lengthUnitTypeAbbreviationAsString[THLengthUnitType.inch] =
        localizations.mpLengthUnitInchAbbreviation;
    _lengthUnitTypeAbbreviationAsString[THLengthUnitType.meter] =
        localizations.mpLengthUnitMeterAbbreviation;
    _lengthUnitTypeAbbreviationAsString[THLengthUnitType.yard] =
        localizations.mpLengthUnitYardAbbreviation;
  }

  static String getLengthUnitTypeAbbreviation(THLengthUnitType lengthUnitType) {
    return _lengthUnitTypeAbbreviationAsString.containsKey(lengthUnitType)
        ? _lengthUnitTypeAbbreviationAsString[lengthUnitType]!
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
    return (_pointTypeAsString.containsKey(pointType) &&
            pointType != THPointType.userDefined)
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
    return (_lineTypeAsString.containsKey(lineType) &&
            lineType != THLineType.userDefined)
        ? _lineTypeAsString[lineType]!
        : lineType.name;
  }

  static void _initializeAreaTypeAsString() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _areaTypeAsString[THAreaType.bedrock] = localizations.thAreaBedrock;
    _areaTypeAsString[THAreaType.blocks] = localizations.thAreaBlocks;
    _areaTypeAsString[THAreaType.clay] = localizations.thAreaClay;
    _areaTypeAsString[THAreaType.debris] = localizations.thAreaDebris;
    _areaTypeAsString[THAreaType.flowstone] = localizations.thAreaFlowstone;
    _areaTypeAsString[THAreaType.ice] = localizations.thAreaIce;
    _areaTypeAsString[THAreaType.moonmilk] = localizations.thAreaMoonmilk;
    _areaTypeAsString[THAreaType.mudcrack] = localizations.thAreaMudcrack;
    _areaTypeAsString[THAreaType.pebbles] = localizations.thAreaPebbles;
    _areaTypeAsString[THAreaType.pillar] = localizations.thAreaPillar;
    _areaTypeAsString[THAreaType.pillars] = localizations.thAreaPillars;
    _areaTypeAsString[THAreaType.pillarsWithCurtains] =
        localizations.thAreaPillarsWithCurtains;
    _areaTypeAsString[THAreaType.pillarWithCurtains] =
        localizations.thAreaPillarWithCurtains;
    _areaTypeAsString[THAreaType.sand] = localizations.thAreaSand;
    _areaTypeAsString[THAreaType.snow] = localizations.thAreaSnow;
    _areaTypeAsString[THAreaType.stalactite] = localizations.thAreaStalactite;
    _areaTypeAsString[THAreaType.stalactiteStalagmite] =
        localizations.thAreaStalactiteStalagmite;
    _areaTypeAsString[THAreaType.stalagmite] = localizations.thAreaStalagmite;
    _areaTypeAsString[THAreaType.sump] = localizations.thAreaSump;
    _areaTypeAsString[THAreaType.u] = localizations.thAreaU;
    _areaTypeAsString[THAreaType.water] = localizations.thAreaWater;
  }

  static String getAreaType(THAreaType areaType) {
    return (_areaTypeAsString.containsKey(areaType) &&
            (areaType != THAreaType.userDefined))
        ? _areaTypeAsString[areaType]!
        : areaType.name;
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
    _commandOptionTypeAsString[THCommandOptionType.attr] =
        localizations.thCommandOptionAttr;
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
        localizations.thCommandOptionCS;
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
    _commandOptionTypeAsString[THCommandOptionType.plScale] =
        localizations.thCommandOptionPLScale;
    _commandOptionTypeAsString[THCommandOptionType.pointHeightValue] =
        localizations.thCommandOptionPointHeightValue;
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
        localizations.thCommandOptionUnrecognized;
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
            .begin] =
        localizations.thMultipleChoiceArrowPositionBegin;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
            .both] =
        localizations.thMultipleChoiceArrowPositionBoth;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
            .end] =
        localizations.thMultipleChoiceArrowPositionEnd;
    _multipleChoiceArrowPositionChoiceAsString[THOptionChoicesArrowPositionType
            .none] =
        localizations.thMultipleChoiceFlipNone;
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
            .center] =
        localizations.thMultipleChoiceAlignCenter;
    _multipleChoiceLineGradientChoiceAsString[THOptionChoicesLineGradientType
            .none] =
        localizations.thMultipleChoiceFlipNone;
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

    _multipleChoiceLinePointDirectionChoiceAsString[THOptionChoicesLinePointDirectionType
            .begin] =
        localizations.thMultipleChoiceArrowPositionBegin;
    _multipleChoiceLinePointDirectionChoiceAsString[THOptionChoicesLinePointDirectionType
            .both] =
        localizations.thMultipleChoiceArrowPositionBoth;
    _multipleChoiceLinePointDirectionChoiceAsString[THOptionChoicesLinePointDirectionType
            .end] =
        localizations.thMultipleChoiceArrowPositionEnd;
    _multipleChoiceLinePointDirectionChoiceAsString[THOptionChoicesLinePointDirectionType
            .none] =
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

    _multipleChoiceLinePointGradientChoiceAsString[THOptionChoicesLinePointGradientType
            .center] =
        localizations.thMultipleChoiceAlignCenter;
    _multipleChoiceLinePointGradientChoiceAsString[THOptionChoicesLinePointGradientType
            .none] =
        localizations.thMultipleChoiceFlipNone;
    _multipleChoiceLinePointGradientChoiceAsString[THOptionChoicesLinePointGradientType
            .point] =
        localizations.thMultipleChoiceLinePointGradientPoint;
  }

  static String getMultipleChoiceLinePointGradientChoice(
    THOptionChoicesLinePointGradientType type,
  ) {
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
    THOptionChoicesOutlineType type,
  ) {
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

  static String removeDiacritics(String text) {
    const Map<String, String> diacritics = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'å': 'a',
      'ą': 'a',
      'ā': 'a',
      'ă': 'a',
      'ç': 'c',
      'ć': 'c',
      'č': 'c',
      'đ': 'd',
      'é': 'e',
      'è': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ë': 'e',
      'ę': 'e',
      'ē': 'e',
      'ĕ': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ĩ': 'i',
      'ï': 'i',
      'ī': 'i',
      'ł': 'l',
      'ń': 'n',
      'ñ': 'n',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ō': 'o',
      'ő': 'o',
      'ø': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ũ': 'u',
      'ü': 'u',
      'ū': 'u',
      'ű': 'u',
      'ś': 's',
      'š': 's',
      'ź': 'z',
      'ż': 'z',
      'ž': 'z',
    };

    for (int i = 0; i < text.length; i++) {
      final String char = text[i];

      if (diacritics.containsKey(char)) {
        final String diacriticSubstitution = diacritics[char]!;

        text = text.replaceAll(char, diacriticSubstitution);
      }
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

  static int compareStringsUsingLocale(final String a, final String b) {
    switch (_locale.toLanguageTag()) {
      default:
        return compareStringsNoDiacritics(a, b);
    }
  }

  static Map<String, String> getProjectionModeTypeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THProjectionModeType.values) {
      choices[choiceType.name] = getProjectionModeType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getAngleUnitTypeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THAngleUnitType.values) {
      choices[choiceType.name] = getAngleUnitType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getPointHeightValueModeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THPointHeightValueMode.values) {
      choices[choiceType.name] = getPointHeightValueMode(choiceType);
    }

    return choices;
  }

  static Map<String, String> getPassageHeightModesChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THPassageHeightModes.values) {
      choices[choiceType.name] = getPassageHeightModesChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getPLScaleCommandOptionTypeOptions() {
    final Map<String, String> choices = {};

    for (final choiceType in THPLScaleCommandOptionType.values) {
      choices[choiceType.name] = getPLScaleCommandOptionType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getNamedScaleOptions() {
    final Map<String, String> choices = {};

    for (final String choiceType in THScaleMultipleChoicePart.choices) {
      choices[choiceType] = getNamedScaleOption(choiceType);
    }

    return choices;
  }

  static Map<String, String> getAreaTypeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THAreaType.values) {
      choices[choiceType.name] = getAreaType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getLineTypeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THLineType.values) {
      choices[choiceType.name] = getLineType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getLineSegmentTypeChoices() {
    final Map<String, String> choices = {
      THElementType.bezierCurveLineSegment.name:
          mpLocator.appLocalizations.thElementBezierCurveLineSegment,
      THElementType.straightLineSegment.name:
          mpLocator.appLocalizations.thElementStraightLineSegment,
    };

    return choices;
  }

  static Map<String, String> getPointTypeChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THPointType.values) {
      choices[choiceType.name] = getPointType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getLengthUnitsChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THLengthUnitType.values) {
      choices[choiceType.name] = getLengthUnitType(choiceType);
    }

    return choices;
  }

  static Map<String, String> getAdjustChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesAdjustType.values) {
      choices[choiceType.name] = getMultipleChoiceAdjustChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getAlignChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesAlignType.values) {
      choices[choiceType.name] = getMultipleChoiceAlignChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getOnOffChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesOnOffType.values) {
      choices[choiceType.name] = getMultipleChoiceOnOffChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getOnOffAutoChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesOnOffAutoType.values) {
      choices[choiceType.name] = getMultipleChoiceOnOffAutoChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getFlipChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesFlipType.values) {
      choices[choiceType.name] = getMultipleChoiceFlipChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getArrowPositionChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesArrowPositionType.values) {
      choices[choiceType.name] = getMultipleChoiceArrowPositionChoice(
        choiceType,
      );
    }

    return choices;
  }

  static Map<String, String> getLineGradientChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesLineGradientType.values) {
      choices[choiceType.name] = getMultipleChoiceLineGradientChoice(
        choiceType,
      );
    }

    return choices;
  }

  static Map<String, String> getLinePointDirectionChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesLinePointDirectionType.values) {
      choices[choiceType.name] = getMultipleChoiceLinePointDirectionChoice(
        choiceType,
      );
    }

    return choices;
  }

  static Map<String, String> getLinePointGradientChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesLinePointGradientType.values) {
      choices[choiceType.name] = getMultipleChoiceLinePointGradientChoice(
        choiceType,
      );
    }

    return choices;
  }

  static Map<String, String> getOutlineChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesOutlineType.values) {
      choices[choiceType.name] = getMultipleChoiceOutlineChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getPlaceChoices() {
    final Map<String, String> choices = {};

    for (final choiceType in THOptionChoicesPlaceType.values) {
      choices[choiceType.name] = getMultipleChoicePlaceChoice(choiceType);
    }

    return choices;
  }

  static Map<String, String> getOptionChoicesWithUnset(
    Map<String, String> choices,
  ) {
    final Map<String, String> choicesWithUnset = {
      mpUnsetOptionID: mpLocator.appLocalizations.mpChoiceUnset,
    };
    final Map<String, String> orderedChoices = getOrderedChoices(choices);

    choicesWithUnset.addAll(orderedChoices);

    return choicesWithUnset;
  }

  static Map<String, String> getOrderedChoices(Map<String, String> choices) {
    final List<MapEntry<String, String>> orderedChoices =
        choices.entries.toList()..sort(
          (a, b) => MPTextToUser.compareStringsUsingLocale(a.value, b.value),
        );

    return Map.fromEntries(orderedChoices);
  }
}
