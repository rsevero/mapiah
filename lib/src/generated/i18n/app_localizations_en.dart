// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutMapiahDialogChangelog => 'Changelog';

  @override
  String get aboutMapiahDialogLicense => 'License';

  @override
  String aboutMapiahDialogMapiahVersion(Object version) {
    return 'Version $version';
  }

  @override
  String aboutMapiahDialogRelease(Object releaseName, Object releaseUrl) {
    return 'The $releaseName release ($releaseUrl)';
  }

  @override
  String aboutMapiahDialogReleaseNoUrl(Object releaseName) {
    return 'The $releaseName release';
  }

  @override
  String get aboutMapiahDialogReleaseUrlLabel => 'Release page';

  @override
  String get aboutMapiahDialogWindowTitle => 'About Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get buttonClose => 'Close';

  @override
  String get cannotSplitAreaBorderLine =>
      'Cannot split a line that is part of an area border';

  @override
  String get fileEditWindowWindowTitle => 'File edit';

  @override
  String get helpDialogFailureToLoad => 'Failed to load help content';

  @override
  String get helpDialogTooltip => 'Help (F1)';

  @override
  String get initialPagePresentation =>
      'Mapiah: an user-friendly graphical interface for cave mapping with Therion';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'sys': 'System',
      'en': 'English',
      'pt': 'Português',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get mapiahHomeAboutMapiahDialog => 'About Mapiah';

  @override
  String get mapiahHomeHelpDialogTitle => 'Main page';

  @override
  String get mapiahHomeNewFileButtonTooltip =>
      'New file (Ctrl+N or Ctrl+Shift+N)';

  @override
  String get mapiahHomeOpenFile => 'Open file (Ctrl+O or Ctrl+Shift+O)';

  @override
  String get mapiahKeyboardShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get mapiahKeyboardShortcutsTooltip => 'Keyboard Shortcuts (Ctrl+K)';

  @override
  String get mapiahOpenTHConfigAndRunTherionButtonTooltip =>
      'Open THConfig file and run Therion (Ctrl+T)';

  @override
  String get mapiahRunTherionButtonLabel => 'Rerun Therion';

  @override
  String get mapiahRunTherionButtonTooltip => 'Run Therion (T)';

  @override
  String get mapiahRunTherionHelpDialogTitle => 'Run Therion dialog';

  @override
  String get mapiahTherionRunCloseButtonTooltip => 'Close (Esc)';

  @override
  String get mapiahTherionRunDialogTitle => 'Therion output';

  @override
  String mapiahTherionRunElapsedLabel(Object elapsed) {
    return 'Elapsed time: $elapsed s';
  }

  @override
  String mapiahTherionRunEndTime(Object time) {
    return 'End: $time';
  }

  @override
  String get mapiahTherionRunNoTherionOutputFound => 'No Therion output found';

  @override
  String get mapiahTherionRunOutputLabel => 'Output:';

  @override
  String get mapiahTherionRunParametersLabel => 'Run parameters:';

  @override
  String mapiahTherionRunStartTime(Object time) {
    return 'Start: $time';
  }

  @override
  String get mapiahTherionRunStatusError => 'error';

  @override
  String get mapiahTherionRunStatusLabel => 'Status:';

  @override
  String get mapiahTherionRunStatusOk => 'ok';

  @override
  String get mapiahTherionRunStatusRunning => 'running';

  @override
  String get mapiahTherionRunStatusWarning => 'warning';

  @override
  String get mapiahTherionRunTherionLogBegin => 'Begin therion.log';

  @override
  String get mapiahTherionRunTherionLogEnd => 'End therion.log';

  @override
  String get mapiahTherionRunTherionOutputBegin => 'Begin Therion output';

  @override
  String get mapiahTherionRunTherionOutputEnd => 'End Therion output';

  @override
  String get mapiahTherionSelectTHConfigDialogTitle => 'Select THConfig file';

  @override
  String get mergeAreasLineSegmentsOutsideBoundary =>
      'Merge areas: line segments outside the outer boundary were found — merge aborted';

  @override
  String get mergeAreasNoSelectedAreas => 'No areas selected for merging';

  @override
  String get mpAltitudeInvalidValueErrorMessage => 'Invalid altitude';

  @override
  String get mpAngleUnitDegree => 'degree';

  @override
  String get mpAngleUnitGrad => 'grad';

  @override
  String get mpAngleUnitMil => 'mil';

  @override
  String get mpAngleUnitMinute => 'minute';

  @override
  String get mpAreaBordersAddButton => 'Add area border';

  @override
  String get mpAreaBordersPanelTitle => 'Area borders';

  @override
  String get mpAttrNameEmpty => 'Empty attribute name';

  @override
  String get mpAttrNameInvalid => 'Invalid chars in attribute name';

  @override
  String get mpAttrNameLabel => 'Name';

  @override
  String get mpAttrValueEmpty => 'Empty attribute value';

  @override
  String get mpAttrValueLabel => 'Value';

  @override
  String get mpAuthorInvalidValueErrorMessage =>
      'Invalid date/interval and person name';

  @override
  String get mpAzimuthAzimuthLabel => 'Azimuth';

  @override
  String get mpAzimuthEast => 'East';

  @override
  String get mpAzimuthEastAbbreviation => 'E';

  @override
  String get mpAzimuthInvalidErrorMessage => 'Invalid azimuth';

  @override
  String get mpAzimuthNorth => 'North';

  @override
  String get mpAzimuthNorthAbbreviation => 'N';

  @override
  String get mpAzimuthSouth => 'South';

  @override
  String get mpAzimuthSouthAbbreviation => 'S';

  @override
  String get mpAzimuthWest => 'West';

  @override
  String get mpAzimuthWestAbbreviation => 'W';

  @override
  String get mpButtonApply => 'Apply';

  @override
  String get mpButtonCancel => 'Cancel';

  @override
  String get mpButtonCreate => 'Create';

  @override
  String get mpButtonOK => 'OK';

  @override
  String get mpButtonReset => 'Reset';

  @override
  String get mpButtonResetAllSettings => 'Reset all settings';

  @override
  String get mpButtonSave => 'Save';

  @override
  String get mpButtonSaveAndClose => 'Save & Close';

  @override
  String mpCSEPSGESRILabel(Object csOption) {
    return '$csOption identifier (1-99999)';
  }

  @override
  String get mpCSETRSLabel => 'Optional ETRS identifier (28-37)';

  @override
  String get mpCSForOutputLabel => 'For output';

  @override
  String get mpCSInvalidValueErrorMessage => 'Invalid value';

  @override
  String get mpCSOSGBMajorLabel => 'OSGB major';

  @override
  String get mpCSOSGBMinorLabel => 'OSGB minor';

  @override
  String get mpCSUTMZoneNumberLabel => 'Zone number (1-60)';

  @override
  String get mpChoiceMultipleValues => 'multiple values';

  @override
  String get mpChoiceSet => 'Set';

  @override
  String get mpChoiceUnset => 'Unset';

  @override
  String get mpCommandDescriptionAddArea => 'Add area';

  @override
  String get mpCommandDescriptionAddAreaBorderTHID => 'Add area border line';

  @override
  String get mpCommandDescriptionAddElement => 'Add element';

  @override
  String get mpCommandDescriptionAddElements => 'Add elements';

  @override
  String get mpCommandDescriptionAddEmptyLine => 'Add empty line';

  @override
  String get mpCommandDescriptionAddLine => 'Add line';

  @override
  String get mpCommandDescriptionAddLineSegment => 'Add line segment';

  @override
  String get mpCommandDescriptionAddLines => 'Add lines';

  @override
  String get mpCommandDescriptionAddPoint => 'Add point';

  @override
  String get mpCommandDescriptionAddScrap => 'Add scrap';

  @override
  String get mpCommandDescriptionAddXTherionImageInsertConfig => 'Add image';

  @override
  String get mpCommandDescriptionCutElements => 'Cut elements';

  @override
  String get mpCommandDescriptionDuplicateElements => 'Duplicate elements';

  @override
  String get mpCommandDescriptionEditAreaType => 'Edit area type';

  @override
  String get mpCommandDescriptionEditAreasType => 'Edit multiple areas type';

  @override
  String get mpCommandDescriptionEditBezierCurve => 'Edit Bézier curve';

  @override
  String get mpCommandDescriptionEditLine => 'Edit line';

  @override
  String get mpCommandDescriptionEditLineSegment => 'Edit line segment';

  @override
  String get mpCommandDescriptionEditLineSegmentType =>
      'Edit line segment type';

  @override
  String get mpCommandDescriptionEditLineSegmentsType =>
      'Edit multiple line segments type';

  @override
  String get mpCommandDescriptionEditLineType => 'Edit line type';

  @override
  String get mpCommandDescriptionEditLinesType => 'Edit multiple lines type';

  @override
  String get mpCommandDescriptionEditPointType => 'Edit point type';

  @override
  String get mpCommandDescriptionEditPointsType => 'Edit multiple points type';

  @override
  String get mpCommandDescriptionMoveArea => 'Move area';

  @override
  String get mpCommandDescriptionMoveBezierLineSegment =>
      'Move Bézier line segment';

  @override
  String get mpCommandDescriptionMoveElements => 'Move elements';

  @override
  String get mpCommandDescriptionMoveLine => 'Move line';

  @override
  String get mpCommandDescriptionMoveLineSegments => 'Move line segments';

  @override
  String get mpCommandDescriptionMoveLines => 'Move lines';

  @override
  String get mpCommandDescriptionMovePoint => 'Move point';

  @override
  String get mpCommandDescriptionMoveStraightLineSegment =>
      'Move straight line segment';

  @override
  String get mpCommandDescriptionMultipleElements => 'Multiple elements edit';

  @override
  String get mpCommandDescriptionRemoveArea => 'Remove area';

  @override
  String get mpCommandDescriptionRemoveAreaBorderTHID =>
      'Remove area border line';

  @override
  String get mpCommandDescriptionRemoveElement => 'Remove element';

  @override
  String get mpCommandDescriptionRemoveElements => 'Remove elements';

  @override
  String get mpCommandDescriptionRemoveEmptyLine => 'Remove empty line';

  @override
  String get mpCommandDescriptionRemoveLine => 'Remove line';

  @override
  String get mpCommandDescriptionRemoveLineSegment => 'Remove line segment';

  @override
  String get mpCommandDescriptionRemoveLineSegments => 'Remove line segments';

  @override
  String get mpCommandDescriptionRemoveLines => 'Remove lines';

  @override
  String get mpCommandDescriptionRemoveOptionFromElement => 'Remove option';

  @override
  String get mpCommandDescriptionRemoveOptionFromElements =>
      'Remove option from multiple elements';

  @override
  String get mpCommandDescriptionRemovePoint => 'Remove point';

  @override
  String get mpCommandDescriptionRemoveScrap => 'Remove scrap';

  @override
  String get mpCommandDescriptionRemoveXTherionImageInsertConfig =>
      'Remove image';

  @override
  String get mpCommandDescriptionReorderImages => 'Reorder images';

  @override
  String get mpCommandDescriptionReorderScraps => 'Reorder scraps';

  @override
  String get mpCommandDescriptionSetFileEncoding => 'Set file encoding';

  @override
  String get mpCommandDescriptionSetOptionToElement => 'Set option';

  @override
  String get mpCommandDescriptionSetOptionToElements =>
      'Set option to multiple elements';

  @override
  String get mpCommandDescriptionSimplifyBezier => 'Simplify Bézier curve';

  @override
  String get mpCommandDescriptionSimplifyLine => 'Simplify line';

  @override
  String get mpCommandDescriptionSimplifyLines => 'Simplify lines';

  @override
  String get mpCommandDescriptionSimplifyStraight => 'Simplify straight line';

  @override
  String get mpCommandDescriptionSimplifyToBezier =>
      'Simplify into Bézier curve';

  @override
  String get mpCommandDescriptionSimplifyToStraight =>
      'Simplify into straight line';

  @override
  String get mpCommandDescriptionSubstituteLineSegments =>
      'Substitute line segments';

  @override
  String get mpCommandDescriptionToggleReverseOption => 'Toggle reverse option';

  @override
  String get mpCommandDescriptionToggleSmoothOption => 'Toggle smooth option';

  @override
  String get mpContextInvalidValueErrorMessage => 'Both fields are mandatory';

  @override
  String get mpCopyrightInvalidMessageErrorMessage =>
      'Invalid copyright message';

  @override
  String get mpCopyrightMessageLabel => 'Copyright';

  @override
  String get mpDateIntervalEndDateHint => 'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]]';

  @override
  String get mpDateIntervalEndDateLabel => 'End date';

  @override
  String get mpDateIntervalIntervalLabel => 'Interval';

  @override
  String get mpDateIntervalInvalidEndDateFormatErrorMessage =>
      'Invalid end date';

  @override
  String get mpDateIntervalInvalidStartDateFormatErrorMessage =>
      'Invalid start date';

  @override
  String get mpDateIntervalSingleDateLabel => 'Date';

  @override
  String get mpDateIntervalStartDateHint =>
      'YYYY[.MM[.DD[@HH[:MM[:SS[.SS]]]]]] or \'-\'';

  @override
  String get mpDateIntervalStartDateLabel => 'Start date';

  @override
  String get mpDateValueInvalidValueErrorMessage => 'Invalid date/interval';

  @override
  String get mpDefaultOptionsAreasTab => 'Areas';

  @override
  String get mpDefaultOptionsLinesTab => 'Lines';

  @override
  String get mpDefaultOptionsPointsTab => 'Points';

  @override
  String get mpDefaultOptionsReset => 'Reset';

  @override
  String get mpDefaultOptionsTitle => 'Default options';

  @override
  String get mpDefaultOptionsToolbarTooltip => 'Default options';

  @override
  String get mpDimensionsAboveLabel => 'Above';

  @override
  String get mpDimensionsBelowLabel => 'Below';

  @override
  String get mpDimensionsInvalidValueErrorMessage => 'Invalid dimension value';

  @override
  String get mpDistDistanceLabel => 'Distance';

  @override
  String get mpDistInvalidValueErrorMessage => 'Invalid numeric distance value';

  @override
  String get mpDoubleValueInvalidValueErrorMessage => 'Invalid numeric value';

  @override
  String get mpEditSingleLineStateStatusBarMessage => 'Editing line';

  @override
  String get mpEncodingLabel => 'Encoding';

  @override
  String get mpErrorDialogFilenameLabel => 'File';

  @override
  String get mpErrorDialogFullPathLabel => 'Full path';

  @override
  String get mpErrorReadingXVIFile => 'Error reading XVI file';

  @override
  String get mpExploredLengthLabel => 'Length';

  @override
  String get mpExtendStationLabel => 'Station';

  @override
  String get mpIDIDLabel => 'ID';

  @override
  String get mpIDInvalidValueErrorMessage =>
      'Invalid ID: must be a sequence of characters A-Z, a-z, 0-9 and _-/ (not starting with ‘-’).';

  @override
  String get mpIDMissingErrorMessage => 'ID is required';

  @override
  String get mpIDNonUniqueValueErrorMessage => 'ID must be unique';

  @override
  String get mpLSizeLabel => 'Size';

  @override
  String get mpLengthUnitCentimeter => 'centimeter';

  @override
  String get mpLengthUnitCentimeterAbbreviation => 'cm';

  @override
  String get mpLengthUnitFoot => 'feet';

  @override
  String get mpLengthUnitFootAbbreviation => 'ft';

  @override
  String get mpLengthUnitInch => 'inch';

  @override
  String get mpLengthUnitInchAbbreviation => 'in';

  @override
  String get mpLengthUnitMeter => 'meter';

  @override
  String get mpLengthUnitMeterAbbreviation => 'm';

  @override
  String get mpLengthUnitYard => 'yard';

  @override
  String get mpLengthUnitYardAbbreviation => 'yd';

  @override
  String get mpLineHeightHeightLabel => 'Height';

  @override
  String get mpLineHeightInvalidValueErrorMessage => 'Invalid line height';

  @override
  String get mpLineSegmentTypeTypesTitle => 'Line segment type';

  @override
  String get mpMarkTextLabel => 'Mark';

  @override
  String mpMovingElementsStateAreasLinesAndPointsStatusBarMessage(
    Object pointsAmount,
    Object linesAmount,
    Object areaAmount,
  ) {
    return 'Moving $pointsAmount point(s), $linesAmount line(s), and $areaAmount area(s)';
  }

  @override
  String mpMovingEndControlPointsStateBarMessage(Object endPointsAmount) {
    return 'Moving $endPointsAmount end control points';
  }

  @override
  String get mpMovingSingleControlPointStateBarMessage =>
      'Moving control point';

  @override
  String get mpMultipleElementsClickedAllChoice => 'All';

  @override
  String get mpMultipleElementsClickedTitle => 'Multiple elements clicked';

  @override
  String get mpMultipleEndControlPointsClickedTitle =>
      'Multiple points clicked';

  @override
  String get mpMultipleEndControlPointsControlPoint1 => 'Control point 1';

  @override
  String get mpMultipleEndControlPointsControlPoint2 => 'Control point 2';

  @override
  String get mpMultipleEndControlPointsEndPoint => 'End point';

  @override
  String get mpNameStationLabel => 'Station';

  @override
  String get mpNamedScaleHuge => 'Huge';

  @override
  String get mpNamedScaleLarge => 'Large';

  @override
  String get mpNamedScaleNormal => 'Normal';

  @override
  String get mpNamedScaleSmall => 'Small';

  @override
  String get mpNamedScaleTiny => 'Tiny';

  @override
  String get mpNewScrapDialogCreateNewScrap => 'Create new scrap';

  @override
  String get mpNewScrapDialogCreateScrapIDHint => 'Enter the scrap identifier';

  @override
  String get mpNewScrapDialogCreateScrapIDLabel => 'Scrap ID';

  @override
  String get mpNoTherionFound => 'No Therion found';

  @override
  String mpNonEmptySelectionStateAreasLinesAndPointsStatusBarMessage(
    Object pointsAmount,
    Object linesAmount,
    Object areaAmount,
  ) {
    return '$pointsAmount point(s), $linesAmount line(s), and $areaAmount area(s) selected';
  }

  @override
  String get mpOptionsEditLineSegmentTypes => 'Line segments types';

  @override
  String get mpOptionsEditTitle => 'Options';

  @override
  String get mpPLATypeAll => 'All';

  @override
  String get mpPLATypeAreaTitle => 'Area types';

  @override
  String get mpPLATypeCurrent => 'Current';

  @override
  String get mpPLATypeDropdownSelectATypeLabel => 'Select a type';

  @override
  String get mpPLATypeLastUsed => 'Last used';

  @override
  String get mpPLATypeLineTitle => 'Line types';

  @override
  String get mpPLATypeMostUsed => 'Most used';

  @override
  String get mpPLATypeNone => 'None';

  @override
  String get mpPLATypePointTitle => 'Point types';

  @override
  String get mpPLATypeUnknownInvalid => 'Invalid type';

  @override
  String get mpPLATypeUnknownLabel => 'Type';

  @override
  String get mpPLScaleCommandOptionNamed => 'Named';

  @override
  String get mpPLScaleCommandOptionNumeric => 'Numeric';

  @override
  String get mpPLScaleNumericLabel => 'Size';

  @override
  String get mpPassageHeightCeiling => 'Ceiling';

  @override
  String get mpPassageHeightCeilingLabel => 'Ceiling';

  @override
  String get mpPassageHeightDepth => 'Depth';

  @override
  String get mpPassageHeightDepthLabel => 'Depth';

  @override
  String get mpPassageHeightDepthWarning => 'Invalid depth';

  @override
  String get mpPassageHeightDistanceBetweenFloorAndCeiling =>
      'Distance floor ceiling';

  @override
  String get mpPassageHeightDistanceBetweenFloorAndCeilingLabel =>
      'Floor to ceiling';

  @override
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloor =>
      'Distance to ceiling and to floor';

  @override
  String get mpPassageHeightDistanceToCeilingAndDistanceToFloorLabel =>
      'To ceiling/to floor';

  @override
  String get mpPassageHeightFloor => 'Floor';

  @override
  String get mpPassageHeightFloorLabel => 'Floor';

  @override
  String get mpPassageHeightHeight => 'Height';

  @override
  String get mpPassageHeightHeightLabel => 'Height';

  @override
  String get mpPassageHeightHeightWarning => 'Invalid height';

  @override
  String get mpPersonNameHint =>
      '\'FirstName Surname\' or \'FirstNames/Surnames\'';

  @override
  String get mpPersonNameInvalidFormatErrorMessage => 'Invalid person name';

  @override
  String get mpPersonNameLabel => 'Name';

  @override
  String get mpPointHeightChimney => 'Chimney';

  @override
  String get mpPointHeightLengthWarning => 'Invalid length';

  @override
  String get mpPointHeightPit => 'Pit';

  @override
  String get mpPointHeightPresumedMinus => 'Minus presumed (-?)';

  @override
  String get mpPointHeightPresumedPlus => 'Plus presumed (+?)';

  @override
  String get mpPointHeightStep => 'Step';

  @override
  String get mpPointHeightValueChimneyLabel => 'Height';

  @override
  String get mpPointHeightValueChimneyObservation =>
      'Chimeny height (treated as positive)';

  @override
  String get mpPointHeightValuePitLabel => 'Depth';

  @override
  String get mpPointHeightValuePitObservation =>
      'Pit depth (treated as negative)';

  @override
  String get mpPointHeightValueStepLabel => 'Height';

  @override
  String get mpPointHeightValueStepObservation =>
      'Step height (treated as positive)';

  @override
  String get mpProjectionAngleWarning => 'Invalid angle (0 <= angle < 360)';

  @override
  String get mpProjectionElevationAzimuthLabel => 'Azimuth';

  @override
  String get mpProjectionIndexLabel => 'Index (optional)';

  @override
  String get mpProjectionModeElevation => 'Elevation';

  @override
  String get mpProjectionModeExtended => 'Extended';

  @override
  String get mpProjectionModeNone => 'None';

  @override
  String get mpProjectionModePlan => 'Plan';

  @override
  String get mpScrapFreeText => 'Free text';

  @override
  String get mpScrapFromFile => 'From file';

  @override
  String get mpScrapLabel => 'Scrap ID';

  @override
  String get mpScrapScale11Label => 'Real';

  @override
  String get mpScrapScale1ValueLabel => 'Real to 1 point';

  @override
  String get mpScrapScale1ValueObservation => 'Real units per drawing point';

  @override
  String get mpScrapScale21Label => 'Drawing';

  @override
  String get mpScrapScale22Label => 'Real';

  @override
  String get mpScrapScale2ValueObservation => 'real units per drawing points';

  @override
  String get mpScrapScale2ValuesLabel => 'Real to points';

  @override
  String get mpScrapScale81Label => 'Draw X1';

  @override
  String get mpScrapScale82Label => 'Draw Y1';

  @override
  String get mpScrapScale83Label => 'Draw X2';

  @override
  String get mpScrapScale84Label => 'Draw Y2';

  @override
  String get mpScrapScale85Label => 'Real X1';

  @override
  String get mpScrapScale86Label => 'Real Y1';

  @override
  String get mpScrapScale87Label => 'Real X2';

  @override
  String get mpScrapScale88Label => 'Real Y2';

  @override
  String get mpScrapScale8ValueObservation =>
      'Real coordinates per drawing coordinates';

  @override
  String get mpScrapScale8ValuesLabel => 'Real to drawing coordinates';

  @override
  String get mpScrapScaleInvalidValueError => 'Invalid scale ref';

  @override
  String get mpScrapWarning => 'Scrap not set';

  @override
  String get mpSeconds => 's';

  @override
  String get mpSettingsEnumNewLineCreationMethodMapiahQuadratic =>
      'Mapiah quadratic';

  @override
  String get mpSettingsEnumNewLineCreationMethodXTherionCubicSmooth =>
      'xTherion cubic smooth';

  @override
  String get mpSettingsInvalidInteger => 'Invalid integer';

  @override
  String get mpSettingsInvalidNumber => 'Invalid number';

  @override
  String get mpSettingsPageHelpDialogTitle => 'Settings Help';

  @override
  String get mpSettingsPageTitle => 'Settings';

  @override
  String get mpSettingsSectionMain => 'Main';

  @override
  String get mpSettingsSectionTH2Edit => 'TH2 edit';

  @override
  String get mpSettingsSectionTherion => 'Therion';

  @override
  String get mpSettingsSettingMainLocaleID => 'Language';

  @override
  String get mpSettingsSettingMainTherionExecutablePath =>
      'Therion executable path';

  @override
  String get mpSettingsSettingMainTherionRunParameters =>
      'Therion run parameters';

  @override
  String get mpSettingsSettingTH2EditEnableElementTransforms =>
      'Enable element transforms';

  @override
  String get mpSettingsSettingTH2EditEnableSpecialBorderForIDSet =>
      'Enable special border for ID set';

  @override
  String
  get mpSettingsSettingTH2EditEnableSpecialBorderForSlopeLineWithoutLSize =>
      'Enable special border for slope line without l-size';

  @override
  String get mpSettingsSettingTH2EditEnableSpecialBorderForVisibilityOff =>
      'Enable special border for visibility off';

  @override
  String get mpSettingsSettingTH2EditLineThickness => 'Line thickness';

  @override
  String get mpSettingsSettingTH2EditNewLineCreationMethod =>
      'New line creation method';

  @override
  String get mpSettingsSettingTH2EditNudgeFactor => 'Nudge factor';

  @override
  String get mpSettingsSettingTH2EditPointRadius => 'Point radius';

  @override
  String get mpSettingsSettingTH2EditSelectionTolerance =>
      'Selection tolerance';

  @override
  String get mpSettingsSettingTH2EditShowDirectionTicksOnNonSelectedLines =>
      'Show direction ticks on non-selected lines';

  @override
  String get mpSettingsSettingTH2EditShowLastUsedPLATypeButtons =>
      'Show last used PLA type buttons';

  @override
  String get mpSettingsSettingTH2EditSnapAngle => 'Snap angle';

  @override
  String get mpSettingsSettingTherionDebugLog1 => 'Debug log 1';

  @override
  String get mpSketchChooseFileButtonLabel => 'Choose file';

  @override
  String get mpSketchCoordinateInvalid => 'Invalid coordinate';

  @override
  String get mpSketchFilenameLabel => 'Filename';

  @override
  String get mpSketchXLabel => 'X';

  @override
  String get mpSketchYLabel => 'Y';

  @override
  String get mpSnapLinePointTargetsLabel => 'Line point snap';

  @override
  String get mpSnapPointTargetsLabel => 'Point snap';

  @override
  String get mpSnapTargetLinePoint => 'Line points';

  @override
  String get mpSnapTargetLinePointByType => 'Line points by line type';

  @override
  String get mpSnapTargetNone => 'None';

  @override
  String get mpSnapTargetPoint => 'Points';

  @override
  String get mpSnapTargetPointByType => 'Points by type';

  @override
  String get mpSnapTargetXVIFileGridLine => 'Grid lines';

  @override
  String get mpSnapTargetXVIFileGridLineIntersection =>
      'Grid line intersections';

  @override
  String get mpSnapTargetXVIFileShot => 'Shots';

  @override
  String get mpSnapTargetXVIFileSketchLine => 'Sketch lines';

  @override
  String get mpSnapTargetXVIFileStation => 'Stations';

  @override
  String get mpSnapXVIFileTargetsLabel => 'XVI file snap';

  @override
  String get mpStationNamesPrefixLabel => 'Prefix';

  @override
  String get mpStationNamesPrefixMessageEmpty => 'Prefix empty';

  @override
  String get mpStationNamesSuffixLabel => 'Suffix';

  @override
  String get mpStationNamesSuffixMessageEmpty => 'Suffix empty';

  @override
  String get mpStationTypeOptionWarning => 'Station not set';

  @override
  String get mpStationTypeSurveyInvalidWarning => 'Invalid survey';

  @override
  String get mpStationTypeSurveyLabel => 'Survey';

  @override
  String get mpStationTypeUniqueEmptyWarning => 'Station name not set';

  @override
  String get mpStationTypeUniqueInvalidWarning => 'Invalid station name';

  @override
  String get mpStationTypeUniqueLabel => 'Station name';

  @override
  String get mpStationsAddField => 'Add field';

  @override
  String get mpStationsNameEmpty => 'Station name empty';

  @override
  String get mpStationsNameLabel => 'Station';

  @override
  String mpStatusBarMessageEditLinePointOrientationLSize(
    Object orientation,
    Object forcedOrientation,
    Object lsize,
    Object forcedLSize,
  ) {
    return 'Orientation $orientation°$forcedOrientation, LSize $lsize$forcedLSize';
  }

  @override
  String get mpStatusBarMessageEditLinePointOrientationLSizeForced =>
      ' (forced)';

  @override
  String mpStatusBarMessageSingleSelectedAreaAreaBordersList(
    Object areaBordersCount,
    Object areaBordersList,
  ) {
    return ' - $areaBordersCount area border(s): $areaBordersList';
  }

  @override
  String get mpStatusBarMessageSingleSelectedAreaNoAreaBorders =>
      ' - no area borders';

  @override
  String mpStatusBarMessageSingleSelectedAreaType(Object areaType) {
    return 'Area $areaType';
  }

  @override
  String mpStatusBarMessageSingleSelectedElementID(Object elementID) {
    return ', ID: $elementID';
  }

  @override
  String get mpStatusBarMessageSingleSelectedElementSelectedControlPoint =>
      ' - selected: control point';

  @override
  String mpStatusBarMessageSingleSelectedElementSelectedEndPoints(
    Object count,
  ) {
    return ' - selected: $count end point(s)';
  }

  @override
  String mpStatusBarMessageSingleSelectedElementSubtype(Object subtype) {
    return ', subtype $subtype';
  }

  @override
  String mpStatusBarMessageSingleSelectedLineLineSegmentsCount(
    Object lineSegmentsCount,
    Object straightLineSegmentsCount,
    Object bezierLineSegmentsCount,
  ) {
    return ' - $lineSegmentsCount line segments ($straightLineSegmentsCount straight, $bezierLineSegmentsCount Bézier)';
  }

  @override
  String get mpStatusBarMessageSingleSelectedLineNoLineSegments =>
      ' - no line segments';

  @override
  String mpStatusBarMessageSingleSelectedLineParentArea(Object parentArea) {
    return ' - border of $parentArea';
  }

  @override
  String mpStatusBarMessageSingleSelectedLineType(Object lineType) {
    return 'Line $lineType';
  }

  @override
  String mpStatusBarMessageSingleSelectedPointType(Object pointType) {
    return 'Point $pointType';
  }

  @override
  String mpTH2FileEditPageMousePosition(Object x, Object y) {
    return 'x: $x, y: $y';
  }

  @override
  String get mpTextTextLabel => 'Text';

  @override
  String get mpTextTypeOptionWarning => 'Text not set';

  @override
  String mpTherionCannotExecuteCommand(Object commandLine) {
    return 'Error executing command: $commandLine';
  }

  @override
  String get mpTitleTextLabel => 'Title';

  @override
  String get mpUnrecognizedCommandOptionTextLabel => 'Unrecognized option';

  @override
  String get noCoincidingLineExtremitiesFound =>
      'No coinciding extremities found between selected lines';

  @override
  String get noLinesAtCrossingsFound =>
      'No crossings found between selected lines';

  @override
  String get parsingErrors => 'Parsing errors';

  @override
  String get telemetryConsentDialogAccept => 'Yes, participate';

  @override
  String get telemetryConsentDialogBody =>
      'Mapiah can collect anonymous, aggregated usage data to help improve the app. No personal information, file contents or identifying data is ever collected or transmitted. You can change this setting at any time in Settings.';

  @override
  String get telemetryConsentDialogDecline => 'No thanks';

  @override
  String get telemetryConsentDialogLearnMore =>
      'Learn more about what is collected';

  @override
  String get telemetryConsentDialogTitle => 'Help improve Mapiah';

  @override
  String get telemetrySettingsReviewLink =>
      'Review telemetry details and consent';

  @override
  String get telemetrySettingsSectionTitle => 'Telemetry';

  @override
  String get telemetrySettingsToggleLabel => 'Share anonymous usage data';

  @override
  String get th2FileEditPageAddArea => 'Add area (A)';

  @override
  String th2FileEditPageAddAreaStatusBarMessage(Object type) {
    return 'Select a line to be included as border of a new $type area';
  }

  @override
  String get th2FileEditPageAddElementOptions => 'Add element';

  @override
  String get th2FileEditPageAddImageButton => 'Add image (I)';

  @override
  String get th2FileEditPageAddLine => 'Add line (L)';

  @override
  String th2FileEditPageAddLineStatusBarMessage(Object type) {
    return 'Click to add a $type line';
  }

  @override
  String th2FileEditPageAddLineToAreaStatusBarMessage(Object type) {
    return 'Select a line to be included as border of the selected $type area';
  }

  @override
  String get th2FileEditPageAddPoint => 'Add point (P)';

  @override
  String th2FileEditPageAddPointStatusBarMessage(Object type) {
    return 'Click to add a $type point';
  }

  @override
  String get th2FileEditPageAddScrapButton => 'Add scrap (K)';

  @override
  String get th2FileEditPageChangeActiveScrapTitle => 'Change active scrap';

  @override
  String get th2FileEditPageChangeActiveScrapTool =>
      'Change active scrap (Alt+K)';

  @override
  String get th2FileEditPageChangeImageTitle => 'Change images';

  @override
  String get th2FileEditPageChangeImageTool => 'Change image (Alt+I)';

  @override
  String get th2FileEditPageContinueTracing =>
      'Continue tracing (Ctrl+Shift+T)';

  @override
  String get th2FileEditPageConvertLineSegmentsToBezier =>
      'Convert line segments to Bézier (J)';

  @override
  String get th2FileEditPageConvertLineSegmentsToStraight =>
      'Convert line segments to straight (Shift+J)';

  @override
  String get th2FileEditPageCopyElements => 'Copy elements (Ctrl+C)';

  @override
  String get th2FileEditPageCopyScrapButton => 'Copy scrap';

  @override
  String get th2FileEditPageCreateMapConnectionLines =>
      'Create map connection lines';

  @override
  String get th2FileEditPageCutElements => 'Cut elements (Ctrl+X)';

  @override
  String get th2FileEditPageCutScrapButton => 'Cut scrap';

  @override
  String get th2FileEditPageDeselectAllElements =>
      'Deselect all elements (Ctrl+D)';

  @override
  String get th2FileEditPageDeselectAllEndPoints =>
      'Deselect all end points (Ctrl+D)';

  @override
  String get th2FileEditPageDisableImageEditModeButton => 'Stop editing image';

  @override
  String get th2FileEditPageDuplicateElements =>
      'Duplicate elements (Ctrl+Shift+D)';

  @override
  String get th2FileEditPageDuplicateScrapButton => 'Duplicate scrap';

  @override
  String get th2FileEditPageElementRotateStatusBarMessage =>
      'Element rotate mode';

  @override
  String get th2FileEditPageEmptySelectionStatusBarMessage => 'Empty selection';

  @override
  String get th2FileEditPageEnableImageEditModeButton => 'Edit image';

  @override
  String get th2FileEditPageFlipElementsHorizontally =>
      'Flip elements horizontally (H)';

  @override
  String get th2FileEditPageFlipElementsVertically =>
      'Flip elements vertically (V)';

  @override
  String get th2FileEditPageFlipImageHorizontally =>
      'Flip image horizontally (H)';

  @override
  String get th2FileEditPageFlipImageVertically => 'Flip image vertically (V)';

  @override
  String get th2FileEditPageHelpDialogTitle => 'TH2 File Edit Help';

  @override
  String get th2FileEditPageImageGridVisibilityTooltip =>
      'Toggle grid visibility';

  @override
  String get th2FileEditPageImageMoveOverlayLabel => 'Move';

  @override
  String get th2FileEditPageImageMoveStatusBarMessage => 'Image transform mode';

  @override
  String get th2FileEditPageImageRotateOverlayLabel => 'Rotate';

  @override
  String get th2FileEditPageImageRotateStatusBarMessage => 'Image rotate mode';

  @override
  String get th2FileEditPageImageScaleOverlayLabel => 'Scale';

  @override
  String get th2FileEditPageImageScaleStatusBarMessage => 'Image scale mode';

  @override
  String get th2FileEditPageImageVisibilityTooltip => 'Toggle image visibility';

  @override
  String get th2FileEditPageInteractiveSimplifyLines =>
      'Interactive simplify lines (Ctrl+Alt+Shift+L)';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesCanvasToleranceLabel =>
      'Canvas tolerance';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesDescription =>
      'Preview the selected lines while adjusting the simplification method and intensity.';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesForceBezier =>
      'Force Bézier curves';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesForceStraight =>
      'Force straight segments';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesIntensityLabel =>
      'Intensity';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesKeepOriginal =>
      'Keep original segment types';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesMethodLabel => 'Method';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesScreenToleranceLabel =>
      'Screen tolerance equivalent';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusAfterLabel => 'After';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusBeforeLabel =>
      'Before';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusBezierLabel =>
      'Bézier';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusLabel =>
      'Segment counts';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusStraightLabel =>
      'Straight';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesStatusTotalLabel => 'Total';

  @override
  String get th2FileEditPageInteractiveSimplifyLinesTitle =>
      'Interactive simplify lines';

  @override
  String get th2FileEditPageJoinLinesAtCoincidingExtremities =>
      'Join lines at coinciding extremities (Ctrl+J)';

  @override
  String get th2FileEditPageLoadImageButton => 'Load image';

  @override
  String th2FileEditPageLoadingFile(Object filename) {
    return 'Loading file $filename ...';
  }

  @override
  String get th2FileEditPageMergeAreas => 'Merge areas (Ctrl+M)';

  @override
  String get th2FileEditPageNoRedoAvailable => 'No redo available';

  @override
  String get th2FileEditPageNoUndoAvailable => 'No undo available';

  @override
  String get th2FileEditPageNodeEditTool => 'Node/line edit (N)';

  @override
  String get th2FileEditPageOpenOptionWindow => 'Open options window (O)';

  @override
  String get th2FileEditPageOptionTool => 'Option edit (O)';

  @override
  String get th2FileEditPagePanTool => 'Pan';

  @override
  String get th2FileEditPagePasteElements => 'Paste elements (Ctrl+V)';

  @override
  String th2FileEditPageRedo(Object redoDescription) {
    return 'Redo \'$redoDescription\' (Ctrl+Y)';
  }

  @override
  String get th2FileEditPageRemoveButton => 'Remove (Del)';

  @override
  String get th2FileEditPageRemoveImageButton => 'Remove image';

  @override
  String get th2FileEditPageRemoveScrapButton => 'Remove scrap';

  @override
  String get th2FileEditPageResetImageButton => 'Reset image transform';

  @override
  String get th2FileEditPageReverseLine => 'Reverse line (Ctrl+Shift+R)';

  @override
  String get th2FileEditPageSave => 'Save (Ctrl+S)';

  @override
  String get th2FileEditPageSaveAs => 'Save as (Shift+Ctrl+S)';

  @override
  String get th2FileEditPageSaveAsDialogTitle => 'Save TH2 file as';

  @override
  String get th2FileEditPageSearchSelectAddToSelection => 'Add to selection';

  @override
  String get th2FileEditPageSearchSelectAll => 'All';

  @override
  String get th2FileEditPageSearchSelectAreas => 'Areas';

  @override
  String get th2FileEditPageSearchSelectButton => 'Search and select';

  @override
  String get th2FileEditPageSearchSelectByID => 'By ID';

  @override
  String get th2FileEditPageSearchSelectByLineSegmentOption =>
      'By line segment option';

  @override
  String get th2FileEditPageSearchSelectByOption => 'By option';

  @override
  String get th2FileEditPageSearchSelectBySubtype => 'By subtype';

  @override
  String get th2FileEditPageSearchSelectByType => 'By type';

  @override
  String get th2FileEditPageSearchSelectCancel => 'Cancel';

  @override
  String get th2FileEditPageSearchSelectLines => 'Lines';

  @override
  String th2FileEditPageSearchSelectMatchCount(Object count) {
    return '$count elements match';
  }

  @override
  String get th2FileEditPageSearchSelectOptionSet => 'Set';

  @override
  String get th2FileEditPageSearchSelectOptionUndefined => 'Undefined';

  @override
  String get th2FileEditPageSearchSelectOptionUnset => 'Unset';

  @override
  String get th2FileEditPageSearchSelectPoints => 'Points';

  @override
  String get th2FileEditPageSearchSelectRemoveFromSelection =>
      'Remove from selection';

  @override
  String get th2FileEditPageSearchSelectReset => 'Reset';

  @override
  String get th2FileEditPageSearchSelectSetSelection => 'Set selection';

  @override
  String get th2FileEditPageSearchSelectTitle => 'Search and select';

  @override
  String get th2FileEditPageSelectAllElements => 'Select all elements (Ctrl+A)';

  @override
  String get th2FileEditPageSelectAllEndPoints =>
      'Select all end points (Ctrl+A)';

  @override
  String get th2FileEditPageSelectTool => 'Select (C)';

  @override
  String get th2FileEditPageSelectionWindowZoomStatusBarMessage =>
      'Select a zoom area';

  @override
  String get th2FileEditPageSimplifyLines => 'Simplify lines (Ctrl+L)';

  @override
  String get th2FileEditPageSimplifyLinesForcingBezier =>
      'Simplify lines forcing Bézier (Ctrl+Alt+L)';

  @override
  String get th2FileEditPageSimplifyLinesForcingStraight =>
      'Simplify lines forcing straight (Ctrl+Shift+L)';

  @override
  String get th2FileEditPageSmoothLineSegments =>
      'Turn on smooth option on line segments (S)';

  @override
  String get th2FileEditPageSnapButton => 'Snap';

  @override
  String get th2FileEditPageSplitLineAtSelectedEndPoints =>
      'Split line at selected end points (Ctrl+P)';

  @override
  String get th2FileEditPageSplitLinesAtCrossings =>
      'Split selected lines at crossings (Ctrl+Shift+X)';

  @override
  String get th2FileEditPageStopTracing => 'Stop tracing (Ctrl+Shift+T)';

  @override
  String get th2FileEditPageToggleAllGridsVisibilityHideAllTooltip =>
      'Hide all grids (Ctrl+G)';

  @override
  String get th2FileEditPageToggleAllGridsVisibilityShowAllTooltip =>
      'Show all grids (Ctrl+G)';

  @override
  String get th2FileEditPageToggleAllImagesVisibilityHideAllTooltip =>
      'Hide all images (Ctrl+I)';

  @override
  String get th2FileEditPageToggleAllImagesVisibilityShowAllTooltip =>
      'Show all images (Ctrl+I)';

  @override
  String get th2FileEditPageToggleAllScrapsVisibilityHideOthersTooltip =>
      'Hide all but active';

  @override
  String get th2FileEditPageToggleAllScrapsVisibilityShowAllTooltip =>
      'Show all scraps';

  @override
  String get th2FileEditPageToggleScrapVisibilityTooltip =>
      'Toggle scrap visibility';

  @override
  String th2FileEditPageUndo(Object undoDescription) {
    return 'Undo \'$undoDescription\' (Ctrl+Z)';
  }

  @override
  String get th2FileEditPageZoomIn => 'Zoom In (+)';

  @override
  String get th2FileEditPageZoomOneToOne => 'Zoom 1:1 (1)';

  @override
  String get th2FileEditPageZoomOptions => 'Zoom Options';

  @override
  String get th2FileEditPageZoomOut => 'Zoom Out (-)';

  @override
  String get th2FileEditPageZoomOutFile => 'Show file (4)';

  @override
  String get th2FileEditPageZoomOutScrap => 'Show scrap (3)';

  @override
  String get th2FileEditPageZoomToSelection => 'Zoom to selection (2)';

  @override
  String get th2FileEditPageZoomToSelectionWindow =>
      'Zoom selection window (5)';

  @override
  String get th2FilePickSVGHeightLabel => 'Height';

  @override
  String get th2FilePickSVGImportErrorTitle => 'Unable to import SVG image';

  @override
  String get th2FilePickSVGInvalidDimensionError =>
      'Enter a value greater than zero';

  @override
  String get th2FilePickSVGMissingMetadataBody =>
      'This SVG file has neither a viewBox nor width/height metadata. Enter the image width and height to continue importing it.';

  @override
  String get th2FilePickSVGMissingMetadataLabel => 'Missing metadata';

  @override
  String get th2FilePickSVGViewBoxLabel => 'viewBox';

  @override
  String get th2FilePickSVGWidthHeightLabel => 'width/height';

  @override
  String get th2FilePickSVGWidthLabel => 'Width';

  @override
  String get th2FilePickSelectImageFile => 'Select an image file';

  @override
  String get th2FilePickSelectTH2File => 'Select a TH2 file';

  @override
  String get th2FilePropertiesPageClose => 'Close';

  @override
  String get th2FilePropertiesPageEncodingDescription =>
      'The character encoding used when saving the file. Changing this does not re-encode existing content; it only affects how the file is written.';

  @override
  String get th2FilePropertiesPageEncodingLabel => 'Encoding';

  @override
  String get th2FilePropertiesPageTitle => 'File properties';

  @override
  String get th2FileTabsPageCloseTabTooltip => 'Close file';

  @override
  String get th2FileTabsPagePropertiesTabTooltip => 'File properties';

  @override
  String get thAreaBedrock => 'Bedrock';

  @override
  String get thAreaBlocks => 'Blocks';

  @override
  String get thAreaClay => 'Clay';

  @override
  String get thAreaDebris => 'Debris';

  @override
  String get thAreaFlowstone => 'Flowstone';

  @override
  String get thAreaIce => 'Ice';

  @override
  String get thAreaMoonmilk => 'Moonmilk';

  @override
  String get thAreaMudcrack => 'Mudcrack';

  @override
  String get thAreaPebbles => 'Pebbles';

  @override
  String get thAreaPillar => 'Pillar';

  @override
  String get thAreaPillarWithCurtains => 'Pillar with Curtains';

  @override
  String get thAreaPillars => 'Pillars';

  @override
  String get thAreaPillarsWithCurtains => 'Pillars with Curtains';

  @override
  String get thAreaSand => 'Sand';

  @override
  String get thAreaSnow => 'Snow';

  @override
  String get thAreaStalactite => 'Stalactite';

  @override
  String get thAreaStalactiteStalagmite => 'Stalactite-Stalagmite';

  @override
  String get thAreaStalagmite => 'Stalagmite';

  @override
  String get thAreaSump => 'Sump';

  @override
  String get thAreaU => 'User';

  @override
  String get thAreaUnknown => 'Unknown';

  @override
  String get thAreaWater => 'Water';

  @override
  String get thCommandOptionAdjust => 'Adjust';

  @override
  String get thCommandOptionAlign => 'Align';

  @override
  String get thCommandOptionAltitude => 'Altitude';

  @override
  String get thCommandOptionAltitudeFix => 'Fix';

  @override
  String get thCommandOptionAltitudeValue => 'Altitude';

  @override
  String get thCommandOptionAnchors => 'Anchors';

  @override
  String get thCommandOptionAttr => 'Attribute (custom)';

  @override
  String get thCommandOptionAuthor => 'Author';

  @override
  String get thCommandOptionBorder => 'Border';

  @override
  String get thCommandOptionCS => 'Coordinate System';

  @override
  String get thCommandOptionClip => 'Clip';

  @override
  String get thCommandOptionClose => 'Close';

  @override
  String get thCommandOptionContext => 'Context';

  @override
  String get thCommandOptionCopyright => 'Copyright';

  @override
  String get thCommandOptionDateValue => 'Date';

  @override
  String get thCommandOptionDimensionsValue => 'Dimensions';

  @override
  String get thCommandOptionDist => 'Distance';

  @override
  String get thCommandOptionExplored => 'Explored';

  @override
  String get thCommandOptionExtend => 'Extend';

  @override
  String get thCommandOptionFlip => 'Flip';

  @override
  String get thCommandOptionFrom => 'From';

  @override
  String get thCommandOptionHead => 'Head';

  @override
  String get thCommandOptionId => 'ID';

  @override
  String get thCommandOptionLSize => 'L-Size';

  @override
  String get thCommandOptionLengthUnit => 'Unit';

  @override
  String get thCommandOptionLineDirection => 'Direction';

  @override
  String get thCommandOptionLineGradient => 'Gradient';

  @override
  String get thCommandOptionLineHeight => 'Height';

  @override
  String get thCommandOptionLinePointDirection => 'Direction';

  @override
  String get thCommandOptionLinePointGradient => 'Gradient';

  @override
  String get thCommandOptionMark => 'Mark';

  @override
  String get thCommandOptionName => 'Station';

  @override
  String get thCommandOptionOrientation => 'Orientation';

  @override
  String get thCommandOptionOutline => 'Outline';

  @override
  String get thCommandOptionPLScale => 'Scale';

  @override
  String get thCommandOptionPassageHeightValue => 'Passage Height';

  @override
  String get thCommandOptionPlace => 'Place';

  @override
  String get thCommandOptionPointHeightValue => 'Height';

  @override
  String get thCommandOptionProjection => 'Projection';

  @override
  String get thCommandOptionRebelays => 'Rebelays';

  @override
  String get thCommandOptionReverse => 'Reverse';

  @override
  String get thCommandOptionScrap => 'Scrap';

  @override
  String get thCommandOptionScrapScale => 'Scale';

  @override
  String get thCommandOptionSketch => 'Sketch';

  @override
  String get thCommandOptionSmooth => 'Smooth';

  @override
  String get thCommandOptionStationNames => 'Station Names';

  @override
  String get thCommandOptionStations => 'Stations';

  @override
  String get thCommandOptionSubtype => 'Subtype';

  @override
  String get thCommandOptionText => 'Text';

  @override
  String get thCommandOptionTitle => 'Title';

  @override
  String get thCommandOptionUnrecognized => 'Unrecognized Command Option';

  @override
  String get thCommandOptionVisibility => 'Visibility';

  @override
  String get thCommandOptionWalls => 'Walls';

  @override
  String get thElementArea => 'Area';

  @override
  String get thElementAreaBorderTHID => 'Area border ID';

  @override
  String get thElementBezierCurveLineSegment => 'Bézier curve line segment';

  @override
  String get thElementComment => 'Comment';

  @override
  String get thElementEmptyLine => 'Empty line';

  @override
  String get thElementEncoding => 'Encoding';

  @override
  String get thElementEndArea => 'End area';

  @override
  String get thElementEndComment => 'End comment';

  @override
  String get thElementEndLine => 'End line';

  @override
  String get thElementEndScrap => 'End scrap';

  @override
  String get thElementLine => 'Line';

  @override
  String get thElementLineSegment => 'Line segment';

  @override
  String get thElementMultilineComment => 'Multiline comment';

  @override
  String get thElementMultilineCommentContent => 'Multiline comment content';

  @override
  String get thElementPoint => 'Point';

  @override
  String get thElementScrap => 'Scrap';

  @override
  String get thElementStraightLineSegment => 'Straight line segment';

  @override
  String get thElementUnrecognized => 'Unrecognized ';

  @override
  String get thElementXTherionConfig => 'XTherion config';

  @override
  String get thLineAbyssEntrance => 'Abyss Entrance';

  @override
  String get thLineArrow => 'Arrow';

  @override
  String get thLineBorder => 'Border';

  @override
  String get thLineCeilingMeander => 'Ceiling Meander';

  @override
  String get thLineCeilingStep => 'Ceiling Step';

  @override
  String get thLineChimney => 'Chimney';

  @override
  String get thLineContour => 'Contour';

  @override
  String get thLineDripline => 'Dripline';

  @override
  String get thLineFault => 'Fault';

  @override
  String get thLineFixedLadder => 'Fixed Ladder';

  @override
  String get thLineFloorMeander => 'Floor Meander';

  @override
  String get thLineFloorStep => 'Floor Step';

  @override
  String get thLineFlowstone => 'Flowstone';

  @override
  String get thLineGradient => 'Gradient';

  @override
  String get thLineHandrail => 'Handrail';

  @override
  String get thLineJoint => 'Joint';

  @override
  String get thLineLabel => 'Label';

  @override
  String get thLineLowCeiling => 'Low Ceiling';

  @override
  String get thLineMapConnection => 'Map Connection';

  @override
  String get thLineMoonmilk => 'Moonmilk';

  @override
  String get thLineOverhang => 'Overhang';

  @override
  String get thLinePit => 'Pit';

  @override
  String get thLinePitChimney => 'Pit Chimney';

  @override
  String get thLinePitch => 'Pitch';

  @override
  String get thLineRimstoneDam => 'Rimstone Dam';

  @override
  String get thLineRimstonePool => 'Rimstone Pool';

  @override
  String get thLineRockBorder => 'Rock Border';

  @override
  String get thLineRockEdge => 'Rock Edge';

  @override
  String get thLineRope => 'Rope';

  @override
  String get thLineRopeLadder => 'Rope Ladder';

  @override
  String get thLineSection => 'Section';

  @override
  String get thLineSlope => 'Slope';

  @override
  String get thLineSteps => 'Steps';

  @override
  String get thLineSurvey => 'Survey';

  @override
  String get thLineU => 'User';

  @override
  String get thLineUnknown => 'Unknown';

  @override
  String get thLineViaFerrata => 'Via Ferrata';

  @override
  String get thLineWalkWay => 'Walkway';

  @override
  String get thLineWall => 'Wall';

  @override
  String get thLineWaterFlow => 'Water Flow';

  @override
  String get thMultipleChoiceAdjustHorizontal => 'Horizontal';

  @override
  String get thMultipleChoiceAdjustVertical => 'Vertical';

  @override
  String get thMultipleChoiceAlignBottom => 'Bottom';

  @override
  String get thMultipleChoiceAlignBottomLeft => 'Bottom Left';

  @override
  String get thMultipleChoiceAlignBottomRight => 'Bottom Right';

  @override
  String get thMultipleChoiceAlignCenter => 'Center';

  @override
  String get thMultipleChoiceAlignLeft => 'Left';

  @override
  String get thMultipleChoiceAlignRight => 'Right';

  @override
  String get thMultipleChoiceAlignTop => 'Top';

  @override
  String get thMultipleChoiceAlignTopLeft => 'Top Left';

  @override
  String get thMultipleChoiceAlignTopRight => 'Top Right';

  @override
  String get thMultipleChoiceArrowPositionBegin => 'Begin';

  @override
  String get thMultipleChoiceArrowPositionBoth => 'Both';

  @override
  String get thMultipleChoiceArrowPositionEnd => 'End';

  @override
  String get thMultipleChoiceFlipNone => 'None';

  @override
  String get thMultipleChoiceLinePointGradientPoint => 'Point';

  @override
  String get thMultipleChoiceOnOffAutoAuto => 'Auto';

  @override
  String get thMultipleChoiceOnOffOff => 'Off';

  @override
  String get thMultipleChoiceOnOffOn => 'On';

  @override
  String get thMultipleChoiceOutlineIn => 'In';

  @override
  String get thMultipleChoiceOutlineOut => 'Out';

  @override
  String get thMultipleChoicePlaceDefault => 'Default';

  @override
  String get thPointAirDraught => 'Air draught';

  @override
  String get thPointAltar => 'Altar';

  @override
  String get thPointAltitude => 'Altitude';

  @override
  String get thPointAnastomosis => 'Anastomosis';

  @override
  String get thPointAnchor => 'Anchor';

  @override
  String get thPointAragonite => 'Aragonite';

  @override
  String get thPointArcheoExcavation => 'Archeo Excavation';

  @override
  String get thPointArcheoMaterial => 'Archeo Material';

  @override
  String get thPointAudio => 'Audio';

  @override
  String get thPointBat => 'Bat';

  @override
  String get thPointBedrock => 'Bedrock';

  @override
  String get thPointBlocks => 'Blocks';

  @override
  String get thPointBones => 'Bones';

  @override
  String get thPointBreakdownChoke => 'Breakdown Choke';

  @override
  String get thPointBridge => 'Bridge';

  @override
  String get thPointCamp => 'Camp';

  @override
  String get thPointCavePearl => 'Cave Pearl';

  @override
  String get thPointClay => 'Clay';

  @override
  String get thPointClayChoke => 'Clay Choke';

  @override
  String get thPointClayTree => 'Clay Tree';

  @override
  String get thPointContinuation => 'Continuation';

  @override
  String get thPointCrystal => 'Crystal';

  @override
  String get thPointCurtain => 'Curtain';

  @override
  String get thPointCurtains => 'Curtains';

  @override
  String get thPointDanger => 'Danger';

  @override
  String get thPointDate => 'Date';

  @override
  String get thPointDebris => 'Debris';

  @override
  String get thPointDig => 'Dig';

  @override
  String get thPointDimensions => 'Dimensions';

  @override
  String get thPointDiscPillar => 'Disc Pillar';

  @override
  String get thPointDiscPillars => 'Disc Pillars';

  @override
  String get thPointDiscStalactite => 'Disc Stalactite';

  @override
  String get thPointDiscStalactites => 'Disc Stalactites';

  @override
  String get thPointDiscStalagmite => 'Disc Stalagmite';

  @override
  String get thPointDiscStalagmites => 'Disc Stalagmites';

  @override
  String get thPointDisk => 'Disk';

  @override
  String get thPointElectricLight => 'Electric Light';

  @override
  String get thPointEntrance => 'Entrance';

  @override
  String get thPointExVoto => 'Ex Voto';

  @override
  String get thPointExtra => 'Extra';

  @override
  String get thPointFixedLadder => 'Fixed Ladder';

  @override
  String get thPointFlowstone => 'Flowstone';

  @override
  String get thPointFlowstoneChoke => 'Flowstone Choke';

  @override
  String get thPointFlute => 'Flute';

  @override
  String get thPointGate => 'Gate';

  @override
  String get thPointGradient => 'Gradient';

  @override
  String get thPointGuano => 'Guano';

  @override
  String get thPointGypsum => 'Gypsum';

  @override
  String get thPointGypsumFlower => 'Gypsum Flower';

  @override
  String get thPointHandrail => 'Handrail';

  @override
  String get thPointHeight => 'Height';

  @override
  String get thPointHelictite => 'Helictite';

  @override
  String get thPointHelictites => 'Helictites';

  @override
  String get thPointHumanBones => 'Human Bones';

  @override
  String get thPointIce => 'Ice';

  @override
  String get thPointIcePillar => 'Ice Pillar';

  @override
  String get thPointIceStalactite => 'Ice Stalactite';

  @override
  String get thPointIceStalagmite => 'Ice Stalagmite';

  @override
  String get thPointKarren => 'Karren';

  @override
  String get thPointLabel => 'Label';

  @override
  String get thPointLowEnd => 'Low End';

  @override
  String get thPointMapConnection => 'Map Connection';

  @override
  String get thPointMasonry => 'Masonry';

  @override
  String get thPointMoonmilk => 'Moonmilk';

  @override
  String get thPointMud => 'Mud';

  @override
  String get thPointMudcrack => 'Mudcrack';

  @override
  String get thPointNamePlate => 'Name Plate';

  @override
  String get thPointNarrowEnd => 'Narrow End';

  @override
  String get thPointNoEquipment => 'No Equipment';

  @override
  String get thPointNoWheelchair => 'No Wheelchair';

  @override
  String get thPointPaleoMaterial => 'Paleo Material';

  @override
  String get thPointPassageHeight => 'Passage Height';

  @override
  String get thPointPebbles => 'Pebbles';

  @override
  String get thPointPendant => 'Pendant';

  @override
  String get thPointPhoto => 'Photo';

  @override
  String get thPointPillar => 'Pillar';

  @override
  String get thPointPillarWithCurtains => 'Pillar With Curtains';

  @override
  String get thPointPillarsWithCurtains => 'Pillars With Curtains';

  @override
  String get thPointPopcorn => 'Popcorn';

  @override
  String get thPointRaft => 'Raft';

  @override
  String get thPointRaftCone => 'Raft Cone';

  @override
  String get thPointRemark => 'Remark';

  @override
  String get thPointRimstoneDam => 'Rimstone Dam';

  @override
  String get thPointRimstonePool => 'Rimstone Pool';

  @override
  String get thPointRoot => 'Root';

  @override
  String get thPointRope => 'Rope';

  @override
  String get thPointRopeLadder => 'Rope Ladder';

  @override
  String get thPointSand => 'Sand';

  @override
  String get thPointScallop => 'Scallop';

  @override
  String get thPointSection => 'Section';

  @override
  String get thPointSeedGermination => 'Seed Germination';

  @override
  String get thPointSink => 'Sink';

  @override
  String get thPointSnow => 'Snow';

  @override
  String get thPointSodaStraw => 'Soda Straw';

  @override
  String get thPointSpring => 'Spring';

  @override
  String get thPointStalactite => 'Stalactite';

  @override
  String get thPointStalactiteStalagmite => 'Stalactite Stalagmite';

  @override
  String get thPointStalactites => 'Stalactites';

  @override
  String get thPointStalactitesStalagmites => 'Stalactites Stalagmites';

  @override
  String get thPointStalagmite => 'Stalagmite';

  @override
  String get thPointStalagmites => 'Stalagmites';

  @override
  String get thPointStation => 'Station';

  @override
  String get thPointStationName => 'Station Name';

  @override
  String get thPointSteps => 'Steps';

  @override
  String get thPointTraverse => 'Traverse';

  @override
  String get thPointTreeTrunk => 'Tree Trunk';

  @override
  String get thPointU => 'User';

  @override
  String get thPointUnknown => 'Unknown';

  @override
  String get thPointVegetableDebris => 'Vegetable Debris';

  @override
  String get thPointViaFerrata => 'Via Ferrata';

  @override
  String get thPointVolcano => 'Volcano';

  @override
  String get thPointWalkway => 'Walkway';

  @override
  String get thPointWallCalcite => 'Wall Calcite';

  @override
  String get thPointWater => 'Water';

  @override
  String get thPointWaterDrip => 'Water Drip';

  @override
  String get thPointWaterFlow => 'Water Flow';

  @override
  String get thPointWheelchair => 'Wheelchair';

  @override
  String get thProjection => 'Projection';

  @override
  String get thSubtypeEmpty => 'Subtype empty';

  @override
  String get thSubtypeLabel => 'Subtype';

  @override
  String get thSubtypeLineBorderInvisible => 'Invisible';

  @override
  String get thSubtypeLineBorderPresumed => 'Presumed';

  @override
  String get thSubtypeLineBorderTemporary => 'Temporary';

  @override
  String get thSubtypeLineBorderVisible => 'Visible';

  @override
  String get thSubtypeLineSurveyCave => 'Cave';

  @override
  String get thSubtypeLineSurveySurface => 'Surface';

  @override
  String get thSubtypeLineWallBedrock => 'Bedrock';

  @override
  String get thSubtypeLineWallBlocks => 'Blocks';

  @override
  String get thSubtypeLineWallClay => 'Clay';

  @override
  String get thSubtypeLineWallDebris => 'Debris';

  @override
  String get thSubtypeLineWallFlowstone => 'Flowstone';

  @override
  String get thSubtypeLineWallIce => 'Ice';

  @override
  String get thSubtypeLineWallInvisible => 'Invisible';

  @override
  String get thSubtypeLineWallMoonmilk => 'Moonmilk';

  @override
  String get thSubtypeLineWallOverlying => 'Overlying';

  @override
  String get thSubtypeLineWallPebbles => 'Pebbles';

  @override
  String get thSubtypeLineWallPit => 'Pit';

  @override
  String get thSubtypeLineWallPresumed => 'Presumed';

  @override
  String get thSubtypeLineWallSand => 'Sand';

  @override
  String get thSubtypeLineWallUnderlying => 'Underlying';

  @override
  String get thSubtypeLineWallUnsurveyed => 'Unsurveyed';

  @override
  String get thSubtypeLineWaterFlowConjectural => 'Conjectural';

  @override
  String get thSubtypeLineWaterFlowIntermittent => 'Intermittent';

  @override
  String get thSubtypeLineWaterFlowPermanent => 'Permanent';

  @override
  String get thSubtypePointAirDraughtSummer => 'Summer';

  @override
  String get thSubtypePointAirDraughtUndefined => 'Undefined';

  @override
  String get thSubtypePointAirDraughtWinter => 'Winter';

  @override
  String get thSubtypePointStationFixed => 'Fixed';

  @override
  String get thSubtypePointStationNatural => 'Natural';

  @override
  String get thSubtypePointStationPainted => 'Painted';

  @override
  String get thSubtypePointStationTemporary => 'Temporary';

  @override
  String get thSubtypePointWaterFlowIntermittent => 'Intermittent';

  @override
  String get thSubtypePointWaterFlowPaleo => 'Paleo';

  @override
  String get thSubtypePointWaterFlowPermanent => 'Permanent';

  @override
  String updateAvailableBody(
    Object currentVersion,
    Object latestVersion,
    Object tagName,
    Object releaseUrl,
  ) {
    return 'A newer version is available.\n\nCurrent: $currentVersion\nLatest: $latestVersion ($tagName)\n\nDownload: $releaseUrl';
  }

  @override
  String updateAvailableInstalledVersionAge(int commitCount, int dayCount) {
    String _temp0 = intl.Intl.pluralLogic(
      commitCount,
      locale: localeName,
      other: '$commitCount commits',
      one: '1 commit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      dayCount,
      locale: localeName,
      other: '$dayCount days',
      one: '1 day',
    );
    return 'Installed version is $_temp0 and $_temp1 behind the latest release.';
  }

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableTitleWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count newer Mapiah versions available',
      one: '1 newer Mapiah version available',
    );
    return '$_temp0';
  }

  @override
  String updateCheckFailedHttpStatusBody(Object statusCode) {
    return 'Update server returned HTTP $statusCode.';
  }

  @override
  String get updateCheckFailedNoAnswerBody =>
      'Unable to check for updates because the server did not respond. Do you have an internet connection?';

  @override
  String get updateCheckFailedParsingBody =>
      'Unable to read the latest version from the update server.';

  @override
  String updateCheckFailedParsingWithTagBody(Object tagName) {
    return 'Unable to parse the latest version tag: $tagName';
  }

  @override
  String get updateCheckFailedTitle => 'Update check failed';
}
