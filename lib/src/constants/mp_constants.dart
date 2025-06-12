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
const int thMaxDecimalPositions = 6;
const int thDefaultDecimalPositions = 4;
const int mpDefaultDecimalPositionsAzimuth = 1;

const String thDefaultEncoding = 'UTF-8';

const String thNullValueAsString = '!!! property has null value !!!';

const double thCanvasVisibleMargin = 0.1;
const double thCanvasOutOfSightMargin = 2.0;

const double thRegularZoomFactor = math.sqrt2;
const double thRoundToFactor = thRegularZoomFactor - 1;
const double thFineZoomFactor = thRoundToFactor / 2 + 1;
const double thCanvasMovementFactor = 0.1;
const double thCanvasRoundFactor = 25.0;

const double thLogN10 = math.ln10;
const double th45Degrees = math.pi / 4;

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

// keyword . a sequence of A-Z, a-z, 0-9 and _-/ characters (not starting with ‘-’).
final RegExp thKeywordRegex = RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_-]*$');

// ext keyword . keyword that can also contain +*.,’ characters, but not on the first
// position.
final RegExp thExtKeywordRegex =
    RegExp(r'''^[a-zA-Z0-9_][a-zA-Z0-9_+*.,'-]*$''');

// date . a date (or a time interval) specification in the format
// YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
// or ‘-’ to leave a date unspecified.
final RegExp thDatetimeRegex = RegExp(
    r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$');

const String thConfigDirectory = 'Config';
const String thMainDirectory = 'Mapiah';
const String thProjectsDirectory = 'Projects';

const String thMainConfigFilename = 'mapiah.toml';
const String thDefaultLocaleID = 'sys';
const String thEnglishLocaleID = 'en';

const double thFloatingActionIconSize = 32;
const double thFloatingActionZoomIconSize = 24;
const double mpButtonSpace = 8;
const double mpButtonMargin = mpButtonSpace * 4;
const double mpOverlayWindowPadding = 16;
const double mpOverlayWindowCornerRadius = 18;
const double mpOverlayWindowBlockPadding = 12;
const double mpOverlayWindowBlockCornerRadius = 14;
const double mpOverlayWindowBlockElevation = 2;
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

const int mpInitialZOrder = 0;
const int mpDefaultZOrderIncrement = 1000;

const double thClickDragThreshold = 2.0;
const double thClickDragThresholdSquared =
    thClickDragThreshold * thClickDragThreshold;
const double thDefaultSelectionTolerance = 6.0;
const double thDefaultPointRadius = 5.0;
const double thDefaultLineThickness = 2.0;
const double thControlLineThicknessFactor = 0.5;
const double thControlPointRadiusFactor = 1.5;
const double thSelectedEndControlPointFactor = 1.25;
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

const double mpLineDirectionTickLength = 10.0;
const double mpAverageTangentDelta = 0.1;
const int mpLineSegmentsPerDirectionTick = 5;

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

const String mpScrapFromFileTHID = 'FROM_FILE';
const String mpScrapFreeTextTHID = 'FREE_TEXT';

const String mpAreaTHIDPrefix = 'area';
const String mpLineTHIDPrefix = 'line';

const int mpScrapScaleMaxValues = 8;
const String mpScrapScale1ValueID = 'ONE_VALUE';
const String mpScrapScale2ValuesID = 'TWO_VALUES';
const String mpScrapScale8ValuesID = 'EIGHT_VALUES';

const int mpMultipleElementsClickedAllChoiceID = 0;
const int mpMultipleElementsClickedNoneChoiceID = -1;

const int mpMaxLastUsedTypes = 5;
const int mpMaxMostUsedTypes = 5;

const String mpNoSubtypeID = 'NO_SUBTYPE';
