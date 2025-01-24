import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';

class MapiahHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MPSettingsStore settingsStore = getIt<MPSettingsStore>();
    setWindowTitle(AppLocalizations.of(context).appTitle);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(AppLocalizations.of(context).appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_open_outlined),
            onPressed: () => _pickTh2File(context),
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
          _buildLanguageDropdown(settingsStore, context),
        ],
      ),
      body: Center(
          child: Text(AppLocalizations.of(context).initialPagePresentation)),
    );
  }

  Widget _buildLanguageDropdown(
      MPSettingsStore settingsStore, BuildContext context) {
    final List<String> localeIDs = [
      'sys',
      ...AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return PopupMenuButton<String>(
          onSelected: (String newValue) {
            settingsStore.setLocaleID(newValue);
          },
          itemBuilder: (BuildContext context) {
            return localeIDs.map<PopupMenuEntry<String>>((String localeID) {
              return PopupMenuItem<String>(
                value: localeID,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Row(
                    children: [
                      if (localeID == settingsStore.localeID) ...[
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary),
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

  void _pickTh2File(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: AppLocalizations.of(context).th2FilePickSelectTH2File,
        type: FileType.custom,
        allowedExtensions: ['th2'],
        initialDirectory: kDebugMode ? thDebugPath : './',
      );

      if (result != null) {
        // Use the file
        String? pickedFilePath = result.files.single.path;
        if (pickedFilePath == null) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TH2FileEditPage(filename: pickedFilePath)),
        );
      } else {
        // User canceled the picker
        getIt<MPLog>().i('No file selected.');
      }
    } catch (e) {
      getIt<MPLog>().e('Error picking file', error: e);
      // Optionally, handle the error for the user
    }
  }

  void _showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).aboutMapiahDialogWindowTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)
                    .aboutMapiahDialogMapiahVersion(version)),
                SizedBox(height: 16),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).close),
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
