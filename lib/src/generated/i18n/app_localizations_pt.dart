import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mapiah';

  @override
  String get initialPresentation => 'Mapiah: uma interface gráfica amigável para mapeamento de cavernas com Therion';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'en': 'English',
        'pt': 'Português',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }
}
