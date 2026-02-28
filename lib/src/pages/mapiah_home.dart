import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MPDialogAux.checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final MPSettingsController mpSettingsController =
        mpLocator.mpSettingsController;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    try {
      setWindowTitle(appLocalizations.appTitle);
    } on MissingPluginException {
      // In widget tests, desktop plugins (like window_size) may not be
      // registered. Ignore the missing plugin so tests can run headless.
    } on PlatformException {
      // Also ignore other platform exceptions in non-desktop environments
      // during tests.
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
          Observer(
            builder: (_) {
              final bool therionAvailable =
                  mpSettingsController.isTherionAvailable;

              final VoidCallback? onPressed = therionAvailable
                  ? () async {
                      await MPDialogAux.pickTHConfigFileAndRunTherion(context);
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  : () => MPDialogAux.showHelpDialog(
                      context,
                      'no_therion_found',
                      appLocalizations.mpNoTherionFound,
                    );

              return IconButton(
                key: ValueKey('MapiahHomeOpenTHConfigAndRunTherionButton'),
                icon: Icon(Icons.playlist_add_check_outlined),
                color: therionAvailable
                    ? colorScheme.onSecondaryContainer
                    : mpTherionRunStatusBackgroundErrorColor,
                onPressed: onPressed,
                tooltip: therionAvailable
                    ? appLocalizations
                          .mapiahOpenTHConfigAndRunTherionButtonTooltip
                    : appLocalizations.mpNoTherionFound,
              );
            },
          ),
          Observer(
            builder: (_) {
              final bool therionAvailable =
                  mpSettingsController.isTherionAvailable;

              final bool hasTHConfig =
                  mpLocator.mpGeneralController.thConfigFilePath.isNotEmpty;

              final VoidCallback? onPressed = !hasTHConfig
                  ? null
                  : (therionAvailable
                        ? () => MPDialogAux.runTherion(context)
                        : () => MPDialogAux.showHelpDialog(
                            context,
                            'no_therion_found',
                            appLocalizations.mpNoTherionFound,
                          ));

              return IconButton(
                key: ValueKey('MapiahHomeRunTherionButton'),
                icon: Icon(Icons.play_arrow_outlined),
                color: therionAvailable
                    ? colorScheme.onSecondaryContainer
                    : mpTherionRunStatusBackgroundErrorColor,
                onPressed: onPressed,
                tooltip: therionAvailable
                    ? appLocalizations.mapiahRunTherionButtonTooltip
                    : appLocalizations.mpNoTherionFound,
              );
            },
          ),
          IconButton(
            key: ValueKey('MapiahHomeSettingsButton'),
            icon: Icon(Icons.settings_outlined),
            color: colorScheme.onSecondaryContainer,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const MPSettingsPage(),
                ),
              );
            },
            tooltip: appLocalizations.mpSettingsPageTitle,
          ),
          MPHelpButtonWidget(
            context,
            mpHelpPageKeyboardShortcutsMain,
            appLocalizations.mapiahKeyboardShortcutsTitle,
            iconData: Icons.keyboard_alt_outlined,
            tooltip: appLocalizations.mapiahKeyboardShortcutsTooltip,
          ),
          MPHelpButtonWidget(
            context,
            mpHelpPageMapiahHome,
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
            mpHelpPageMapiahHome,
            appLocalizations.mapiahHomeHelpDialogTitle,
          ),
      // Keyboard shortcuts
      const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
          MPDialogAux.showHelpDialog(
            context,
            mpHelpPageKeyboardShortcutsMain,
            appLocalizations.mapiahKeyboardShortcutsTitle,
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
