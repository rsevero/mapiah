import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mapiah/src/definitions/color_schemes.orange_brown.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mapiah_home.dart';
import 'package:mapiah/src/stores/multiple_store_reactions.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_settings_store.dart';
import 'package:mapiah/src/stores/th_store_store.dart';

final GetIt getIt = GetIt.instance;

void main() {
  _setup();
  runApp(MapiahApp());
}

void _setup() {
  getIt.registerSingleton<THSettingsStore>(THSettingsStore());
  getIt.registerSingleton<THStoreStore>(THStoreStore());
  getIt.registerSingleton<THFileDisplayStore>(THFileDisplayStore());
  getIt.registerSingleton<MultipleStoreReactions>(MultipleStoreReactions());
}

class MapiahApp extends StatelessWidget {
  const MapiahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final THSettingsStore settingsStore = getIt<THSettingsStore>();

    return Observer(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: settingsStore.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MapiahHome(),
      ),
    );
  }
}
