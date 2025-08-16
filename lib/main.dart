import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_context_menu_suppression.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mapiah_home.dart';

// /// For mobx debugging with spy().
// import 'package:mobx/mobx.dart';

final MPLocator mpLocator = MPLocator();

void main(List<String> arguments) {
  String? fileToRead;

  // Parse command line arguments: first arg not starting with '-'
  for (var arg in arguments) {
    if (!arg.startsWith('-')) {
      fileToRead = arg;
      break;
    }
  }

  // /// For mobx debugging with spy().
  // mainContext.config = mainContext.config.clone(
  //   isSpyEnabled: true,
  // );
  // mainContext.spy((spyEvent) {
  //   switch (spyEvent.type) {
  //     case 'action':
  //       print('Action: ${spyEvent}');
  //     // case 'transaction':
  //     //   print('Transaction: ${spyEvent.name}');
  //     case 'reaction':
  //       print('Reaction: ${spyEvent.name}');
  //     case 'computed':
  //       print('Computed: ${spyEvent}');
  //     // case 'error':
  //     //   print('Error: ${spyEvent.name}');
  //     default:
  //     // print('Unknown: $spyEvent');
  //   }
  //   // Uncomment and modify the following lines as needed for debugging:
  //   // print("Spy event: $spyEvent");
  //   // if (spyEvent.type == 'compute') {
  //   //   print('Compute: ${spyEvent.name}');
  //   // }
  // });

  // /// For layout debugging.
  // debugPaintSizeEnabled = true;
  if (kIsWeb) {
    suppressContextMenu();
  }
  runApp(MapiahApp(fileToRead: fileToRead));
}

class MapiahApp extends StatelessWidget {
  final String? fileToRead;

  const MapiahApp({super.key, this.fileToRead});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 0xe2, 0x5b, 0x30),
            dynamicSchemeVariant: DynamicSchemeVariant.content,
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              padding: WidgetStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
          ),
        ),
        // darkTheme: ThemeData(
        //   useMaterial3: true,
        //   colorScheme: MaterialTheme.darkScheme().toColorScheme(),
        // ),
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: mpLocator.mpSettingsController.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MapiahHome(mainFilePath: fileToRead),
      ),
    );
  }
}
