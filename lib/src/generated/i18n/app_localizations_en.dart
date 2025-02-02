import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String aboutMapiahDialogMapiahVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutMapiahDialogWindowTitle => 'About Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get close => 'Close';

  @override
  String get initialPagePresentation => 'Mapiah: an user-friendly graphical interface for cave mapping with Therion';

  @override
  String get fileEditWindowWindowTitle => 'File edit';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'sys': 'System',
        'en': 'English',
        'pt': 'Português',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get mpLengthUnitCentimeterAbbreviation => 'cm';

  @override
  String get mpLengthUnitFootAbbreviation => 'ft';

  @override
  String get mpLengthUnitInchAbbreviation => 'in';

  @override
  String get mpLengthUnitMeterAbbreviation => 'm';

  @override
  String get mpLengthUnitYardAbbreviation => 'yd';

  @override
  String get mpMoveBezierLineSegmentCommandDescription => 'Move Bézier line segment';

  @override
  String get mpMoveElementsCommandDescription => 'Move elements';

  @override
  String get mpMoveLineCommandDescription => 'Move line';

  @override
  String get mpMovePointCommandDescription => 'Move point';

  @override
  String get mpMoveStraightLineSegmentCommandDescription => 'Move straight line segment';

  @override
  String get parsingErrors => 'Parsing errors';

  @override
  String get th2FileEditPageChangeActiveScrapTool => 'Change active scrap';

  @override
  String th2FileEditPageLoadingFile(Object filename) {
    return 'Loading file $filename ...';
  }

  @override
  String get th2FileEditPageNoUndoAvailable => 'No undo available';

  @override
  String get th2FileEditPageNoRedoAvailable => 'No redo available';

  @override
  String get th2FileEditPagePanTool => 'Pan';

  @override
  String get th2FileEditPageSelectTool => 'Select';

  @override
  String get th2FileEditPageZoomIn => 'Zoom In (Ctrl+)';

  @override
  String get th2FileEditPageZoomOneToOne => 'Zoom 1:1 (1)';

  @override
  String get th2FileEditPageZoomOptions => 'Zoom Options';

  @override
  String get th2FileEditPageZoomOut => 'Zoom Out (Ctrl-)';

  @override
  String get th2FileEditPageZoomOutFile => 'Show file (3)';

  @override
  String get th2FileEditPageZoomOutScrap => 'Show scrap (4)';

  @override
  String get th2FileEditPageZoomToSelection => 'Zoom to selection (2)';

  @override
  String get th2FilePickSelectTH2File => 'Select a TH2 file';
}
