import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/definitions/color_schemes.orange_brown.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mapiah_home.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/stores/th_settings_store.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MapiahApp());
}

class MapiahApp extends StatelessWidget {
  const MapiahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => THSettingsStore(),
        ),
        Provider(
          create: (context) => THFileStore(),
        ),
        Provider(
          create: (context) => THFileDisplayStore(),
        ),
      ],
      child: Consumer<THSettingsStore>(
        builder: (context, settingsStore, child) {
          return Observer(
            builder: (context) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme:
                  ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
              darkTheme:
                  ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              locale: settingsStore.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MapiahHome(),
            ),
          );
        },
      ),
    );
  }
}
