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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
  String get close;

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

  /// The description for the add elements command
  ///
  /// In en, this message translates to:
  /// **'Add elements'**
  String get mpAddElementsCommandDescription;

  /// The description for the add line command
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get mpAddLineCommandDescription;

  /// The description for the add line segment command
  ///
  /// In en, this message translates to:
  /// **'Add line segment'**
  String get mpAddLineSegmentCommandDescription;

  /// The description for the add point command
  ///
  /// In en, this message translates to:
  /// **'Add point'**
  String get mpAddPointCommandDescription;

  /// The description for the delete elements command
  ///
  /// In en, this message translates to:
  /// **'Delete elements'**
  String get mpDeleteElementsCommandDescription;

  /// The description for the delete line command
  ///
  /// In en, this message translates to:
  /// **'Delete line'**
  String get mpDeleteLineCommandDescription;

  /// The description for the delete line segment command
  ///
  /// In en, this message translates to:
  /// **'Delete line segment'**
  String get mpDeleteLineSegmentCommandDescription;

  /// The description for the delete point command
  ///
  /// In en, this message translates to:
  /// **'Delete point'**
  String get mpDeletePointCommandDescription;

  /// The description for the edit Bézier curve command
  ///
  /// In en, this message translates to:
  /// **'Edit Bézier curve'**
  String get mpEditBezierCurveCommandDescription;

  /// The description for the edit line command
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get mpEditLineCommandDescription;

  /// The description for the edit line segment command
  ///
  /// In en, this message translates to:
  /// **'Edit line segment'**
  String get mpEditLineSegmentCommandDescription;

  /// The abbreviation for the centimeter length unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get mpLengthUnitCentimeterAbbreviation;

  /// The abbreviation for the foot length unit
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get mpLengthUnitFootAbbreviation;

  /// The abbreviation for the inch length unit
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get mpLengthUnitInchAbbreviation;

  /// The abbreviation for the meter length unit
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get mpLengthUnitMeterAbbreviation;

  /// The abbreviation for the yard length unit
  ///
  /// In en, this message translates to:
  /// **'yd'**
  String get mpLengthUnitYardAbbreviation;

  /// The description for the move Bézier line segment command
  ///
  /// In en, this message translates to:
  /// **'Move Bézier line segment'**
  String get mpMoveBezierLineSegmentCommandDescription;

  /// The description for the move elements command
  ///
  /// In en, this message translates to:
  /// **'Move elements'**
  String get mpMoveElementsCommandDescription;

  /// The description for the move line command
  ///
  /// In en, this message translates to:
  /// **'Move line'**
  String get mpMoveLineCommandDescription;

  /// The description for the move point command
  ///
  /// In en, this message translates to:
  /// **'Move point'**
  String get mpMovePointCommandDescription;

  /// The description for the move straight line segment command
  ///
  /// In en, this message translates to:
  /// **'Move straight line segment'**
  String get mpMoveStraightLineSegmentCommandDescription;

  /// The label for the parsing errors dialog
  ///
  /// In en, this message translates to:
  /// **'Parsing errors'**
  String get parsingErrors;

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

  /// The label for the delete tool button
  ///
  /// In en, this message translates to:
  /// **'Delete (Del)'**
  String get th2FileEditPageDeleteButton;

  /// The status bar message for the empty selection
  ///
  /// In en, this message translates to:
  /// **'Empty selection'**
  String get th2FileEditPageEmptySelectionStatusBarMessage;

  /// The label for only lines selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{amount} line(s) selected'**
  String th2FileEditPageNonEmptySelectionOnlyLinesStatusBarMessage(Object amount);

  /// The label for only points selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{amount} point(s) selected'**
  String th2FileEditPageNonEmptySelectionOnlyPointsStatusBarMessage(Object amount);

  /// The label for points and lines selected status bar messagee
  ///
  /// In en, this message translates to:
  /// **'{pointsAmount} point(s) and {linesAmount} line(s) selected'**
  String th2FileEditPageNonEmptySelectionPointsAndLinesStatusBarMessage(Object pointsAmount, Object linesAmount);

  /// The label for the loading file message
  ///
  /// In en, this message translates to:
  /// **'Loading file {filename} ...'**
  String th2FileEditPageLoadingFile(Object filename);

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

  /// The label for the pan tool button
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get th2FileEditPagePanTool;

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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
