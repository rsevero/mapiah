import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:mapiah/src/widgets/mp_url_text_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';

class MapiahHome extends StatefulWidget {
  final String? mainFilePath;

  const MapiahHome({super.key, this.mainFilePath}) : super();

  @override
  State<MapiahHome> createState() => _MapiahHomeState();
}

class _MapiahHomeState extends State<MapiahHome> {
  @override
  void initState() {
    super.initState();

    // If a TH2 file path is provided, navigate to edit page after frame builds
    if (widget.mainFilePath != null) {
      if (widget.mainFilePath!.toLowerCase().endsWith(".th2")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openTH2FileFromPath(widget.mainFilePath!);
        });
      } else {
        mpLocator.mpLog.e('Invalid file extension: ${widget.mainFilePath}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!kIsWeb) {
      try {
        setWindowTitle(appLocalizations.appTitle);
      } on MissingPluginException {
        // In widget tests, desktop plugins (like window_size) may not be
        // registered. Ignore the missing plugin so tests can run headless.
      } on PlatformException {
        // Also ignore other platform exceptions in non-desktop environments
        // during tests.
      }
    }
    initializeMPCommandLocalizations(context);

    final Scaffold scaffold = Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(appLocalizations.appTitle),
        actions: <Widget>[
          IconButton(
            key: ValueKey('MapiahHomeNewFileButton'),
            icon: Icon(Icons.insert_drive_file_outlined),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => MPDialogAux.newFile(context),
            tooltip: appLocalizations.mapiahHomeNewFileButtonTooltip,
          ),
          IconButton(
            key: ValueKey('MapiahHomeOpenFileButton'),
            icon: Icon(Icons.file_open_outlined),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => MPDialogAux.pickTH2File(context),
            tooltip: appLocalizations.mapiahHomeOpenFile,
          ),
          buildLanguageDropdown(context),
          MPHelpButtonWidget(
            context,
            'mapiah_home_help',
            appLocalizations.mapiahHomeHelpDialogTitle,
          ),
          IconButton(
            key: ValueKey('MapiahHomeAboutButton'),
            icon: Icon(Icons.info_outline),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => showAboutDialog(context),
            tooltip: appLocalizations.mapiahHomeAboutMapiahDialog,
          ),
        ],
      ),
      body: Center(child: Text(appLocalizations.initialPagePresentation)),
    );

    return _withShortcuts(scaffold);
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
                        Icon(Icons.check, color: colorScheme.primary),
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
                Icon(Icons.language, color: colorScheme.onSecondaryContainer),
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

  void _openTH2FileFromPath(String filePath) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TH2FileEditPage(
            key: ValueKey("TH2FileEditPage|$filePath"),
            filename: filePath,
          ),
        ),
      );
    } catch (e) {
      mpLocator.mpLog.e('Error opening file: $e');
    }
  }

  void showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String version = packageInfo.version;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.aboutMapiahDialogWindowTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(appLocalizations.aboutMapiahDialogMapiahVersion(version)),
                SizedBox(height: mpButtonSpace),
                MPURLTextWidget(
                  url: mpChangelogURL,
                  label: appLocalizations.aboutMapiahDialogChangelog,
                ),
                SizedBox(height: mpButtonSpace),
                MPURLTextWidget(
                  url: mpLicenseURL,
                  label: appLocalizations.aboutMapiahDialogLicense,
                ),
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

// Shortcut handling using CallbackShortcuts (simpler than Intent/Action for basic triggers)
extension on _MapiahHomeState {
  Widget _withShortcuts(Widget child) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bindings = <ShortcutActivator, VoidCallback>{
      // New file
      const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
          MPDialogAux.newFile(context),
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
          MPDialogAux.newFile(context),
      // macOS Cmd+Shift+N
      const SingleActivator(
        LogicalKeyboardKey.keyN,
        meta: true,
        shift: true,
      ): () =>
          MPDialogAux.newFile(context),
      // Web-safe fallback (Ctrl+Shift+N) since some browsers block Ctrl+N
      const SingleActivator(
        LogicalKeyboardKey.keyN,
        control: true,
        shift: true,
      ): () =>
          MPDialogAux.newFile(context),
      // Open file: desktop standard Ctrl/Cmd+O
      const SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
          MPDialogAux.pickTH2File(context),
      const SingleActivator(LogicalKeyboardKey.keyO, meta: true): () =>
          MPDialogAux.pickTH2File(context),
      // macOS Cmd+Shift+O
      const SingleActivator(
        LogicalKeyboardKey.keyO,
        meta: true,
        shift: true,
      ): () =>
          MPDialogAux.pickTH2File(context),
      const SingleActivator(
        LogicalKeyboardKey.keyO,
        control: true,
        shift: true,
      ): () =>
          MPDialogAux.pickTH2File(context),
      // Help
      const SingleActivator(LogicalKeyboardKey.f1): () =>
          MPDialogAux.showHelpDialog(
            context,
            'mapiah_home_help',
            appLocalizations.mapiahHomeHelpDialogTitle,
          ),
    };

    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
