// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/mp_window_title.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/mp_settings_page.dart';
import 'package:mapiah/src/pages/th2_file_properties_page.dart';
import 'package:mapiah/src/widgets/help_button_widget.dart';
import 'package:mapiah/src/widgets/mp_file_tab_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_body_widget.dart';
import 'package:mobx/mobx.dart' hide Listener;

class TH2FileTabsPage extends StatefulWidget {
  const TH2FileTabsPage({super.key});

  @override
  State<TH2FileTabsPage> createState() => _TH2FileTabsPageState();
}

class _TH2FileTabsPageState extends State<TH2FileTabsPage> {
  late ReactionDisposer _openFileOrderReaction;
  late ReactionDisposer _activeTabFocusReaction;
  final Map<String, Future<TH2FileEditControllerCreateResult>> _loadFutures =
      <String, Future<TH2FileEditControllerCreateResult>>{};
  late final ScrollController _tabScrollController;

  int _dragOverTabIndex = -1;

  @override
  void initState() {
    super.initState();

    _tabScrollController = ScrollController();

    _openFileOrderReaction = reaction(
      (_) => mpLocator.mpGeneralController.openFileOrder.length,
      (int length) {
        if (length == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        }
      },
    );

    /// Give keyboard focus to the incoming tab's canvas after each tab
    /// switch so that keyboard shortcuts (e.g. Ctrl+V) are delivered to
    /// the visible canvas and not to an offstage one.
    _activeTabFocusReaction = reaction(
      (_) => mpLocator.mpGeneralController.activeTabIndex,
      (int index) {
        final List<String> order = mpLocator.mpGeneralController.openFileOrder;

        if ((index < 0) || (index >= order.length)) {
          return;
        }

        final String filename = order[index];
        final TH2FileEditController? controller = mpLocator.mpGeneralController
            .getTH2FileEditControllerIfExists(filename);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller?.th2FileFocusNode.requestFocus();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _openFileOrderReaction();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        title: const SizedBox.shrink(),
        actions: <Widget>[
          IconButton(
            key: const ValueKey('TH2FileTabsPageNewFileButton'),
            icon: const Icon(Icons.insert_drive_file_outlined),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => MPDialogAux.newFile(context),
            tooltip: appLocalizations.mapiahHomeNewFileButtonTooltip,
          ),
          IconButton(
            key: const ValueKey('TH2FileTabsPageOpenFileButton'),
            icon: const Icon(Icons.file_open_outlined),
            color: colorScheme.onSecondaryContainer,
            onPressed: () => MPDialogAux.pickTH2File(context),
            tooltip: appLocalizations.mapiahHomeOpenFile,
          ),
          actionsSeparator,
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
              final TH2FileEditController? controller = mpLocator
                  .mpGeneralController
                  .getTH2FileEditControllerIfExists(activeFilename);

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
                    onPressed: () => controller?.saveAsTH2File(),
                    tooltip: appLocalizations.th2FileEditPageSaveAs,
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

              return IconButton(
                key: const ValueKey(
                  'TH2FileTabsPageOpenTHConfigAndRunTherionButton',
                ),
                icon: const Icon(Icons.playlist_add_check_outlined),
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
      body: Observer(
        builder: (_) {
          final List<String> openFileOrder =
              mpLocator.mpGeneralController.openFileOrder;
          final int activeTabIndex =
              mpLocator.mpGeneralController.activeTabIndex;

          if (openFileOrder.isEmpty) {
            return Center(
              child: Text(appLocalizations.initialPagePresentation),
            );
          }

          return PopScope(
            canPop: false,
            child: IndexedStack(
              index: activeTabIndex,
              children: <Widget>[
                for (String filename in openFileOrder)
                  _buildTabContentWidget(filename),
              ],
            ),
          );
        },
      ),
    );

    return _withShortcuts(scaffold);
  }

  Widget _buildTabContentWidget(String filename) {
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(filename);

    if (controller == null) {
      return const Center(child: Text('Controller not found'));
    }

    if (!_loadFutures.containsKey(filename)) {
      if (filename.startsWith(mpNewFilePrefix) || controller.isFileLoaded) {
        _loadFutures[filename] =
            Future<TH2FileEditControllerCreateResult>.value(
              TH2FileEditControllerCreateResult(true, <String>[]),
            );
      } else {
        _loadFutures[filename] = controller.load();
      }
    }

    final Future<TH2FileEditControllerCreateResult> future =
        _loadFutures[filename]!;

    return TH2FileEditBodyWidget(
      key: ValueKey<String>(filename),
      th2FileEditController: controller,
      loadFuture: future,
    );
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
                    final TH2FileEditController? controller = mpLocator
                        .mpGeneralController
                        .getTH2FileEditControllerIfExists(filename);
                    controller?.close();
                  },
                  onProperties: () {
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
                  },
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
        onKeyEvent: (node, event) {
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
