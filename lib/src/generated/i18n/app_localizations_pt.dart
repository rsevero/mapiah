import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String aboutMapiahDialogMapiahVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get aboutMapiahDialogWindowTitle => 'Sobre o Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get close => 'Fechar';

  @override
  String get initialPageAboutMapiahDialog => 'Sobre o Mapiah';

  @override
  String get initialPageLanguage => 'Idioma';

  @override
  String get initialPageOpenFile => 'Abrir arquivo (Ctrl+O)';

  @override
  String get initialPagePresentation => 'Mapiah: uma interface gráfica amigável para mapeamento de cavernas com Therion';

  @override
  String get fileEditWindowWindowTitle => 'Edição de arquivo';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'sys': 'Sistema',
        'en': 'English',
        'pt': 'Português',
        'other': 'Desconhecido',
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
  String get mpCreateElementsCommandDescription => 'Criar elementos';

  @override
  String get mpCreateLineCommandDescription => 'Criar linha';

  @override
  String get mpCreatePointCommandDescription => 'Criar ponto';

  @override
  String get mpDeleteElementsCommandDescription => 'Apagar elementos';

  @override
  String get mpDeleteLineCommandDescription => 'Apagar linha';

  @override
  String get mpDeletePointCommandDescription => 'Apagar ponto';

  @override
  String get mpMoveBezierLineSegmentCommandDescription => 'Mover segmento de linha Bézier';

  @override
  String get mpMoveElementsCommandDescription => 'Mover elementos';

  @override
  String get mpMoveLineCommandDescription => 'Mover linha';

  @override
  String get mpMovePointCommandDescription => 'Mover ponto';

  @override
  String get mpMoveStraightLineSegmentCommandDescription => 'Mover segmento de linha reta';

  @override
  String get parsingErrors => 'Erros na interpretação do arquivo';

  @override
  String get th2FileEditPageChangeActiveScrapTool => 'Alterar croqui ativo (Alt+C)';

  @override
  String get th2FileEditPageDeleteButton => 'Apagar (Del)';

  @override
  String th2FileEditPageLoadingFile(Object filename) {
    return 'Lendo arquivo $filename ...';
  }

  @override
  String get th2FileEditPageNoUndoAvailable => 'Nenhuma ação para desfazer';

  @override
  String get th2FileEditPageNoRedoAvailable => 'Nenhuma ação para refazer';

  @override
  String get th2FileEditPagePanTool => 'Mover ponto de vista';

  @override
  String get th2FileEditPageSave => 'Salvar (Ctrl+S)';

  @override
  String get th2FileEditPageSaveAs => 'Salvar como (Shift+Ctrl+S)';

  @override
  String th2FileEditPageRedo(Object redoDescription) {
    return 'Refazer \'$redoDescription\' (Ctrl+Y)';
  }

  @override
  String get th2FileEditPageSelectTool => 'Selecionar';

  @override
  String th2FileEditPageUndo(Object undoDescription) {
    return 'Desfazer \'$undoDescription\' (Ctrl+Z)';
  }

  @override
  String get th2FileEditPageZoomIn => 'Aproximar (+)';

  @override
  String get th2FileEditPageZoomOneToOne => 'Mostrar 1:1 (1)';

  @override
  String get th2FileEditPageZoomOptions => 'Opções de zoom';

  @override
  String get th2FileEditPageZoomOut => 'Afastar (-)';

  @override
  String get th2FileEditPageZoomOutFile => 'Mostrar arquivo (3)';

  @override
  String get th2FileEditPageZoomOutScrap => 'Mostrar croqui (4)';

  @override
  String get th2FileEditPageZoomToSelection => 'Mostrar seleção (2)';

  @override
  String get th2FilePickSelectTH2File => 'Selecione um arquivo TH2';
}
