import 'dart:math' as math;

import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';

/// Constants and others definitioons that should be generally available.

const String thDebugPath =
    '/home/rodrigo/devel/mapiah/test/auxiliary/unused/th2parser';

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

const String thDefaultEncoding = 'UTF-8';

const String thNullValueAsString = '!!! property has null value !!!';

const double thCanvasVisibleMargin = 0.1;
const double thCanvasOutOfSightMargin = 2.0;

const double thRegularZoomFactor = numerics.sqrt2;
const double thRoundToFactor = thRegularZoomFactor - 1;
const double thFineZoomFactor = thRoundToFactor / 2 + 1;
const double thCanvasMovementFactor = 0.1;
final double thLogN10 = math.log(10);

const double thMinimumSizeForDrawing = 10.0;

const int thFirstMapiahIDForTHFiles = -1;
const int thFirstMapiahIDForElements = 1;

const double thDesiredSegmentLengthOnScreen = 10.0;

const double thDesiredGraphicalScaleScreenPointLength = 200.0;
const double thGraphicalScalePadding = 20.0;
const double thGraphicalScaleUptickLength = 8.0;
const double thGraphicalScaleFontSize = 12.0;

const String thDefaultLengthUnit = 'meter';

const String thClipMultipleChoiceType = 'clip';

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

const double thClickDragThreshold = 2.0;
const double thClickDragThresholdSquared =
    thClickDragThreshold * thClickDragThreshold;
const double thDefaultSelectionTolerance = 10.0;
const double thDefaultPointRadius = 5.0;
const double thDefaultLineThickness = 2.0;
const double thSelectionWindowBorderPaintDashInterval = 5.0;
const double thSelectionHandleSize = 7.0;
const double thSelectionHandleThresholdMultiplier = 10.0;
const double thSelectionHandleSizeAmplifier = 1.5;
const double thSelectionHandleDistance = 10.0;
const double thSelectionHandleLineThickness = 2.0;
final Paint thSelectionHandleFillPaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.stroke;

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

const double thMeterToCentimeter = 100.0;
const double thInchToCentimeter = 2.54;
const double thFeetToInch = 12.0;
const double thYardToFeet = 3.0;

const double thMeterToInch = thMeterToCentimeter / thInchToCentimeter;
const double thMeterToFeet =
    thMeterToCentimeter / (thInchToCentimeter * thFeetToInch);
const double thMeterToYard =
    thMeterToCentimeter / (thInchToCentimeter * thFeetToInch * thYardToFeet);

const double thInchToMeter = 1 / thMeterToInch;
const double thFeetToMeter = 1 / thMeterToFeet;
const double thYardToMeter = 1 / thMeterToYard;
const double thCentimeterToMeter = 1 / thMeterToCentimeter;

const double thCentimeterToInch = 1 / thInchToCentimeter;
const double thCentimeterToFeet = 1 / (thInchToCentimeter * thFeetToInch);
const double thCentimeterToYard =
    1 / (thInchToCentimeter * thFeetToInch * thYardToFeet);

const double thInchToFeet = 1 / thFeetToInch;
const double thInchToYard = 1 / (thFeetToInch * thYardToFeet);

const double thFeetToCentimeter = 1 / thCentimeterToFeet;
const double thFeetToYard = 1 / thYardToFeet;

const double thYardToCentimeter = 1 / thCentimeterToYard;
const double thYardToInch = 1 / thInchToYard;

final Map<THLengthUnitType, Map<THLengthUnitType, double>>
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
