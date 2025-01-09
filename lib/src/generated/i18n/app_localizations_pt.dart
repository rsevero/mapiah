import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutMapiah => 'Sobre o Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get close => 'Fechar';

  @override
  String get initialPresentation => 'Mapiah: uma interface gráfica amigável para mapeamento de cavernas com Therion';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'en': 'English',
        'pt': 'Português',
        'other': 'Desconhecido',
      },
    );
    return '$_temp0';
  }

  @override
  String mapiahVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get parsingErrors => 'Erros na interpretação do arquivo';

  @override
  String get selectTH2File => 'Selecione um arquivo TH2';
}
