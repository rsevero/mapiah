import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

const String thDebugPath =
    '/home/rodrigo/devel/mapiah/test/auxiliary/unused/th2parser';
const bool mpDebugMousePosition = false;

const String mpHelpPagePath = 'assets/help';

const String thCommentChar = '#';
const String thDecimalSeparator = '.';
const String thBackslash = '\\';
const String thUnixLineBreak = '\n';
const String thWindowsLineBreak = '\r\n';
const String thDoubleQuote = '"';
const String thDoubleQuotePair = r'""';

/// This char is from the private-use chars.
// See [https://www.unicode.org/faq/private_use.html]
const String thDoubleQuotePairEncoded = '\uE001';
const String thWhitespaceChars = ' \t';

const String thIndentation = '  ';

const int thMaxEncodingLength = 20;
const int thMaxFileLineLength = 80;
const int mpMaxDecimalPositions = 6;
const int thDefaultDecimalPositions = 4;
const int mpDefaultDecimalPositionsAzimuth = 1;
const double mpDefaultSnapOnScreenDistance = 9;
const double mpSnapGridCellSizeFactor = 1.1;

const String mpDefaultEncoding = 'UTF-8';

const String thNullValueAsString = '!!! property has null value !!!';

const double mpCanvasVisibleMargin = 0.1;
const double mpCanvasOutOfSightMargin = 2.0;
const double mpScrapBackgroundPadding = 0.02;

const double thRegularZoomFactor = math.sqrt2;
const double thRoundToFactor = thRegularZoomFactor - 1;
const double thFineZoomFactor = thRoundToFactor / 2 + 1;
const double thCanvasMovementFactor = 0.1;
const double thCanvasRoundFactor = 25.0;

const double mpDoubleNextEpsilon = 2.220446049250313e-16;
const double mpDoubleUpEpsilonFactor = 1.0 + mpDoubleNextEpsilon;
const double mpDoubleDownEpsilonFactor = 1.0 - mpDoubleNextEpsilon;
const double mpDoubleComparisonEpsilon = 1e-9;

/// Smallest *normalized* positive double (DBL_MIN). Note this is different
/// from `double.minPositive` (the smallest positive subnormal value).
const double mpDoubleMinNormalized = 2.2250738585072014e-308;

const double mpCompleteBezierArcT = 1.0;
const double mpHalfBezierArcPart = 0.5;
const int mpArcBezierLengthSteps = 5;
const int mpSplitBezierCurveAtHalfLengthIterations = 5;
const double mpConvertBezierToStraightFactor = 10.0;

/// Using the lower limits [-2^53 + 1, 2^53 − 1] that are also supported by the
/// web version. The higher limits
/// [-0x7fffffffffffffff - 1,  0x7fffffffffffffff] are only supported by the
/// desktop versions of Flutter apps.
const int mpMinimumInt = -2 ^ 53 + 1;
const int mpMaximumInt = 2 ^ 53 - 1;

const double mpLogN10 = math.ln10;
const double mp45DegreesInRad = math.pi / 4;
const double mp60DegreeInRad = math.pi / 3;
const double mp90DegreeInRad = math.pi / 2;
const double mp180DegreeInRad = math.pi;
const double mp1DegreeInRad = math.pi / 180;
const double mp1Radian = 180 / math.pi;
const double mp1OverPi = 1 / math.pi;

const double mpLineSimplifyEpsilonOnScreen = 1.0;

const double thMinimumSizeForDrawing = 10.0;

const int thFirstMPIDForTHFiles = -1;
const int thFirstMPIDForElements = 1;

const double thDesiredSegmentLengthOnScreen = 15.0;

const double thDesiredGraphicalScaleScreenPointLength = 200.0;
const double thGraphicalScalePadding = 20.0;
const double thGraphicalScaleUptickLength = 8.0;
const double thGraphicalScaleFontSize = 12.0;

const THLengthUnitType thDefaultLengthUnit = THLengthUnitType.meter;
final String thDefaultLengthUnitAsString = thDefaultLengthUnit.name;
const THAngleUnitType thDefaultAngleUnit = THAngleUnitType.degree;
final String thDefaultAngleUnitAsString = thDefaultAngleUnit.name;
const double mpAzimuthConstraintAngle = 15.0;

// keyword . a sequence of A-Z, a-z, 0-9 and _-/ characters (not starting with ‘-’).
final RegExp thKeywordRegex = RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_-]*$');

// ext keyword . keyword that can also contain +*.,’ characters, but not on the first
// position.
final RegExp thExtKeywordRegex = RegExp(
  r'''^[a-zA-Z0-9_][a-zA-Z0-9_+*.,'-]*$''',
);

// date . a date (or a time interval) specification in the format
// YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
// or ‘-’ to leave a date unspecified.
final RegExp thDatetimeRegex = RegExp(
  r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$',
);

const String thConfigDirectory = 'Config';
const String thMainDirectory = 'Mapiah';
const String thProjectsDirectory = 'Projects';

const String thMainConfigFilename = 'mapiah.toml';
const String thDefaultLocaleID = 'sys';
const String thEnglishLocaleID = 'en';

const double mpFloatingActionIconSize = 32;
const double mpFloatingActionZoomIconSize = 24;
const double mpFloatingStateActionZoomIconSize = 24;
const double mpButtonSpace = 8;
const double mpDefaultButtonRadius = 8;
const double mpButtonMargin = mpButtonSpace * 4;
const double mpOverlayWindowPadding = 16;
const double mpOverlayWindowCornerRadius = 18;
const double mpOverlayWindowBlockPadding = 12;
const double mpOverlayWindowBlockCornerRadius = 14;
const double mpOverlayWindowBlockElevation = 2;
const double mpOverlayWindowOutsidePadding = 32;
const double mpSwitchScaleFactor = 0.7;
const int mpTileWidgetOnHoverAlpha = 50;
const double mpTileWidgetEdgeInset = 12;
const double mpTileWidgetEdgeInsetDense = 8;
const EdgeInsets mpOverlayWindowBlockEdgeInsets = EdgeInsets.only(
  top: mpOverlayWindowBlockPadding,
  bottom: mpOverlayWindowBlockPadding / 2,
  left: mpOverlayWindowBlockPadding,
  right: mpOverlayWindowBlockPadding,
);
const double mpOverlayWindowMinWidth = 180;
const int mpDefaultMinDigitsForTextFields = 6;
const int mpDefaultMinCharsForTextFields = 10;
const int mpDefaultMaxCharsForTextFields = 20;

const int mpETRSMin = 28;
const int mpETRSMax = 37;
const int mpEPSGESRIMin = 1;
const int mpEPSGESRIMax = 99999;
const int mpUTMMin = 1;
const int mpUTMMax = 60;

const double thClickDragThreshold = 2.0;
const double thClickDragThresholdSquared =
    thClickDragThreshold * thClickDragThreshold;
const double thDefaultSelectionTolerance = 7.0;
const double thDefaultPointRadius = 7.0;
const double thDefaultLineThickness = 2.0;
const double thControlLineThicknessFactor = 0.5;
const double thControlPointRadiusFactor = 1.5;
const double thSelectedEndControlPointFactor = 1.25;
const double xviPointFactor = 0.5;
const double thSelectionWindowBorderPaintDashInterval = 5.0;
const double thSelectionHandleSize = 7.0;
const double thSelectionHandleThresholdMultiplier = 10.0;
const double thSelectionHandleSizeAmplifier = 1.5;
const double thSelectionHandleDistance = 10.0;
const double thSelectionHandleLineThickness = 2.0;
final Paint thSelectionHandleFillPaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.stroke;
const double thWhiteBackgroundIncrease = 1.5;
const double mpOverlayWindowOuterAnchorMargin = 15.0;
const double mpDiamondLongerDiagonalRatio = math.sqrt2;
const int mpAreaFillTransparency = 30;
const int mpScrapBackgroundFillTransparency = 15;

const double mpLineDirectionTickLength = 10.0;
const double mpAverageTangentDelta = 0.1;
const int mpLineSegmentsPerDirectionTick = 5;
const double mpXVILineThickness = 1.0;

final double mpSqrt3 = math.sqrt(3);
final double mpSqrt3Over2 = mpSqrt3 / 2;

const String thMainConfigSection = 'Main';
const String thMainConfigLocale = 'Locale';
const String thFileEditConfigSection = 'FileEdit';
const String thFileEditConfigSelectionTolerance = 'SelectionTolerance';
const String thFileEditConfigPointRadius = 'PointRadius';
const String thFileEditConfigLineThickness = 'LineThickness';

final Paint thSelectionWindowFillPaint = Paint()
  ..color = Colors.redAccent.withValues(alpha: 0.3)
  ..style = PaintingStyle.fill;
final Paint thSelectionWindowBorderPaint = Paint()
  ..color = Colors.blue
  ..style = PaintingStyle.stroke;
const double thSelectionWindowBorderPaintStrokeWidth = 2;

const double mpCompass45DegreeLineFactor = 0.87;
const double mpCompass90DegreeLineFactor = 0.68;
const double mpCompassArrowBaseLengthFactor = 0.78;
const double mpCompassArrowBodyWidthFactor = 2.0;
const double mpCompassArrowFixedLengthScreenFactor = 2.78;
const double mpCompassArrowScreenBodyWidth = 3.0;
const double mpCompassArrowSideFactor = 0.2;
const double mpCompassArrowTipBaseFactor = 0.85;
const double mpCompassArrowVariableLengthScreenFactor = 5.0;
const double mpCompassBoxSizeFactor = 0.8;
const double mpCompassCardinalDirectionsFontSizeFactor = 0.1;
const double mpCompassCardinalDirectionsTextOffsetFactor = 0.83;
const double mpCompassCentralCircleFactor = 0.3;
const double mpSlopeLinePointDefaultLSize = 20.0;

const double thCentimeterToMeter = 0.01;
const double thMeterToCentimeter = 100.0;
const double thInchToCentimeter = 2.54;
const double thFeetToInch = 12.0;
const double thYardToFeet = 3.0;

const double thMeterToInch = thMeterToCentimeter / thInchToCentimeter;
const double thFeetToCentimeter = thFeetToInch * thInchToCentimeter;
const double thMeterToFeet = thMeterToCentimeter / thFeetToCentimeter;
const double thYardToCentimeter =
    thYardToFeet * thFeetToInch * thInchToCentimeter;
const double thMeterToYard = thMeterToCentimeter / thYardToCentimeter;
const double thInchToMeter = thInchToCentimeter / thMeterToCentimeter;
const double thFeetToMeter = thFeetToCentimeter / thMeterToCentimeter;
const double thYardToMeter = thYardToCentimeter / thMeterToCentimeter;
const double thCentimeterToInch = 1 / thInchToCentimeter;
const double thCentimeterToFeet = 1 / thFeetToCentimeter;
const double thCentimeterToYard = 1 / thYardToCentimeter;
const double thInchToFeet = 1 / thFeetToInch;
const double thYardToInch = thFeetToInch * thYardToFeet;
const double thInchToYard = 1 / thYardToInch;
const double thFeetToYard = 1 / thYardToFeet;

const Map<THLengthUnitType, Map<THLengthUnitType, double>>
lengthConversionFactors = {
  THLengthUnitType.centimeter: {
    THLengthUnitType.feet: thCentimeterToFeet,
    THLengthUnitType.inch: thCentimeterToInch,
    THLengthUnitType.meter: thCentimeterToMeter,
    THLengthUnitType.yard: thCentimeterToYard,
  },
  THLengthUnitType.feet: {
    THLengthUnitType.centimeter: thFeetToCentimeter,
    THLengthUnitType.inch: thFeetToInch,
    THLengthUnitType.meter: thFeetToMeter,
    THLengthUnitType.yard: thFeetToYard,
  },
  THLengthUnitType.inch: {
    THLengthUnitType.centimeter: thInchToCentimeter,
    THLengthUnitType.feet: thInchToFeet,
    THLengthUnitType.meter: thInchToMeter,
    THLengthUnitType.yard: thInchToYard,
  },
  THLengthUnitType.meter: {
    THLengthUnitType.centimeter: thMeterToCentimeter,
    THLengthUnitType.feet: thMeterToFeet,
    THLengthUnitType.inch: thMeterToInch,
    THLengthUnitType.yard: thMeterToYard,
  },
  THLengthUnitType.yard: {
    THLengthUnitType.centimeter: thYardToCentimeter,
    THLengthUnitType.feet: thYardToFeet,
    THLengthUnitType.inch: thYardToInch,
    THLengthUnitType.meter: thYardToMeter,
  },
};

const double thDefaultTHFileScale = 1.0;
const THLengthUnitType thDefaultTHFileLengthUnit = THLengthUnitType.meter;

const THPointType thDefaultPointType = THPointType.station;
const THLineType thDefaultLineType = THLineType.wall;
const THAreaType thDefaultAreaType = THAreaType.water;

const String mpUnsetOptionID = 'UNSET';
const String mpUnrecognizedOptionID = 'UNRECOGNIZED';
const String mpNonMultipleChoiceSetID = 'SET';

const String thPointHeightValuePresumedPlus = '+?';
const String thPointHeightValuePresumedMinus = '-?';

const String mpScrapFromFileTHID = 'FROM_FILE';
const String mpScrapFreeTextTHID = 'FREE_TEXT';

const String mpUnknownPLAType = 'unknown';

const String mpAreaTHIDPrefix = 'area';
const String mpLineTHIDPrefix = 'line';
const String mpScrapTHIDPrefix = 'scrap';

const String mpNewFilePrefix = 'NEW_TH2_FILE';

const int mpParentMPIDPlaceholder = 0;

const int mpScrapScaleMaxValues = 8;
const String mpScrapScale1ValueID = 'ONE_VALUE';
const String mpScrapScale2ValuesID = 'TWO_VALUES';
const String mpScrapScale8ValuesID = 'EIGHT_VALUES';

const int mpMultipleElementsClickedAllChoiceID = 0;
const int mpMultipleElementsClickedNoneChoiceID = -1;

const int mpMaxLastUsedTypes = 5;
const int mpMaxMostUsedTypes = 5;

const String mpNoSubtypeID = 'NO_SUBTYPE';

const String mpChangelogURL =
    'https://github.com/rsevero/mapiah/blob/main/CHANGELOG.md';
const String mpLicenseURL =
    'https://github.com/rsevero/mapiah/blob/main/LICENSE.md';

const String xTherionImageInsertConfigID = 'xth_me_image_insert';
const String mpXVIExtension = '.xvi';
const String xTherionConfigID = '##XTHERION##';

const String mpXTherionImageInsertButtonImagePath =
    'assets/icons/change-image-tool.png';
const String mpScrapButtonImagePath = 'assets/icons/change-scrap-tool.png';

const int mpAddChildAtEndMinusOneOfParentChildrenList = -1;
const int mpAddChildAtEndOfParentChildrenList = -2;
