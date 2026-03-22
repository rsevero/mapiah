// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:mapiah/src/widgets/mp_telemetry_consent_dialog.dart';
import 'package:mapiah/src/widgets/mp_url_text_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';

class MapiahHome extends StatefulWidget {
  final String? mainFilePath;
  final List<String> th2FilePaths;
  final String? thConfigFilePath;

  const MapiahHome({
    super.key,
    this.mainFilePath,
    this.th2FilePaths = const <String>[],
    this.thConfigFilePath,
  }) : super();

  @override
  State<MapiahHome> createState() => _MapiahHomeState();
}

class _MapiahHomeState extends State<MapiahHome> {
  @override
  void initState() {
    super.initState();

    // Handle command-line file arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Handle --th2 files (named argument)
      if (widget.th2FilePaths.isNotEmpty) {
        for (final String filePath in widget.th2FilePaths) {
          _openTH2FileFromPath(filePath);
        }
      }

      // Handle --thconfig file (named argument)
      if (widget.thConfigFilePath != null) {
        MPDialogAux.runTherionWithTHConfigFile(
          context,
          widget.thConfigFilePath!,
        );
      }

      // Handle positional argument (backward compatibility)
      if (widget.mainFilePath != null &&
          widget.th2FilePaths.isEmpty &&
          widget.thConfigFilePath == null) {
        if (widget.mainFilePath!.toLowerCase().endsWith(".th2")) {
          // Open as TH2 file
          _openTH2FileFromPath(widget.mainFilePath!);
        } else {
          // Treat as THConfig file and run Therion
          MPDialogAux.runTherionWithTHConfigFile(context, widget.mainFilePath!);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mpDebugTelemetryAlwaysShowConsent ||
          !mpLocator.mpSettingsController.isBoolSet(
            MPSettingID.Main_TelemetryConsent,
          )) {
        await MPTelemetryConsentDialog.show(context);
      }

      MPDialogAux.checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final MPSettingsController mpSettingsController =
        mpLocator.mpSettingsController;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget actionsSeparator = SizedBox(
      height: 24,
      child: VerticalDivider(
        width: 8,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),
    );

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
          actionsSeparator,
          Observer(
            builder: (_) {
              final bool therionAvailable =
                  mpSettingsController.isTherionAvailable;

              return IconButton(
                key: ValueKey('MapiahHomeOpenTHConfigAndRunTherionButton'),
                icon: Icon(Icons.playlist_add_check_outlined),
                color: therionAvailable
                    ? colorScheme.onSecondaryContainer
                    : mpTherionRunStatusBackgroundErrorColor,
                onPressed: () =>
                    MPDialogAux.chooseTHConfigAndRunTherion(context),
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
              final VoidCallback? onPressed = hasTHConfig
                  ? () => MPDialogAux.runTherionWithLastTHConfig(context)
                  : null;

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
          actionsSeparator,
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
      body: Center(
        child: Text(
          appLocalizations.initialPagePresentation,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );

    return _withShortcuts(scaffold);
  }

  void initializeMPCommandLocalizations(BuildContext context) {
    mpLocator.resetAppLocalizations(context);
    MPTextToUser.initialize();
  }

  void _openTH2FileFromPath(String filePath) async {
    try {
      // Create the controller for the file before adding the tab
      mpLocator.mpGeneralController.getTH2FileEditController(
        filename: filePath,
      );

      mpLocator.mpGeneralController.addFileTab(filePath);
      MPDialogAux.ensureTabsPageOpen(context);
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
                // Version
                Text(appLocalizations.aboutMapiahDialogMapiahVersion(version)),
                SizedBox(height: mpButtonSpace),
                // Optional release information (handle name-only, url-only, and both)
                if (mpReleaseName.isNotEmpty && mpReleaseURL.isNotEmpty) ...[
                  // Show localized release name and a clickable URL in parentheses
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        appLocalizations.aboutMapiahDialogReleaseNoUrl(
                          mpReleaseName,
                        ),
                      ),
                      Text(' ('),
                      MPURLTextWidget(url: mpReleaseURL, label: mpReleaseURL),
                      Text(')'),
                    ],
                  ),
                  SizedBox(height: mpButtonSpace),
                ] else if (mpReleaseName.isNotEmpty) ...[
                  Text(
                    appLocalizations.aboutMapiahDialogReleaseNoUrl(
                      mpReleaseName,
                    ),
                  ),
                  SizedBox(height: mpButtonSpace),
                ] else if (mpReleaseURL.isNotEmpty) ...[
                  // Only URL present: show it as a clickable link
                  MPURLTextWidget(url: mpReleaseURL, label: mpReleaseURL),
                  SizedBox(height: mpButtonSpace),
                ],
                // Changelog and license links
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
    final Map<ShortcutActivator, VoidCallback> bindings =
        <ShortcutActivator, VoidCallback>{
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
          // Therion: Ctrl+T
          const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
              MPDialogAux.chooseTHConfigAndRunTherion(context),
          const SingleActivator(LogicalKeyboardKey.keyT, meta: true): () =>
              MPDialogAux.chooseTHConfigAndRunTherion(context),
          // Therion: T (no modifiers)
          const SingleActivator(LogicalKeyboardKey.keyT): () =>
              MPDialogAux.runTherionWithLastTHConfig(context),
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
