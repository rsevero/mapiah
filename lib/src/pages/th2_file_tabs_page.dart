// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/mp_window_title.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';
import 'package:mapiah/src/pages/th2_file_properties_page.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:mapiah/src/widgets/mp_file_tab_widget.dart';
import 'package:mapiah/src/widgets/mp_responsive_app_bar.dart';
import 'package:mapiah/src/widgets/mp_telemetry_consent_dialog.dart';
import 'package:mapiah/src/widgets/mp_url_text_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_body_widget.dart';
import 'package:mapiah/src/widgets/th_project_search_widget.dart';
import 'package:mapiah/src/widgets/th_project_tree_resize_divider_widget.dart';
import 'package:mapiah/src/widgets/th_project_tree_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_tab_body_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart' hide Listener;
import 'package:package_info_plus/package_info_plus.dart';

enum _TH2FileTabsAction {
  save,
  saveAs,
  runTherion,
  closeProject,
  settings,
  keyboardShortcuts,
  help,
  about,
}

typedef _TH2FileLoad = ({
  TH2FileEditController controller,
  Future<TH2FileEditControllerCreateResult> future,
});

class TH2FileTabsPage extends StatefulWidget {
  final String? mainFilePath;
  final List<String> th2FilePaths;
  final String? thConfigFilePath;
  final MPPickProjectAndRunTherion? pickProjectAndRunTherion;
  final MPRerunTherionForOpenProject? rerunTherionForOpenProject;

  const TH2FileTabsPage({
    super.key,
    this.mainFilePath,
    this.th2FilePaths = const <String>[],
    this.thConfigFilePath,
    this.pickProjectAndRunTherion,
    this.rerunTherionForOpenProject,
  });

  @override
  State<TH2FileTabsPage> createState() => _TH2FileTabsPageState();
}

class _TH2FileTabsPageState extends State<TH2FileTabsPage> {
  late ReactionDisposer _activeTabFocusReaction;
  final Map<String, _TH2FileLoad> _fileLoads = <String, _TH2FileLoad>{};
  late final ScrollController _tabScrollController;

  int _dragOverTabIndex = -1;

  @override
  void initState() {
    super.initState();

    _tabScrollController = ScrollController();

    /// Give keyboard focus to the incoming tab's canvas after each tab
    /// switch so that keyboard shortcuts (e.g. Ctrl+V) are delivered to
    /// the visible canvas and not to an offstage one.
    _activeTabFocusReaction = reaction(
      (_) => mpLocator.mpGeneralController.activeTabIndex,
      (_) => _scheduleActiveTabFocus(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runStartupFileActions();

      if (!mounted) {
        return;
      }

      _scheduleActiveTabFocus();

      if (mpDebugTelemetryAlwaysShowConsent ||
          !mpLocator.mpSettingsController.isBoolSet(
            MPSettingID.Main_TelemetryConsent,
          )) {
        await MPTelemetryConsentDialog.show(context);
      }

      MPDialogAux.checkForUpdates();
    });
  }

  void _scheduleActiveTabFocus() {
    final int index = mpLocator.mpGeneralController.activeTabIndex;
    final List<String> order = mpLocator.mpGeneralController.openFileOrder;

    if ((index < 0) || (index >= order.length)) {
      return;
    }

    final String filename = order[index];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (isTH2Tab(filename)) {
        mpLocator.mpGeneralController
            .getTH2FileEditControllerIfExists(filename)
            ?.th2FileFocusNode
            .requestFocus();
      } else {
        mpLocator.mpGeneralController
            .getTextEditorControllerIfExists(filename)
            ?.textEditorFocusNode
            .requestFocus();
      }
    });
  }

  Future<void> _runStartupFileActions() async {
    final bool isTherionDebugLog1Enabled =
        mpLocator.mpSettingsController.isTherionDebugLog1Enabled;

    // Handle --th2 files (named argument)
    if (widget.th2FilePaths.isNotEmpty) {
      if (isTherionDebugLog1Enabled) {
        mpLocator.mpLog.i(
          '$mpTherionStartupDebugPrefix opening TH2 files from startup '
          'arguments: ${widget.th2FilePaths.join(' | ')} '
          'currentDirectory=${Directory.current.path}',
        );
      }

      for (final String filePath in widget.th2FilePaths) {
        await _openTH2FileFromPath(filePath);
      }
    }

    // Handle --thconfig file (named argument)
    if (widget.thConfigFilePath != null) {
      if (isTherionDebugLog1Enabled) {
        mpLocator.mpLog.i(
          '$mpTherionStartupDebugPrefix startup launch mode=--thconfig '
          'path=${widget.thConfigFilePath} '
          'currentDirectory=${Directory.current.path}',
        );
      }

      if (!mounted) {
        return;
      }

      await MPDialogAux.runTherionAndOpenProjectInBackground(
        context,
        widget.thConfigFilePath!,
      );

      return;
    }

    // Handle positional argument (backward compatibility)
    if ((widget.mainFilePath != null) && widget.th2FilePaths.isEmpty) {
      if (widget.mainFilePath!.toLowerCase().endsWith(".th2")) {
        if (isTherionDebugLog1Enabled) {
          mpLocator.mpLog.i(
            '$mpTherionStartupDebugPrefix startup launch mode=positional-th2 '
            'path=${widget.mainFilePath} '
            'currentDirectory=${Directory.current.path}',
          );
        }
        await _openTH2FileFromPath(widget.mainFilePath!);
      } else {
        if (isTherionDebugLog1Enabled) {
          mpLocator.mpLog.i(
            '$mpTherionStartupDebugPrefix '
            'startup launch mode=positional-thconfig '
            'path=${widget.mainFilePath} '
            'currentDirectory=${Directory.current.path}',
          );
        }

        if (!mounted) {
          return;
        }

        await MPDialogAux.runTherionAndOpenProjectInBackground(
          context,
          widget.mainFilePath!,
        );
      }
    }
  }

  Future<void> _openTH2FileFromPath(String filePath) async {
    try {
      // Create the controller for the file before adding the tab
      mpLocator.mpGeneralController.getTH2FileEditController(
        filename: filePath,
      );

      mpLocator.mpGeneralController.addFileTab(filePath);
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

  @override
  void dispose() {
    _tabScrollController.dispose();
    _activeTabFocusReaction();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeMPCommandLocalizations(context);

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

    unawaited(mpSetWindowTitleIfAvailable(appLocalizations.appTitle));

    final Scaffold scaffold = Scaffold(
      appBar: MPResponsiveAppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        title: const SizedBox.shrink(),
        compactAction: _buildOverflowMenu(
          appLocalizations: appLocalizations,
          mpSettingsController: mpSettingsController,
        ),
        expandedActions: <Widget>[
          Observer(
            builder: (_) {
              final List<String> openFileOrder =
                  mpLocator.mpGeneralController.openFileOrder;
              final int activeTabIndex =
                  mpLocator.mpGeneralController.activeTabIndex;

              if (openFileOrder.isEmpty ||
                  activeTabIndex >= openFileOrder.length) {
                return SizedBox.shrink();
              }

              final String activeFilename = openFileOrder[activeTabIndex];
              final bool isTH2 = isTH2Tab(activeFilename);
              final TH2FileEditController? controller = isTH2
                  ? mpLocator.mpGeneralController
                        .getTH2FileEditControllerIfExists(activeFilename)
                  : null;
              final THTextEditorController? textController = isTH2
                  ? null
                  : mpLocator.mpGeneralController
                        .getTextEditorControllerIfExists(activeFilename);

              return Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.save_outlined,
                      color: (controller?.enableSaveButton ?? false)
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSecondaryContainer.withAlpha(100),
                    ),
                    onPressed: (controller?.enableSaveButton ?? false)
                        ? () => controller?.saveTH2File()
                        : null,
                    tooltip: appLocalizations.th2FileEditPageSave,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.save_as_outlined,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    onPressed: isTH2
                        ? ((controller?.isBroken ?? false)
                              ? null
                              : () => controller?.saveAsTH2File())
                        : () => unawaited(textController?.saveAs()),
                    tooltip: isTH2
                        ? appLocalizations.th2FileEditPageSaveAs
                        : appLocalizations.textEditorTabSaveAs,
                  ),
                ],
              );
            },
          ),
          actionsSeparator,
          Observer(
            builder: (_) {
              final bool therionAvailable =
                  mpSettingsController.isTherionAvailable;
              final bool hasOpenProject =
                  mpLocator.thProjectController.rootConfigPath.isNotEmpty;
              final VoidCallback? onPressed = hasOpenProject
                  ? _rerunTherionForOpenProject
                  : null;

              return IconButton(
                key: const ValueKey('TH2FileTabsPageRunTherionButton'),
                icon: const Icon(Icons.play_arrow_outlined),
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
            key: const ValueKey('TH2FileTabsPageSettingsButton'),
            icon: const Icon(Icons.settings_outlined),
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
            mpHelpPageKeyboardShortcutsEdit,
            appLocalizations.mapiahKeyboardShortcutsTitle,
            iconData: Icons.keyboard_alt_outlined,
            tooltip: appLocalizations.mapiahKeyboardShortcutsTooltip,
          ),
          MPHelpButtonWidget(
            context,
            mpHelpPageTh2FileEdit,
            appLocalizations.th2FileEditPageHelpDialogTitle,
          ),
          IconButton(
            key: const ValueKey('TH2FileTabsPageAboutButton'),
            icon: const Icon(Icons.info_outline),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => showAboutDialog(context),
            tooltip: appLocalizations.mapiahHomeAboutMapiahDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(mpTabBarHeight),
          child: Observer(
            builder: (_) {
              final List<String> openFileOrder =
                  mpLocator.mpGeneralController.openFileOrder;
              final int activeTabIndex =
                  mpLocator.mpGeneralController.activeTabIndex;

              return SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: MouseRegion(
                    onEnter: (_) {
                      // Focus the SingleChildScrollView to receive mouse wheel events
                    },
                    child: Listener(
                      onPointerSignal: (PointerSignalEvent event) {
                        if (event is PointerScrollEvent) {
                          final double newOffset =
                              (_tabScrollController.offset +
                              event.scrollDelta.dy);
                          _tabScrollController.jumpTo(
                            newOffset.clamp(
                              0.0,
                              _tabScrollController.position.maxScrollExtent,
                            ),
                          );
                        }
                      },
                      child: GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          _tabScrollController.jumpTo(
                            _tabScrollController.offset - details.delta.dx,
                          );
                        },
                        child: SingleChildScrollView(
                          controller: _tabScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (
                                int tabIndex = 0;
                                tabIndex < openFileOrder.length;
                                tabIndex++
                              )
                                _buildDraggableTab(
                                  filename: openFileOrder[tabIndex],
                                  tabIndex: tabIndex,
                                  openFileOrder: openFileOrder,
                                  activeTabIndex: activeTabIndex,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Observer(
            builder: (_) {
              final List<String> openFileOrder =
                  mpLocator.mpGeneralController.openFileOrder;
              final int activeTabIndex =
                  mpLocator.mpGeneralController.activeTabIndex;
              final THProjectTreeUIController projectTreeUIController =
                  mpLocator.thProjectTreeUIController;
              final bool sidebarCollapsed =
                  projectTreeUIController.isSidebarCollapsed ||
                  (constraints.maxWidth <
                      (mpProjectTreeSidebarMinWidth +
                          mpProjectTreeMinimumWorkspaceWidth));
              final Widget workspace;

              if (openFileOrder.isEmpty) {
                workspace = Center(
                  child: Text(appLocalizations.initialPagePresentation),
                );
              } else {
                workspace = PopScope(
                  canPop: false,
                  child: IndexedStack(
                    index: activeTabIndex,
                    children: <Widget>[
                      for (String filename in openFileOrder)
                        _buildTabContentWidget(filename),
                    ],
                  ),
                );
              }

              return Row(
                children: <Widget>[
                  if (!sidebarCollapsed)
                    SizedBox(
                      width: projectTreeUIController.sidebarWidth,
                      child: projectTreeUIController.sidebarMode ==
                              THProjectSidebarMode.projectSearch
                          ? const THProjectSearchWidget()
                          : THProjectTreeWidget(
                              pickProjectAndRunTherion:
                                  widget.pickProjectAndRunTherion,
                            ),
                    ),
                  if (!sidebarCollapsed)
                    const THProjectTreeResizeDividerWidget(),
                  if (sidebarCollapsed)
                    SizedBox(
                      width: mpProjectTreeRailWidth,
                      child: IconButton(
                        key: const ValueKey('THProjectTreeExpandButton'),
                        icon: const Icon(Icons.chevron_right),
                        tooltip:
                            appLocalizations.projectTreeExpandSidebarTooltip,
                        onPressed: () {
                          projectTreeUIController.setSidebarCollapsed(false);
                        },
                      ),
                    ),
                  Expanded(child: workspace),
                ],
              );
            },
          );
        },
      ),
    );

    return _withShortcuts(
      Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _closeOverlayWindowsOnClickOutsideDrawingArea,
        child: scaffold,
      ),
    );
  }

  /// Closes the overlay windows opened over the active drawing area when the
  /// pointer goes down anywhere else in the page (app bar, tabs, project tree,
  /// status bar...). Clicks on the overlay windows themselves never reach this
  /// listener as they live in the root overlay above this page.
  void _closeOverlayWindowsOnClickOutsideDrawingArea(PointerDownEvent event) {
    final TH2FileEditController? controller = _getActiveController();

    if (controller == null) {
      return;
    }

    final RenderObject? renderObject = controller
        .getTH2FileWidgetGlobalKey()
        .currentContext
        ?.findRenderObject();

    if ((renderObject is RenderBox) && renderObject.hasSize) {
      final Offset localPosition = renderObject.globalToLocal(event.position);

      if (renderObject.paintBounds.contains(localPosition)) {
        return;
      }
    }

    controller.overlayWindowController
        .performCloseOverlayWindowsOnOutsideClick();
  }

  /// Builds the compact menu used when the file editor app bar is narrow.
  Widget _buildOverflowMenu({
    required AppLocalizations appLocalizations,
    required MPSettingsController mpSettingsController,
  }) {
    return Observer(
      builder: (BuildContext context) {
        final TH2FileEditController? controller = _getActiveController();
        final THTextEditorController? textController =
            _getActiveTextEditorController();
        final bool therionAvailable = mpSettingsController.isTherionAvailable;
        final bool hasOpenProject =
            mpLocator.thProjectController.rootConfigPath.isNotEmpty;

        return PopupMenuButton<_TH2FileTabsAction>(
          key: const ValueKey('TH2FileTabsPageMoreActionsButton'),
          icon: Icon(
            Icons.more_vert_outlined,
            color: therionAvailable
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : mpTherionRunStatusBackgroundErrorColor,
          ),
          tooltip: appLocalizations.mpMoreActionsTooltip,
          onSelected: _handleOverflowMenuAction,
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<_TH2FileTabsAction>>[
                ..._buildFileMenuEntries(
                  appLocalizations,
                  controller,
                  textController,
                ),
                const PopupMenuDivider(),
                ..._buildTherionMenuEntries(appLocalizations, hasOpenProject),
                const PopupMenuDivider(),
                ..._buildSupportMenuEntries(appLocalizations),
              ],
        );
      },
    );
  }

  /// Creates the file-related entries for the compact app bar menu. [controller]
  /// backs the active tab when it is a `.th2` tab; [textController] backs it
  /// when it is a `thconfig`/`.th` text-editor tab. Regular Save stays
  /// TH2-only here (unchanged by Phase 10); Save As routes to whichever
  /// controller is non-null.
  List<PopupMenuEntry<_TH2FileTabsAction>> _buildFileMenuEntries(
    AppLocalizations appLocalizations,
    TH2FileEditController? controller,
    THTextEditorController? textController,
  ) {
    return <PopupMenuEntry<_TH2FileTabsAction>>[
      _overflowMenuItem(
        action: _TH2FileTabsAction.save,
        label: appLocalizations.th2FileEditPageSave,
        enabled: controller?.enableSaveButton ?? false,
      ),
      _overflowMenuItem(
        action: _TH2FileTabsAction.saveAs,
        label: (controller != null)
            ? appLocalizations.th2FileEditPageSaveAs
            : appLocalizations.textEditorTabSaveAs,
        enabled:
            ((controller != null) && !controller.isBroken) ||
            (textController != null),
      ),
    ];
  }

  /// Creates the Therion entries for the compact app bar menu.
  List<PopupMenuEntry<_TH2FileTabsAction>> _buildTherionMenuEntries(
    AppLocalizations appLocalizations,
    bool hasOpenProject,
  ) {
    return <PopupMenuEntry<_TH2FileTabsAction>>[
      _overflowMenuItem(
        action: _TH2FileTabsAction.runTherion,
        label: appLocalizations.mapiahRunTherionButtonTooltip,
        enabled: hasOpenProject,
      ),
      _overflowMenuItem(
        action: _TH2FileTabsAction.closeProject,
        label: appLocalizations.mapiahCloseProjectButtonTooltip,
        enabled: hasOpenProject,
      ),
    ];
  }

  /// Creates the support entries for the compact app bar menu.
  List<PopupMenuEntry<_TH2FileTabsAction>> _buildSupportMenuEntries(
    AppLocalizations appLocalizations,
  ) {
    return <PopupMenuEntry<_TH2FileTabsAction>>[
      _overflowMenuItem(
        action: _TH2FileTabsAction.settings,
        label: appLocalizations.mpSettingsPageTitle,
      ),
      _overflowMenuItem(
        action: _TH2FileTabsAction.keyboardShortcuts,
        label: appLocalizations.mapiahKeyboardShortcutsTooltip,
      ),
      _overflowMenuItem(
        action: _TH2FileTabsAction.help,
        label: appLocalizations.helpDialogTooltip,
      ),
      _overflowMenuItem(
        action: _TH2FileTabsAction.about,
        label: appLocalizations.mapiahHomeAboutMapiahDialog,
      ),
    ];
  }

  /// Builds one compact file editor app bar menu entry.
  PopupMenuItem<_TH2FileTabsAction> _overflowMenuItem({
    required _TH2FileTabsAction action,
    required String label,
    bool enabled = true,
  }) {
    return PopupMenuItem<_TH2FileTabsAction>(
      value: action,
      enabled: enabled,
      child: Text(label),
    );
  }

  /// Returns the active file controller when the active tab is valid.
  TH2FileEditController? _getActiveController() {
    final List<String> openFileOrder =
        mpLocator.mpGeneralController.openFileOrder;
    final int activeTabIndex = mpLocator.mpGeneralController.activeTabIndex;

    if (openFileOrder.isEmpty ||
        (activeTabIndex < 0) ||
        (activeTabIndex >= openFileOrder.length)) {
      return null;
    }

    return mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
      openFileOrder[activeTabIndex],
    );
  }

  /// Returns the active text-editor controller when the active tab is a
  /// `thconfig`/`.th` text-editor tab.
  THTextEditorController? _getActiveTextEditorController() {
    final List<String> openFileOrder =
        mpLocator.mpGeneralController.openFileOrder;
    final int activeTabIndex = mpLocator.mpGeneralController.activeTabIndex;

    if (openFileOrder.isEmpty ||
        (activeTabIndex < 0) ||
        (activeTabIndex >= openFileOrder.length)) {
      return null;
    }

    return mpLocator.mpGeneralController.getTextEditorControllerIfExists(
      openFileOrder[activeTabIndex],
    );
  }

  /// Runs the action selected from the compact file editor app bar menu.
  void _handleOverflowMenuAction(_TH2FileTabsAction action) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TH2FileEditController? controller = _getActiveController();
    final THTextEditorController? textController =
        _getActiveTextEditorController();

    switch (action) {
      case _TH2FileTabsAction.save:
        controller?.saveTH2File();
      case _TH2FileTabsAction.saveAs:
        if (controller != null) {
          controller.saveAsTH2File();
        } else {
          unawaited(textController?.saveAs());
        }
      case _TH2FileTabsAction.runTherion:
        _rerunTherionForOpenProject();
      case _TH2FileTabsAction.closeProject:
        MPDialogAux.closeOpenProject(context);
      case _TH2FileTabsAction.settings:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const MPSettingsPage(),
          ),
        );
      case _TH2FileTabsAction.keyboardShortcuts:
        MPDialogAux.showHelpDialog(
          context,
          mpHelpPageKeyboardShortcutsEdit,
          appLocalizations.mapiahKeyboardShortcutsTitle,
        );
      case _TH2FileTabsAction.help:
        MPDialogAux.showHelpDialog(
          context,
          mpHelpPageTh2FileEdit,
          appLocalizations.th2FileEditPageHelpDialogTitle,
        );
      case _TH2FileTabsAction.about:
        showAboutDialog(context);
    }
  }

  Widget _buildTabContentWidget(String filename) {
    if (!isTH2Tab(filename)) {
      final THTextEditorController? textEditorController = mpLocator
          .mpGeneralController
          .getTextEditorControllerIfExists(filename);

      if (textEditorController == null) {
        return const Center(child: Text('Controller not found'));
      }

      return THTextEditorTabBodyWidget(
        key: ValueKey<String>(filename),
        controller: textEditorController,
        filePath: filename,
      );
    }

    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(filename);

    if (controller == null) {
      return const Center(child: Text('Controller not found'));
    }

    final _TH2FileLoad? existingLoad = _fileLoads[filename];

    if ((existingLoad == null) ||
        !identical(existingLoad.controller, controller)) {
      final Future<TH2FileEditControllerCreateResult> loadFuture;

      if (filename.startsWith(mpNewFilePrefix) || controller.isFileLoaded) {
        loadFuture = Future<TH2FileEditControllerCreateResult>.value(
          TH2FileEditControllerCreateResult(true, <String>[]),
        );
      } else {
        loadFuture = controller.load();
      }

      _fileLoads[filename] = (controller: controller, future: loadFuture);
    }

    final Future<TH2FileEditControllerCreateResult> future =
        _fileLoads[filename]!.future;

    return TH2FileEditBodyWidget(
      key: ObjectKey(controller),
      th2FileEditController: controller,
      loadFuture: future,
      onLoadFailed: () =>
          _discardFailedFileLoad(filename: filename, controller: controller),
      onReload: () {
        unawaited(
          mpLocator.mpGeneralController.reloadTH2File(filename),
        );
        setState(() {});
      },
    );
  }

  /// Evicts only the load state owned by the controller that failed.
  void _discardFailedFileLoad({
    required String filename,
    required TH2FileEditController controller,
  }) {
    final _TH2FileLoad? failedLoad = _fileLoads[filename];

    if ((failedLoad != null) && identical(failedLoad.controller, controller)) {
      _fileLoads.remove(filename);
    }

    final TH2FileEditController? cachedController = mpLocator
        .mpGeneralController
        .getTH2FileEditControllerIfExists(filename);

    if (identical(cachedController, controller)) {
      mpLocator.mpGeneralController.removeFileController(filename: filename);
    }
  }

  Widget _buildDraggableTab({
    required String filename,
    required int tabIndex,
    required List<String> openFileOrder,
    required int activeTabIndex,
  }) {
    return Draggable<String>(
      data: filename,
      feedback: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Material(
          color: Colors.grey.withAlpha(200),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Text(
              filename
                  .split('/')
                  .last
                  .replaceAll(RegExp(r'\.th2$', caseSensitive: false), ''),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _dragOverTabIndex = tabIndex;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            _dragOverTabIndex = -1;
          });
        },
        onAcceptWithDetails: (DragTargetDetails<String> details) {
          setState(() {
            _dragOverTabIndex = -1;
          });

          final String draggedFilename = details.data;
          final int draggedIndex = openFileOrder.indexOf(draggedFilename);

          if (draggedIndex != tabIndex && draggedIndex != -1) {
            // Reorder the files
            final List<String> newOrder = List<String>.from(openFileOrder);
            newOrder.removeAt(draggedIndex);
            newOrder.insert(tabIndex, draggedFilename);

            // Update the controller with the new order
            mpLocator.mpGeneralController.reorderFileTabs(newOrder);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_dragOverTabIndex == tabIndex)
                SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Center(
                    child: Container(
                      width: 2.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  mpLocator.mpGeneralController.setActiveTab(tabIndex);
                },
                child: MPFileTabWidget(
                  filename: filename,
                  isActive:
                      (activeTabIndex < openFileOrder.length) &&
                      (openFileOrder[activeTabIndex] == filename),
                  onClose: () {
                    if (isTH2Tab(filename)) {
                      mpLocator.mpGeneralController
                          .getTH2FileEditControllerIfExists(filename)
                          ?.close();
                    } else {
                      mpLocator.mpGeneralController
                          .getTextEditorControllerIfExists(filename)
                          ?.close();
                    }
                  },
                  onProperties: isTH2Tab(filename)
                      ? () {
                          final TH2FileEditController? controller = mpLocator
                              .mpGeneralController
                              .getTH2FileEditControllerIfExists(filename);

                          if (controller == null) {
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TH2FilePropertiesPage(
                                th2FileEditController: controller,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void initializeMPCommandLocalizations(BuildContext context) {
    mpLocator.resetAppLocalizations(context);
    MPTextToUser.initialize();
  }

  Widget _withShortcuts(Widget child) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final MPGeneralController generalController = mpLocator.mpGeneralController;
    final Map<ShortcutActivator, VoidCallback> bindings =
        <ShortcutActivator, VoidCallback>{
          // Open project: desktop standard Ctrl/Cmd+O
          const SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
              MPDialogAux.pickProjectFile(context),
          const SingleActivator(LogicalKeyboardKey.keyO, meta: true): () =>
              MPDialogAux.pickProjectFile(context),
          // macOS Cmd+Shift+O
          const SingleActivator(
            LogicalKeyboardKey.keyO,
            meta: true,
            shift: true,
          ): () =>
              MPDialogAux.pickProjectFile(context),
          const SingleActivator(
            LogicalKeyboardKey.keyO,
            control: true,
            shift: true,
          ): () =>
              MPDialogAux.pickProjectFile(context),
          // Save file
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
              unawaited(_saveActiveTab(generalController)),
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () =>
              unawaited(_saveActiveTab(generalController)),
          // Save file as
          const SingleActivator(
            LogicalKeyboardKey.keyS,
            control: true,
            shift: true,
          ): () => _saveActiveTabAs(generalController),
          const SingleActivator(
            LogicalKeyboardKey.keyS,
            meta: true,
            shift: true,
          ): () => _saveActiveTabAs(generalController),
          // Help
          const SingleActivator(LogicalKeyboardKey.f1): () =>
              MPDialogAux.showHelpDialog(
                context,
                mpHelpPageTh2FileEdit,
                appLocalizations.th2FileEditPageHelpDialogTitle,
              ),
          // Keyboard shortcuts
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              MPDialogAux.showHelpDialog(
                context,
                mpHelpPageKeyboardShortcutsEdit,
                appLocalizations.mapiahKeyboardShortcutsTitle,
              ),
          // Multi-file search: Ctrl/Cmd+Shift+F (single-file Ctrl/Cmd+F stays
          // editor-local in THTextEditorWidget).
          const SingleActivator(
            LogicalKeyboardKey.keyF,
            control: true,
            shift: true,
          ): () => mpLocator.thProjectTreeUIController.showProjectSearch(),
          const SingleActivator(
            LogicalKeyboardKey.keyF,
            meta: true,
            shift: true,
          ): () => mpLocator.thProjectTreeUIController.showProjectSearch(),
          // Run Therion and open project: Ctrl/Cmd+T
          const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
              _pickProjectAndRunTherionIfNoProject(),
          const SingleActivator(LogicalKeyboardKey.keyT, meta: true): () =>
              _pickProjectAndRunTherionIfNoProject(),
          // Rerun Therion: T (no modifiers) is handled below, in the outer
          // Focus's onKeyEvent, so that it only fires when no text field
          // (e.g. a thconfig editor) has focus; otherwise plain "T" keeps
          // typing the letter.
        };

    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyT &&
              !HardwareKeyboard.instance.isControlPressed &&
              !HardwareKeyboard.instance.isMetaPressed &&
              !HardwareKeyboard.instance.isShiftPressed &&
              !HardwareKeyboard.instance.isAltPressed &&
              !_isTextInputFocused()) {
            _rerunTherionForOpenProject();

            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }

  /// Whether the currently focused widget is a text-editing field (e.g. a
  /// thconfig editor, a search box, a rename dialog), so that global,
  /// unmodified single-letter shortcuts (like plain "T") should not fire.
  bool _isTextInputFocused() {
    final BuildContext? focusedContext =
        FocusManager.instance.primaryFocus?.context;

    return focusedContext != null &&
        focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  Future<void> _pickProjectAndRunTherion() {
    final MPPickProjectAndRunTherion pickProjectAndRunTherion =
        widget.pickProjectAndRunTherion ??
        MPDialogAux.pickProjectFileAndRunTherion;

    return pickProjectAndRunTherion(context);
  }

  /// Opens and runs a project only while the workspace has no loaded project.
  Future<void> _pickProjectAndRunTherionIfNoProject() {
    if (mpLocator.thProjectController.rootConfigPath.isNotEmpty) {
      return Future<void>.value();
    }

    return _pickProjectAndRunTherion();
  }

  /// Reruns Therion for the loaded project through the configured callback.
  Future<void> _rerunTherionForOpenProject() {
    final MPRerunTherionForOpenProject rerunTherionForOpenProject =
        widget.rerunTherionForOpenProject ??
        MPDialogAux.rerunTherionForOpenProject;

    return rerunTherionForOpenProject(context);
  }

  /// Save As for the active tab's `Ctrl/Cmd+Shift+S` binding, routing to
  /// whichever controller type backs it.
  void _saveActiveTabAs(MPGeneralController generalController) {
    final List<String> openFileOrder = generalController.openFileOrder;
    final int activeTabIndex = generalController.activeTabIndex;

    if (openFileOrder.isEmpty ||
        (activeTabIndex < 0) ||
        (activeTabIndex >= openFileOrder.length)) {
      return;
    }

    final String activeFilename = openFileOrder[activeTabIndex];

    if (isTH2Tab(activeFilename)) {
      generalController
          .getTH2FileEditControllerIfExists(activeFilename)
          ?.saveAsTH2File();
    } else {
      unawaited(
        generalController
            .getTextEditorControllerIfExists(activeFilename)
            ?.saveAs(),
      );
    }
  }

  /// Saves whichever controller type backs the active tab.
  Future<void> _saveActiveTab(MPGeneralController generalController) async {
    final List<String> openFileOrder = generalController.openFileOrder;
    final int activeTabIndex = generalController.activeTabIndex;

    if (openFileOrder.isEmpty ||
        (activeTabIndex < 0) ||
        (activeTabIndex >= openFileOrder.length)) {
      return;
    }

    final String activeFilename = openFileOrder[activeTabIndex];

    try {
      if (isTH2Tab(activeFilename)) {
        final TH2FileEditController? controller = generalController
            .getTH2FileEditControllerIfExists(activeFilename);

        if ((controller != null) && controller.enableSaveButton) {
          controller.saveTH2File();
        }
      } else {
        await generalController
            .getTextEditorControllerIfExists(activeFilename)
            ?.save();
      }
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[TH2FileTabsPage] _saveActiveTab failed for $activeFilename',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
