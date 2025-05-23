import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';

class MapiahHome extends StatefulWidget {
  const MapiahHome({super.key}) : super();

  @override
  State<MapiahHome> createState() => _MapiahHomeState();
}

class _MapiahHomeState extends State<MapiahHome> {
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  Widget build(BuildContext context) {
    setWindowTitle(mpLocator.appLocalizations.appTitle);

    initializeMPCommandLocalizations(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(appLocalizations.appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_open_outlined),
            onPressed: () => MPDialogAux.pickTh2File(context),
            tooltip: appLocalizations.initialPageOpenFile,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(context),
            tooltip: appLocalizations.initialPageAboutMapiahDialog,
          ),
          buildLanguageDropdown(context),
        ],
      ),
      body: Center(
        child: Text(
          appLocalizations.initialPagePresentation,
        ),
      ),
    );
  }

  Widget buildLanguageDropdown(BuildContext context) {
    final List<String> localeIDs = [
      'sys',
      ...AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return PopupMenuButton<String>(
          onSelected: (String newValue) {
            mpLocator.mpSettingsController.setLocaleID(newValue);
          },
          itemBuilder: (BuildContext context) {
            return localeIDs.map<PopupMenuEntry<String>>((String localeID) {
              return PopupMenuItem<String>(
                value: localeID,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Row(
                    children: [
                      if (localeID ==
                          mpLocator.mpSettingsController.localeID) ...[
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                      ] else
                        const SizedBox(width: 32),
                      Text(appLocalizations.languageName(localeID)),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.language),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  void initializeMPCommandLocalizations(BuildContext context) {
    mpLocator.resetAppLocalizations(context);

    MPTextToUser.initialize();
  }

  void showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.aboutMapiahDialogWindowTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(appLocalizations.aboutMapiahDialogMapiahVersion(version)),
                SizedBox(height: 16),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalizations.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
