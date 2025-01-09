import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mapiah';

  @override
  String get initialPresentation => 'Mapiah: an user-friendly graphical interface for cave mapping with Therion';

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
