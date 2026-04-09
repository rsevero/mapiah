// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/exceptions/th_base_exception.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mapiah_home.dart';

// /// For mobx debugging with spy().
// import 'package:mobx/mobx.dart';

MPLocator? _mpLocator;

MPLocator get mpLocator => _mpLocator ??= MPLocator();

void main(List<String> arguments) {
  String? fileToRead;
  String? thConfigFile;
  String? therionRunParametersArg;
  final List<String> th2Files = <String>[];

  // Parse command line arguments
  for (int i = 0; i < arguments.length; i++) {
    final String arg = arguments[i];

    if (arg == '--thconfig') {
      if (thConfigFile != null) {
        print(
          'Error: Multiple --thconfig parameters provided. Only one is allowed.',
        );
        exit(1);
      }
      if (i + 1 < arguments.length) {
        thConfigFile = arguments[i + 1];
        i++; // Skip next argument as it's the value
      } else {
        print('Error: --thconfig requires a file path.');
        exit(1);
      }
    } else if (arg == '--th2') {
      if ((i + 1) < arguments.length) {
        th2Files.add(arguments[i + 1]);
        i++; // Skip next argument as it's the value
      } else {
        print('Error: --th2 requires a file path.');
        exit(1);
      }
    } else if (arg == '--therion_run_parameters') {
      if ((i + 1) < arguments.length) {
        therionRunParametersArg = arguments[i + 1];
        i++; // Skip next argument as it's the value
      } else {
        print('Error: --therion_run_parameters requires a value.');
        exit(1);
      }
    } else if (!arg.startsWith('-')) {
      // Backward compatibility: first non-flag argument
      fileToRead ??= arg;
    }
  }

  // Merge th2Files into fileToRead for backward compatibility handling
  if (th2Files.isNotEmpty) {
    fileToRead = null; // Ignore positional arg if named args are used
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

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Wait for settings initialization (reads config file and SharedPreferences)
      await mpLocator.mpSettingsController.initialized;

      mpLocator.mpLog.i(
        '$mpTherionStartupDebugPrefix rawArguments=${arguments.join(' | ')}',
      );
      mpLocator.mpLog.i(
        '$mpTherionStartupDebugPrefix parsed mainFilePath=$fileToRead '
        'thConfigFilePath=$thConfigFile '
        'th2Files=${th2Files.join(' | ')} '
        'currentDirectory=${Directory.current.path}',
      );

      if (therionRunParametersArg != null) {
        mpLocator.mpSettingsController.setString(
          MPSettingID.Therion_RunParameters,
          therionRunParametersArg,
        );
      }

      unawaited(mpLocator.mpTelemetryController.initialize());

      THBaseException.registerUnhandledReporter((error, stack) {
        MPDialogAux.showUnhandledErrorDialog(error, stack);
      });

      // /// For layout debugging.
      // debugPaintSizeEnabled = true;

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (details.exception is! THBaseException) {
          MPDialogAux.showUnhandledErrorDialog(
            details.exception,
            details.stack,
          );
        }
      };

      ui.PlatformDispatcher.instance.onError =
          (Object error, StackTrace stack) {
            if (error is! THBaseException) {
              MPDialogAux.showUnhandledErrorDialog(error, stack);
            }
            return true;
          };

      runApp(
        MapiahApp(
          mainFilePath: fileToRead,
          th2FilePaths: th2Files,
          thConfigFilePath: thConfigFile,
        ),
      );
    },
    (Object error, StackTrace stack) {
      if (error is! THBaseException) {
        MPDialogAux.showUnhandledErrorDialog(error, stack);
      }
    },
  );
}

class MapiahApp extends StatelessWidget {
  final String? mainFilePath;
  final List<String> th2FilePaths;
  final String? thConfigFilePath;

  const MapiahApp({
    super.key,
    this.mainFilePath,
    this.th2FilePaths = const <String>[],
    this.thConfigFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        mpLocator.mpSettingsController.getTrigger(MPSettingID.Main_LocaleID);

        return MaterialApp(
          navigatorKey: mpLocator.mpNavigatorKey,
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
          home: MapiahHome(
            mainFilePath: mainFilePath,
            th2FilePaths: th2FilePaths,
            thConfigFilePath: thConfigFilePath,
          ),
        );
      },
    );
  }
}
