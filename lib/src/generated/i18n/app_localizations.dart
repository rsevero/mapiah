import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// The label for the changelog section in the About dialog
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get aboutMapiahDialogChangelog;

  /// The label for the license section in the About dialog
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutMapiahDialogLicense;

  /// The version of Mapiah for the About dialog
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutMapiahDialogMapiahVersion(Object version);

  /// The title for the About dialog
  ///
  /// In en, this message translates to:
  /// **'About Mapiah'**
  String get aboutMapiahDialogWindowTitle;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Mapiah'**
  String get appTitle;

  /// The label for the close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// The label for the about Mapiah dialog
  ///
  /// In en, this message translates to:
  /// **'About Mapiah'**
  String get initialPageAboutMapiahDialog;

  /// The label for the language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get initialPageLanguage;

  /// The label for the open file button
  ///
  /// In en, this message translates to:
  /// **'Open file (Ctrl+O)'**
  String get initialPageOpenFile;

  /// The initial page presentation of the application
  ///
  /// In en, this message translates to:
  /// **'Mapiah: an user-friendly graphical interface for cave mapping with Therion'**
  String get initialPagePresentation;

  /// The title for the file edit window
  ///
  /// In en, this message translates to:
  /// **'File edit'**
  String get fileEditWindowWindowTitle;

  /// The name of the language based on the language code. Translate only 'System' and your language name. Leave the other values as they are.
  ///
  /// In en, this message translates to:
  /// **'{language, select, sys {System} en {English} pt {Português} other {Unknown}}'**
  String languageName(String language);

  /// The message displayed when the help content fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load help content'**
  String get helpDialogFailureToLoad;

  /// The tooltip for the help dialog button
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpDialogTooltip;

  /// The title for the main page of the help dialog
  ///
  /// In en, this message translates to:
  /// **'Main page'**
  String get mapiahHomeHelpDialogTitle;

  /// The description for the degree angle unit
  ///
  /// In en, this message translates to:
  /// **'degree'**
  String get mpAngleUnitDegree;

  /// The description for the grad angle unit
  ///
  /// In en, this message translates to:
  /// **'grad'**
  String get mpAngleUnitGrad;

  /// The description for the mil angle unit
  ///
  /// In en, this message translates to:
  /// **'mil'**
  String get mpAngleUnitMil;

  /// The description for the minute angle unit
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get mpAngleUnitMinute;

  /// The error message for invalid altitude value
  ///
  /// In en, this message translates to:
  /// **'Invalid altitude'**
  String get mpAltitudeInvalidValueErrorMessage;

  /// The error message for invalid author value
  ///
  /// In en, this message translates to:
  /// **'Invalid date/interval and person name'**
  String get mpAuthorInvalidValueErrorMessage;

  /// The label for the azimuth type
  ///
  /// In en, this message translates to:
  /// **'Azimuth'**
  String get mpAzimuthAzimuthLabel;

  /// The error message for invalid azimuth value
  ///
  /// In en, this message translates to:
  /// **'Invalid azimuth'**
  String get mpAzimuthInvalidErrorMessage;

  /// The label for the north azimuth
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get mpAzimuthNorth;

  /// The label for the south azimuth
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get mpAzimuthSouth;

  /// The label for the east azimuth
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get mpAzimuthEast;

  /// The label for the west azimuth
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get mpAzimuthWest;

  /// The abbreviation for the north azimuth
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get mpAzimuthNorthAbbreviation;

  /// The abbreviation for the south azimuth
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get mpAzimuthSouthAbbreviation;

  /// The abbreviation for the east azimuth
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get mpAzimuthEastAbbreviation;

  /// The abbreviation for the west azimuth
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get mpAzimuthWestAbbreviation;

  /// The label for the cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mpButtonCancel;

  /// The label for the OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get mpButtonOK;

  /// The label for the set choice type
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get mpChoiceSet;

  /// The label for the unset choice type
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get mpChoiceUnset;

  /// The description for the add area command
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get mpCommandDescriptionAddArea;

  /// The description for the add area border line command
  ///
  /// In en, this message translates to:
  /// **'Add area border line'**
  String get mpCommandDescriptionAddAreaBorderTHID;

  /// The description for the add elements command
  ///
  /// In en, this message translates to:
  /// **'Add elements'**
  String get mpCommandDescriptionAddElements;

  /// The description for the add line command
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get mpCommandDescriptionAddLine;

  /// The description for the add line segment command
  ///
  /// In en, this message translates to:
  /// **'Add line segment'**
  String get mpCommandDescriptionAddLineSegment;

  /// The description for the add point command
  ///
  /// In en, this message translates to:
  /// **'Add point'**
  String get mpCommandDescriptionAddPoint;

  /// The description for the edit areas type command
  ///
  /// In en, this message translates to:
  /// **'Edit multiple areas type'**
  String get mpCommandDescriptionEditAreasType;

  /// The description for the edit area type command
  ///
  /// In en, this message translates to:
  /// **'Edit area type'**
  String get mpCommandDescriptionEditAreaType;

  /// The description for the edit Bézier curve command
  ///
  /// In en, this message translates to:
  /// **'Edit Bézier curve'**
  String get mpCommandDescriptionEditBezierCurve;

  /// The description for the edit line command
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get mpCommandDescriptionEditLine;

  /// The description for the edit line segment command
  ///
  /// In en, this message translates to:
  /// **'Edit line segment'**
  String get mpCommandDescriptionEditLineSegment;

  /// The description for the edit line segments type command
  ///
  /// In en, this message translates to:
  /// **'Edit multiple line segments type'**
  String get mpCommandDescriptionEditLineSegmentsType;

  /// The description for the edit line segment type command
  ///
  /// In en, this message translates to:
  /// **'Edit line segment type'**
  String get mpCommandDescriptionEditLineSegmentType;

  /// The description for the edit lines type command
  ///
  /// In en, this message translates to:
  /// **'Edit multiple lines type'**
  String get mpCommandDescriptionEditLinesType;

  /// The description for the edit line type command
  ///
  /// In en, this message translates to:
  /// **'Edit line type'**
  String get mpCommandDescriptionEditLineType;

  /// The description for the edit points type command
  ///
  /// In en, this message translates to:
  /// **'Edit multiple points type'**
  String get mpCommandDescriptionEditPointsType;

  /// The description for the edit point type command
  ///
  /// In en, this message translates to:
  /// **'Edit point type'**
  String get mpCommandDescriptionEditPointType;

  /// The description for the move area command
  ///
  /// In en, this message translates to:
  /// **'Move area'**
  String get mpCommandDescriptionMoveArea;

  /// The description for the move Bézier line segment command
  ///
  /// In en, this message translates to:
  /// **'Move Bézier line segment'**
  String get mpCommandDescriptionMoveBezierLineSegment;

  /// The description for the move elements command
  ///
  /// In en, this message translates to:
  /// **'Move elements'**
  String get mpCommandDescriptionMoveElements;

  /// The description for the move line command
  ///
  /// In en, this message translates to:
  /// **'Move line'**
  String get mpCommandDescriptionMoveLine;

  /// The description for the move lines command
  ///
  /// In en, this message translates to:
  /// **'Move lines'**
  String get mpCommandDescriptionMoveLines;

  /// The description for the move line segments command
  ///
  /// In en, this message translates to:
  /// **'Move line segments'**
  String get mpCommandDescriptionMoveLineSegments;

  /// The description for the move point command
  ///
  /// In en, this message translates to:
  /// **'Move point'**
  String get mpCommandDescriptionMovePoint;

  /// The description for the move straight line segment command
  ///
  /// In en, this message translates to:
  /// **'Move straight line segment'**
  String get mpCommandDescriptionMoveStraightLineSegment;

  /// The description for the multiple elements edit command
  ///
  /// In en, this message translates to:
  /// **'Multiple elements edit'**
  String get mpCommandDescriptionMultipleElements;

  /// The description for the remove area command
  ///
  /// In en, this message translates to:
  /// **'Remove area'**
  String get mpCommandDescriptionRemoveArea;

  /// The description for the remove area border line command
  ///
  /// In en, this message translates to:
  /// **'Remove area border line'**
  String get mpCommandDescriptionRemoveAreaBorderTHID;

  /// The description for the remove elements command
  ///
  /// In en, this message translates to:
  /// **'Remove elements'**
  String get mpCommandDescriptionRemoveElements;

  /// The description for the remove line command
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get mpCommandDescriptionRemoveLine;

  /// The description for the remove line segment command
  ///
  /// In en, this message translates to:
  /// **'Remove line segment'**
  String get mpCommandDescriptionRemoveLineSegment;

  /// The description for the remove line segments command
  ///
  /// In en, this message translates to:
  /// **'Remove line segments'**
  String get mpCommandDescriptionRemoveLineSegments;

  /// The description for the remove option command
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get mpCommandDescriptionRemoveOptionFromElement;

  /// The description for the remove option from elements command
  ///
  /// In en, this message translates to:
  /// **'Remove option from multiple elements'**
  String get mpCommandDescriptionRemoveOptionFromElements;

  /// The description for the remove point command
  ///
  /// In en, this message translates to:
  /// **'Remove point'**
  String get mpCommandDescriptionRemovePoint;

  /// The description for the set option command
  ///
  /// In en, this message translates to:
  /// **'Set option'**
  String get mpCommandDescriptionSetOptionToElement;

  /// The description for the set option to elements command
  ///
  /// In en, this message translates to:
  /// **'Set option to multiple elements'**
  String get mpCommandDescriptionSetOptionToElements;

  /// The error message for invalid context value
  ///
  /// In en, this message translates to:
  /// **'Both fields are mandatory'**
  String get mpContextInvalidValueErrorMessage;

  /// The error message for invalid copyright value
  ///
  /// In en, this message translates to:
  /// **'Invalid copyright message'**
  String get mpCopyrightInvalidMessageErrorMessage;

  /// The label for the copyright message
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get mpCopyrightMessageLabel;

  /// The label for the CS EPSG SGRI option
  ///
  /// In en, this message translates to:
  /// **'{csOption} identifier (1-99999)'**
  String mpCSEPSGESRILabel(Object csOption);

  /// The label for the CS ETRS option
  ///
  /// In en, this message translates to:
  /// **'Optional ETRS identifier (28-37)'**
  String get mpCSETRSLabel;

  /// The error message for invalid CS value
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get mpCSInvalidValueErrorMessage;

  /// The label for the CS for output option
  ///
  /// In en, this message translates to:
  /// **'For output'**
  String get mpCSForOutputLabel;

  /// The label for the CS OSGB major option
  ///
  /// In en, this message translates to:
  /// **'OSGB major'**
  String get mpCSOSGBMajorLabel;

  /// The label for the CS OSGB minor option
  ///
  /// In en, this message translates to:
  /// **'OSGB minor'**
  String get mpCSOSGBMinorLabel;

  /// The label for the CS UTM zone number option
  ///
  /// In en, this message translates to:
  /// **'Zone number (1-60)'**
  String get mpCSUTMZoneNumberLabel;

  /// The hint for the end date field in the date interval dialog
  ///
  /// In en, this message translates to:
  /// **'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]'**
  String get mpDateIntervalEndDateHint;

  /// The label for the end date type
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get mpDateIntervalEndDateLabel;

  /// The label for the interval date type
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get mpDateIntervalIntervalLabel;

  /// The error message for invalid end date format
  ///
  /// In en, this message translates to:
  /// **'Invalid end date'**
  String get mpDateIntervalInvalidEndDateFormatErrorMessage;

  /// The error message for invalid start date format
  ///
  /// In en, this message translates to:
  /// **'Invalid start date'**
  String get mpDateIntervalInvalidStartDateFormatErrorMessage;

  /// The label for the single date type
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mpDateIntervalSingleDateLabel;

  /// The hint for the start date field in the date interval dialog
  ///
  /// In en, this message translates to:
  /// **'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] or \'-\''**
  String get mpDateIntervalStartDateHint;

  /// The label for the start date type
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get mpDateIntervalStartDateLabel;

  /// The error message for invalid date value
  ///
  /// In en, this message translates to:
  /// **'Invalid date/interval'**
  String get mpDateValueInvalidValueErrorMessage;

  /// The label for the above dimension type
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get mpDimensionsAboveLabel;

  /// The label for the below dimension type
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get mpDimensionsBelowLabel;

  /// The error message for invalid dimensions value
  ///
  /// In en, this message translates to:
  /// **'Invalid dimension value'**
  String get mpDimensionsInvalidValueErrorMessage;

  /// The error message for invalid distance value
  ///
  /// In en, this message translates to:
  /// **'Invalid numeric distance value'**
  String get mpDistInvalidValueErrorMessage;

  /// The label for the distance type
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get mpDistDistanceLabel;

  /// The error message for invalid double value
  ///
  /// In en, this message translates to:
  /// **'Invalid numeric value'**
  String get mpDoubleValueInvalidValueErrorMessage;

  /// The label for the explored length type
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get mpExploredLengthLabel;

  /// The label for the extend station type
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpExtendStationLabel;

  /// The label for the ID type
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get mpIDIDLabel;

  /// The error message for invalid ID value
  ///
  /// In en, this message translates to:
  /// **'Invalid ID'**
  String get mpIDInvalidValueErrorMessage;

  /// The error message for non-unique ID value
  ///
  /// In en, this message translates to:
  /// **'ID must be unique'**
  String get mpIDNonUniqueValueErrorMessage;

  /// The description for the centimeter length unit
  ///
  /// In en, this message translates to:
  /// **'centimeter'**
  String get mpLengthUnitCentimeter;

  /// The abbreviation for the centimeter length unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get mpLengthUnitCentimeterAbbreviation;

  /// The description for the foot length unit
  ///
  /// In en, this message translates to:
  /// **'feet'**
  String get mpLengthUnitFoot;

  /// The abbreviation for the foot length unit
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get mpLengthUnitFootAbbreviation;

  /// The description for the inch length unit
  ///
  /// In en, this message translates to:
  /// **'inch'**
  String get mpLengthUnitInch;

  /// The abbreviation for the inch length unit
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get mpLengthUnitInchAbbreviation;

  /// The description for the meter length unit
  ///
  /// In en, this message translates to:
  /// **'meter'**
  String get mpLengthUnitMeter;

  /// The abbreviation for the meter length unit
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get mpLengthUnitMeterAbbreviation;

  /// The description for the yard length unit
  ///
  /// In en, this message translates to:
  /// **'yard'**
  String get mpLengthUnitYard;

  /// The abbreviation for the yard length unit
  ///
  /// In en, this message translates to:
  /// **'yd'**
  String get mpLengthUnitYardAbbreviation;

  /// The error message for invalid line height value
  ///
  /// In en, this message translates to:
  /// **'Invalid line height'**
  String get mpLineHeightInvalidValueErrorMessage;

  /// The label for the height type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpLineHeightHeightLabel;

  /// The title for the line segment type
  ///
  /// In en, this message translates to:
  /// **'Line segment type'**
  String get mpLineSegmentTypeTypesTitle;

  /// The label for the size type
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get mpLSizeLabel;

  /// The label for the mark text type
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mpMarkTextLabel;

  /// The label for the all choice in the multiple elements clicked dialog
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mpMultipleElementsClickedAllChoice;

  /// The title for the multiple elements clicked dialog
  ///
  /// In en, this message translates to:
  /// **'Multiple elements clicked'**
  String get mpMultipleElementsClickedTitle;

  /// The title for the multiple end control points clicked dialog
  ///
  /// In en, this message translates to:
  /// **'Multiple points clicked'**
  String get mpMultipleEndControlPointsClickedTitle;

  /// The label for the control point 1 in the multiple end control points dialog
  ///
  /// In en, this message translates to:
  /// **'Control point 1'**
  String get mpMultipleEndControlPointsControlPoint1;

  /// The label for the control point 2 in the multiple end control points dialog
  ///
  /// In en, this message translates to:
  /// **'Control point 2'**
  String get mpMultipleEndControlPointsControlPoint2;

  /// The label for the end point in the multiple end control points dialog
  ///
  /// In en, this message translates to:
  /// **'End point'**
  String get mpMultipleEndControlPointsEndPoint;

  /// The label for the tiny named scale
  ///
  /// In en, this message translates to:
  /// **'Tiny'**
  String get mpNamedScaleTiny;

  /// The label for the small named scale
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get mpNamedScaleSmall;

  /// The label for the normal named scale
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get mpNamedScaleNormal;

  /// The label for the large named scale
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get mpNamedScaleLarge;

  /// The label for the huge named scale
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get mpNamedScaleHuge;

  /// The label for the name station type
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpNameStationLabel;

  /// The label for the line segment types in the options edit dialog
  ///
  /// In en, this message translates to:
  /// **'Line segments types'**
  String get mpOptionsEditLineSegmentTypes;

  /// The label for the ceiling type
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get mpPassageHeightCeiling;

  /// The label for the ceiling type
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get mpPassageHeightCeilingLabel;

  /// The label for the depth type
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPassageHeightDepth;

  /// The warning message for invalid depth
  ///
  /// In en, this message translates to:
  /// **'Invalid depth'**
  String get mpPassageHeightDepthWarning;

  /// The label for the depth type
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPassageHeightDepthLabel;

  /// The label for the distance between floor and ceiling type
  ///
  /// In en, this message translates to:
  /// **'Distance floor ceiling'**
  String get mpPassageHeightDistanceBetweenFloorAndCeiling;

  /// The label for the distance between floor and ceiling type
  ///
  /// In en, this message translates to:
  /// **'Floor to ceiling'**
  String get mpPassageHeightDistanceBetweenFloorAndCeilingLabel;

  /// The label for the distance to ceiling and distance to floor type
  ///
  /// In en, this message translates to:
  /// **'Distance to ceiling and to floor'**
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloor;

  /// The label for the distance to ceiling and distance to floor type
  ///
  /// In en, this message translates to:
  /// **'To ceiling/to floor'**
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloorLabel;

  /// The label for the floor type
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get mpPassageHeightFloor;

  /// The label for the floor type
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get mpPassageHeightFloorLabel;

  /// The label for the height type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPassageHeightHeight;

  /// The label for the height type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPassageHeightHeightLabel;

  /// The warning message for invalid height
  ///
  /// In en, this message translates to:
  /// **'Invalid height'**
  String get mpPassageHeightHeightWarning;

  /// The error message for invalid person name format
  ///
  /// In en, this message translates to:
  /// **'Invalid person name'**
  String get mpPersonNameInvalidFormatErrorMessage;

  /// The label for the name field in the person name dialog
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mpPersonNameLabel;

  /// The hint for the name field in the person name dialog
  ///
  /// In en, this message translates to:
  /// **'\'FirstName Surname\' or \'FirstNames/Surnames\''**
  String get mpPersonNameHint;

  /// The label for the all type
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mpPLATypeAll;

  /// The title for the area types
  ///
  /// In en, this message translates to:
  /// **'Area types'**
  String get mpPLATypeAreaTitle;

  /// The label for the current type
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get mpPLATypeCurrent;

  /// The label for the dropdown select a type
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get mpPLATypeDropdownSelectATypeLabel;

  /// The label for the last used type
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get mpPLATypeLastUsed;

  /// The title for the line types
  ///
  /// In en, this message translates to:
  /// **'Line types'**
  String get mpPLATypeLineTitle;

  /// The label for the most used type
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get mpPLATypeMostUsed;

  /// The title for the point types
  ///
  /// In en, this message translates to:
  /// **'Point types'**
  String get mpPLATypePointTitle;

  /// The label for the named scale option
  ///
  /// In en, this message translates to:
  /// **'Named'**
  String get mpPLScaleCommandOptionNamed;

  /// The label for the numeric scale option
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get mpPLScaleCommandOptionNumeric;

  /// The label for the numeric scale type
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get mpPLScaleNumericLabel;

  /// The label for the chimney type
  ///
  /// In en, this message translates to:
  /// **'Chimney'**
  String get mpPointHeightChimney;

  /// The label for the chimney height type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPointHeightValueChimneyLabel;

  /// The warning message for invalid length
  ///
  /// In en, this message translates to:
  /// **'Invalid length'**
  String get mpPointHeightLengthWarning;

  /// The label for the pit type
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get mpPointHeightPit;

  /// The label for the pit depth type
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPointHeightValuePitLabel;

  /// The label for the step type
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get mpPointHeightStep;

  /// The label for the step height type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPointHeightValueStepLabel;

  /// The label for the height observation type
  ///
  /// In en, this message translates to:
  /// **'Chimeny height (treated as positive)'**
  String get mpPointHeightValueChimneyObservation;

  /// The label for the depth observation type
  ///
  /// In en, this message translates to:
  /// **'Pit depth (treated as negative)'**
  String get mpPointHeightValuePitObservation;

  /// The label for the step observation type
  ///
  /// In en, this message translates to:
  /// **'Step height (treated as positive)'**
  String get mpPointHeightValueStepObservation;

  /// The warning message for invalid angle
  ///
  /// In en, this message translates to:
  /// **'Invalid angle (0 <= angle < 360)'**
  String get mpProjectionAngleWarning;

  /// The label for the azimuth type
  ///
  /// In en, this message translates to:
  /// **'Azimuth'**
  String get mpProjectionElevationAzimuthLabel;

  /// The label for the index type
  ///
  /// In en, this message translates to:
  /// **'Index (optional)'**
  String get mpProjectionIndexLabel;

  /// The label for the elevation projection mode
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get mpProjectionModeElevation;

  /// The label for the extended projection mode
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get mpProjectionModeExtended;

  /// The label for the none projection mode
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mpProjectionModeNone;

  /// The label for the plan projection mode
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get mpProjectionModePlan;

  /// The title for the options edit dialog
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get mpOptionsEditTitle;

  /// The label for the real to 1 point type
  ///
  /// In en, this message translates to:
  /// **'Real to 1 point'**
  String get mpScrapScale1ValueLabel;

  /// The label for the real units per drawing point observation type
  ///
  /// In en, this message translates to:
  /// **'Real units per drawing point'**
  String get mpScrapScale1ValueObservation;

  /// The label for the real units per drawing point type
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get mpScrapScale11Label;

  /// The label for the real to points type
  ///
  /// In en, this message translates to:
  /// **'Real to points'**
  String get mpScrapScale2ValuesLabel;

  /// The label for the real units per drawing points observation type
  ///
  /// In en, this message translates to:
  /// **'real units per drawing points'**
  String get mpScrapScale2ValueObservation;

  /// The label for the drawing units per drawing point type
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get mpScrapScale21Label;

  /// The label for the real units per drawing point type
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get mpScrapScale22Label;

  /// The label for the real to drawing coordinates type
  ///
  /// In en, this message translates to:
  /// **'Real to drawing coordinates'**
  String get mpScrapScale8ValuesLabel;

  /// The label for the real coordinates per drawing coordinates observation type
  ///
  /// In en, this message translates to:
  /// **'Real coordinates per drawing coordinates'**
  String get mpScrapScale8ValueObservation;

  /// The label for the drawing X1 type
  ///
  /// In en, this message translates to:
  /// **'Draw X1'**
  String get mpScrapScale81Label;

  /// The label for the drawing Y1 type
  ///
  /// In en, this message translates to:
  /// **'Draw Y1'**
  String get mpScrapScale82Label;

  /// The label for the drawing X2 type
  ///
  /// In en, this message translates to:
  /// **'Draw X2'**
  String get mpScrapScale83Label;

  /// The label for the drawing Y2 type
  ///
  /// In en, this message translates to:
  /// **'Draw Y2'**
  String get mpScrapScale84Label;

  /// The label for the real X1 type
  ///
  /// In en, this message translates to:
  /// **'Real X1'**
  String get mpScrapScale85Label;

  /// The label for the real Y1 type
  ///
  /// In en, this message translates to:
  /// **'Real Y1'**
  String get mpScrapScale86Label;

  /// The label for the real X2 type
  ///
  /// In en, this message translates to:
  /// **'Real X2'**
  String get mpScrapScale87Label;

  /// The label for the real Y2 type
  ///
  /// In en, this message translates to:
  /// **'Real Y2'**
  String get mpScrapScale88Label;

  /// The label for the free text scrap type
  ///
  /// In en, this message translates to:
  /// **'Free text'**
  String get mpScrapFreeText;

  /// The label for the from file scrap type
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get mpScrapFromFile;

  /// The error message for invalid scale reference
  ///
  /// In en, this message translates to:
  /// **'Invalid scale ref'**
  String get mpScrapScaleInvalidValueError;

  /// The label for the scrap ID type
  ///
  /// In en, this message translates to:
  /// **'Scrap ID'**
  String get mpScrapLabel;

  /// The warning message for the scrap option
  ///
  /// In en, this message translates to:
  /// **'Scrap not set'**
  String get mpScrapWarning;

  /// The label for the choose file button
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get mpSketchChooseFileButtonLabel;

  /// The error message for invalid coordinate
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinate'**
  String get mpSketchCoordinateInvalid;

  /// The label for the filename type
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get mpSketchFilenameLabel;

  /// The label for the X coordinate type
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get mpSketchXLabel;

  /// The label for the Y coordinate type
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get mpSketchYLabel;

  /// The label for the station names prefix type
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get mpStationNamesPrefixLabel;

  /// The error message for empty station names prefix
  ///
  /// In en, this message translates to:
  /// **'Prefix empty'**
  String get mpStationNamesPrefixMessageEmpty;

  /// The label for the station names suffix type
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get mpStationNamesSuffixLabel;

  /// The error message for empty station names suffix
  ///
  /// In en, this message translates to:
  /// **'Suffix empty'**
  String get mpStationNamesSuffixMessageEmpty;

  /// The label for the add field button
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get mpStationsAddField;

  /// The error message for empty station name
  ///
  /// In en, this message translates to:
  /// **'Station name empty'**
  String get mpStationsNameEmpty;

  /// The label for the station name type
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpStationsNameLabel;

  /// The warning message for the station type option
  ///
  /// In en, this message translates to:
  /// **'Station not set'**
  String get mpStationTypeOptionWarning;

  /// The error message for empty subtype
  ///
  /// In en, this message translates to:
  /// **'Subtype empty'**
  String get mpSubtypeEmpty;

  /// The label for the subtype type
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get mpSubtypeLabel;

  /// The label for the winter subtype
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get mpSubtypePointAirDraughtWinter;

  /// The label for the summer subtype
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get mpSubtypePointAirDraughtSummer;

  /// The label for the undefined subtype
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get mpSubtypePointAirDraughtUndefined;

  /// The label for the temporary subtype
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get mpSubtypePointStationTemporary;

  /// The label for the painted subtype
  ///
  /// In en, this message translates to:
  /// **'Painted'**
  String get mpSubtypePointStationPainted;

  /// The label for the natural subtype
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get mpSubtypePointStationNatural;

  /// The label for the fixed subtype
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get mpSubtypePointStationFixed;

  /// The label for the permanent water flow subtype
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get mpSubtypePointWaterFlowPermanent;

  /// The label for the intermittent water flow subtype
  ///
  /// In en, this message translates to:
  /// **'Intermittent'**
  String get mpSubtypePointWaterFlowIntermittent;

  /// The label for the paleo water flow subtype
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get mpSubtypePointWaterFlowPaleo;

  /// The label for the invisible border subtype
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get mpSubtypeLineBorderInvisible;

  /// The label for the presumed border subtype
  ///
  /// In en, this message translates to:
  /// **'Presumed'**
  String get mpSubtypeLineBorderPresumed;

  /// The label for the temporary border subtype
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get mpSubtypeLineBorderTemporary;

  /// The label for the visible border subtype
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get mpSubtypeLineBorderVisible;

  /// The label for the cave survey subtype
  ///
  /// In en, this message translates to:
  /// **'Cave'**
  String get mpSubtypeLineSurveyCave;

  /// The label for the surface survey subtype
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get mpSubtypeLineSurveySurface;

  /// The label for the bedrock wall subtype
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get mpSubtypeLineWallBedrock;

  /// The label for the blocks wall subtype
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get mpSubtypeLineWallBlocks;

  /// The label for the clay wall subtype
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get mpSubtypeLineWallClay;

  /// The label for the debris wall subtype
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get mpSubtypeLineWallDebris;

  /// The label for the flowstone wall subtype
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get mpSubtypeLineWallFlowstone;

  /// The label for the ice wall subtype
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get mpSubtypeLineWallIce;

  /// The label for the invisible wall subtype
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get mpSubtypeLineWallInvisible;

  /// The label for the moonmilk wall subtype
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get mpSubtypeLineWallMoonmilk;

  /// The label for the overlying wall subtype
  ///
  /// In en, this message translates to:
  /// **'Overlying'**
  String get mpSubtypeLineWallOverlying;

  /// The label for the pebbles wall subtype
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get mpSubtypeLineWallPebbles;

  /// The label for the pit wall subtype
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get mpSubtypeLineWallPit;

  /// The label for the presumed wall subtype
  ///
  /// In en, this message translates to:
  /// **'Presumed'**
  String get mpSubtypeLineWallPresumed;

  /// The label for the sand wall subtype
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get mpSubtypeLineWallSand;

  /// The label for the underlying wall subtype
  ///
  /// In en, this message translates to:
  /// **'Underlying'**
  String get mpSubtypeLineWallUnderlying;

  /// The label for the unsurveyed wall subtype
  ///
  /// In en, this message translates to:
  /// **'Unsurveyed'**
  String get mpSubtypeLineWallUnsurveyed;

  /// The label for the permanent water flow line subtype
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get mpSubtypeLineWaterFlowPermanent;

  /// The label for the conjectural water flow line subtype
  ///
  /// In en, this message translates to:
  /// **'Conjectural'**
  String get mpSubtypeLineWaterFlowConjectural;

  /// The label for the intermittent water flow line subtype
  ///
  /// In en, this message translates to:
  /// **'Intermittent'**
  String get mpSubtypeLineWaterFlowIntermittent;

  /// The label for the text type
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get mpTextTextLabel;

  /// The warning message for the text type option
  ///
  /// In en, this message translates to:
  /// **'Text not set'**
  String get mpTextTypeOptionWarning;

  /// The label for the title type
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mpTitleTextLabel;

  /// The label for the unrecognized command option
  ///
  /// In en, this message translates to:
  /// **'Unrecognized option'**
  String get mpUnrecognizedCommandOptionTextLabel;

  /// The label for the parsing errors dialog
  ///
  /// In en, this message translates to:
  /// **'Parsing errors'**
  String get parsingErrors;

  /// The title for the TH2 File Edit help dialog
  ///
  /// In en, this message translates to:
  /// **'TH2 File Edit Help'**
  String get th2FileEditPageHelpDialogTitle;

  /// The label for the add area button
  ///
  /// In en, this message translates to:
  /// **'Add area (A)'**
  String get th2FileEditPageAddArea;

  /// The status bar message for the add area tool
  ///
  /// In en, this message translates to:
  /// **'Click to add a {type} area'**
  String th2FileEditPageAddAreaStatusBarMessage(Object type);

  /// The label for the add element options button
  ///
  /// In en, this message translates to:
  /// **'Add element'**
  String get th2FileEditPageAddElementOptions;

  /// The label for the add line button
  ///
  /// In en, this message translates to:
  /// **'Add line (L)'**
  String get th2FileEditPageAddLine;

  /// The status bar message for the add line tool
  ///
  /// In en, this message translates to:
  /// **'Click to add a {type} line'**
  String th2FileEditPageAddLineStatusBarMessage(Object type);

  /// The label for the add point button
  ///
  /// In en, this message translates to:
  /// **'Add point (P)'**
  String get th2FileEditPageAddPoint;

  /// The status bar message for the add point tool
  ///
  /// In en, this message translates to:
  /// **'Click to add a {type} point'**
  String th2FileEditPageAddPointStatusBarMessage(Object type);

  /// The label for the change active scrap tool button
  ///
  /// In en, this message translates to:
  /// **'Change active scrap (Alt+C)'**
  String get th2FileEditPageChangeActiveScrapTool;

  /// The title for the change active scrap dialog
  ///
  /// In en, this message translates to:
  /// **'Change active scrap'**
  String get th2FileEditPageChangeActiveScrapTitle;

  /// The status bar message for the empty selection
  ///
  /// In en, this message translates to:
  /// **'Empty selection'**
  String get th2FileEditPageEmptySelectionStatusBarMessage;

  /// The label for the loading file message
  ///
  /// In en, this message translates to:
  /// **'Loading file {filename} ...'**
  String th2FileEditPageLoadingFile(Object filename);

  /// The label for the node edit tool button
  ///
  /// In en, this message translates to:
  /// **'Node edit (N)'**
  String get th2FileEditPageNodeEditTool;

  /// The label for only lines selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{amount} line(s) selected'**
  String th2FileEditPageNonEmptySelectionOnlyLinesStatusBarMessage(
      Object amount);

  /// The label for only points selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{amount} point(s) selected'**
  String th2FileEditPageNonEmptySelectionOnlyPointsStatusBarMessage(
      Object amount);

  /// The label for points and lines selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{pointsAmount} point(s) and {linesAmount} line(s) selected'**
  String th2FileEditPageNonEmptySelectionPointsAndLinesStatusBarMessage(
      Object pointsAmount, Object linesAmount);

  /// The label for the no undo available message
  ///
  /// In en, this message translates to:
  /// **'No undo available'**
  String get th2FileEditPageNoUndoAvailable;

  /// The label for the no redo available message
  ///
  /// In en, this message translates to:
  /// **'No redo available'**
  String get th2FileEditPageNoRedoAvailable;

  /// The label for the option tool button
  ///
  /// In en, this message translates to:
  /// **'Option edit (O)'**
  String get th2FileEditPageOptionTool;

  /// The label for the pan tool button
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get th2FileEditPagePanTool;

  /// The label for the remove tool button
  ///
  /// In en, this message translates to:
  /// **'Remove (Del)'**
  String get th2FileEditPageRemoveButton;

  /// The label for the save button
  ///
  /// In en, this message translates to:
  /// **'Save (Ctrl+S)'**
  String get th2FileEditPageSave;

  /// The label for the save as button
  ///
  /// In en, this message translates to:
  /// **'Save as (Shift+Ctrl+S)'**
  String get th2FileEditPageSaveAs;

  /// The label for the redo shortcut
  ///
  /// In en, this message translates to:
  /// **'Redo \'{redoDescription}\' (Ctrl+Y)'**
  String th2FileEditPageRedo(Object redoDescription);

  /// The label for the select tool button
  ///
  /// In en, this message translates to:
  /// **'Select (C)'**
  String get th2FileEditPageSelectTool;

  /// The label for the undo shortcut
  ///
  /// In en, this message translates to:
  /// **'Undo \'{undoDescription}\' (Ctrl+Z)'**
  String th2FileEditPageUndo(Object undoDescription);

  /// The label for the zoom in button
  ///
  /// In en, this message translates to:
  /// **'Zoom In (+)'**
  String get th2FileEditPageZoomIn;

  /// The label for the zoom 1:1 button
  ///
  /// In en, this message translates to:
  /// **'Zoom 1:1 (1)'**
  String get th2FileEditPageZoomOneToOne;

  /// The label for the zoom options button
  ///
  /// In en, this message translates to:
  /// **'Zoom Options'**
  String get th2FileEditPageZoomOptions;

  /// The label for the zoom out button
  ///
  /// In en, this message translates to:
  /// **'Zoom Out (-)'**
  String get th2FileEditPageZoomOut;

  /// The label for the show file zoom button
  ///
  /// In en, this message translates to:
  /// **'Show file (3)'**
  String get th2FileEditPageZoomOutFile;

  /// The label for the show scrap zoom button
  ///
  /// In en, this message translates to:
  /// **'Show scrap (4)'**
  String get th2FileEditPageZoomOutScrap;

  /// The label for the zoom to selection button
  ///
  /// In en, this message translates to:
  /// **'Zoom to selection (2)'**
  String get th2FileEditPageZoomToSelection;

  /// The label for the TH2 file selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select a TH2 file'**
  String get th2FilePickSelectTH2File;

  /// The label for the bedrock area type
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get thAreaBedrock;

  /// The label for the blocks area type
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get thAreaBlocks;

  /// The label for the clay area type
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get thAreaClay;

  /// The label for the debris area type
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get thAreaDebris;

  /// The label for the flowstone area type
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thAreaFlowstone;

  /// The label for the ice area type
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get thAreaIce;

  /// The label for the moonmilk area type
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thAreaMoonmilk;

  /// The label for the mudcrack area type
  ///
  /// In en, this message translates to:
  /// **'Mudcrack'**
  String get thAreaMudcrack;

  /// The label for the pebbles area type
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get thAreaPebbles;

  /// The label for the pillar area type
  ///
  /// In en, this message translates to:
  /// **'Pillar'**
  String get thAreaPillar;

  /// The label for the pillars area type
  ///
  /// In en, this message translates to:
  /// **'Pillars'**
  String get thAreaPillars;

  /// The label for the pillars with curtains area type
  ///
  /// In en, this message translates to:
  /// **'Pillars with Curtains'**
  String get thAreaPillarsWithCurtains;

  /// The label for the pillar with curtains area type
  ///
  /// In en, this message translates to:
  /// **'Pillar with Curtains'**
  String get thAreaPillarWithCurtains;

  /// The label for the sand area type
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get thAreaSand;

  /// The label for the snow area type
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get thAreaSnow;

  /// The label for the stalactite area type
  ///
  /// In en, this message translates to:
  /// **'Stalactite'**
  String get thAreaStalactite;

  /// The label for the stalactite-stalagmite area type
  ///
  /// In en, this message translates to:
  /// **'Stalactite-Stalagmite'**
  String get thAreaStalactiteStalagmite;

  /// The label for the stalagmite area type
  ///
  /// In en, this message translates to:
  /// **'Stalagmite'**
  String get thAreaStalagmite;

  /// The label for the sump area type
  ///
  /// In en, this message translates to:
  /// **'Sump'**
  String get thAreaSump;

  /// The label for the user defined area type
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get thAreaU;

  /// The label for the water area type
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get thAreaWater;

  /// The label for the area element type
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get thElementArea;

  /// The label for the area border ID element type
  ///
  /// In en, this message translates to:
  /// **'Area border ID'**
  String get thElementAreaBorderTHID;

  /// The label for the Bézier curve line segment element type
  ///
  /// In en, this message translates to:
  /// **'Bézier curve line segment'**
  String get thElementBezierCurveLineSegment;

  /// The label for the comment element type
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get thElementComment;

  /// The label for the empty line element type
  ///
  /// In en, this message translates to:
  /// **'Empty line'**
  String get thElementEmptyLine;

  /// The label for the encoding element type
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get thElementEncoding;

  /// The label for the end area element type
  ///
  /// In en, this message translates to:
  /// **'End area'**
  String get thElementEndArea;

  /// The label for the end comment element type
  ///
  /// In en, this message translates to:
  /// **'End comment'**
  String get thElementEndComment;

  /// The label for the end line element type
  ///
  /// In en, this message translates to:
  /// **'End line'**
  String get thElementEndLine;

  /// The label for the end scrap element type
  ///
  /// In en, this message translates to:
  /// **'End scrap'**
  String get thElementEndScrap;

  /// The label for the line element type
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get thElementLine;

  /// The label for the line segment element type
  ///
  /// In en, this message translates to:
  /// **'Line segment'**
  String get thElementLineSegment;

  /// The label for the multiline comment content element type
  ///
  /// In en, this message translates to:
  /// **'Multiline comment content'**
  String get thElementMultilineCommentContent;

  /// The label for the multiline comment element type
  ///
  /// In en, this message translates to:
  /// **'Multiline comment'**
  String get thElementMultilineComment;

  /// The label for the point element type
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get thElementPoint;

  /// The label for the scrap element type
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get thElementScrap;

  /// The label for the straight line segment element type
  ///
  /// In en, this message translates to:
  /// **'Straight line segment'**
  String get thElementStraightLineSegment;

  /// The label for the unrecognized element type
  ///
  /// In en, this message translates to:
  /// **'Unrecognized '**
  String get thElementUnrecognized;

  /// The label for the XTherion config element type
  ///
  /// In en, this message translates to:
  /// **'XTherion config'**
  String get thElementXTherionConfig;

  /// The label for the air draught point type
  ///
  /// In en, this message translates to:
  /// **'Air draught'**
  String get thPointAirDraught;

  /// The label for the altar point type
  ///
  /// In en, this message translates to:
  /// **'Altar'**
  String get thPointAltar;

  /// The label for the altitude point type
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thPointAltitude;

  /// The label for the anastomosis point type
  ///
  /// In en, this message translates to:
  /// **'Anastomosis'**
  String get thPointAnastomosis;

  /// The label for the anchor point type
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get thPointAnchor;

  /// The label for the aragonite point type
  ///
  /// In en, this message translates to:
  /// **'Aragonite'**
  String get thPointAragonite;

  /// The label for the archeo excavation point type
  ///
  /// In en, this message translates to:
  /// **'Archeo Excavation'**
  String get thPointArcheoExcavation;

  /// The label for the archeo material point type
  ///
  /// In en, this message translates to:
  /// **'Archeo Material'**
  String get thPointArcheoMaterial;

  /// The label for the audio point type
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get thPointAudio;

  /// The label for the bat point type
  ///
  /// In en, this message translates to:
  /// **'Bat'**
  String get thPointBat;

  /// The label for the bedrock point type
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get thPointBedrock;

  /// The label for the blocks point type
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get thPointBlocks;

  /// The label for the bones point type
  ///
  /// In en, this message translates to:
  /// **'Bones'**
  String get thPointBones;

  /// The label for the breakdown choke point type
  ///
  /// In en, this message translates to:
  /// **'Breakdown Choke'**
  String get thPointBreakdownChoke;

  /// The label for the bridge point type
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get thPointBridge;

  /// The label for the camp point type
  ///
  /// In en, this message translates to:
  /// **'Camp'**
  String get thPointCamp;

  /// The label for the cave pearl point type
  ///
  /// In en, this message translates to:
  /// **'Cave Pearl'**
  String get thPointCavePearl;

  /// The label for the clay point type
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get thPointClay;

  /// The label for the clay choke point type
  ///
  /// In en, this message translates to:
  /// **'Clay Choke'**
  String get thPointClayChoke;

  /// The label for the clay tree point type
  ///
  /// In en, this message translates to:
  /// **'Clay Tree'**
  String get thPointClayTree;

  /// The label for the continuation point type
  ///
  /// In en, this message translates to:
  /// **'Continuation'**
  String get thPointContinuation;

  /// The label for the crystal point type
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get thPointCrystal;

  /// The label for the curtain point type
  ///
  /// In en, this message translates to:
  /// **'Curtain'**
  String get thPointCurtain;

  /// The label for the curtains point type
  ///
  /// In en, this message translates to:
  /// **'Curtains'**
  String get thPointCurtains;

  /// The label for the danger point type
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get thPointDanger;

  /// The label for the date point type
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get thPointDate;

  /// The label for the debris point type
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get thPointDebris;

  /// The label for the dig point type
  ///
  /// In en, this message translates to:
  /// **'Dig'**
  String get thPointDig;

  /// The label for the dimensions point type
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get thPointDimensions;

  /// The label for the disc pillar point type
  ///
  /// In en, this message translates to:
  /// **'Disc Pillar'**
  String get thPointDiscPillar;

  /// The label for the disc pillars point type
  ///
  /// In en, this message translates to:
  /// **'Disc Pillars'**
  String get thPointDiscPillars;

  /// The label for the disc stalactite point type
  ///
  /// In en, this message translates to:
  /// **'Disc Stalactite'**
  String get thPointDiscStalactite;

  /// The label for the disc stalactites point type
  ///
  /// In en, this message translates to:
  /// **'Disc Stalactites'**
  String get thPointDiscStalactites;

  /// The label for the disc stalagmite point type
  ///
  /// In en, this message translates to:
  /// **'Disc Stalagmite'**
  String get thPointDiscStalagmite;

  /// The label for the disc stalagmites point type
  ///
  /// In en, this message translates to:
  /// **'Disc Stalagmites'**
  String get thPointDiscStalagmites;

  /// The label for the disk point type
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get thPointDisk;

  /// The label for the electric light point type
  ///
  /// In en, this message translates to:
  /// **'Electric Light'**
  String get thPointElectricLight;

  /// The label for the entrance point type
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get thPointEntrance;

  /// The label for the extra point type
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get thPointExtra;

  /// The label for the ex voto point type
  ///
  /// In en, this message translates to:
  /// **'Ex Voto'**
  String get thPointExVoto;

  /// The label for the fixed ladder point type
  ///
  /// In en, this message translates to:
  /// **'Fixed Ladder'**
  String get thPointFixedLadder;

  /// The label for the flowstone point type
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thPointFlowstone;

  /// The label for the flowstone choke point type
  ///
  /// In en, this message translates to:
  /// **'Flowstone Choke'**
  String get thPointFlowstoneChoke;

  /// The label for the flute point type
  ///
  /// In en, this message translates to:
  /// **'Flute'**
  String get thPointFlute;

  /// The label for the gate point type
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get thPointGate;

  /// The label for the gradient point type
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thPointGradient;

  /// The label for the guano point type
  ///
  /// In en, this message translates to:
  /// **'Guano'**
  String get thPointGuano;

  /// The label for the gypsum point type
  ///
  /// In en, this message translates to:
  /// **'Gypsum'**
  String get thPointGypsum;

  /// The label for the gypsum flower point type
  ///
  /// In en, this message translates to:
  /// **'Gypsum Flower'**
  String get thPointGypsumFlower;

  /// The label for the handrail point type
  ///
  /// In en, this message translates to:
  /// **'Handrail'**
  String get thPointHandrail;

  /// The label for the height point type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thPointHeight;

  /// The label for the helictite point type
  ///
  /// In en, this message translates to:
  /// **'Helictite'**
  String get thPointHelictite;

  /// The label for the helictites point type
  ///
  /// In en, this message translates to:
  /// **'Helictites'**
  String get thPointHelictites;

  /// The label for the human bones point type
  ///
  /// In en, this message translates to:
  /// **'Human Bones'**
  String get thPointHumanBones;

  /// The label for the ice point type
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get thPointIce;

  /// The label for the ice pillar point type
  ///
  /// In en, this message translates to:
  /// **'Ice Pillar'**
  String get thPointIcePillar;

  /// The label for the ice stalactite point type
  ///
  /// In en, this message translates to:
  /// **'Ice Stalactite'**
  String get thPointIceStalactite;

  /// The label for the ice stalagmite point type
  ///
  /// In en, this message translates to:
  /// **'Ice Stalagmite'**
  String get thPointIceStalagmite;

  /// The label for the karren point type
  ///
  /// In en, this message translates to:
  /// **'Karren'**
  String get thPointKarren;

  /// The label for the label point type
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get thPointLabel;

  /// The label for the low end point type
  ///
  /// In en, this message translates to:
  /// **'Low End'**
  String get thPointLowEnd;

  /// The label for the map connection point type
  ///
  /// In en, this message translates to:
  /// **'Map Connection'**
  String get thPointMapConnection;

  /// The label for the masonry point type
  ///
  /// In en, this message translates to:
  /// **'Masonry'**
  String get thPointMasonry;

  /// The label for the moonmilk point type
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thPointMoonmilk;

  /// The label for the mud point type
  ///
  /// In en, this message translates to:
  /// **'Mud'**
  String get thPointMud;

  /// The label for the mudcrack point type
  ///
  /// In en, this message translates to:
  /// **'Mudcrack'**
  String get thPointMudcrack;

  /// The label for the name plate point type
  ///
  /// In en, this message translates to:
  /// **'Name Plate'**
  String get thPointNamePlate;

  /// The label for the narrow end point type
  ///
  /// In en, this message translates to:
  /// **'Narrow End'**
  String get thPointNarrowEnd;

  /// The label for the no equipment point type
  ///
  /// In en, this message translates to:
  /// **'No Equipment'**
  String get thPointNoEquipment;

  /// The label for the no wheelchair point type
  ///
  /// In en, this message translates to:
  /// **'No Wheelchair'**
  String get thPointNoWheelchair;

  /// The label for the paleo material point type
  ///
  /// In en, this message translates to:
  /// **'Paleo Material'**
  String get thPointPaleoMaterial;

  /// The label for the passage height point type
  ///
  /// In en, this message translates to:
  /// **'Passage Height'**
  String get thPointPassageHeight;

  /// The label for the pebbles point type
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get thPointPebbles;

  /// The label for the pendant point type
  ///
  /// In en, this message translates to:
  /// **'Pendant'**
  String get thPointPendant;

  /// The label for the photo point type
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get thPointPhoto;

  /// The label for the pillar point type
  ///
  /// In en, this message translates to:
  /// **'Pillar'**
  String get thPointPillar;

  /// The label for the pillars with curtains point type
  ///
  /// In en, this message translates to:
  /// **'Pillars With Curtains'**
  String get thPointPillarsWithCurtains;

  /// The label for the pillar with curtains point type
  ///
  /// In en, this message translates to:
  /// **'Pillar With Curtains'**
  String get thPointPillarWithCurtains;

  /// The label for the popcorn point type
  ///
  /// In en, this message translates to:
  /// **'Popcorn'**
  String get thPointPopcorn;

  /// The label for the raft point type
  ///
  /// In en, this message translates to:
  /// **'Raft'**
  String get thPointRaft;

  /// The label for the raft cone point type
  ///
  /// In en, this message translates to:
  /// **'Raft Cone'**
  String get thPointRaftCone;

  /// The label for the remark point type
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get thPointRemark;

  /// The label for the rimstone dam point type
  ///
  /// In en, this message translates to:
  /// **'Rimstone Dam'**
  String get thPointRimstoneDam;

  /// The label for the rimstone pool point type
  ///
  /// In en, this message translates to:
  /// **'Rimstone Pool'**
  String get thPointRimstonePool;

  /// The label for the root point type
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get thPointRoot;

  /// The label for the rope point type
  ///
  /// In en, this message translates to:
  /// **'Rope'**
  String get thPointRope;

  /// The label for the rope ladder point type
  ///
  /// In en, this message translates to:
  /// **'Rope Ladder'**
  String get thPointRopeLadder;

  /// The label for the sand point type
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get thPointSand;

  /// The label for the scallop point type
  ///
  /// In en, this message translates to:
  /// **'Scallop'**
  String get thPointScallop;

  /// The label for the section point type
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get thPointSection;

  /// The label for the seed germination point type
  ///
  /// In en, this message translates to:
  /// **'Seed Germination'**
  String get thPointSeedGermination;

  /// The label for the sink point type
  ///
  /// In en, this message translates to:
  /// **'Sink'**
  String get thPointSink;

  /// The label for the snow point type
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get thPointSnow;

  /// The label for the soda straw point type
  ///
  /// In en, this message translates to:
  /// **'Soda Straw'**
  String get thPointSodaStraw;

  /// The label for the spring point type
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get thPointSpring;

  /// The label for the stalactite point type
  ///
  /// In en, this message translates to:
  /// **'Stalactite'**
  String get thPointStalactite;

  /// The label for the stalactites point type
  ///
  /// In en, this message translates to:
  /// **'Stalactites'**
  String get thPointStalactites;

  /// The label for the stalactites stalagmites point type
  ///
  /// In en, this message translates to:
  /// **'Stalactites Stalagmites'**
  String get thPointStalactitesStalagmites;

  /// The label for the stalactite stalagmite point type
  ///
  /// In en, this message translates to:
  /// **'Stalactite Stalagmite'**
  String get thPointStalactiteStalagmite;

  /// The label for the stalagmite point type
  ///
  /// In en, this message translates to:
  /// **'Stalagmite'**
  String get thPointStalagmite;

  /// The label for the stalagmites point type
  ///
  /// In en, this message translates to:
  /// **'Stalagmites'**
  String get thPointStalagmites;

  /// The label for the station point type
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get thPointStation;

  /// The label for the station name point type
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get thPointStationName;

  /// The label for the steps point type
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get thPointSteps;

  /// The label for the traverse point type
  ///
  /// In en, this message translates to:
  /// **'Traverse'**
  String get thPointTraverse;

  /// The label for the tree trunk point type
  ///
  /// In en, this message translates to:
  /// **'Tree Trunk'**
  String get thPointTreeTrunk;

  /// The label for the user defined point type
  ///
  /// In en, this message translates to:
  /// **'user defined'**
  String get thPointU;

  /// The label for the vegetable debris point type
  ///
  /// In en, this message translates to:
  /// **'Vegetable Debris'**
  String get thPointVegetableDebris;

  /// The label for the via ferrata point type
  ///
  /// In en, this message translates to:
  /// **'Via Ferrata'**
  String get thPointViaFerrata;

  /// The label for the volcano point type
  ///
  /// In en, this message translates to:
  /// **'Volcano'**
  String get thPointVolcano;

  /// The label for the walkway point type
  ///
  /// In en, this message translates to:
  /// **'Walkway'**
  String get thPointWalkway;

  /// The label for the wall calcite point type
  ///
  /// In en, this message translates to:
  /// **'Wall Calcite'**
  String get thPointWallCalcite;

  /// The label for the water point type
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get thPointWater;

  /// The label for the water drip point type
  ///
  /// In en, this message translates to:
  /// **'Water Drip'**
  String get thPointWaterDrip;

  /// The label for the water flow point type
  ///
  /// In en, this message translates to:
  /// **'Water Flow'**
  String get thPointWaterFlow;

  /// The label for the wheelchair point type
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get thPointWheelchair;

  /// The label for the abyss entrance line type
  ///
  /// In en, this message translates to:
  /// **'Abyss Entrance'**
  String get thLineAbyssEntrance;

  /// The label for the arrow line type
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get thLineArrow;

  /// The label for the border line type
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get thLineBorder;

  /// The label for the ceiling meander line type
  ///
  /// In en, this message translates to:
  /// **'Ceiling Meander'**
  String get thLineCeilingMeander;

  /// The label for the ceiling step line type
  ///
  /// In en, this message translates to:
  /// **'Ceiling Step'**
  String get thLineCeilingStep;

  /// The label for the chimney line type
  ///
  /// In en, this message translates to:
  /// **'Chimney'**
  String get thLineChimney;

  /// The label for the contour line type
  ///
  /// In en, this message translates to:
  /// **'Contour'**
  String get thLineContour;

  /// The label for the dripline line type
  ///
  /// In en, this message translates to:
  /// **'Dripline'**
  String get thLineDripline;

  /// The label for the fault line type
  ///
  /// In en, this message translates to:
  /// **'Fault'**
  String get thLineFault;

  /// The label for the fixed ladder line type
  ///
  /// In en, this message translates to:
  /// **'Fixed Ladder'**
  String get thLineFixedLadder;

  /// The label for the floor meander line type
  ///
  /// In en, this message translates to:
  /// **'Floor Meander'**
  String get thLineFloorMeander;

  /// The label for the floor step line type
  ///
  /// In en, this message translates to:
  /// **'Floor Step'**
  String get thLineFloorStep;

  /// The label for the flowstone line type
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thLineFlowstone;

  /// The label for the gradient line type
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thLineGradient;

  /// The label for the handrail line type
  ///
  /// In en, this message translates to:
  /// **'Handrail'**
  String get thLineHandrail;

  /// The label for the joint line type
  ///
  /// In en, this message translates to:
  /// **'Joint'**
  String get thLineJoint;

  /// The label for the label line type
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get thLineLabel;

  /// The label for the low ceiling line type
  ///
  /// In en, this message translates to:
  /// **'Low Ceiling'**
  String get thLineLowCeiling;

  /// The label for the map connection line type
  ///
  /// In en, this message translates to:
  /// **'Map Connection'**
  String get thLineMapConnection;

  /// The label for the moonmilk line type
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thLineMoonmilk;

  /// The label for the overhang line type
  ///
  /// In en, this message translates to:
  /// **'Overhang'**
  String get thLineOverhang;

  /// The label for the pit line type
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get thLinePit;

  /// The label for the pitch line type
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get thLinePitch;

  /// The label for the pit chimney line type
  ///
  /// In en, this message translates to:
  /// **'Pit Chimney'**
  String get thLinePitChimney;

  /// The label for the rimstone dam line type
  ///
  /// In en, this message translates to:
  /// **'Rimstone Dam'**
  String get thLineRimstoneDam;

  /// The label for the rimstone pool line type
  ///
  /// In en, this message translates to:
  /// **'Rimstone Pool'**
  String get thLineRimstonePool;

  /// The label for the rock border line type
  ///
  /// In en, this message translates to:
  /// **'Rock Border'**
  String get thLineRockBorder;

  /// The label for the rock edge line type
  ///
  /// In en, this message translates to:
  /// **'Rock Edge'**
  String get thLineRockEdge;

  /// The label for the rope line type
  ///
  /// In en, this message translates to:
  /// **'Rope'**
  String get thLineRope;

  /// The label for the rope ladder line type
  ///
  /// In en, this message translates to:
  /// **'Rope Ladder'**
  String get thLineRopeLadder;

  /// The label for the section line type
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get thLineSection;

  /// The label for the slope line type
  ///
  /// In en, this message translates to:
  /// **'Slope'**
  String get thLineSlope;

  /// The label for the steps line type
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get thLineSteps;

  /// The label for the survey line type
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get thLineSurvey;

  /// The label for the U line type
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get thLineU;

  /// The label for the via ferrata line type
  ///
  /// In en, this message translates to:
  /// **'Via Ferrata'**
  String get thLineViaFerrata;

  /// The label for the walkway line type
  ///
  /// In en, this message translates to:
  /// **'Walkway'**
  String get thLineWalkWay;

  /// The label for the wall line type
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get thLineWall;

  /// The label for the water flow line type
  ///
  /// In en, this message translates to:
  /// **'Water Flow'**
  String get thLineWaterFlow;

  /// The label for the adjust command option type
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get thCommandOptionAdjust;

  /// The label for the align command option type
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get thCommandOptionAlign;

  /// The label for the altitude command option type
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thCommandOptionAltitude;

  /// The label for the altitude command option fix choice
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get thCommandOptionAltitudeFix;

  /// The label for the altitude value command option type
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thCommandOptionAltitudeValue;

  /// The label for the anchors command option type
  ///
  /// In en, this message translates to:
  /// **'Anchors'**
  String get thCommandOptionAnchors;

  /// The label for the author command option type
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get thCommandOptionAuthor;

  /// The label for the border command option type
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get thCommandOptionBorder;

  /// The label for the clip command option type
  ///
  /// In en, this message translates to:
  /// **'Clip'**
  String get thCommandOptionClip;

  /// The label for the close command option type
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get thCommandOptionClose;

  /// The label for the context command option type
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get thCommandOptionContext;

  /// The label for the copyright command option type
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get thCommandOptionCopyright;

  /// The label for the Coordinate System command option type
  ///
  /// In en, this message translates to:
  /// **'Coordinate System'**
  String get thCommandOptionCS;

  /// The label for the date value command option type
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get thCommandOptionDateValue;

  /// The label for the dimensions value command option type
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get thCommandOptionDimensionsValue;

  /// The label for the dist command option type
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get thCommandOptionDist;

  /// The label for the explored command option type
  ///
  /// In en, this message translates to:
  /// **'Explored'**
  String get thCommandOptionExplored;

  /// The label for the extend command option type
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get thCommandOptionExtend;

  /// The label for the flip command option type
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get thCommandOptionFlip;

  /// The label for the from command option type
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get thCommandOptionFrom;

  /// The label for the head command option type
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get thCommandOptionHead;

  /// The label for the ID command option type
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get thCommandOptionId;

  /// The label for the length unit command option type
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get thCommandOptionLengthUnit;

  /// The label for the line direction command option type
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get thCommandOptionLineDirection;

  /// The label for the line gradient command option type
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thCommandOptionLineGradient;

  /// The label for the line height command option type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thCommandOptionLineHeight;

  /// The label for the line point direction command option type
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get thCommandOptionLinePointDirection;

  /// The label for the line point gradient command option type
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thCommandOptionLinePointGradient;

  /// The label for the L size command option type
  ///
  /// In en, this message translates to:
  /// **'L-Size'**
  String get thCommandOptionLSize;

  /// The label for the mark command option type
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get thCommandOptionMark;

  /// The label for the station name command option type
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get thCommandOptionName;

  /// The label for the outline command option type
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get thCommandOptionOutline;

  /// The label for the orientation command option type
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get thCommandOptionOrientation;

  /// The label for the passage height value command option type
  ///
  /// In en, this message translates to:
  /// **'Passage Height'**
  String get thCommandOptionPassageHeightValue;

  /// The label for the place command option type
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get thCommandOptionPlace;

  /// The label for the point height value command option type
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thCommandOptionPointHeightValue;

  /// The label for the point/line/line segment scale command option type
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get thCommandOptionPLScale;

  /// The label for the projection command option type
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get thCommandOptionProjection;

  /// The label for the rebelays command option type
  ///
  /// In en, this message translates to:
  /// **'Rebelays'**
  String get thCommandOptionRebelays;

  /// The label for the reverse command option type
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get thCommandOptionReverse;

  /// The label for the scrap command option type
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get thCommandOptionScrap;

  /// The label for the scrap scale command option type
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get thCommandOptionScrapScale;

  /// The label for the sketch command option type
  ///
  /// In en, this message translates to:
  /// **'Sketch'**
  String get thCommandOptionSketch;

  /// The label for the smooth command option type
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get thCommandOptionSmooth;

  /// The label for the station names command option type
  ///
  /// In en, this message translates to:
  /// **'Station Names'**
  String get thCommandOptionStationNames;

  /// The label for the stations command option type
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get thCommandOptionStations;

  /// The label for the subtype command option type
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get thCommandOptionSubtype;

  /// The label for the text command option type
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get thCommandOptionText;

  /// The label for the title command option type
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get thCommandOptionTitle;

  /// The label for the unrecognized command option type
  ///
  /// In en, this message translates to:
  /// **'Unrecognized Command Option'**
  String get thCommandOptionUnrecognized;

  /// The label for the visibility command option type
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get thCommandOptionVisibility;

  /// The label for the walls command option type
  ///
  /// In en, this message translates to:
  /// **'Walls'**
  String get thCommandOptionWalls;

  /// The label for the horizontal adjust multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get thMultipleChoiceAdjustHorizontal;

  /// The label for the vertical adjust multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get thMultipleChoiceAdjustVertical;

  /// The label for the bottom align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get thMultipleChoiceAlignBottom;

  /// The label for the bottom left align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Bottom Left'**
  String get thMultipleChoiceAlignBottomLeft;

  /// The label for the bottom right align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Bottom Right'**
  String get thMultipleChoiceAlignBottomRight;

  /// The label for the center align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get thMultipleChoiceAlignCenter;

  /// The label for the left align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get thMultipleChoiceAlignLeft;

  /// The label for the right align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get thMultipleChoiceAlignRight;

  /// The label for the top align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get thMultipleChoiceAlignTop;

  /// The label for the top left align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Top Left'**
  String get thMultipleChoiceAlignTopLeft;

  /// The label for the top right align multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Top Right'**
  String get thMultipleChoiceAlignTopRight;

  /// The label for the off on/off multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get thMultipleChoiceOnOffOff;

  /// The label for the on on/off multiple choice type
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get thMultipleChoiceOnOffOn;

  /// The label for the auto auto/on/off multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get thMultipleChoiceOnOffAutoAuto;

  /// The label for the none flip multiple choice type
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get thMultipleChoiceFlipNone;

  /// The label for the begin arrow position multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get thMultipleChoiceArrowPositionBegin;

  /// The label for the both arrow position multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get thMultipleChoiceArrowPositionBoth;

  /// The label for the end arrow position multiple choice type
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get thMultipleChoiceArrowPositionEnd;

  /// The label for the point line point gradient multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get thMultipleChoiceLinePointGradientPoint;

  /// The label for the in outline multiple choice type
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get thMultipleChoiceOutlineIn;

  /// The label for the out outline multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get thMultipleChoiceOutlineOut;

  /// The label for the default place multiple choice type
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get thMultipleChoicePlaceDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
