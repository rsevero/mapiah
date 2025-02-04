import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:window_size/window_size.dart';

class MapiahHome extends StatefulWidget {
  const MapiahHome({super.key}) : super();

  @override
  State<MapiahHome> createState() => _MapiahHomeState();
}

class _MapiahHomeState extends State<MapiahHome> {
  bool _isFilePickerOpen = false;

  @override
  Widget build(BuildContext context) {
    setWindowTitle(AppLocalizations.of(context).appTitle);

    initializeMPCommandLocalizations(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(AppLocalizations.of(context).appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_open_outlined),
            onPressed: () => pickTh2File(context),
            tooltip: mpLocator.appLocalizations.initialPageOpenFile,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(context),
            tooltip: mpLocator.appLocalizations.initialPageAboutMapiahDialog,
          ),
          buildLanguageDropdown(context),
        ],
      ),
      body: Center(
          child: Text(AppLocalizations.of(context).initialPagePresentation)),
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
            mpLocator.mpSettingsStore.setLocaleID(newValue);
          },
          itemBuilder: (BuildContext context) {
            return localeIDs.map<PopupMenuEntry<String>>((String localeID) {
              return PopupMenuItem<String>(
                value: localeID,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Row(
                    children: [
                      if (localeID == mpLocator.mpSettingsStore.localeID) ...[
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

  void initializeMPCommandLocalizations(BuildContext context) {
    mpLocator.resetAppLocalizations(context);

    MPTextToUser.resetTextToUser();
  }

  void pickTh2File(BuildContext context) async {
    if (_isFilePickerOpen) {
      return;
    }

    _isFilePickerOpen = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: AppLocalizations.of(context).th2FilePickSelectTH2File,
        type: FileType.custom,
        allowedExtensions: ['th2'],
        initialDirectory: mpLocator.mpGeneralStore.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralStore.lastAccessedDirectory,
      );

      if (result != null) {
        String? pickedFilePath = result.files.single.path;

        if (pickedFilePath == null) {
          return;
        }

        String directoryPath = p.dirname(pickedFilePath);
        mpLocator.mpGeneralStore.lastAccessedDirectory = directoryPath;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TH2FileEditPage(filename: pickedFilePath)),
        );
      } else {
        mpLocator.mpLog.i('No file selected.');
      }
    } catch (e) {
      mpLocator.mpLog.e('Error picking file', error: e);
    } finally {
      _isFilePickerOpen = false;
    }
  }

  void showAboutDialog(BuildContext context) async {
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
