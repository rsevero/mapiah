import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

const String thDebugPath =
    '/home/rodrigo/devel/mapiah/test/auxiliary/unused/th2parser';
const bool mpDebugMousePosition = bool.fromEnvironment(
  'debugMousePosition',
  defaultValue: false,
);

// Compile-time flag to indicate we built the app for Flathub (set with
// `--dart-define=isFlathub=true` when building). Defaults to false.
const bool mpIsFlathub = bool.fromEnvironment('isFlathub', defaultValue: false);

// Compile-time flag to indicate we built the app as a Flatpak (set with
// `--dart-define=isFlatpak=true` when building). Defaults to false.
const bool mpIsFlatpak = bool.fromEnvironment('isFlatpak', defaultValue: false);

// Debug compile-time flag to force showing Flathub version info dialog even
// when the remote version is not newer. Set with
// `--dart-define=debugAlwaysShowVersions=true` for debugging.
const bool mpDebugAlwaysShowVersions = bool.fromEnvironment(
  'debugAlwaysShowVersions',
  defaultValue: false,
);

// Debug constant to override the current version used when comparing to the
// newest version available. If empty, the actual current version is used.
const String mpDebugNewVersionInterfaceCurrentVersion = '';

const String mpHelpPagePath = 'assets/help';
const String mpHelpPageFlathubDisabled = 'flathub_disabled';

const String mpCommentChar = '#';
const String mpDecimalSeparator = '.';
const String mpUnixLineBreak = '\n';
const String mpWindowsLineBreak = '\r\n';
const String mpCarriageReturn = '\r';
const String mpDoubleQuote = '"';
const String mpDoubleQuotePair = r'""';

/// This char is from the private-use chars.
// See [https://www.unicode.org/faq/private_use.html]
const String mpDoubleQuotePairEncoded = '\uE001';
const String mpWhitespaceChars = ' \t';

const String mpIndentation = '  ';

const int mpthMaxEncodingLength = 20;
const int mpMaxFileLineLength = 80;
const int mpMaxDecimalPositions = 6;
const int mpDefaultDecimalPositions = 4;
const int mpDefaultDecimalPositionsAzimuth = 1;
const double mpDefaultSnapOnScreenDistance = 9;
const double mpSnapGridCellSizeFactor = 1.1;

const String mpDefaultEncoding = 'UTF-8';

const String mpNullValueAsString = '!!! property has null value !!!';

const double mpCanvasVisibleMargin = 0.1;
const double mpCanvasOutOfSightMargin = 2.0;
const double mpScrapBackgroundPadding = 0.02;

const double mpRegularZoomFactor = math.sqrt2;
const double mpRoundToFactor = mpRegularZoomFactor - 1;
const double mpFineZoomFactor = mpRoundToFactor / 2 + 1;
const double mpCanvasMovementFactor = 0.1;
const double mpCanvasRoundFactor = 25.0;

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

/// Fraction used to inset connection lines from endpoints (e.g., 1/20).
const double mpConnectionLineInsetFraction = 1.0 / 20.0;

/// Factor for converting Catmull-Rom tangent vectors to cubic Bézier control
/// point offsets. Derived from the cubic Bézier derivative: B'(0) = 3*(P1-P0),
/// so P1 = P0 + tangent/3.
const double mpCatmullRomToBezierHandleFactor = 1.0 / 3.0;

/// Standard Catmull-Rom centripetal parameter for interior anchor tangent
/// estimation: tangent = 0.5 * (P[i+1] - P[i-1]).
const double mpCatmullRomInteriorTangentFactor = 0.5;

/// Fraction of the average segment length used as the fitting tolerance when
/// converting straight line segments to Bézier curves. This makes the
/// tolerance adapt to the data's geometric scale, enabling meaningful merging
/// of segments regardless of coordinate magnitude.
const double mpStraightToBezierFittingToleranceFraction = 0.1;

/// Limits compatible with Dart VM (used on Linux, MacOS and Windows).
const int mpMinimumInt = -0x7fffffffffffffff - 1;
const int mpMaximumInt = 0x7fffffffffffffff;

const double mpLogN10 = math.ln10;
const double mp45DegreesInRad = math.pi / 4;
const double mp60DegreeInRad = math.pi / 3;
const double mp90DegreeInRad = math.pi / 2;
const double mp180DegreeInRad = math.pi;
const double mp360DegreeInRad = 2 * math.pi;
const double mp1DegreeInRad = math.pi / 180;
const double mp1RadInDegree = 180 / math.pi;
const double mp1OverPi = 1 / math.pi;
const double mpDegreesInCircle = 360.0;

const double mpLineSimplifyEpsilonOnScreen = 1.0;

const double mpMinimumSizeForDrawing = 10.0;

const int mpFirstMPIDForTHFiles = -1;
const int mpFirstMPIDForElements = 1;

const double mpDesiredSegmentLengthOnScreen = 15.0;

const double mpDesiredGraphicalScaleScreenPointLength = 200.0;
const double mpGraphicalScalePadding = 20.0;
const double mpGraphicalScaleUptickLength = 8.0;
const double mpGraphicalScaleFontSize = 12.0;

const THLengthUnitType thDefaultLengthUnit = THLengthUnitType.meter;
final String thDefaultLengthUnitAsString = thDefaultLengthUnit.name;
const THAngleUnitType thDefaultAngleUnit = THAngleUnitType.degree;
final String thDefaultAngleUnitAsString = thDefaultAngleUnit.name;
const double mpAzimuthConstraintAngle = 15.0;

// keyword . a sequence of A-Z, a-z, 0-9 and _-/ characters (not starting with ‘-’).
final RegExp mpKeywordRegex = RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_-]*$');

// ext keyword . keyword that can also contain +*.,’ characters, but not on the first
// position.
final RegExp mpExtKeywordRegex = RegExp(
  r'''^[a-zA-Z0-9_][a-zA-Z0-9_+*.,'-]*$''',
);

// date . a date (or a time interval) specification in the format
// YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] [- YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]]
// or ‘-’ to leave a date unspecified.
final RegExp mpDatetimeRegex = RegExp(
  r'^(?<year>\d{4}(\.(?<month>(0[1-9]|1[0-2]))(\.(?<day>(0[1-9]|[12][0-9]|3[01]))(\@(?<hour>(0[0-9]|1[0-9]|2[0-4]))(\:(?<minute>(0[0-9]|[1-5][0-9]))(\:(?<second>(0[0-9]|[1-5][0-9]))(\.(?<fractional>(0[0-9]|[1-5][0-9])))?)?)?)?)?)?)$',
);

const String mpConfigDirectory = 'Config';
const String mpMainDirectory = 'Mapiah';
const String mpProjectsDirectory = 'Projects';

const String mpMainConfigFilename = 'mapiah.toml';
const String mpDefaultLocaleID = 'sys';
const String mpEnglishLocaleID = 'en';
const String mpPathEnvironmentVariableName = 'PATH';
const String mpPathEnvironmentEntrySeparatorUnix = ':';
const String mpPathEnvironmentEntrySeparatorMacOS =
    mpPathEnvironmentEntrySeparatorUnix;
const String mpPathEnvironmentEntrySeparatorWindows = ';';
const String mpWindowsExecutableExtension = '.exe';
const String mpTherionExecutableName = 'therion';
const String mpTherionLogFileName = 'therion.log';
const String mpTherionWindowsExecutableName =
    '$mpTherionExecutableName$mpWindowsExecutableExtension';
const String mpTherionDefaultExecutableCommand = mpTherionExecutableName;
const String mpTherionPrintEncodingsArgument = '--print-encodings';
const String mpFlatpakSpawnExecutableName = 'flatpak-spawn';
const String mpFlatpakSpawnHostArgument = '--host';
const String mpFlatpakSpawnDirectoryFlag = '--directory';
const String mpFlatpakSandboxSafeWorkingDirectory = '/';
const String mpTherionVersionArgument = '--version';
const String mpSettingsMainSection = 'Main';
const String mpSettingsTH2EditSection = 'TH2Edit';
const String mpSettingsInternalSection = 'Internal';
const String mpSettingsStringListSeparator = ', ';

const double mpTherionRunDialogWidth = 900;
const double mpTherionRunDialogHeight = 600;
const double mpTherionRunDialogSpacing = 12;
const double mpTherionRunStatusBoxMinWidth = 120;
const double mpTherionRunOutputBorderWidth = 1;
const double mpTherionRunIssuesListHeight = 120;
const Duration mpTherionRunScrollAnimationDuration = Duration(
  milliseconds: 250,
);
const Curve mpTherionRunScrollAnimationCurve = Curves.easeInOut;
const int mpTherionLogOlderLimitInMilliseconds = 1500;
final Duration mpTherionLogOlderLimitDuration = Duration(
  milliseconds: mpTherionLogOlderLimitInMilliseconds,
);

const Color mpTherionRunStatusBackgroundRunningColor = Colors.yellow;
const Color mpTherionRunStatusBackgroundOkColor = Colors.green;
const Color mpTherionRunStatusBackgroundWarningColor = Colors.orange;
const Color mpTherionRunStatusBackgroundErrorColor = Colors.red;

const Color mpTherionRunOutputWarningColor =
    mpTherionRunStatusBackgroundWarningColor;
const Color mpTherionRunOutputErrorColor =
    mpTherionRunStatusBackgroundErrorColor;

const String mpTherionWarningWord = 'warning';
const String mpTherionErrorWord = 'error';
const String mpTherionOutputSectionDelimiter = '====================';

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
const double mpSettingsPageOuterPadding = 16;
const double mpSettingsPageSectionSpacing = 12;
const double mpSettingsPageCardPadding = 12;
const double mpSettingsPageFieldSpacing = 8;
const double mpSettingsPageButtonSpacing = 8;
const double mpSettingsEditableFieldMinWidth = 320;
const int mpDefaultMinDigitsForTextFields = 6;
const int mpDefaultMinCharsForTextFields = 10;
const int mpDefaultMaxCharsForTextFields = 20;

const int mpETRSMin = 28;
const int mpETRSMax = 37;
const int mpEPSGESRIMin = 1;
const int mpEPSGESRIMax = 99999;
const int mpUTMMin = 1;
const int mpUTMMax = 60;

const double mpClickDragThreshold = 2.0;
const double mpClickDragThresholdSquared =
    mpClickDragThreshold * mpClickDragThreshold;
const double mpDefaultSelectionTolerance = 7.0;
const double mpDefaultPointRadius = 7.0;
const double mpDefaultLineThickness = 2.0;
const double mpControlLineThicknessFactor = 0.5;
const double mpControlPointRadiusFactor = 1.5;
const double mpSelectedEndControlPointFactor = 1.25;
const double xviPointFactor = 0.5;
const double mpSelectionWindowBorderPaintDashInterval = 5.0;
const double mpSelectionHandleSize = 7.0;
const double mpSelectionHandleThresholdMultiplier = 10.0;
const double mpSelectionHandleSizeAmplifier = 1.5;
const double mpSelectionHandleDistance = 10.0;
const double mpSelectionHandleLineThickness = 2.0;
final Paint mpSelectionHandleFillPaint = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.stroke;
const double mpWhiteBackgroundIncrease = 1.5;
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

const String mpMainConfigSection = 'Main';
const String mpMainConfigLocale = 'Locale';
const String mpFileEditConfigSection = 'FileEdit';
const String mpFileEditConfigSelectionTolerance = 'SelectionTolerance';
const String mpFileEditConfigPointRadius = 'PointRadius';
const String mpFileEditConfigLineThickness = 'LineThickness';

final Paint mpSelectionWindowFillPaint = Paint()
  ..color = Colors.redAccent.withValues(alpha: 0.3)
  ..style = PaintingStyle.fill;
final Paint mpSelectionWindowBorderPaint = Paint()
  ..color = Colors.blue
  ..style = PaintingStyle.stroke;
const double mpSelectionWindowBorderPaintStrokeWidth = 2;

const double mpCompass45DegreeLineFactor = 0.87;
const double mpCompass90DegreeLineFactor = 0.68;
const double mpCompassArrowBaseLengthFactor = 0.78;
const double mpCompassArrowBodyWidthFactor = 2.0;
const double mpCompassArrowScreenBodyWidth = 3.0;
const double mpCompassArrowHeadReferenceLengthOnScreen = 18.0;
const double mpCompassArrowSideFactor = 0.5;
const double mpCompassArrowTipBaseFactor = 0.5;
const double mpCompassArrowVariableLengthScreenFactor = 5.0;
const double mpCompassBoxSizeFactor = 0.8;
const double mpCompassCardinalDirectionsFontSizeFactor = 0.1;
const double mpCompassCardinalDirectionsTextOffsetFactor = 0.83;
const double mpCompassCentralCircleFactor = 0.3;
const double mpSlopeLinePointDefaultLSize = 40.0;
const int mpLSizeOptionDecimalPlaces = 1;
const int mpOrientationOptionDecimalPlaces = 1;

const double mpCentimeterToMeter = 0.01;
const double mpMeterToCentimeter = 100.0;
const double mpInchToCentimeter = 2.54;
const double mpFeetToInch = 12.0;
const double mpYardToFeet = 3.0;

const double mpMeterToInch = mpMeterToCentimeter / mpInchToCentimeter;
const double mpFeetToCentimeter = mpFeetToInch * mpInchToCentimeter;
const double mpMeterToFeet = mpMeterToCentimeter / mpFeetToCentimeter;
const double mpYardToCentimeter =
    mpYardToFeet * mpFeetToInch * mpInchToCentimeter;
const double mpMeterToYard = mpMeterToCentimeter / mpYardToCentimeter;
const double mpInchToMeter = mpInchToCentimeter / mpMeterToCentimeter;
const double mpFeetToMeter = mpFeetToCentimeter / mpMeterToCentimeter;
const double mpYardToMeter = mpYardToCentimeter / mpMeterToCentimeter;
const double mpCentimeterToInch = 1 / mpInchToCentimeter;
const double mpCentimeterToFeet = 1 / mpFeetToCentimeter;
const double mpCentimeterToYard = 1 / mpYardToCentimeter;
const double mpInchToFeet = 1 / mpFeetToInch;
const double mpYardToInch = mpFeetToInch * mpYardToFeet;
const double mpInchToYard = 1 / mpYardToInch;
const double mpFeetToYard = 1 / mpYardToFeet;

const Map<THLengthUnitType, Map<THLengthUnitType, double>>
lengthConversionFactors = {
  THLengthUnitType.centimeter: {
    THLengthUnitType.feet: mpCentimeterToFeet,
    THLengthUnitType.inch: mpCentimeterToInch,
    THLengthUnitType.meter: mpCentimeterToMeter,
    THLengthUnitType.yard: mpCentimeterToYard,
  },
  THLengthUnitType.feet: {
    THLengthUnitType.centimeter: mpFeetToCentimeter,
    THLengthUnitType.inch: mpFeetToInch,
    THLengthUnitType.meter: mpFeetToMeter,
    THLengthUnitType.yard: mpFeetToYard,
  },
  THLengthUnitType.inch: {
    THLengthUnitType.centimeter: mpInchToCentimeter,
    THLengthUnitType.feet: mpInchToFeet,
    THLengthUnitType.meter: mpInchToMeter,
    THLengthUnitType.yard: mpInchToYard,
  },
  THLengthUnitType.meter: {
    THLengthUnitType.centimeter: mpMeterToCentimeter,
    THLengthUnitType.feet: mpMeterToFeet,
    THLengthUnitType.inch: mpMeterToInch,
    THLengthUnitType.yard: mpMeterToYard,
  },
  THLengthUnitType.yard: {
    THLengthUnitType.centimeter: mpYardToCentimeter,
    THLengthUnitType.feet: mpYardToFeet,
    THLengthUnitType.inch: mpYardToInch,
    THLengthUnitType.meter: mpYardToMeter,
  },
};

const double mpDefaultTHFileScale = 1.0;
const THLengthUnitType mpDefaultTHFileLengthUnit = THLengthUnitType.meter;

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
const String mpPLATypeSubtypeSeparator = ':';
const String mpSubtypeIDSeparator = '|';
const String mpPointSubtypeIDPrefix = 'point$mpSubtypeIDSeparator';
const String mpLineSubtypeIDPrefix = 'line$mpSubtypeIDSeparator';
const String mpAreaSubtypeIDPrefix = 'area$mpSubtypeIDSeparator';

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

// Flathub/Flatpak application id used on Flathub
const String mpMapiahFlathubAppID = 'io.github.rsevero.mapiah';

const String mpXTherionImageInsertConfigID = 'xth_me_image_insert';
const String mpXVIExtension = '.xvi';
const String mpXTherionConfigID = '##XTHERION##';

const String mpXTherionImageInsertButtonImagePath =
    'assets/icons/change-image-tool.png';
const String mpScrapButtonImagePath = 'assets/icons/change-scrap-tool.png';

// Help page identifiers (match files under assets/help/<lang>/)
const String mpHelpPageKeyboardShortcutsMain = 'keyboard_shortcuts_main';
const String mpHelpPageKeyboardShortcutsEdit = 'keyboard_shortcuts_edit';
const String mpHelpPageMapiahHome = 'mapiah_home_help';
const String mpHelpPageTh2FileEdit = 'th2_file_edit_page_help';

const int mpAddChildAtEndMinusOneOfParentChildrenList = -1;
const int mpAddChildAtEndOfParentChildrenList = -2;

const int mpMapiahReleasesAPIPerPage = 100;
const int mpSemanticVersionComponentCount = 3;
const String mpMapiahStableReleaseTagPattern = r'^v?(\d+)\.(\d+)\.(\d+)$';
const String mpMapiahReleasesAPIURL =
    'https://api.github.com/repos/rsevero/mapiah/tags?per_page=$mpMapiahReleasesAPIPerPage';
const String mpMapiahReleasesAPIHeaderAccept = 'application/vnd.github+json';
const String mpMapiahGithubReleasesURL =
    'https://github.com/rsevero/mapiah/releases/tag/';
const String mpMapiahGithubRawContentURLPrefix =
    'https://raw.githubusercontent.com/rsevero/mapiah/main';
const String mpMapiahGithubHelpPagesURLPrefix =
    '$mpMapiahGithubRawContentURLPrefix/assets/help';
const String mpMapiahVersionFlathubURLPrefix =
    'https://flathub.org/apps/details/';

const int mpSecondsCheckPauseBetweenNewVersionChecks = 24 * 60 * 60; // 24 hours
const int mpMaxNumberOfNewerVersionsToRespectCheckPause = 3;

const bool mpDefaultDefaultBoolSetting = false;
const double mpDefaultDefaultDoubleSetting = 0.0;
const int mpHttpStatusOk = 200;
const int mpDefaultDefaultIntSetting = 0;
const int mpProcessExitCodeSuccess = 0;
const String mpDefaultDefaultStringSetting = '';
const List<String> mpDefaultDefaultStringListSetting = [];

const String mpWindowsRegistryTherionMachinePath =
    r'HKEY_LOCAL_MACHINE\SOFTWARE\Therion';
const String mpWindowsRegistryTherionUserPath =
    r'HKEY_CURRENT_USER\SOFTWARE\Therion';
const String mpWindowsRegistryInstallDirValueName = 'InstallDir';

const String mpWindowsForwardSlash = '/';
const String mpWindowsBackslashPair = '\\';

const String mpWindowsCmdExecutable = 'cmd.exe';
const String mpWindowsCommandExecutable = 'command.com';
const String mpWindowsShellExecuteFlag = '/c';
const String mpWindowsRegistryQueryCommand = 'reg';
const String mpWindowsRegistryQuerySubcommand = 'query';
const String mpWindowsRegistryQueryValueSwitch = '/v';
const String mpWindowsRegistryQuery64BitSwitch = '/reg:64';
const String mpWindowsRegistryQuery32BitSwitch = '/reg:32';
const String mpWindowsSystemRootEnvironmentVariable = 'SystemRoot';
const String mpWindowsSystem32Directory = 'System32';

const String mpTherionWindowsDebugPrefix = '[Mapiah][Therion][Debug]';
const String mpTherionWindowsRegistryLookupHeader =
    '$mpTherionWindowsDebugPrefix Registry lookup results:';
const String mpTherionWindowsRegistryLookupStatusFound = 'FOUND';
const String mpTherionWindowsRegistryLookupStatusMissing = 'NOT_FOUND_OR_EMPTY';
const String mpTherionWindowsRegistryLookupFallbackMessage =
    '$mpTherionWindowsDebugPrefix Falling back to executable from PATH.';
const String mpTherionWindowsRegistryLookupCacheHitMessage =
    '$mpTherionWindowsDebugPrefix Using cached executable path from previous registry lookup.';
const String mpTherionWindowsRegistryLookupValueUnavailable = '<unavailable>';

const int mpWindowsRegistryQueryValueStartTokenIndex = 2;
const int mpWindowsRegistryQueryMinimumTokens =
    mpWindowsRegistryQueryValueStartTokenIndex + 1;

const String mpTherionCompileFlag = '-x';
const String mpTherionBezierInterpolationFlag = '-b';
const String mpTherionConfigFileExtension = '.thconfig';

const String mpCommandSeparatorSpace = ' ';
const String mpEmptyString = '';

// macOS therion path search – well-known package-manager installation
// directories probed in priority order (most common first).
const String mpMacOSHomebrewArmBinDirectory = '/opt/homebrew/bin';
const String mpMacOSHomebrewIntelBinDirectory = '/usr/local/bin';
const String mpMacOSMacPortsBinDirectory = '/opt/local/bin';
const String mpMacOSFinkBinDirectory = '/sw/bin';

const List<String> mpTherionMacOSSearchDirectories = <String>[
  mpMacOSHomebrewArmBinDirectory,
  mpMacOSHomebrewIntelBinDirectory,
  mpMacOSMacPortsBinDirectory,
  mpMacOSFinkBinDirectory,
];

const String mpTherionMacOSDebugPrefix = '[Mapiah][Therion][Debug][macOS]';
const String mpTherionMacOSPathSearchHeader =
    '$mpTherionMacOSDebugPrefix Path search results:';
const String mpTherionMacOSPathSearchStatusFound = 'FOUND';
const String mpTherionMacOSPathSearchStatusMissing = 'NOT_FOUND_OR_MISSING';
const String mpTherionMacOSPathSearchFallbackMessage =
    '$mpTherionMacOSDebugPrefix Falling back to executable from PATH.';
const String mpTherionMacOSPathSearchCacheHitMessage =
    '$mpTherionMacOSDebugPrefix Using cached executable path from previous path search.';

// Linux therion process runner – diagnostic constants.
const String mpTherionLinuxDebugPrefix = '[Mapiah][Therion][Debug][Linux]';
const String mpTherionLinuxPathSearchCacheHitMessage =
    '$mpTherionLinuxDebugPrefix Using cached executable path.';
const String mpTherionLinuxPathSearchFallbackMessage =
    '$mpTherionLinuxDebugPrefix Falling back to executable from PATH.';
