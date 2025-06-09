import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';

class MapiahHome extends StatefulWidget {
  const MapiahHome({super.key}) : super();

  @override
  State<MapiahHome> createState() => _MapiahHomeState();
}

class _MapiahHomeState extends State<MapiahHome> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (!kIsWeb) {
      setWindowTitle(appLocalizations.appTitle);
    }
    initializeMPCommandLocalizations(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(appLocalizations.appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_open_outlined),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            onPressed: () => MPDialogAux.pickTH2File(context),
            tooltip: appLocalizations.initialPageOpenFile,
          ),
          buildLanguageDropdown(context),
          MPHelpButtonWidget(
            context,
            'mapiah_home_help',
            appLocalizations.mapiahHomeHelpDialogTitle,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            onPressed: () => showAboutDialog(context),
            tooltip: appLocalizations.initialPageAboutMapiahDialog,
          ),
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
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                        Icon(
                          Icons.check,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                      ] else
                        const SizedBox(width: 32),
                      Text(AppLocalizations.of(context).languageName(localeID)),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  color: colorScheme.onSecondaryContainer,
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSecondaryContainer,
                ),
              ],
            ),
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

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
              child: Text(appLocalizations.buttonClose),
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
