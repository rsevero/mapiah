import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/themes/material_theme.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mapiah_home.dart';

// /// For mobx debugging with spy().
// import 'package:mobx/mobx.dart';

final MPLocator mpLocator = MPLocator();

void main() {
  // /// For mobx debugging with spy().
  // mainContext.config = mainContext.config.clone(
  //   isSpyEnabled: true,
  // );

  // mainContext.spy(print);

  // /// For layout debugging.
  // debugPaintSizeEnabled = true;
  runApp(MapiahApp());
}

class MapiahApp extends StatelessWidget {
  const MapiahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: MaterialTheme.lightScheme().toColorScheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: MaterialTheme.darkScheme().toColorScheme(),
        ),
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: mpLocator.mpSettingsController.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MapiahHome(),
      ),
    );
  }
}
