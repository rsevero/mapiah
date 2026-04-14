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
    Locale('pt'),
  ];

  /// The label for the changelog section in the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get aboutMapiahDialogChangelog;

  /// The label for the license section in the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutMapiahDialogLicense;

  /// The version of Mapiah for the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutMapiahDialogMapiahVersion(Object version);

  /// The release name and URL to show in the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'The {releaseName} release ({releaseUrl})'**
  String aboutMapiahDialogRelease(Object releaseName, Object releaseUrl);

  /// Release name without URL for the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'The {releaseName} release'**
  String aboutMapiahDialogReleaseNoUrl(Object releaseName);

  /// Label for the release URL link in the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'Release page'**
  String get aboutMapiahDialogReleaseUrlLabel;

  /// The title for the About dialog. Used on: _MapiahHomeState.showAboutDialog
  ///
  /// In en, this message translates to:
  /// **'About Mapiah'**
  String get aboutMapiahDialogWindowTitle;

  /// The title of the application. Used on: MapiahApp.build, _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'Mapiah'**
  String get appTitle;

  /// The label for the close button. Used on: MPErrorDialog.build, MPHelpDialogWidget.build, _MPRunTherionDialogWidgetState.build, _MPSnapTargetsWidgetState.build, _MapiahHomeState.showAboutDialog, lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Error message shown when the user tries to split a line that belongs to an area border. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart
  ///
  /// In en, this message translates to:
  /// **'Cannot split a line that is part of an area border'**
  String get cannotSplitAreaBorderLine;

  /// The title for the file edit window. Used on: _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'File edit'**
  String get fileEditWindowWindowTitle;

  /// The message displayed when the help content fails to load. Used on: MPHelpDialogWidget.build
  ///
  /// In en, this message translates to:
  /// **'Failed to load help content'**
  String get helpDialogFailureToLoad;

  /// The tooltip for the help dialog button. Used on: MPHelpButtonWidget.build
  ///
  /// In en, this message translates to:
  /// **'Help (F1)'**
  String get helpDialogTooltip;

  /// The initial page presentation of the application. Used on: _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'Mapiah: an user-friendly graphical interface for cave mapping with Therion'**
  String get initialPagePresentation;

  /// The name of the language based on the language code. Translate only 'System' and your language name. Leave the other values as they are. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'{language, select, sys {System} en {English} pt {Português} other {Unknown}}'**
  String languageName(String language);

  /// The label for the about Mapiah dialog. Used on: _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'About Mapiah'**
  String get mapiahHomeAboutMapiahDialog;

  /// The title for the main page of the help dialog. Used on: _MapiahHomeState.build, on._withShortcuts
  ///
  /// In en, this message translates to:
  /// **'Main page'**
  String get mapiahHomeHelpDialogTitle;

  /// The tooltip for the new file button on the main page. Used on: _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'New file (Ctrl+N or Ctrl+Shift+N)'**
  String get mapiahHomeNewFileButtonTooltip;

  /// The label for the open file button. Used on: _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'Open file (Ctrl+O or Ctrl+Shift+O)'**
  String get mapiahHomeOpenFile;

  /// The title for the keyboard shortcuts help dialog. Used on: _MapiahHomeState.build, _TH2FileEditPageState.build, lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_state_move_canvas_mixin.dart, on._withShortcuts
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get mapiahKeyboardShortcutsTitle;

  /// The tooltip for the keyboard shortcuts help button. Used on: _MapiahHomeState.build, _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts (Ctrl+K)'**
  String get mapiahKeyboardShortcutsTooltip;

  /// The tooltip for the button that opens a THConfig file and runs Therion. Used on: _MapiahHomeState.build, _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Open THConfig file and run Therion (Ctrl+T)'**
  String get mapiahOpenTHConfigAndRunTherionButtonTooltip;

  /// Label for the Run Therion button. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Rerun Therion'**
  String get mapiahRunTherionButtonLabel;

  /// The tooltip for the Run Therion button. Used on: _MPRunTherionDialogWidgetState.build, _MapiahHomeState.build, _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Run Therion (T)'**
  String get mapiahRunTherionButtonTooltip;

  /// Title for the Run Therion help dialog. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Run Therion dialog'**
  String get mapiahRunTherionHelpDialogTitle;

  /// Tooltip for the Close button in the Run Therion dialog, indicating the Escape keyboard shortcut. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Close (Esc)'**
  String get mapiahTherionRunCloseButtonTooltip;

  /// Title for the Therion output dialog. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Therion output'**
  String get mapiahTherionRunDialogTitle;

  /// Label for Therion run elapsed time. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Elapsed time: {elapsed} s'**
  String mapiahTherionRunElapsedLabel(Object elapsed);

  /// Line that shows the Therion run end time after the therion.log section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'End: {time}'**
  String mapiahTherionRunEndTime(Object time);

  /// Message shown when no acceptable therion.log can be appended. Used on: lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'No Therion output found'**
  String get mapiahTherionRunNoTherionOutputFound;

  /// Label for Therion output area. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Output:'**
  String get mapiahTherionRunOutputLabel;

  /// Label for the run parameters field in the Therion run dialog. Used on: lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Run parameters:'**
  String get mapiahTherionRunParametersLabel;

  /// Line that shows the Therion run start time before the Therion output section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String mapiahTherionRunStartTime(Object time);

  /// Status shown when Therion output has errors. Used on: _MPRunTherionDialogWidgetState.build, lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get mapiahTherionRunStatusError;

  /// Label for Therion run status. Used on: _MPRunTherionDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get mapiahTherionRunStatusLabel;

  /// Status shown when Therion finishes. Used on: lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get mapiahTherionRunStatusOk;

  /// Status while Therion is running. Used on: lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'running'**
  String get mapiahTherionRunStatusRunning;

  /// Status shown when Therion output has warnings. Used on: _MPRunTherionDialogWidgetState.build, lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get mapiahTherionRunStatusWarning;

  /// Header line marking the beginning of therion.log section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'Begin therion.log'**
  String get mapiahTherionRunTherionLogBegin;

  /// Header line marking the end of therion.log section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'End therion.log'**
  String get mapiahTherionRunTherionLogEnd;

  /// Header line marking the beginning of Therion output section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'Begin Therion output'**
  String get mapiahTherionRunTherionOutputBegin;

  /// Header line marking the end of Therion output section. Used on: _MPRunTherionDialogWidgetState._onTherionRunFinished
  ///
  /// In en, this message translates to:
  /// **'End Therion output'**
  String get mapiahTherionRunTherionOutputEnd;

  /// Title for THConfig file picker dialog. Used on: MPDialogAux.pickTHConfigFile
  ///
  /// In en, this message translates to:
  /// **'Select THConfig file'**
  String get mapiahTherionSelectTHConfigDialogTitle;

  /// Snackbar message shown when merge areas finds segments outside the chosen bounding path. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart
  ///
  /// In en, this message translates to:
  /// **'Merge areas: line segments outside the outer boundary were found — merge aborted'**
  String get mergeAreasLineSegmentsOutsideBoundary;

  /// Snackbar message shown when merge areas is triggered but no areas are selected. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart
  ///
  /// In en, this message translates to:
  /// **'No areas selected for merging'**
  String get mergeAreasNoSelectedAreas;

  /// The error message for invalid altitude value. Used on: lib/src/widgets/options/mp_altitude_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid altitude'**
  String get mpAltitudeInvalidValueErrorMessage;

  /// The description for the degree angle unit. Used on: MPTextToUser._initializeAngleUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'degree'**
  String get mpAngleUnitDegree;

  /// The description for the grad angle unit. Used on: MPTextToUser._initializeAngleUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'grad'**
  String get mpAngleUnitGrad;

  /// The description for the mil angle unit. Used on: MPTextToUser._initializeAngleUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'mil'**
  String get mpAngleUnitMil;

  /// The description for the minute angle unit. Used on: MPTextToUser._initializeAngleUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get mpAngleUnitMinute;

  /// Label for the button to add a new area border THID reference. Used on: lib/src/widgets/mp_options_edit_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Add area border'**
  String get mpAreaBordersAddButton;

  /// Title for the area borders block listing area border THIDs. Used on: lib/src/widgets/mp_options_edit_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Area borders'**
  String get mpAreaBordersPanelTitle;

  /// The error message for an empty attribute name. Used on: lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Empty attribute name'**
  String get mpAttrNameEmpty;

  /// The error message for invalid characters in attribute name. Used on: lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid chars in attribute name'**
  String get mpAttrNameInvalid;

  /// The label for the attribute name. Used on: lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mpAttrNameLabel;

  /// The error message for an empty attribute value. Used on: lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Empty attribute value'**
  String get mpAttrValueEmpty;

  /// The label for the attribute value. Used on: lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get mpAttrValueLabel;

  /// The error message for invalid author value. Used on: lib/src/widgets/options/mp_author_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid date/interval and person name'**
  String get mpAuthorInvalidValueErrorMessage;

  /// The label for the azimuth type. Used on: lib/src/widgets/options/mp_orientation_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Azimuth'**
  String get mpAzimuthAzimuthLabel;

  /// The label for the east azimuth. Used on: none
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get mpAzimuthEast;

  /// The abbreviation for the east azimuth. Used on: MPCompassPainter.paint
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get mpAzimuthEastAbbreviation;

  /// The error message for invalid azimuth value. Used on: lib/src/widgets/options/mp_orientation_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid azimuth'**
  String get mpAzimuthInvalidErrorMessage;

  /// The label for the north azimuth. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get mpAzimuthNorth;

  /// The abbreviation for the north azimuth. Used on: MPCompassPainter.paint, lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get mpAzimuthNorthAbbreviation;

  /// The label for the south azimuth. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get mpAzimuthSouth;

  /// The abbreviation for the south azimuth. Used on: MPCompassPainter.paint, lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get mpAzimuthSouthAbbreviation;

  /// The label for the west azimuth. Used on: none
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get mpAzimuthWest;

  /// The abbreviation for the west azimuth. Used on: MPCompassPainter.paint
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get mpAzimuthWestAbbreviation;

  /// The label for the apply button. Used on: _MPSettingsPageState.build
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get mpButtonApply;

  /// The label for the cancel button. Used on: MPEncodingWidgetState.build, MPProjectionOptionWidgetState.build, MPScrapScaleOptionWidgetState.build, _MPAddFileDialogWidgetState.build, _MPAddScrapDialogWidgetState.build, _MPSettingsPageState.build, lib/src/widgets/options/mp_altitude_option_widget.dart, lib/src/widgets/options/mp_attr_option_widget.dart, lib/src/widgets/options/mp_author_option_widget.dart, lib/src/widgets/options/mp_context_option_widget.dart, lib/src/widgets/options/mp_copyright_option_widget.dart, lib/src/widgets/options/mp_cs_option_widget.dart, lib/src/widgets/options/mp_date_value_option_widget.dart, lib/src/widgets/options/mp_dimensions_option_widget.dart, lib/src/widgets/options/mp_distance_type_option_widget.dart, lib/src/widgets/options/mp_double_value_option_widget.dart, lib/src/widgets/options/mp_id_option_widget.dart, lib/src/widgets/options/mp_orientation_option_widget.dart, lib/src/widgets/options/mp_passage_height_option_widget.dart, lib/src/widgets/options/mp_pl_scale_option_widget.dart, lib/src/widgets/options/mp_point_height_option_widget.dart, lib/src/widgets/options/mp_scrap_option_widget.dart, lib/src/widgets/options/mp_sketch_option_widget.dart, lib/src/widgets/options/mp_station_names_option_widget.dart, lib/src/widgets/options/mp_station_type_option_widget.dart, lib/src/widgets/options/mp_stations_option_widget.dart, lib/src/widgets/options/mp_subtype_option_widget.dart, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mpButtonCancel;

  /// The label for the create button. Used on: _MPAddScrapDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get mpButtonCreate;

  /// The label for the OK button. Used on: MPDialogAux.showNow, MPEncodingWidgetState.build, MPProjectionOptionWidgetState.build, MPScrapScaleOptionWidgetState.build, _MPAddFileDialogWidgetState.build, lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart, lib/src/widgets/options/mp_altitude_option_widget.dart, lib/src/widgets/options/mp_attr_option_widget.dart, lib/src/widgets/options/mp_author_option_widget.dart, lib/src/widgets/options/mp_context_option_widget.dart, lib/src/widgets/options/mp_copyright_option_widget.dart, lib/src/widgets/options/mp_cs_option_widget.dart, lib/src/widgets/options/mp_date_value_option_widget.dart, lib/src/widgets/options/mp_dimensions_option_widget.dart, lib/src/widgets/options/mp_distance_type_option_widget.dart, lib/src/widgets/options/mp_double_value_option_widget.dart, lib/src/widgets/options/mp_id_option_widget.dart, lib/src/widgets/options/mp_orientation_option_widget.dart, lib/src/widgets/options/mp_passage_height_option_widget.dart, lib/src/widgets/options/mp_pl_scale_option_widget.dart, lib/src/widgets/options/mp_point_height_option_widget.dart, lib/src/widgets/options/mp_scrap_option_widget.dart, lib/src/widgets/options/mp_sketch_option_widget.dart, lib/src/widgets/options/mp_station_names_option_widget.dart, lib/src/widgets/options/mp_station_type_option_widget.dart, lib/src/widgets/options/mp_stations_option_widget.dart, lib/src/widgets/options/mp_subtype_option_widget.dart, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get mpButtonOK;

  /// The label for the reset button. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get mpButtonReset;

  /// The label for the reset all settings button. Used on: _MPSettingsPageState.build
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get mpButtonResetAllSettings;

  /// The label for the save button. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get mpButtonSave;

  /// The label for the save and close button. Used on: _MPSettingsPageState.build
  ///
  /// In en, this message translates to:
  /// **'Save & Close'**
  String get mpButtonSaveAndClose;

  /// The label for the CS EPSG SGRI option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'{csOption} identifier (1-99999)'**
  String mpCSEPSGESRILabel(Object csOption);

  /// The label for the CS ETRS option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Optional ETRS identifier (28-37)'**
  String get mpCSETRSLabel;

  /// The label for the CS for output option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'For output'**
  String get mpCSForOutputLabel;

  /// The error message for invalid CS value. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get mpCSInvalidValueErrorMessage;

  /// The label for the CS OSGB major option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'OSGB major'**
  String get mpCSOSGBMajorLabel;

  /// The label for the CS OSGB minor option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'OSGB minor'**
  String get mpCSOSGBMinorLabel;

  /// The label for the CS UTM zone number option. Used on: lib/src/widgets/options/mp_cs_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Zone number (1-60)'**
  String get mpCSUTMZoneNumberLabel;

  /// The label for the multiple values choice type. Used on: none
  ///
  /// In en, this message translates to:
  /// **'multiple values'**
  String get mpChoiceMultipleValues;

  /// The label for the set choice type. Used on: lib/src/widgets/options/mp_altitude_option_widget.dart, lib/src/widgets/options/mp_author_option_widget.dart, lib/src/widgets/options/mp_context_option_widget.dart, lib/src/widgets/options/mp_copyright_option_widget.dart, lib/src/widgets/options/mp_cs_option_widget.dart, lib/src/widgets/options/mp_date_value_option_widget.dart, lib/src/widgets/options/mp_dimensions_option_widget.dart, lib/src/widgets/options/mp_distance_type_option_widget.dart, lib/src/widgets/options/mp_double_value_option_widget.dart, lib/src/widgets/options/mp_id_option_widget.dart, lib/src/widgets/options/mp_orientation_option_widget.dart, lib/src/widgets/options/mp_sketch_option_widget.dart, lib/src/widgets/options/mp_station_names_option_widget.dart, lib/src/widgets/options/mp_station_type_option_widget.dart, lib/src/widgets/options/mp_stations_option_widget.dart, lib/src/widgets/options/mp_subtype_option_widget.dart, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get mpChoiceSet;

  /// The label for the unset choice type. Used on: MPProjectionOptionWidgetState.build, MPScrapScaleOptionWidgetState.build, lib/src/auxiliary/mp_text_to_user.dart, lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_edit_single_line.dart, lib/src/widgets/options/mp_altitude_option_widget.dart, lib/src/widgets/options/mp_author_option_widget.dart, lib/src/widgets/options/mp_context_option_widget.dart, lib/src/widgets/options/mp_copyright_option_widget.dart, lib/src/widgets/options/mp_cs_option_widget.dart, lib/src/widgets/options/mp_date_value_option_widget.dart, lib/src/widgets/options/mp_dimensions_option_widget.dart, lib/src/widgets/options/mp_distance_type_option_widget.dart, lib/src/widgets/options/mp_double_value_option_widget.dart, lib/src/widgets/options/mp_id_option_widget.dart, lib/src/widgets/options/mp_orientation_option_widget.dart, lib/src/widgets/options/mp_passage_height_option_widget.dart, lib/src/widgets/options/mp_pl_scale_option_widget.dart, lib/src/widgets/options/mp_point_height_option_widget.dart, lib/src/widgets/options/mp_scrap_option_widget.dart, lib/src/widgets/options/mp_sketch_option_widget.dart, lib/src/widgets/options/mp_station_names_option_widget.dart, lib/src/widgets/options/mp_station_type_option_widget.dart, lib/src/widgets/options/mp_stations_option_widget.dart, lib/src/widgets/options/mp_subtype_option_widget.dart, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get mpChoiceUnset;

  /// The description for the add area command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get mpCommandDescriptionAddArea;

  /// The description for the add area border line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add area border line'**
  String get mpCommandDescriptionAddAreaBorderTHID;

  /// The description for the add element command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add element'**
  String get mpCommandDescriptionAddElement;

  /// The description for the add elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add elements'**
  String get mpCommandDescriptionAddElements;

  /// The description for the add empty line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add empty line'**
  String get mpCommandDescriptionAddEmptyLine;

  /// The description for the add line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get mpCommandDescriptionAddLine;

  /// The description for the add line segment command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add line segment'**
  String get mpCommandDescriptionAddLineSegment;

  /// The description for the add lines command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add lines'**
  String get mpCommandDescriptionAddLines;

  /// The description for the add point command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add point'**
  String get mpCommandDescriptionAddPoint;

  /// The description for the add scrap command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add scrap'**
  String get mpCommandDescriptionAddScrap;

  /// The description for the add XTherion image insert config command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get mpCommandDescriptionAddXTherionImageInsertConfig;

  /// The description for the cut elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Cut elements'**
  String get mpCommandDescriptionCutElements;

  /// The description for the duplicate elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Duplicate elements'**
  String get mpCommandDescriptionDuplicateElements;

  /// The description for the edit area type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit area type'**
  String get mpCommandDescriptionEditAreaType;

  /// The description for the edit areas type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit multiple areas type'**
  String get mpCommandDescriptionEditAreasType;

  /// The description for the edit Bézier curve command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit Bézier curve'**
  String get mpCommandDescriptionEditBezierCurve;

  /// The description for the edit line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get mpCommandDescriptionEditLine;

  /// The description for the edit line segment command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit line segment'**
  String get mpCommandDescriptionEditLineSegment;

  /// The description for the edit line segment type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit line segment type'**
  String get mpCommandDescriptionEditLineSegmentType;

  /// The description for the edit line segments type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit multiple line segments type'**
  String get mpCommandDescriptionEditLineSegmentsType;

  /// The description for the edit line type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit line type'**
  String get mpCommandDescriptionEditLineType;

  /// The description for the edit lines type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit multiple lines type'**
  String get mpCommandDescriptionEditLinesType;

  /// The description for the edit point type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit point type'**
  String get mpCommandDescriptionEditPointType;

  /// The description for the edit points type command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Edit multiple points type'**
  String get mpCommandDescriptionEditPointsType;

  /// The description for the move area command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move area'**
  String get mpCommandDescriptionMoveArea;

  /// The description for the move Bézier line segment command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move Bézier line segment'**
  String get mpCommandDescriptionMoveBezierLineSegment;

  /// The description for the move elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move elements'**
  String get mpCommandDescriptionMoveElements;

  /// The description for the move line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move line'**
  String get mpCommandDescriptionMoveLine;

  /// The description for the move line segments command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move line segments'**
  String get mpCommandDescriptionMoveLineSegments;

  /// The description for the move lines command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move lines'**
  String get mpCommandDescriptionMoveLines;

  /// The description for the move point command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move point'**
  String get mpCommandDescriptionMovePoint;

  /// The description for the move straight line segment command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Move straight line segment'**
  String get mpCommandDescriptionMoveStraightLineSegment;

  /// The description for the multiple elements edit command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Multiple elements edit'**
  String get mpCommandDescriptionMultipleElements;

  /// The description for the remove area command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove area'**
  String get mpCommandDescriptionRemoveArea;

  /// The description for the remove area border line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString, lib/src/widgets/mp_options_edit_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Remove area border line'**
  String get mpCommandDescriptionRemoveAreaBorderTHID;

  /// The description for the remove element command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove element'**
  String get mpCommandDescriptionRemoveElement;

  /// The description for the remove elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove elements'**
  String get mpCommandDescriptionRemoveElements;

  /// The description for the remove empty line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove empty line'**
  String get mpCommandDescriptionRemoveEmptyLine;

  /// The description for the remove line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get mpCommandDescriptionRemoveLine;

  /// The description for the remove line segment command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove line segment'**
  String get mpCommandDescriptionRemoveLineSegment;

  /// The description for the remove line segments command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove line segments'**
  String get mpCommandDescriptionRemoveLineSegments;

  /// The description for the remove lines command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove lines'**
  String get mpCommandDescriptionRemoveLines;

  /// The description for the remove option command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get mpCommandDescriptionRemoveOptionFromElement;

  /// The description for the remove option from elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove option from multiple elements'**
  String get mpCommandDescriptionRemoveOptionFromElements;

  /// The description for the remove point command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove point'**
  String get mpCommandDescriptionRemovePoint;

  /// The description for the remove scrap command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove scrap'**
  String get mpCommandDescriptionRemoveScrap;

  /// The description for the remove XTherion image insert config command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get mpCommandDescriptionRemoveXTherionImageInsertConfig;

  /// The description for the reorder images command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Reorder images'**
  String get mpCommandDescriptionReorderImages;

  /// The description for the reorder scraps command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Reorder scraps'**
  String get mpCommandDescriptionReorderScraps;

  /// Undo/redo description for changing the file encoding. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Set file encoding'**
  String get mpCommandDescriptionSetFileEncoding;

  /// The description for the set option command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Set option'**
  String get mpCommandDescriptionSetOptionToElement;

  /// The description for the set option to elements command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Set option to multiple elements'**
  String get mpCommandDescriptionSetOptionToElements;

  /// The description for the simplify Bézier curve command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify Bézier curve'**
  String get mpCommandDescriptionSimplifyBezier;

  /// The description for the simplify line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify line'**
  String get mpCommandDescriptionSimplifyLine;

  /// The description for the simplify lines command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify lines'**
  String get mpCommandDescriptionSimplifyLines;

  /// The description for the simplify straight line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify straight line'**
  String get mpCommandDescriptionSimplifyStraight;

  /// The description for the simplify Bézier curve line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify into Bézier curve'**
  String get mpCommandDescriptionSimplifyToBezier;

  /// The description for the simplify into straight line command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Simplify into straight line'**
  String get mpCommandDescriptionSimplifyToStraight;

  /// The description for the substitute line segments command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Substitute line segments'**
  String get mpCommandDescriptionSubstituteLineSegments;

  /// The description for the toggle reverse option command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Toggle reverse option'**
  String get mpCommandDescriptionToggleReverseOption;

  /// The description for the toggle smooth option command. Used on: MPTextToUser._initializeCommandDescriptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Toggle smooth option'**
  String get mpCommandDescriptionToggleSmoothOption;

  /// The error message for invalid context value. Used on: lib/src/widgets/options/mp_context_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Both fields are mandatory'**
  String get mpContextInvalidValueErrorMessage;

  /// The error message for invalid copyright value. Used on: lib/src/widgets/options/mp_copyright_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid copyright message'**
  String get mpCopyrightInvalidMessageErrorMessage;

  /// The label for the copyright message. Used on: lib/src/widgets/options/mp_copyright_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get mpCopyrightMessageLabel;

  /// The hint for the end date field in the date interval dialog. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]'**
  String get mpDateIntervalEndDateHint;

  /// The label for the end date type. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get mpDateIntervalEndDateLabel;

  /// The label for the interval date type. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get mpDateIntervalIntervalLabel;

  /// The error message for invalid end date format. Used on: _MPDateIntervalInputWidgetState.setState
  ///
  /// In en, this message translates to:
  /// **'Invalid end date'**
  String get mpDateIntervalInvalidEndDateFormatErrorMessage;

  /// The error message for invalid start date format. Used on: _MPDateIntervalInputWidgetState.setState
  ///
  /// In en, this message translates to:
  /// **'Invalid start date'**
  String get mpDateIntervalInvalidStartDateFormatErrorMessage;

  /// The label for the single date type. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mpDateIntervalSingleDateLabel;

  /// The hint for the start date field in the date interval dialog. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] or \'-\''**
  String get mpDateIntervalStartDateHint;

  /// The label for the start date type. Used on: _MPDateIntervalInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get mpDateIntervalStartDateLabel;

  /// The error message for invalid date value. Used on: lib/src/widgets/options/mp_date_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid date/interval'**
  String get mpDateValueInvalidValueErrorMessage;

  /// Label for the Areas tab in the default options overlay. Used on: MPDefaultOptionsOverlayWindowWidget
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get mpDefaultOptionsAreasTab;

  /// Label for the Lines tab in the default options overlay. Used on: MPDefaultOptionsOverlayWindowWidget
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get mpDefaultOptionsLinesTab;

  /// Label for the Points tab in the default options overlay. Used on: MPDefaultOptionsOverlayWindowWidget
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get mpDefaultOptionsPointsTab;

  /// Label for the Reset button in the default options overlay. Clears all stored defaults for the current element type. Used on: MPDefaultOptionsOverlayWindowWidget
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get mpDefaultOptionsReset;

  /// Title for the default options overlay window. Used on: MPDefaultOptionsOverlayWindowWidget
  ///
  /// In en, this message translates to:
  /// **'Default options'**
  String get mpDefaultOptionsTitle;

  /// Tooltip for the default options toolbar button. Used on: TH2FileEditBodyWidget
  ///
  /// In en, this message translates to:
  /// **'Default options'**
  String get mpDefaultOptionsToolbarTooltip;

  /// The label for the above dimension type. Used on: lib/src/widgets/options/mp_dimensions_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get mpDimensionsAboveLabel;

  /// The label for the below dimension type. Used on: lib/src/widgets/options/mp_dimensions_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get mpDimensionsBelowLabel;

  /// The error message for invalid dimensions value. Used on: lib/src/widgets/options/mp_dimensions_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid dimension value'**
  String get mpDimensionsInvalidValueErrorMessage;

  /// The label for the distance type. Used on: lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get mpDistDistanceLabel;

  /// The error message for invalid distance value. Used on: lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid numeric distance value'**
  String get mpDistInvalidValueErrorMessage;

  /// The error message for invalid double value. Used on: lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid numeric value'**
  String get mpDoubleValueInvalidValueErrorMessage;

  /// The status bar message when editing a line. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Editing line'**
  String get mpEditSingleLineStateStatusBarMessage;

  /// The label for the encoding type. Used on: MPEncodingWidgetState.build, _MPAddFileDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get mpEncodingLabel;

  /// Label shown before the filename (basename) in the parsing error dialog. Used on: MPErrorDialog
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get mpErrorDialogFilenameLabel;

  /// Label shown before the full file path in the parsing error dialog. Used on: MPErrorDialog
  ///
  /// In en, this message translates to:
  /// **'Full path'**
  String get mpErrorDialogFullPathLabel;

  /// The error message displayed when there is an error reading an XVI file. Used on: MPDialogAux.showNow
  ///
  /// In en, this message translates to:
  /// **'Error reading XVI file'**
  String get mpErrorReadingXVIFile;

  /// The label for the explored length type. Used on: lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get mpExploredLengthLabel;

  /// The label for the extend station type. Used on: lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpExtendStationLabel;

  /// The label for the ID type. Used on: lib/src/widgets/options/mp_id_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get mpIDIDLabel;

  /// The error message for invalid ID value. Used on: _MPAddScrapDialogWidgetState._computeScrapIDError, lib/src/widgets/options/mp_id_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid ID: must be a sequence of characters A-Z, a-z, 0-9 and _-/ (not starting with ‘-’).'**
  String get mpIDInvalidValueErrorMessage;

  /// The error message for missing ID value. Used on: _MPAddScrapDialogWidgetState._computeScrapIDError
  ///
  /// In en, this message translates to:
  /// **'ID is required'**
  String get mpIDMissingErrorMessage;

  /// The error message for non-unique ID value. Used on: _MPAddScrapDialogWidgetState._computeScrapIDError, lib/src/widgets/options/mp_id_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'ID must be unique'**
  String get mpIDNonUniqueValueErrorMessage;

  /// The label for the size type. Used on: lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get mpLSizeLabel;

  /// The description for the centimeter length unit. Used on: MPTextToUser._initializeLengthUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'centimeter'**
  String get mpLengthUnitCentimeter;

  /// The abbreviation for the centimeter length unit. Used on: MPTextToUser._initializeLengthUnitTypeAbbreviationAsString
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get mpLengthUnitCentimeterAbbreviation;

  /// The description for the foot length unit. Used on: MPTextToUser._initializeLengthUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'feet'**
  String get mpLengthUnitFoot;

  /// The abbreviation for the foot length unit. Used on: MPTextToUser._initializeLengthUnitTypeAbbreviationAsString
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get mpLengthUnitFootAbbreviation;

  /// The description for the inch length unit. Used on: MPTextToUser._initializeLengthUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'inch'**
  String get mpLengthUnitInch;

  /// The abbreviation for the inch length unit. Used on: MPTextToUser._initializeLengthUnitTypeAbbreviationAsString
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get mpLengthUnitInchAbbreviation;

  /// The description for the meter length unit. Used on: MPTextToUser._initializeLengthUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'meter'**
  String get mpLengthUnitMeter;

  /// The abbreviation for the meter length unit. Used on: MPTextToUser._initializeLengthUnitTypeAbbreviationAsString
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get mpLengthUnitMeterAbbreviation;

  /// The description for the yard length unit. Used on: MPTextToUser._initializeLengthUnitTypeAsString
  ///
  /// In en, this message translates to:
  /// **'yard'**
  String get mpLengthUnitYard;

  /// The abbreviation for the yard length unit. Used on: MPTextToUser._initializeLengthUnitTypeAbbreviationAsString
  ///
  /// In en, this message translates to:
  /// **'yd'**
  String get mpLengthUnitYardAbbreviation;

  /// The label for the height type. Used on: lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpLineHeightHeightLabel;

  /// The error message for invalid line height value. Used on: lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid line height'**
  String get mpLineHeightInvalidValueErrorMessage;

  /// The title for the line segment type. Used on: MPLineSegmentTypeOptionsOverlayWindowWidget.build
  ///
  /// In en, this message translates to:
  /// **'Line segment type'**
  String get mpLineSegmentTypeTypesTitle;

  /// The label for the mark text type. Used on: lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get mpMarkTextLabel;

  /// The label for points, lines, and areas moving status bar messagee. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_moving_elements.dart
  ///
  /// In en, this message translates to:
  /// **'Moving {pointsAmount} point(s), {linesAmount} line(s), and {areaAmount} area(s)'**
  String mpMovingElementsStateAreasLinesAndPointsStatusBarMessage(
    Object pointsAmount,
    Object linesAmount,
    Object areaAmount,
  );

  /// The label for the moving end control points status bar message. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_moving_end_control_points.dart
  ///
  /// In en, this message translates to:
  /// **'Moving {endPointsAmount} end control points'**
  String mpMovingEndControlPointsStateBarMessage(Object endPointsAmount);

  /// The label for the moving single control point status bar message. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_moving_single_control_point.dart
  ///
  /// In en, this message translates to:
  /// **'Moving control point'**
  String get mpMovingSingleControlPointStateBarMessage;

  /// The label for the all choice in the multiple elements clicked dialog. Used on: lib/src/widgets/mp_multiple_elements_clicked_widget.dart, lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mpMultipleElementsClickedAllChoice;

  /// The title for the multiple elements clicked dialog. Used on: lib/src/widgets/mp_multiple_elements_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Multiple elements clicked'**
  String get mpMultipleElementsClickedTitle;

  /// The title for the multiple end control points clicked dialog. Used on: lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Multiple points clicked'**
  String get mpMultipleEndControlPointsClickedTitle;

  /// The label for the control point 1 in the multiple end control points dialog. Used on: lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Control point 1'**
  String get mpMultipleEndControlPointsControlPoint1;

  /// The label for the control point 2 in the multiple end control points dialog. Used on: lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Control point 2'**
  String get mpMultipleEndControlPointsControlPoint2;

  /// The label for the end point in the multiple end control points dialog. Used on: lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'End point'**
  String get mpMultipleEndControlPointsEndPoint;

  /// The label for the name station type. Used on: lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpNameStationLabel;

  /// The label for the huge named scale. Used on: MPTextToUser._initializeNamedScaleOptionsAsString
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get mpNamedScaleHuge;

  /// The label for the large named scale. Used on: MPTextToUser._initializeNamedScaleOptionsAsString
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get mpNamedScaleLarge;

  /// The label for the normal named scale. Used on: MPTextToUser._initializeNamedScaleOptionsAsString
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get mpNamedScaleNormal;

  /// The label for the small named scale. Used on: MPTextToUser._initializeNamedScaleOptionsAsString
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get mpNamedScaleSmall;

  /// The label for the tiny named scale. Used on: MPTextToUser._initializeNamedScaleOptionsAsString
  ///
  /// In en, this message translates to:
  /// **'Tiny'**
  String get mpNamedScaleTiny;

  /// The label for the create new scrap action in the new scrap dialog. Used on: _MPAddFileDialogWidgetState.build, _MPAddScrapDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Create new scrap'**
  String get mpNewScrapDialogCreateNewScrap;

  /// The hint text for the scrap ID input field in the new scrap dialog. Used on: _MPAddScrapDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Enter the scrap identifier'**
  String get mpNewScrapDialogCreateScrapIDHint;

  /// The label for the scrap ID input field in the new scrap dialog. Used on: _MPAddScrapDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Scrap ID'**
  String get mpNewScrapDialogCreateScrapIDLabel;

  /// Tooltip shown when no Therion executable is available. Used on: MPDialogAux.chooseTHConfigAndRunTherion, MPDialogAux.runTherionWithLastTHConfig, _MapiahHomeState.build, _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'No Therion found'**
  String get mpNoTherionFound;

  /// The label for points, lines, and areas selected status bar messagee. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart
  ///
  /// In en, this message translates to:
  /// **'{pointsAmount} point(s), {linesAmount} line(s), and {areaAmount} area(s) selected'**
  String mpNonEmptySelectionStateAreasLinesAndPointsStatusBarMessage(
    Object pointsAmount,
    Object linesAmount,
    Object areaAmount,
  );

  /// The label for the line segment types in the options edit dialog. Used on: MPLineSegmentTypeWidget.build
  ///
  /// In en, this message translates to:
  /// **'Line segments types'**
  String get mpOptionsEditLineSegmentTypes;

  /// The title for the options edit dialog. Used on: _MPScrapOptionsEditWidgetState.build, lib/src/widgets/mp_line_segment_options_edit_overlay_window_widget.dart, lib/src/widgets/mp_options_edit_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get mpOptionsEditTitle;

  /// The label for the all type. Used on: _MPSnapTargetsWidgetState._buildLinePointTargetGroup, _MPSnapTargetsWidgetState._buildPointTargetGroup, lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mpPLATypeAll;

  /// The title for the area types. Used on: MPPLATypeWidget.build, lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Area types'**
  String get mpPLATypeAreaTitle;

  /// The label for the current type. Used on: lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get mpPLATypeCurrent;

  /// The label for the dropdown select a type. Used on: _MPPLATypeDropdownWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get mpPLATypeDropdownSelectATypeLabel;

  /// The label for the last used type. Used on: lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get mpPLATypeLastUsed;

  /// The title for the line types. Used on: MPPLATypeWidget.build, lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Line types'**
  String get mpPLATypeLineTitle;

  /// The label for the most used type. Used on: lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get mpPLATypeMostUsed;

  /// The label for the none type. Used on: _MPSnapTargetsWidgetState._buildLinePointTargetGroup, _MPSnapTargetsWidgetState._buildPointTargetGroup
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mpPLATypeNone;

  /// The title for the point types. Used on: MPPLATypeWidget.build, lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Point types'**
  String get mpPLATypePointTitle;

  /// The label for the invalid type. Used on: lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid type'**
  String get mpPLATypeUnknownInvalid;

  /// The label for the unknown type. Used on: lib/src/widgets/mp_pla_type_options_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get mpPLATypeUnknownLabel;

  /// The label for the named scale option. Used on: MPTextToUser._initializePLScaleCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Named'**
  String get mpPLScaleCommandOptionNamed;

  /// The label for the numeric scale option. Used on: MPTextToUser._initializePLScaleCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get mpPLScaleCommandOptionNumeric;

  /// The label for the numeric scale type. Used on: lib/src/widgets/options/mp_pl_scale_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get mpPLScaleNumericLabel;

  /// The label for the ceiling type. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get mpPassageHeightCeiling;

  /// The label for the ceiling type. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Ceiling'**
  String get mpPassageHeightCeilingLabel;

  /// The label for the depth type. Used on: MPTextToUser._initializePassageHeightModesChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPassageHeightDepth;

  /// The label for the depth type. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPassageHeightDepthLabel;

  /// The warning message for invalid depth. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid depth'**
  String get mpPassageHeightDepthWarning;

  /// The label for the distance between floor and ceiling type. Used on: MPTextToUser._initializePassageHeightModesChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Distance floor ceiling'**
  String get mpPassageHeightDistanceBetweenFloorAndCeiling;

  /// The label for the distance between floor and ceiling type. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Floor to ceiling'**
  String get mpPassageHeightDistanceBetweenFloorAndCeilingLabel;

  /// The label for the distance to ceiling and distance to floor type. Used on: MPTextToUser._initializePassageHeightModesChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Distance to ceiling and to floor'**
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloor;

  /// The label for the distance to ceiling and distance to floor type. Used on: none
  ///
  /// In en, this message translates to:
  /// **'To ceiling/to floor'**
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloorLabel;

  /// The label for the floor type. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get mpPassageHeightFloor;

  /// The label for the floor type. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get mpPassageHeightFloorLabel;

  /// The label for the height type. Used on: MPTextToUser._initializePassageHeightModesChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPassageHeightHeight;

  /// The label for the height type. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPassageHeightHeightLabel;

  /// The warning message for invalid height. Used on: lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid height'**
  String get mpPassageHeightHeightWarning;

  /// The hint for the name field in the person name dialog. Used on: _MPPersonNameInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'\'FirstName Surname\' or \'FirstNames/Surnames\''**
  String get mpPersonNameHint;

  /// The error message for invalid person name format. Used on: _MPPersonNameInputWidgetState.setState
  ///
  /// In en, this message translates to:
  /// **'Invalid person name'**
  String get mpPersonNameInvalidFormatErrorMessage;

  /// The label for the name field in the person name dialog. Used on: _MPPersonNameInputWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get mpPersonNameLabel;

  /// The label for the chimney type. Used on: MPTextToUser._initializePointHeightValueModeAsString
  ///
  /// In en, this message translates to:
  /// **'Chimney'**
  String get mpPointHeightChimney;

  /// The warning message for invalid length. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid length'**
  String get mpPointHeightLengthWarning;

  /// The label for the pit type. Used on: MPTextToUser._initializePointHeightValueModeAsString
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get mpPointHeightPit;

  /// The label for the presumed minus type. Used on: MPTextToUser._initializePointHeightValueModeAsString
  ///
  /// In en, this message translates to:
  /// **'Minus presumed (-?)'**
  String get mpPointHeightPresumedMinus;

  /// The label for the presumed plus type. Used on: MPTextToUser._initializePointHeightValueModeAsString
  ///
  /// In en, this message translates to:
  /// **'Plus presumed (+?)'**
  String get mpPointHeightPresumedPlus;

  /// The label for the step type. Used on: MPTextToUser._initializePointHeightValueModeAsString
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get mpPointHeightStep;

  /// The label for the chimney height type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPointHeightValueChimneyLabel;

  /// The label for the height observation type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Chimeny height (treated as positive)'**
  String get mpPointHeightValueChimneyObservation;

  /// The label for the pit depth type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get mpPointHeightValuePitLabel;

  /// The label for the depth observation type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Pit depth (treated as negative)'**
  String get mpPointHeightValuePitObservation;

  /// The label for the step height type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get mpPointHeightValueStepLabel;

  /// The label for the step observation type. Used on: lib/src/widgets/options/mp_point_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Step height (treated as positive)'**
  String get mpPointHeightValueStepObservation;

  /// The warning message for invalid angle. Used on: MPProjectionOptionWidgetState._updateIsValid
  ///
  /// In en, this message translates to:
  /// **'Invalid angle (0 <= angle < 360)'**
  String get mpProjectionAngleWarning;

  /// The label for the azimuth type. Used on: MPProjectionOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Azimuth'**
  String get mpProjectionElevationAzimuthLabel;

  /// The label for the index type. Used on: MPProjectionOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Index (optional)'**
  String get mpProjectionIndexLabel;

  /// The label for the elevation projection mode. Used on: MPTextToUser._initializeProjectionModeTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get mpProjectionModeElevation;

  /// The label for the extended projection mode. Used on: MPTextToUser._initializeProjectionModeTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get mpProjectionModeExtended;

  /// The label for the none projection mode. Used on: MPTextToUser._initializeProjectionModeTypeAsString
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mpProjectionModeNone;

  /// The label for the plan projection mode. Used on: MPTextToUser._initializeProjectionModeTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get mpProjectionModePlan;

  /// The label for the free text scrap type. Used on: lib/src/widgets/options/mp_scrap_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Free text'**
  String get mpScrapFreeText;

  /// The label for the from file scrap type. Used on: lib/src/widgets/options/mp_scrap_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get mpScrapFromFile;

  /// The label for the scrap ID type. Used on: lib/src/widgets/options/mp_scrap_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Scrap ID'**
  String get mpScrapLabel;

  /// The label for the real units per drawing point type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get mpScrapScale11Label;

  /// The label for the real to 1 point type. Used on: MPScrapScaleOptionWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Real to 1 point'**
  String get mpScrapScale1ValueLabel;

  /// The label for the real units per drawing point observation type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real units per drawing point'**
  String get mpScrapScale1ValueObservation;

  /// The label for the drawing units per drawing point type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get mpScrapScale21Label;

  /// The label for the real units per drawing point type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real'**
  String get mpScrapScale22Label;

  /// The label for the real units per drawing points observation type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'real units per drawing points'**
  String get mpScrapScale2ValueObservation;

  /// The label for the real to points type. Used on: MPScrapScaleOptionWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Real to points'**
  String get mpScrapScale2ValuesLabel;

  /// The label for the drawing X1 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Draw X1'**
  String get mpScrapScale81Label;

  /// The label for the drawing Y1 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Draw Y1'**
  String get mpScrapScale82Label;

  /// The label for the drawing X2 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Draw X2'**
  String get mpScrapScale83Label;

  /// The label for the drawing Y2 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Draw Y2'**
  String get mpScrapScale84Label;

  /// The label for the real X1 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real X1'**
  String get mpScrapScale85Label;

  /// The label for the real Y1 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real Y1'**
  String get mpScrapScale86Label;

  /// The label for the real X2 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real X2'**
  String get mpScrapScale87Label;

  /// The label for the real Y2 type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real Y2'**
  String get mpScrapScale88Label;

  /// The label for the real coordinates per drawing coordinates observation type. Used on: MPScrapScaleOptionWidgetState._buildFormForOption
  ///
  /// In en, this message translates to:
  /// **'Real coordinates per drawing coordinates'**
  String get mpScrapScale8ValueObservation;

  /// The label for the real to drawing coordinates type. Used on: MPScrapScaleOptionWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Real to drawing coordinates'**
  String get mpScrapScale8ValuesLabel;

  /// The error message for invalid scale reference. Used on: MPScrapScaleOptionWidgetState._updateIsValid
  ///
  /// In en, this message translates to:
  /// **'Invalid scale ref'**
  String get mpScrapScaleInvalidValueError;

  /// The warning message for the scrap option. Used on: lib/src/widgets/options/mp_scrap_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Scrap not set'**
  String get mpScrapWarning;

  /// The abbreviation for seconds unit. Used on: none
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get mpSeconds;

  /// Label for the Mapiah quadratic new line creation method. Used on: enum-backed settings UI
  ///
  /// In en, this message translates to:
  /// **'Mapiah quadratic'**
  String get mpSettingsEnumNewLineCreationMethodMapiahQuadratic;

  /// Label for the xTherion cubic smooth new line creation method. Used on: enum-backed settings UI
  ///
  /// In en, this message translates to:
  /// **'xTherion cubic smooth'**
  String get mpSettingsEnumNewLineCreationMethodXTherionCubicSmooth;

  /// Label for the cost-map A* tracing strategy. Used on: enum-backed settings UI
  ///
  /// In en, this message translates to:
  /// **'Cost-map A*'**
  String get mpSettingsEnumTraceStrategyCostMapAStar;

  /// Label for the local color-guided tracing strategy. Used on: enum-backed settings UI
  ///
  /// In en, this message translates to:
  /// **'Local color-guided'**
  String get mpSettingsEnumTraceStrategyLocalColorGuided;

  /// Validation message for invalid integer values in settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid integer'**
  String get mpSettingsInvalidInteger;

  /// Validation message for invalid double values in settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get mpSettingsInvalidNumber;

  /// The title for the Settings page help dialog. Used on: _MPSettingsPageState.build
  ///
  /// In en, this message translates to:
  /// **'Settings Help'**
  String get mpSettingsPageHelpDialogTitle;

  /// The title for the settings page. Used on: _MPSettingsPageState.build, _MapiahHomeState.build
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mpSettingsPageTitle;

  /// Section title for main settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mpSettingsSectionMain;

  /// Section title for TH2 edit settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'TH2 edit'**
  String get mpSettingsSectionTH2Edit;

  /// Section title for Therion settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Therion'**
  String get mpSettingsSectionTherion;

  /// Label for locale setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get mpSettingsSettingMainLocaleID;

  /// Label for Therion executable path setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Therion executable path'**
  String get mpSettingsSettingMainTherionExecutablePath;

  /// Label for Therion run parameters setting. Used on: lib/src/pages/mp_settings_page.dart, lib/src/widgets/mp_run_therion_dialog_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Therion run parameters'**
  String get mpSettingsSettingMainTherionRunParameters;

  /// The label for the TH2 edit setting that enables scale, rotate and mirror actions for selected elements. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Enable element transforms'**
  String get mpSettingsSettingTH2EditEnableElementTransforms;

  /// Label for enabling the special border used when an element has ID set. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Enable special border for ID set'**
  String get mpSettingsSettingTH2EditEnableSpecialBorderForIDSet;

  /// Label for enabling the special border used on slope lines with no l-size on any line segment. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Enable special border for slope line without l-size'**
  String
  get mpSettingsSettingTH2EditEnableSpecialBorderForSlopeLineWithoutLSize;

  /// Label for enabling the special border used when an element has visibility off. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Enable special border for visibility off'**
  String get mpSettingsSettingTH2EditEnableSpecialBorderForVisibilityOff;

  /// Label for TH2 line thickness setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Line thickness'**
  String get mpSettingsSettingTH2EditLineThickness;

  /// Label for the TH2 new line creation method setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'New line creation method'**
  String get mpSettingsSettingTH2EditNewLineCreationMethod;

  /// Label for TH2 edit nudge factor setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Nudge factor'**
  String get mpSettingsSettingTH2EditNudgeFactor;

  /// Label for TH2 point radius setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Point radius'**
  String get mpSettingsSettingTH2EditPointRadius;

  /// Label for TH2 selection tolerance setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Selection tolerance'**
  String get mpSettingsSettingTH2EditSelectionTolerance;

  /// Label for TH2 show direction ticks on non-selected lines setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Show direction ticks on non-selected lines'**
  String get mpSettingsSettingTH2EditShowDirectionTicksOnNonSelectedLines;

  /// Label for TH2 show last used PLA type buttons setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Show last used PLA type buttons'**
  String get mpSettingsSettingTH2EditShowLastUsedPLATypeButtons;

  /// Label for TH2 snap angle setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Snap angle'**
  String get mpSettingsSettingTH2EditSnapAngle;

  /// Label for the TH2 tracing strategy setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Tracing strategy'**
  String get mpSettingsSettingTH2EditTraceStrategy;

  /// Label for the Therion debug log 1 setting. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Debug log 1'**
  String get mpSettingsSettingTherionDebugLog1;

  /// Tooltip for the tracing strategy setting in the settings page. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Choose the tracing algorithm. Local color-guided is the default; cost-map A* is better for noisy or broken rasters.'**
  String get mpSettingsTraceStrategyTooltip;

  /// The label for the choose file button. Used on: lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get mpSketchChooseFileButtonLabel;

  /// The error message for invalid coordinate. Used on: lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinate'**
  String get mpSketchCoordinateInvalid;

  /// The label for the filename type. Used on: lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get mpSketchFilenameLabel;

  /// The label for the X coordinate type. Used on: lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get mpSketchXLabel;

  /// The label for the Y coordinate type. Used on: lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get mpSketchYLabel;

  /// The label for the line point snap. Used on: _MPSnapTargetsWidgetState._buildLinePointTargetGroup
  ///
  /// In en, this message translates to:
  /// **'Line point snap'**
  String get mpSnapLinePointTargetsLabel;

  /// The label for the point snap. Used on: _MPSnapTargetsWidgetState._buildPointTargetGroup
  ///
  /// In en, this message translates to:
  /// **'Point snap'**
  String get mpSnapPointTargetsLabel;

  /// The label for the line point snap target option. Used on: MPTextToUser._initializeSnapLinePointTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Line points'**
  String get mpSnapTargetLinePoint;

  /// The label for the line point by type snap target option. Used on: MPTextToUser._initializeSnapLinePointTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Line points by line type'**
  String get mpSnapTargetLinePointByType;

  /// The label for the none snap target option. Used on: MPTextToUser._initializeSnapLinePointTargetAsString, MPTextToUser._initializeSnapPointTargetAsString
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mpSnapTargetNone;

  /// The label for the point snap target option. Used on: MPTextToUser._initializeSnapPointTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get mpSnapTargetPoint;

  /// The label for the point by type snap target option. Used on: MPTextToUser._initializeSnapPointTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Points by type'**
  String get mpSnapTargetPointByType;

  /// The label for the grid line snap target option. Used on: MPTextToUser._initializeSnapXVIFileTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Grid lines'**
  String get mpSnapTargetXVIFileGridLine;

  /// The label for the grid line intersection snap target option. Used on: MPTextToUser._initializeSnapXVIFileTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Grid line intersections'**
  String get mpSnapTargetXVIFileGridLineIntersection;

  /// The label for the shot snap target option. Used on: MPTextToUser._initializeSnapXVIFileTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Shots'**
  String get mpSnapTargetXVIFileShot;

  /// The label for the sketch line snap target option. Used on: MPTextToUser._initializeSnapXVIFileTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Sketch lines'**
  String get mpSnapTargetXVIFileSketchLine;

  /// The label for the station snap target option. Used on: MPTextToUser._initializeSnapXVIFileTargetAsString
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get mpSnapTargetXVIFileStation;

  /// The label for the XVI file snap. Used on: _MPSnapTargetsWidgetState._buildXVIFileTargetGroup
  ///
  /// In en, this message translates to:
  /// **'XVI file snap'**
  String get mpSnapXVIFileTargetsLabel;

  /// The label for the station names prefix type. Used on: lib/src/widgets/options/mp_station_names_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get mpStationNamesPrefixLabel;

  /// The error message for empty station names prefix. Used on: lib/src/widgets/options/mp_station_names_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Prefix empty'**
  String get mpStationNamesPrefixMessageEmpty;

  /// The label for the station names suffix type. Used on: lib/src/widgets/options/mp_station_names_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get mpStationNamesSuffixLabel;

  /// The error message for empty station names suffix. Used on: lib/src/widgets/options/mp_station_names_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Suffix empty'**
  String get mpStationNamesSuffixMessageEmpty;

  /// The warning message for the station type option. Used on: lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station not set'**
  String get mpStationTypeOptionWarning;

  /// The warning message for invalid survey part in station name type option. Used on: lib/src/widgets/options/mp_station_name_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid survey'**
  String get mpStationTypeSurveyInvalidWarning;

  /// The label for the survey part field in station name type option. Used on: lib/src/widgets/options/mp_station_name_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get mpStationTypeSurveyLabel;

  /// The warning message for empty unique part in station name type option. Used on: lib/src/widgets/options/mp_station_name_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station name not set'**
  String get mpStationTypeUniqueEmptyWarning;

  /// The warning message for invalid unique part in station name type option. Used on: lib/src/widgets/options/mp_station_name_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Invalid station name'**
  String get mpStationTypeUniqueInvalidWarning;

  /// The label for the unique part field in station name type option. Used on: lib/src/widgets/options/mp_station_name_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station name'**
  String get mpStationTypeUniqueLabel;

  /// The label for the add field button. Used on: lib/src/widgets/options/mp_stations_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get mpStationsAddField;

  /// The error message for empty station name. Used on: lib/src/widgets/options/mp_stations_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station name empty'**
  String get mpStationsNameEmpty;

  /// The label for the station name type. Used on: lib/src/widgets/options/mp_stations_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mpStationsNameLabel;

  /// The status bar message when editing a line point showing its orientation and length. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_edit_single_line.dart
  ///
  /// In en, this message translates to:
  /// **'Orientation {orientation}°{forcedOrientation}, LSize {lsize}{forcedLSize}'**
  String mpStatusBarMessageEditLinePointOrientationLSize(
    Object orientation,
    Object forcedOrientation,
    Object lsize,
    Object forcedLSize,
  );

  /// The forced label for the status bar message when editing a line point. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_edit_single_line.dart
  ///
  /// In en, this message translates to:
  /// **' (forced)'**
  String get mpStatusBarMessageEditLinePointOrientationLSizeForced;

  /// The status bar message when a single area is selected showing its area borders list. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - {areaBordersCount} area border(s): {areaBordersList}'**
  String mpStatusBarMessageSingleSelectedAreaAreaBordersList(
    Object areaBordersCount,
    Object areaBordersList,
  );

  /// The status bar message when a single area is selected with no area borders. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - no area borders'**
  String get mpStatusBarMessageSingleSelectedAreaNoAreaBorders;

  /// The status bar message when a single area is selected. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **'Area {areaType}'**
  String mpStatusBarMessageSingleSelectedAreaType(Object areaType);

  /// The status bar message when a single element is selected showing its ID. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **', ID: {elementID}'**
  String mpStatusBarMessageSingleSelectedElementID(Object elementID);

  /// Appended to the status bar message when a control point is selected in single line edit mode. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - selected: control point'**
  String get mpStatusBarMessageSingleSelectedElementSelectedControlPoint;

  /// Appended to the status bar message showing how many end points are selected in single line edit mode. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - selected: {count} end point(s)'**
  String mpStatusBarMessageSingleSelectedElementSelectedEndPoints(Object count);

  /// The status bar message when a single element with subtype is selected. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **', subtype {subtype}'**
  String mpStatusBarMessageSingleSelectedElementSubtype(Object subtype);

  /// The status bar message when a single line is selected showing its line segments count. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - {lineSegmentsCount} line segments ({straightLineSegmentsCount} straight, {bezierLineSegmentsCount} Bézier)'**
  String mpStatusBarMessageSingleSelectedLineLineSegmentsCount(
    Object lineSegmentsCount,
    Object straightLineSegmentsCount,
    Object bezierLineSegmentsCount,
  );

  /// The status bar message when a single line is selected with no line segments. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - no line segments'**
  String get mpStatusBarMessageSingleSelectedLineNoLineSegments;

  /// The status bar message when a single line is selected showing its parent area. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **' - border of {parentArea}'**
  String mpStatusBarMessageSingleSelectedLineParentArea(Object parentArea);

  /// The status bar message when a single line is selected. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **'Line {lineType}'**
  String mpStatusBarMessageSingleSelectedLineType(Object lineType);

  /// The status bar message when a single point is selected. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart
  ///
  /// In en, this message translates to:
  /// **'Point {pointType}'**
  String mpStatusBarMessageSingleSelectedPointType(Object pointType);

  /// The mouse position shown in the TH2 edit status bar. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'x: {x}, y: {y}'**
  String mpTH2FileEditPageMousePosition(Object x, Object y);

  /// The label for the text type. Used on: lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get mpTextTextLabel;

  /// The warning message for the text type option. Used on: lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Text not set'**
  String get mpTextTypeOptionWarning;

  /// Error message shown when Therion command execution fails. Used on: lib/src/auxiliary/mp_flatpak_therion_runner.dart, lib/src/auxiliary/mp_linux_therion_runner.dart, lib/src/auxiliary/mp_macos_therion_runner.dart, lib/src/auxiliary/mp_windows_therion_runner.dart
  ///
  /// In en, this message translates to:
  /// **'Error executing command: {commandLine}'**
  String mpTherionCannotExecuteCommand(Object commandLine);

  /// The label for the title type. Used on: lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mpTitleTextLabel;

  /// The label for the unrecognized command option. Used on: lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Unrecognized option'**
  String get mpUnrecognizedCommandOptionTextLabel;

  /// Snackbar message shown when joining lines at coinciding extremities finds no joinable extremities. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart
  ///
  /// In en, this message translates to:
  /// **'No coinciding extremities found between selected lines'**
  String get noCoincidingLineExtremitiesFound;

  /// Snackbar message shown when split lines at crossings finds no intersections. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart
  ///
  /// In en, this message translates to:
  /// **'No crossings found between selected lines'**
  String get noLinesAtCrossingsFound;

  /// The label for the parsing errors dialog. Used on: MPErrorDialog.build
  ///
  /// In en, this message translates to:
  /// **'Parsing errors'**
  String get parsingErrors;

  /// Accept button label in the telemetry consent dialog. Used on: lib/src/widgets/mp_telemetry_consent_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'Yes, participate'**
  String get telemetryConsentDialogAccept;

  /// Body text of the telemetry consent dialog. Used on: lib/src/widgets/mp_telemetry_consent_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'Mapiah can collect anonymous, aggregated usage data to help improve the app. No personal information, file contents or identifying data is ever collected or transmitted. You can change this setting at any time in Settings.'**
  String get telemetryConsentDialogBody;

  /// Decline button label in the telemetry consent dialog. Used on: lib/src/widgets/mp_telemetry_consent_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get telemetryConsentDialogDecline;

  /// Link text in the telemetry consent dialog that opens the full telemetry details page. Used on: lib/src/widgets/mp_telemetry_consent_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'Learn more about what is collected'**
  String get telemetryConsentDialogLearnMore;

  /// Title of the telemetry consent dialog shown on first launch. Used on: lib/src/widgets/mp_telemetry_consent_dialog.dart
  ///
  /// In en, this message translates to:
  /// **'Help improve Mapiah'**
  String get telemetryConsentDialogTitle;

  /// Link text on the settings page that re-opens the telemetry consent dialog. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Review telemetry details and consent'**
  String get telemetrySettingsReviewLink;

  /// Section title for telemetry settings. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetrySettingsSectionTitle;

  /// Label for the telemetry consent toggle on the settings page. Used on: lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data'**
  String get telemetrySettingsToggleLabel;

  /// The label for the add area button. Used on: lib/src/pages/th2_file_edit_page.dart
  ///
  /// In en, this message translates to:
  /// **'Add area (A)'**
  String get th2FileEditPageAddArea;

  /// The status bar message for the add area tool. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_add_area.dart
  ///
  /// In en, this message translates to:
  /// **'Select a line to be included as border of a new {type} area'**
  String th2FileEditPageAddAreaStatusBarMessage(Object type);

  /// The label for the add element options button. Used on: lib/src/pages/th2_file_edit_page.dart
  ///
  /// In en, this message translates to:
  /// **'Add element'**
  String get th2FileEditPageAddElementOptions;

  /// The label for the add image button. Used on: _MPAvailableImagesWidgetState.build, _TH2FileEditPageState._addElementButtons
  ///
  /// In en, this message translates to:
  /// **'Add image (I)'**
  String get th2FileEditPageAddImageButton;

  /// The label for the add line button. Used on: lib/src/pages/th2_file_edit_page.dart
  ///
  /// In en, this message translates to:
  /// **'Add line (L)'**
  String get th2FileEditPageAddLine;

  /// The status bar message for the add line tool. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_add_line.dart
  ///
  /// In en, this message translates to:
  /// **'Click to add a {type} line'**
  String th2FileEditPageAddLineStatusBarMessage(Object type);

  /// The status bar message for the add line to area tool. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_add_line_to_area.dart
  ///
  /// In en, this message translates to:
  /// **'Select a line to be included as border of the selected {type} area'**
  String th2FileEditPageAddLineToAreaStatusBarMessage(Object type);

  /// The label for the add point button. Used on: lib/src/pages/th2_file_edit_page.dart
  ///
  /// In en, this message translates to:
  /// **'Add point (P)'**
  String get th2FileEditPageAddPoint;

  /// The status bar message for the add point tool. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_add_point.dart
  ///
  /// In en, this message translates to:
  /// **'Click to add a {type} point'**
  String th2FileEditPageAddPointStatusBarMessage(Object type);

  /// The label for the add scrap button. Used on: _MPAvailableScrapsWidgetState.build, _TH2FileEditPageState._addElementButtons
  ///
  /// In en, this message translates to:
  /// **'Add scrap (K)'**
  String get th2FileEditPageAddScrapButton;

  /// The title for the change active scrap dialog. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Change active scrap'**
  String get th2FileEditPageChangeActiveScrapTitle;

  /// The label for the change active scrap tool button. Used on: _TH2FileEditPageState._changeScrapButton
  ///
  /// In en, this message translates to:
  /// **'Change active scrap (Alt+K)'**
  String get th2FileEditPageChangeActiveScrapTool;

  /// The title for the change image dialog. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Change images'**
  String get th2FileEditPageChangeImageTitle;

  /// The label for the change image tool button. Used on: _TH2FileEditPageState._changeImageButton
  ///
  /// In en, this message translates to:
  /// **'Change image (Alt+I)'**
  String get th2FileEditPageChangeImageTool;

  /// Tooltip for starting semi-automatic line tracing in add line mode. Used on: TH2FileEditAddElementContextFABsPanel
  ///
  /// In en, this message translates to:
  /// **'Continue tracing (Ctrl+Shift+T)'**
  String get th2FileEditPageContinueTracing;

  /// Tooltip for the convert line segments to Bézier FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Convert line segments to Bézier (J)'**
  String get th2FileEditPageConvertLineSegmentsToBezier;

  /// Tooltip for the convert line segments to straight FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Convert line segments to straight (Shift+J)'**
  String get th2FileEditPageConvertLineSegmentsToStraight;

  /// Tooltip for the copy elements FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Copy elements (Ctrl+C)'**
  String get th2FileEditPageCopyElements;

  /// The tooltip for the copy scrap button. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Copy scrap'**
  String get th2FileEditPageCopyScrapButton;

  /// Tooltip for the create map connection lines FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Create map connection lines'**
  String get th2FileEditPageCreateMapConnectionLines;

  /// Tooltip for the cut elements FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Cut elements (Ctrl+X)'**
  String get th2FileEditPageCutElements;

  /// The tooltip for the cut scrap button. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Cut scrap'**
  String get th2FileEditPageCutScrapButton;

  /// Tooltip for the deselect all elements FAB (when all are selected). Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Deselect all elements (Ctrl+D)'**
  String get th2FileEditPageDeselectAllElements;

  /// Tooltip for the deselect all end points FAB (when all are selected). Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Deselect all end points (Ctrl+D)'**
  String get th2FileEditPageDeselectAllEndPoints;

  /// Tooltip for disabling image edit mode from the available images list. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Stop editing image'**
  String get th2FileEditPageDisableImageEditModeButton;

  /// Tooltip for the duplicate elements FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Duplicate elements (Ctrl+Shift+D)'**
  String get th2FileEditPageDuplicateElements;

  /// The tooltip for the duplicate scrap button. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Duplicate scrap'**
  String get th2FileEditPageDuplicateScrapButton;

  /// The status bar message shown while selected-element rotation mode is active. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_element_rotate.dart
  ///
  /// In en, this message translates to:
  /// **'Element rotate mode'**
  String get th2FileEditPageElementRotateStatusBarMessage;

  /// The status bar message for the empty selection. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_empty_selection.dart
  ///
  /// In en, this message translates to:
  /// **'Empty selection'**
  String get th2FileEditPageEmptySelectionStatusBarMessage;

  /// Tooltip for enabling image edit mode from the available images list. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Edit image'**
  String get th2FileEditPageEnableImageEditModeButton;

  /// Tooltip for the flip elements horizontally FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Flip elements horizontally (H)'**
  String get th2FileEditPageFlipElementsHorizontally;

  /// Tooltip for the flip elements vertically FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Flip elements vertically (V)'**
  String get th2FileEditPageFlipElementsVertically;

  /// Tooltip for the flip image horizontally FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Flip image horizontally (H)'**
  String get th2FileEditPageFlipImageHorizontally;

  /// Tooltip for the flip image vertically FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Flip image vertically (V)'**
  String get th2FileEditPageFlipImageVertically;

  /// The title for the TH2 File Edit help dialog. Used on: _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'TH2 File Edit Help'**
  String get th2FileEditPageHelpDialogTitle;

  /// Tooltip for the grid visibility checkbox on each XVI image row. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Toggle grid visibility'**
  String get th2FileEditPageImageGridVisibilityTooltip;

  /// The label shown on the image while move edit mode is active. Used on: lib/src/widgets/mp_image_operation_overlay_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get th2FileEditPageImageMoveOverlayLabel;

  /// The status bar message for the Mapiah image move preparation state. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_image_move.dart
  ///
  /// In en, this message translates to:
  /// **'Image transform mode'**
  String get th2FileEditPageImageMoveStatusBarMessage;

  /// The label shown on the image while rotate edit mode is active. Used on: lib/src/widgets/mp_image_operation_overlay_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get th2FileEditPageImageRotateOverlayLabel;

  /// The status bar message for the Mapiah image rotate preparation state. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_image_rotate.dart
  ///
  /// In en, this message translates to:
  /// **'Image rotate mode'**
  String get th2FileEditPageImageRotateStatusBarMessage;

  /// The label shown on the image while scale edit mode is active. Used on: lib/src/widgets/mp_image_operation_overlay_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get th2FileEditPageImageScaleOverlayLabel;

  /// The status bar message for the Mapiah image scale preparation state. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_image_scale.dart
  ///
  /// In en, this message translates to:
  /// **'Image scale mode'**
  String get th2FileEditPageImageScaleStatusBarMessage;

  /// Tooltip for the visibility checkbox on each image row. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Toggle image visibility'**
  String get th2FileEditPageImageVisibilityTooltip;

  /// Tooltip for the interactive simplify lines FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Interactive simplify lines (Ctrl+Alt+Shift+L)'**
  String get th2FileEditPageInteractiveSimplifyLines;

  /// Label for the canvas tolerance preview in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Canvas tolerance'**
  String get th2FileEditPageInteractiveSimplifyLinesCanvasToleranceLabel;

  /// Description shown in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Preview the selected lines while adjusting the simplification method and intensity.'**
  String get th2FileEditPageInteractiveSimplifyLinesDescription;

  /// Method label in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Force Bézier curves'**
  String get th2FileEditPageInteractiveSimplifyLinesForceBezier;

  /// Method label in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Force straight segments'**
  String get th2FileEditPageInteractiveSimplifyLinesForceStraight;

  /// Label for the intensity slider in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get th2FileEditPageInteractiveSimplifyLinesIntensityLabel;

  /// Method label in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Keep original segment types'**
  String get th2FileEditPageInteractiveSimplifyLinesKeepOriginal;

  /// Label above the method options in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get th2FileEditPageInteractiveSimplifyLinesMethodLabel;

  /// Label for the screen tolerance preview in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Screen tolerance equivalent'**
  String get th2FileEditPageInteractiveSimplifyLinesScreenToleranceLabel;

  /// Column header for the 'after simplification' count in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusAfterLabel;

  /// Column header for the 'before simplification' count in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusBeforeLabel;

  /// Row label for Bézier segment counts in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Bézier'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusBezierLabel;

  /// Section header for the before/after segment count table in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Segment counts'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusLabel;

  /// Row label for straight segment counts in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusStraightLabel;

  /// Row label for total segment counts in the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get th2FileEditPageInteractiveSimplifyLinesStatusTotalLabel;

  /// Title of the interactive line simplification dialog. Used on: MPInteractiveLineSimplificationDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Interactive simplify lines'**
  String get th2FileEditPageInteractiveSimplifyLinesTitle;

  /// Tooltip for the join lines at coinciding extremities FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Join lines at coinciding extremities (Ctrl+J)'**
  String get th2FileEditPageJoinLinesAtCoincidingExtremities;

  /// The label for the load image button. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Load image'**
  String get th2FileEditPageLoadImageButton;

  /// The label for the loading file message. Used on: _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Loading file {filename} ...'**
  String th2FileEditPageLoadingFile(Object filename);

  /// Tooltip for the merge areas FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Merge areas (Ctrl+M)'**
  String get th2FileEditPageMergeAreas;

  /// The label for the no redo available message. Used on: _TH2FileEditPageState._stateActionButtons
  ///
  /// In en, this message translates to:
  /// **'No redo available'**
  String get th2FileEditPageNoRedoAvailable;

  /// The label for the no undo available message. Used on: _TH2FileEditPageState._stateActionButtons
  ///
  /// In en, this message translates to:
  /// **'No undo available'**
  String get th2FileEditPageNoUndoAvailable;

  /// The label for the node edit tool button. Used on: _TH2FileEditPageState._editElementButtons
  ///
  /// In en, this message translates to:
  /// **'Node/line edit (N)'**
  String get th2FileEditPageNodeEditTool;

  /// Tooltip for the open option window FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Open options window (O)'**
  String get th2FileEditPageOpenOptionWindow;

  /// The label for the option tool button. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Option edit (O)'**
  String get th2FileEditPageOptionTool;

  /// The label for the pan tool button. Used on: none
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get th2FileEditPagePanTool;

  /// Tooltip for the paste elements FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Paste elements (Ctrl+V)'**
  String get th2FileEditPagePasteElements;

  /// The label for the redo shortcut. Used on: TH2FileEditControllerBase.updateUndoRedoStatus
  ///
  /// In en, this message translates to:
  /// **'Redo \'{redoDescription}\' (Ctrl+Y)'**
  String th2FileEditPageRedo(Object redoDescription);

  /// The label for the remove tool button. Used on: _TH2FileEditPageState._stateActionButtons
  ///
  /// In en, this message translates to:
  /// **'Remove (Del)'**
  String get th2FileEditPageRemoveButton;

  /// The label for the remove image button. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get th2FileEditPageRemoveImageButton;

  /// The label for the remove scrap button. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Remove scrap'**
  String get th2FileEditPageRemoveScrapButton;

  /// Tooltip for resetting image translation, scale and rotation from the available images list. Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Reset image transform'**
  String get th2FileEditPageResetImageButton;

  /// Tooltip for the reverse line FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Reverse line (Ctrl+Shift+R)'**
  String get th2FileEditPageReverseLine;

  /// The label for the save button. Used on: _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Save (Ctrl+S)'**
  String get th2FileEditPageSave;

  /// The label for the save as button. Used on: _TH2FileEditPageState.build
  ///
  /// In en, this message translates to:
  /// **'Save as (Shift+Ctrl+S)'**
  String get th2FileEditPageSaveAs;

  /// The title for the save as dialog. Used on: TH2FileEditControllerBase.saveAsTH2File
  ///
  /// In en, this message translates to:
  /// **'Save TH2 file as'**
  String get th2FileEditPageSaveAsDialogTitle;

  /// Add to selection button in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Add to selection'**
  String get th2FileEditPageSearchSelectAddToSelection;

  /// All option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get th2FileEditPageSearchSelectAll;

  /// Areas section title in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get th2FileEditPageSearchSelectAreas;

  /// Tooltip for the search and select button. Used on: _TH2FileEditPageState._stateActionButtons
  ///
  /// In en, this message translates to:
  /// **'Search and select'**
  String get th2FileEditPageSearchSelectButton;

  /// By ID option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'By ID'**
  String get th2FileEditPageSearchSelectByID;

  /// By line segment option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'By line segment option'**
  String get th2FileEditPageSearchSelectByLineSegmentOption;

  /// By option option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'By option'**
  String get th2FileEditPageSearchSelectByOption;

  /// By subtype option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'By subtype'**
  String get th2FileEditPageSearchSelectBySubtype;

  /// By type option in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get th2FileEditPageSearchSelectByType;

  /// Cancel button in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get th2FileEditPageSearchSelectCancel;

  /// Lines section title in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get th2FileEditPageSearchSelectLines;

  /// Status bar showing the number of matching elements in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'{count} elements match'**
  String th2FileEditPageSearchSelectMatchCount(Object count);

  /// Set option state in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get th2FileEditPageSearchSelectOptionSet;

  /// Undefined option state in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get th2FileEditPageSearchSelectOptionUndefined;

  /// Unset option state in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get th2FileEditPageSearchSelectOptionUnset;

  /// Points section title in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get th2FileEditPageSearchSelectPoints;

  /// Remove from selection button in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Remove from selection'**
  String get th2FileEditPageSearchSelectRemoveFromSelection;

  /// Reset button in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get th2FileEditPageSearchSelectReset;

  /// Set selection button in the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Set selection'**
  String get th2FileEditPageSearchSelectSetSelection;

  /// Title for the search and select dialog. Used on: MPSearchSelectDialogWidget
  ///
  /// In en, this message translates to:
  /// **'Search and select'**
  String get th2FileEditPageSearchSelectTitle;

  /// Tooltip for the select all elements FAB (when not all are selected). Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Select all elements (Ctrl+A)'**
  String get th2FileEditPageSelectAllElements;

  /// Tooltip for the select all end points FAB (when not all are selected). Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Select all end points (Ctrl+A)'**
  String get th2FileEditPageSelectAllEndPoints;

  /// The label for the select tool button. Used on: _TH2FileEditPageState._editElementButtons
  ///
  /// In en, this message translates to:
  /// **'Select (C)'**
  String get th2FileEditPageSelectTool;

  /// The status bar message for the selection window zoom tool. Used on: lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_selection_window_zoom.dart
  ///
  /// In en, this message translates to:
  /// **'Select a zoom area'**
  String get th2FileEditPageSelectionWindowZoomStatusBarMessage;

  /// Tooltip for the simplify lines FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Simplify lines (Ctrl+L)'**
  String get th2FileEditPageSimplifyLines;

  /// Tooltip for the simplify lines forcing Bézier FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Simplify lines forcing Bézier (Ctrl+Alt+L)'**
  String get th2FileEditPageSimplifyLinesForcingBezier;

  /// Tooltip for the simplify lines forcing straight FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Simplify lines forcing straight (Ctrl+Shift+L)'**
  String get th2FileEditPageSimplifyLinesForcingStraight;

  /// Tooltip for the smooth line segments FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Turn on smooth option on line segments (S)'**
  String get th2FileEditPageSmoothLineSegments;

  /// The label for the snap tool button. Used on: _TH2FileEditPageState._stateActionButtons
  ///
  /// In en, this message translates to:
  /// **'Snap'**
  String get th2FileEditPageSnapButton;

  /// Tooltip for the split line at selected end points FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Split line at selected end points (Ctrl+P)'**
  String get th2FileEditPageSplitLineAtSelectedEndPoints;

  /// Tooltip for the split selected lines at crossings FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Split selected lines at crossings (Ctrl+Shift+X)'**
  String get th2FileEditPageSplitLinesAtCrossings;

  /// Tooltip for stopping semi-automatic line tracing in add line mode. Used on: TH2FileEditAddElementContextFABsPanel
  ///
  /// In en, this message translates to:
  /// **'Stop tracing (Ctrl+Shift+T)'**
  String get th2FileEditPageStopTracing;

  /// Tooltip for the toggle-all grid visibility button when all grids are visible (clicking will hide all). Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Hide all grids (Ctrl+G)'**
  String get th2FileEditPageToggleAllGridsVisibilityHideAllTooltip;

  /// Tooltip for the toggle-all grid visibility button when any grid is hidden (clicking will show all). Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Show all grids (Ctrl+G)'**
  String get th2FileEditPageToggleAllGridsVisibilityShowAllTooltip;

  /// Tooltip for the toggle-all image visibility button when all images are visible (clicking will hide all). Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Hide all images (Ctrl+I)'**
  String get th2FileEditPageToggleAllImagesVisibilityHideAllTooltip;

  /// Tooltip for the toggle-all image visibility button when any image is hidden (clicking will show all). Used on: _MPAvailableImagesWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Show all images (Ctrl+I)'**
  String get th2FileEditPageToggleAllImagesVisibilityShowAllTooltip;

  /// Tooltip for the toggle-all scrap visibility button when all scraps are visible (clicking will hide all except the active one). Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Hide all but active'**
  String get th2FileEditPageToggleAllScrapsVisibilityHideOthersTooltip;

  /// Tooltip for the toggle-all scrap visibility button when any scrap is hidden (clicking will make all scraps visible). Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Show all scraps'**
  String get th2FileEditPageToggleAllScrapsVisibilityShowAllTooltip;

  /// Tooltip for the visibility checkbox on each scrap row in the change active scrap overlay. Used on: _MPAvailableScrapsWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Toggle scrap visibility'**
  String get th2FileEditPageToggleScrapVisibilityTooltip;

  /// The label for the undo shortcut. Used on: TH2FileEditControllerBase.updateUndoRedoStatus
  ///
  /// In en, this message translates to:
  /// **'Undo \'{undoDescription}\' (Ctrl+Z)'**
  String th2FileEditPageUndo(Object undoDescription);

  /// The label for the zoom in button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom In (+)'**
  String get th2FileEditPageZoomIn;

  /// The label for the zoom 1:1 button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom 1:1 (1)'**
  String get th2FileEditPageZoomOneToOne;

  /// The label for the zoom options button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom Options'**
  String get th2FileEditPageZoomOptions;

  /// The label for the zoom out button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom Out (-)'**
  String get th2FileEditPageZoomOut;

  /// The label for the show file zoom button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Show file (4)'**
  String get th2FileEditPageZoomOutFile;

  /// The label for the show scrap zoom button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Show scrap (3)'**
  String get th2FileEditPageZoomOutScrap;

  /// The label for the zoom to selection button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom to selection (2)'**
  String get th2FileEditPageZoomToSelection;

  /// The label for the zoom selection window button. Used on: _TH2FileEditPageState._zoomButtonWithOptions
  ///
  /// In en, this message translates to:
  /// **'Zoom selection window (5)'**
  String get th2FileEditPageZoomToSelectionWindow;

  /// Label for the height field in the SVG import size dialog. Used on: MPDialogAux.promptSVGImportSize
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get th2FilePickSVGHeightLabel;

  /// Title for the SVG import error dialog. Used on: MPDialogAux.showSVGImportErrorsDialog
  ///
  /// In en, this message translates to:
  /// **'Unable to import SVG image'**
  String get th2FilePickSVGImportErrorTitle;

  /// Validation error for width/height fields in the SVG import size dialog. Used on: MPDialogAux.promptSVGImportSize
  ///
  /// In en, this message translates to:
  /// **'Enter a value greater than zero'**
  String get th2FilePickSVGInvalidDimensionError;

  /// Body text shown in the SVG import size dialog when both viewBox and width/height metadata are missing. Used on: MPDialogAux.promptSVGImportSize
  ///
  /// In en, this message translates to:
  /// **'This SVG file has neither a viewBox nor width/height metadata. Enter the image width and height to continue importing it.'**
  String get th2FilePickSVGMissingMetadataBody;

  /// Label shown before the list of missing SVG metadata fields. Used on: MPDialogAux.promptSVGImportSize
  ///
  /// In en, this message translates to:
  /// **'Missing metadata'**
  String get th2FilePickSVGMissingMetadataLabel;

  /// Label used when telling the user that the SVG file is missing a viewBox. Used on: MPDialogAux._describeMissingSVGMetadata
  ///
  /// In en, this message translates to:
  /// **'viewBox'**
  String get th2FilePickSVGViewBoxLabel;

  /// Label used when telling the user that the SVG file is missing width and height metadata. Used on: MPDialogAux._describeMissingSVGMetadata
  ///
  /// In en, this message translates to:
  /// **'width/height'**
  String get th2FilePickSVGWidthHeightLabel;

  /// Label for the width field in the SVG import size dialog. Used on: MPDialogAux.promptSVGImportSize
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get th2FilePickSVGWidthLabel;

  /// The label for the image file selection dialog. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Select an image file'**
  String get th2FilePickSelectImageFile;

  /// The label for the TH2 file selection dialog. Used on: MPDialogAux.pickTH2File
  ///
  /// In en, this message translates to:
  /// **'Select a TH2 file'**
  String get th2FilePickSelectTH2File;

  /// Label for the Close button on the file properties page. Used on: TH2FilePropertiesPage
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get th2FilePropertiesPageClose;

  /// Description text for the encoding field on the file properties page. Used on: TH2FilePropertiesPage
  ///
  /// In en, this message translates to:
  /// **'The character encoding used when saving the file. Changing this does not re-encode existing content; it only affects how the file is written.'**
  String get th2FilePropertiesPageEncodingDescription;

  /// Label for the encoding field on the file properties page. Used on: TH2FilePropertiesPage
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get th2FilePropertiesPageEncodingLabel;

  /// Title of the TH2 file properties page. Used on: TH2FilePropertiesPage
  ///
  /// In en, this message translates to:
  /// **'File properties'**
  String get th2FilePropertiesPageTitle;

  /// Tooltip for the close button on a file tab in the multi-file editor. Used on: TH2FileTabsPage tab close button
  ///
  /// In en, this message translates to:
  /// **'Close file'**
  String get th2FileTabsPageCloseTabTooltip;

  /// Tooltip for the file properties button on a file tab. Used on: MPFileTabWidget properties button
  ///
  /// In en, this message translates to:
  /// **'File properties'**
  String get th2FileTabsPagePropertiesTabTooltip;

  /// The label for the bedrock area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get thAreaBedrock;

  /// The label for the blocks area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get thAreaBlocks;

  /// The label for the clay area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get thAreaClay;

  /// The label for the debris area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get thAreaDebris;

  /// The label for the flowstone area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thAreaFlowstone;

  /// The label for the ice area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get thAreaIce;

  /// The label for the moonmilk area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thAreaMoonmilk;

  /// The label for the mudcrack area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Mudcrack'**
  String get thAreaMudcrack;

  /// The label for the pebbles area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get thAreaPebbles;

  /// The label for the pillar area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillar'**
  String get thAreaPillar;

  /// The label for the pillar with curtains area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillar with Curtains'**
  String get thAreaPillarWithCurtains;

  /// The label for the pillars area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillars'**
  String get thAreaPillars;

  /// The label for the pillars with curtains area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillars with Curtains'**
  String get thAreaPillarsWithCurtains;

  /// The label for the sand area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get thAreaSand;

  /// The label for the snow area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get thAreaSnow;

  /// The label for the stalactite area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactite'**
  String get thAreaStalactite;

  /// The label for the stalactite-stalagmite area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactite-Stalagmite'**
  String get thAreaStalactiteStalagmite;

  /// The label for the stalagmite area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalagmite'**
  String get thAreaStalagmite;

  /// The label for the sump area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Sump'**
  String get thAreaSump;

  /// The label for the user defined area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get thAreaU;

  /// The label for the unknown area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get thAreaUnknown;

  /// The label for the water area type. Used on: MPTextToUser._initializeAreaTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get thAreaWater;

  /// The label for the adjust command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get thCommandOptionAdjust;

  /// The label for the align command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get thCommandOptionAlign;

  /// The label for the altitude command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thCommandOptionAltitude;

  /// The label for the altitude command option fix choice. Used on: lib/src/widgets/options/mp_altitude_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get thCommandOptionAltitudeFix;

  /// The label for the altitude value command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_altitude_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thCommandOptionAltitudeValue;

  /// The label for the anchors command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Anchors'**
  String get thCommandOptionAnchors;

  /// The label for the custom attribute command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_attr_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Attribute (custom)'**
  String get thCommandOptionAttr;

  /// The label for the author command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_author_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get thCommandOptionAuthor;

  /// The label for the border command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get thCommandOptionBorder;

  /// The label for the Coordinate System command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_cs_option_widget.dart, lib/src/widgets/options/mp_pl_scale_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Coordinate System'**
  String get thCommandOptionCS;

  /// The label for the clip command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clip'**
  String get thCommandOptionClip;

  /// The label for the close command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get thCommandOptionClose;

  /// The label for the context command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_context_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get thCommandOptionContext;

  /// The label for the copyright command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_copyright_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get thCommandOptionCopyright;

  /// The label for the date value command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_date_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get thCommandOptionDateValue;

  /// The label for the dimensions value command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_dimensions_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get thCommandOptionDimensionsValue;

  /// The label for the dist command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get thCommandOptionDist;

  /// The label for the explored command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Explored'**
  String get thCommandOptionExplored;

  /// The label for the extend command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get thCommandOptionExtend;

  /// The label for the flip command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get thCommandOptionFlip;

  /// The label for the from command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get thCommandOptionFrom;

  /// The label for the head command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get thCommandOptionHead;

  /// The label for the ID command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_id_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get thCommandOptionId;

  /// The label for the L size command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'L-Size'**
  String get thCommandOptionLSize;

  /// The label for the length unit command option type. Used on: lib/src/widgets/options/mp_altitude_option_widget.dart, lib/src/widgets/options/mp_dimensions_option_widget.dart, lib/src/widgets/options/mp_distance_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get thCommandOptionLengthUnit;

  /// The label for the line direction command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get thCommandOptionLineDirection;

  /// The label for the line gradient command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thCommandOptionLineGradient;

  /// The label for the line height command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_double_value_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thCommandOptionLineHeight;

  /// The label for the line point direction command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get thCommandOptionLinePointDirection;

  /// The label for the line point gradient command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thCommandOptionLinePointGradient;

  /// The label for the mark command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get thCommandOptionMark;

  /// The label for the station name command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_station_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get thCommandOptionName;

  /// The label for the orientation command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_orientation_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get thCommandOptionOrientation;

  /// The label for the outline command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get thCommandOptionOutline;

  /// The label for the point/line/line segment scale command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get thCommandOptionPLScale;

  /// The label for the passage height value command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Passage Height'**
  String get thCommandOptionPassageHeightValue;

  /// The label for the place command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get thCommandOptionPlace;

  /// The label for the point height value command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thCommandOptionPointHeightValue;

  /// The label for the projection command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get thCommandOptionProjection;

  /// The label for the rebelays command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rebelays'**
  String get thCommandOptionRebelays;

  /// The label for the reverse command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get thCommandOptionReverse;

  /// The label for the scrap command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_scrap_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get thCommandOptionScrap;

  /// The label for the scrap scale command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, _MPAddScrapDialogWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get thCommandOptionScrapScale;

  /// The label for the sketch command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_sketch_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Sketch'**
  String get thCommandOptionSketch;

  /// The label for the smooth command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get thCommandOptionSmooth;

  /// The label for the station names command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_station_names_option_widget.dart, lib/src/widgets/options/mp_stations_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Station Names'**
  String get thCommandOptionStationNames;

  /// The label for the stations command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get thCommandOptionStations;

  /// The label for the subtype command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_subtype_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get thCommandOptionSubtype;

  /// The label for the text command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get thCommandOptionText;

  /// The label for the title command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get thCommandOptionTitle;

  /// The label for the unrecognized command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString, lib/src/widgets/options/mp_text_type_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Unrecognized Command Option'**
  String get thCommandOptionUnrecognized;

  /// The label for the visibility command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get thCommandOptionVisibility;

  /// The label for the walls command option type. Used on: MPTextToUser._initializeCommandOptionTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Walls'**
  String get thCommandOptionWalls;

  /// The label for the area element type. Used on: MPTextToUser._initializeElementTypeAsString, lib/src/widgets/inputs/mp_pla_type_input_widget.dart, lib/src/widgets/mp_multiple_elements_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get thElementArea;

  /// The label for the area border ID element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Area border ID'**
  String get thElementAreaBorderTHID;

  /// The label for the Bézier curve line segment element type. Used on: MPLineSegmentTypeWidget.build, MPTextToUser._initializeElementTypeAsString, MPTextToUser.getLineSegmentTypeChoices, lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Bézier curve line segment'**
  String get thElementBezierCurveLineSegment;

  /// The label for the comment element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get thElementComment;

  /// The label for the empty line element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Empty line'**
  String get thElementEmptyLine;

  /// The label for the encoding element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get thElementEncoding;

  /// The label for the end area element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'End area'**
  String get thElementEndArea;

  /// The label for the end comment element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'End comment'**
  String get thElementEndComment;

  /// The label for the end line element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'End line'**
  String get thElementEndLine;

  /// The label for the end scrap element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'End scrap'**
  String get thElementEndScrap;

  /// The label for the line element type. Used on: MPTextToUser._initializeElementTypeAsString, lib/src/widgets/inputs/mp_pla_type_input_widget.dart, lib/src/widgets/mp_multiple_elements_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get thElementLine;

  /// The label for the line segment element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Line segment'**
  String get thElementLineSegment;

  /// The label for the multiline comment element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Multiline comment'**
  String get thElementMultilineComment;

  /// The label for the multiline comment content element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Multiline comment content'**
  String get thElementMultilineCommentContent;

  /// The label for the point element type. Used on: MPTextToUser._initializeElementTypeAsString, lib/src/widgets/inputs/mp_pla_type_input_widget.dart, lib/src/widgets/mp_multiple_elements_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get thElementPoint;

  /// The label for the scrap element type. Used on: MPTextToUser._initializeElementTypeAsString, _MPScrapOptionsEditWidgetState.build
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get thElementScrap;

  /// The label for the straight line segment element type. Used on: MPLineSegmentTypeWidget.build, MPTextToUser._initializeElementTypeAsString, MPTextToUser.getLineSegmentTypeChoices, lib/src/widgets/mp_multiple_end_control_points_clicked_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Straight line segment'**
  String get thElementStraightLineSegment;

  /// The label for the unrecognized element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Unrecognized '**
  String get thElementUnrecognized;

  /// The label for the XTherion config element type. Used on: MPTextToUser._initializeElementTypeAsString
  ///
  /// In en, this message translates to:
  /// **'XTherion config'**
  String get thElementXTherionConfig;

  /// The label for the abyss entrance line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Abyss Entrance'**
  String get thLineAbyssEntrance;

  /// The label for the arrow line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get thLineArrow;

  /// The label for the border line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get thLineBorder;

  /// The label for the ceiling meander line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ceiling Meander'**
  String get thLineCeilingMeander;

  /// The label for the ceiling step line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ceiling Step'**
  String get thLineCeilingStep;

  /// The label for the chimney line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Chimney'**
  String get thLineChimney;

  /// The label for the contour line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Contour'**
  String get thLineContour;

  /// The label for the dripline line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Dripline'**
  String get thLineDripline;

  /// The label for the fault line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Fault'**
  String get thLineFault;

  /// The label for the fixed ladder line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Fixed Ladder'**
  String get thLineFixedLadder;

  /// The label for the floor meander line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Floor Meander'**
  String get thLineFloorMeander;

  /// The label for the floor step line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Floor Step'**
  String get thLineFloorStep;

  /// The label for the flowstone line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thLineFlowstone;

  /// The label for the gradient line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thLineGradient;

  /// The label for the handrail line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Handrail'**
  String get thLineHandrail;

  /// The label for the joint line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Joint'**
  String get thLineJoint;

  /// The label for the label line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get thLineLabel;

  /// The label for the low ceiling line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Low Ceiling'**
  String get thLineLowCeiling;

  /// The label for the map connection line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Map Connection'**
  String get thLineMapConnection;

  /// The label for the moonmilk line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thLineMoonmilk;

  /// The label for the overhang line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Overhang'**
  String get thLineOverhang;

  /// The label for the pit line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get thLinePit;

  /// The label for the pit chimney line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pit Chimney'**
  String get thLinePitChimney;

  /// The label for the pitch line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get thLinePitch;

  /// The label for the rimstone dam line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rimstone Dam'**
  String get thLineRimstoneDam;

  /// The label for the rimstone pool line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rimstone Pool'**
  String get thLineRimstonePool;

  /// The label for the rock border line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rock Border'**
  String get thLineRockBorder;

  /// The label for the rock edge line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rock Edge'**
  String get thLineRockEdge;

  /// The label for the rope line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rope'**
  String get thLineRope;

  /// The label for the rope ladder line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rope Ladder'**
  String get thLineRopeLadder;

  /// The label for the section line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get thLineSection;

  /// The label for the slope line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Slope'**
  String get thLineSlope;

  /// The label for the steps line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get thLineSteps;

  /// The label for the survey line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get thLineSurvey;

  /// The label for the U line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get thLineU;

  /// The label for the unknown line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get thLineUnknown;

  /// The label for the via ferrata line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Via Ferrata'**
  String get thLineViaFerrata;

  /// The label for the walkway line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Walkway'**
  String get thLineWalkWay;

  /// The label for the wall line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get thLineWall;

  /// The label for the water flow line type. Used on: MPTextToUser._initializeLineTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Water Flow'**
  String get thLineWaterFlow;

  /// The label for the horizontal adjust multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAdjustChoiceAsString, MPTextToUser._initializeMultipleChoiceFlipChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get thMultipleChoiceAdjustHorizontal;

  /// The label for the vertical adjust multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAdjustChoiceAsString, MPTextToUser._initializeMultipleChoiceFlipChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get thMultipleChoiceAdjustVertical;

  /// The label for the bottom align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString, MPTextToUser._initializeMultipleChoicePlaceChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get thMultipleChoiceAlignBottom;

  /// The label for the bottom left align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Bottom Left'**
  String get thMultipleChoiceAlignBottomLeft;

  /// The label for the bottom right align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Bottom Right'**
  String get thMultipleChoiceAlignBottomRight;

  /// The label for the center align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString, MPTextToUser._initializeMultipleChoiceLineGradientChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointGradientChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get thMultipleChoiceAlignCenter;

  /// The label for the left align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get thMultipleChoiceAlignLeft;

  /// The label for the right align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get thMultipleChoiceAlignRight;

  /// The label for the top align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString, MPTextToUser._initializeMultipleChoicePlaceChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get thMultipleChoiceAlignTop;

  /// The label for the top left align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Top Left'**
  String get thMultipleChoiceAlignTopLeft;

  /// The label for the top right align multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceAlignChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Top Right'**
  String get thMultipleChoiceAlignTopRight;

  /// The label for the begin arrow position multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceArrowPositionChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointDirectionChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get thMultipleChoiceArrowPositionBegin;

  /// The label for the both arrow position multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceArrowPositionChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointDirectionChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get thMultipleChoiceArrowPositionBoth;

  /// The label for the end arrow position multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceArrowPositionChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointDirectionChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get thMultipleChoiceArrowPositionEnd;

  /// The label for the none flip multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceArrowPositionChoiceAsString, MPTextToUser._initializeMultipleChoiceFlipChoiceAsString, MPTextToUser._initializeMultipleChoiceLineGradientChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointDirectionChoiceAsString, MPTextToUser._initializeMultipleChoiceLinePointGradientChoiceAsString, MPTextToUser._initializeMultipleChoiceOutlineChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get thMultipleChoiceFlipNone;

  /// The label for the point line point gradient multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceLinePointGradientChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get thMultipleChoiceLinePointGradientPoint;

  /// The label for the auto auto/on/off multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceOnOffAutoChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get thMultipleChoiceOnOffAutoAuto;

  /// The label for the off on/off multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceOnOffAutoChoiceAsString, MPTextToUser._initializeMultipleChoiceOnOffChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get thMultipleChoiceOnOffOff;

  /// The label for the on on/off multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceOnOffAutoChoiceAsString, MPTextToUser._initializeMultipleChoiceOnOffChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get thMultipleChoiceOnOffOn;

  /// The label for the in outline multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceOutlineChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get thMultipleChoiceOutlineIn;

  /// The label for the out outline multiple choice type. Used on: MPTextToUser._initializeMultipleChoiceOutlineChoiceAsString
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get thMultipleChoiceOutlineOut;

  /// The label for the default place multiple choice type. Used on: MPTextToUser._initializeMultipleChoicePlaceChoiceAsString, lib/src/pages/mp_settings_page.dart
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get thMultipleChoicePlaceDefault;

  /// The label for the air draught point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Air draught'**
  String get thPointAirDraught;

  /// The label for the altar point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Altar'**
  String get thPointAltar;

  /// The label for the altitude point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get thPointAltitude;

  /// The label for the anastomosis point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Anastomosis'**
  String get thPointAnastomosis;

  /// The label for the anchor point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get thPointAnchor;

  /// The label for the aragonite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Aragonite'**
  String get thPointAragonite;

  /// The label for the archeo excavation point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Archeo Excavation'**
  String get thPointArcheoExcavation;

  /// The label for the archeo material point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Archeo Material'**
  String get thPointArcheoMaterial;

  /// The label for the audio point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get thPointAudio;

  /// The label for the bat point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bat'**
  String get thPointBat;

  /// The label for the bedrock point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get thPointBedrock;

  /// The label for the blocks point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get thPointBlocks;

  /// The label for the bones point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bones'**
  String get thPointBones;

  /// The label for the breakdown choke point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Breakdown Choke'**
  String get thPointBreakdownChoke;

  /// The label for the bridge point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get thPointBridge;

  /// The label for the camp point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Camp'**
  String get thPointCamp;

  /// The label for the cave pearl point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Cave Pearl'**
  String get thPointCavePearl;

  /// The label for the clay point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get thPointClay;

  /// The label for the clay choke point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clay Choke'**
  String get thPointClayChoke;

  /// The label for the clay tree point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clay Tree'**
  String get thPointClayTree;

  /// The label for the continuation point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Continuation'**
  String get thPointContinuation;

  /// The label for the crystal point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get thPointCrystal;

  /// The label for the curtain point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Curtain'**
  String get thPointCurtain;

  /// The label for the curtains point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Curtains'**
  String get thPointCurtains;

  /// The label for the danger point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get thPointDanger;

  /// The label for the date point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get thPointDate;

  /// The label for the debris point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get thPointDebris;

  /// The label for the dig point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Dig'**
  String get thPointDig;

  /// The label for the dimensions point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get thPointDimensions;

  /// The label for the disc pillar point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Pillar'**
  String get thPointDiscPillar;

  /// The label for the disc pillars point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Pillars'**
  String get thPointDiscPillars;

  /// The label for the disc stalactite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Stalactite'**
  String get thPointDiscStalactite;

  /// The label for the disc stalactites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Stalactites'**
  String get thPointDiscStalactites;

  /// The label for the disc stalagmite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Stalagmite'**
  String get thPointDiscStalagmite;

  /// The label for the disc stalagmites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disc Stalagmites'**
  String get thPointDiscStalagmites;

  /// The label for the disk point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get thPointDisk;

  /// The label for the electric light point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Electric Light'**
  String get thPointElectricLight;

  /// The label for the entrance point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get thPointEntrance;

  /// The label for the ex voto point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ex Voto'**
  String get thPointExVoto;

  /// The label for the extra point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get thPointExtra;

  /// The label for the fixed ladder point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Fixed Ladder'**
  String get thPointFixedLadder;

  /// The label for the flowstone point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thPointFlowstone;

  /// The label for the flowstone choke point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flowstone Choke'**
  String get thPointFlowstoneChoke;

  /// The label for the flute point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flute'**
  String get thPointFlute;

  /// The label for the gate point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get thPointGate;

  /// The label for the gradient point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get thPointGradient;

  /// The label for the guano point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Guano'**
  String get thPointGuano;

  /// The label for the gypsum point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gypsum'**
  String get thPointGypsum;

  /// The label for the gypsum flower point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Gypsum Flower'**
  String get thPointGypsumFlower;

  /// The label for the handrail point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Handrail'**
  String get thPointHandrail;

  /// The label for the height point type. Used on: MPTextToUser._initializePointTypeAsString, lib/src/widgets/options/mp_point_height_option_widget.dart, lib/src/widgets/options/mp_scrap_scale_option_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get thPointHeight;

  /// The label for the helictite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Helictite'**
  String get thPointHelictite;

  /// The label for the helictites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Helictites'**
  String get thPointHelictites;

  /// The label for the human bones point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Human Bones'**
  String get thPointHumanBones;

  /// The label for the ice point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get thPointIce;

  /// The label for the ice pillar point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice Pillar'**
  String get thPointIcePillar;

  /// The label for the ice stalactite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice Stalactite'**
  String get thPointIceStalactite;

  /// The label for the ice stalagmite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice Stalagmite'**
  String get thPointIceStalagmite;

  /// The label for the karren point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Karren'**
  String get thPointKarren;

  /// The label for the label point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get thPointLabel;

  /// The label for the low end point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Low End'**
  String get thPointLowEnd;

  /// The label for the map connection point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Map Connection'**
  String get thPointMapConnection;

  /// The label for the masonry point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Masonry'**
  String get thPointMasonry;

  /// The label for the moonmilk point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thPointMoonmilk;

  /// The label for the mud point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Mud'**
  String get thPointMud;

  /// The label for the mudcrack point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Mudcrack'**
  String get thPointMudcrack;

  /// The label for the name plate point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Name Plate'**
  String get thPointNamePlate;

  /// The label for the narrow end point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Narrow End'**
  String get thPointNarrowEnd;

  /// The label for the no equipment point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'No Equipment'**
  String get thPointNoEquipment;

  /// The label for the no wheelchair point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'No Wheelchair'**
  String get thPointNoWheelchair;

  /// The label for the paleo material point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Paleo Material'**
  String get thPointPaleoMaterial;

  /// The label for the passage height point type. Used on: MPTextToUser._initializePointTypeAsString, lib/src/widgets/options/mp_passage_height_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Passage Height'**
  String get thPointPassageHeight;

  /// The label for the pebbles point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get thPointPebbles;

  /// The label for the pendant point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pendant'**
  String get thPointPendant;

  /// The label for the photo point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get thPointPhoto;

  /// The label for the pillar point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillar'**
  String get thPointPillar;

  /// The label for the pillar with curtains point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillar With Curtains'**
  String get thPointPillarWithCurtains;

  /// The label for the pillars with curtains point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pillars With Curtains'**
  String get thPointPillarsWithCurtains;

  /// The label for the popcorn point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Popcorn'**
  String get thPointPopcorn;

  /// The label for the raft point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Raft'**
  String get thPointRaft;

  /// The label for the raft cone point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Raft Cone'**
  String get thPointRaftCone;

  /// The label for the remark point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get thPointRemark;

  /// The label for the rimstone dam point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rimstone Dam'**
  String get thPointRimstoneDam;

  /// The label for the rimstone pool point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rimstone Pool'**
  String get thPointRimstonePool;

  /// The label for the root point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get thPointRoot;

  /// The label for the rope point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rope'**
  String get thPointRope;

  /// The label for the rope ladder point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Rope Ladder'**
  String get thPointRopeLadder;

  /// The label for the sand point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get thPointSand;

  /// The label for the scallop point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Scallop'**
  String get thPointScallop;

  /// The label for the section point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get thPointSection;

  /// The label for the seed germination point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Seed Germination'**
  String get thPointSeedGermination;

  /// The label for the sink point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Sink'**
  String get thPointSink;

  /// The label for the snow point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get thPointSnow;

  /// The label for the soda straw point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Soda Straw'**
  String get thPointSodaStraw;

  /// The label for the spring point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get thPointSpring;

  /// The label for the stalactite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactite'**
  String get thPointStalactite;

  /// The label for the stalactite stalagmite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactite Stalagmite'**
  String get thPointStalactiteStalagmite;

  /// The label for the stalactites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactites'**
  String get thPointStalactites;

  /// The label for the stalactites stalagmites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalactites Stalagmites'**
  String get thPointStalactitesStalagmites;

  /// The label for the stalagmite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalagmite'**
  String get thPointStalagmite;

  /// The label for the stalagmites point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Stalagmites'**
  String get thPointStalagmites;

  /// The label for the station point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get thPointStation;

  /// The label for the station name point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get thPointStationName;

  /// The label for the steps point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get thPointSteps;

  /// The label for the traverse point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Traverse'**
  String get thPointTraverse;

  /// The label for the tree trunk point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Tree Trunk'**
  String get thPointTreeTrunk;

  /// The label for the user defined point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get thPointU;

  /// The label for the unknown point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get thPointUnknown;

  /// The label for the vegetable debris point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Vegetable Debris'**
  String get thPointVegetableDebris;

  /// The label for the via ferrata point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Via Ferrata'**
  String get thPointViaFerrata;

  /// The label for the volcano point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Volcano'**
  String get thPointVolcano;

  /// The label for the walkway point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Walkway'**
  String get thPointWalkway;

  /// The label for the wall calcite point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Wall Calcite'**
  String get thPointWallCalcite;

  /// The label for the water point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get thPointWater;

  /// The label for the water drip point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Water Drip'**
  String get thPointWaterDrip;

  /// The label for the water flow point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Water Flow'**
  String get thPointWaterFlow;

  /// The label for the wheelchair point type. Used on: MPTextToUser._initializePointTypeAsString
  ///
  /// In en, this message translates to:
  /// **'Wheelchair'**
  String get thPointWheelchair;

  /// The label for the projection line type. Used on: _MPAddScrapDialogWidgetState.build, lib/src/widgets/options/mp_projection_option_overlay_window_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get thProjection;

  /// The error message for empty subtype. Used on: lib/src/widgets/options/mp_subtype_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Subtype empty'**
  String get thSubtypeEmpty;

  /// The label for the subtype type. Used on: lib/src/widgets/options/mp_subtype_option_widget.dart
  ///
  /// In en, this message translates to:
  /// **'Subtype'**
  String get thSubtypeLabel;

  /// The label for the invisible border subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get thSubtypeLineBorderInvisible;

  /// The label for the presumed border subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Presumed'**
  String get thSubtypeLineBorderPresumed;

  /// The label for the temporary border subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get thSubtypeLineBorderTemporary;

  /// The label for the visible border subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get thSubtypeLineBorderVisible;

  /// The label for the cave survey subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Cave'**
  String get thSubtypeLineSurveyCave;

  /// The label for the surface survey subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get thSubtypeLineSurveySurface;

  /// The label for the bedrock wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get thSubtypeLineWallBedrock;

  /// The label for the blocks wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get thSubtypeLineWallBlocks;

  /// The label for the clay wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get thSubtypeLineWallClay;

  /// The label for the debris wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get thSubtypeLineWallDebris;

  /// The label for the flowstone wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Flowstone'**
  String get thSubtypeLineWallFlowstone;

  /// The label for the ice wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get thSubtypeLineWallIce;

  /// The label for the invisible wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get thSubtypeLineWallInvisible;

  /// The label for the moonmilk wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Moonmilk'**
  String get thSubtypeLineWallMoonmilk;

  /// The label for the overlying wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Overlying'**
  String get thSubtypeLineWallOverlying;

  /// The label for the pebbles wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pebbles'**
  String get thSubtypeLineWallPebbles;

  /// The label for the pit wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Pit'**
  String get thSubtypeLineWallPit;

  /// The label for the presumed wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Presumed'**
  String get thSubtypeLineWallPresumed;

  /// The label for the sand wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get thSubtypeLineWallSand;

  /// The label for the underlying wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Underlying'**
  String get thSubtypeLineWallUnderlying;

  /// The label for the unsurveyed wall subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Unsurveyed'**
  String get thSubtypeLineWallUnsurveyed;

  /// The label for the conjectural water flow line subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Conjectural'**
  String get thSubtypeLineWaterFlowConjectural;

  /// The label for the intermittent water flow line subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Intermittent'**
  String get thSubtypeLineWaterFlowIntermittent;

  /// The label for the permanent water flow line subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get thSubtypeLineWaterFlowPermanent;

  /// The label for the summer subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get thSubtypePointAirDraughtSummer;

  /// The label for the undefined subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get thSubtypePointAirDraughtUndefined;

  /// The label for the winter subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get thSubtypePointAirDraughtWinter;

  /// The label for the fixed subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get thSubtypePointStationFixed;

  /// The label for the natural subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get thSubtypePointStationNatural;

  /// The label for the painted subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Painted'**
  String get thSubtypePointStationPainted;

  /// The label for the temporary subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get thSubtypePointStationTemporary;

  /// The label for the intermittent water flow subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Intermittent'**
  String get thSubtypePointWaterFlowIntermittent;

  /// The label for the paleo water flow subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get thSubtypePointWaterFlowPaleo;

  /// The label for the permanent water flow subtype. Used on: MPTextToUser._initializeSubtypeAsString
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get thSubtypePointWaterFlowPermanent;

  /// Body text for the update available dialog. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'A newer version is available.\n\nCurrent: {currentVersion}\nLatest: {latestVersion} ({tagName})\n\nDownload: {releaseUrl}'**
  String updateAvailableBody(
    Object currentVersion,
    Object latestVersion,
    Object tagName,
    Object releaseUrl,
  );

  /// Additional update dialog information showing how old the installed version is relative to the latest stable release, by commit count and days. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Installed version is {commitCount, plural, one {1 commit} other {{commitCount} commits}} and {dayCount, plural, one {1 day} other {{dayCount} days}} behind the latest release.'**
  String updateAvailableInstalledVersionAge(int commitCount, int dayCount);

  /// Title for the update available dialog. Used on: MPDialogAux._showFlathubUpdateDialog, lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// Title for the update available dialog including the number of newer versions. Used on: MPDialogAux._showFlathubUpdateDialog, lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 newer Mapiah version available} other {{count} newer Mapiah versions available}}'**
  String updateAvailableTitleWithCount(int count);

  /// Body text for the update check failure dialog when a non-200 HTTP status is returned. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Update server returned HTTP {statusCode}.'**
  String updateCheckFailedHttpStatusBody(Object statusCode);

  /// Body text for the update check failure dialog when there is no response. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Unable to check for updates because the server did not respond. Do you have an internet connection?'**
  String get updateCheckFailedNoAnswerBody;

  /// Body text for the update check failure dialog when parsing fails. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Unable to read the latest version from the update server.'**
  String get updateCheckFailedParsingBody;

  /// Body text for the update check failure dialog when parsing fails and a tag is available. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Unable to parse the latest version tag: {tagName}'**
  String updateCheckFailedParsingWithTagBody(Object tagName);

  /// Title for the update check failure dialog. Used on: lib/src/auxiliary/mp_dialog_aux.dart
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get updateCheckFailedTitle;
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
    'that was used.',
  );
}
