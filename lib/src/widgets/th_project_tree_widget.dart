// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th2_element_tree_row_widget.dart';
import 'package:mapiah/src/widgets/th2_element_tree_drag_controller.dart';
import 'package:mapiah/src/widgets/th_project_tree_node_widget.dart';
import 'package:material_ui/material_ui.dart';

/// The project-tree side column shown next to the tab workspace.
class THProjectTreeWidget extends StatefulWidget {
  final MPPickProjectAndRunTherion? pickProjectAndRunTherion;

  const THProjectTreeWidget({
    super.key,
    this.pickProjectAndRunTherion,
  });

  @override
  State<THProjectTreeWidget> createState() => _THProjectTreeWidgetState();
}

class _THProjectTreeWidgetState extends State<THProjectTreeWidget> {
  final TH2ElementTreeDragController _dragController =
      TH2ElementTreeDragController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scrollViewportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _dragController.scrollController = _scrollController;
    _dragController.viewportKey = _scrollViewportKey;
  }

  @override
  void dispose() {
    _dragController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final THProjectController projectController =
            mpLocator.thProjectController;
        final THProjectNode? root = projectController.projectRootNode;
        final bool isParsing = projectController.isParsing;
        final int projectEpoch = projectController.projectEpoch;
        final String rootConfigPath = projectController.rootConfigPath;
        final List<THProjectParseError> allDiagnostics =
            projectController.allDiagnostics;
        final Set<String> dirtyFilePaths = projectController.dirtyFilePaths
            .toSet();
        final String? activeSelectedNodeId =
            projectController.activeSelectedNodeId;
        final bool filterActive =
            mpLocator.thProjectTreeUIController.filterText.isNotEmpty;
        final Set<String> pathsNeedingLoad = <String>{};
        final List<THProjectTreeVisibleRow> visibleRows = _buildVisibleRows(
          root,
          filterActive: filterActive,
          pathsNeedingLoad: pathsNeedingLoad,
        );

        if (pathsNeedingLoad.isNotEmpty && !filterActive && !isParsing) {
          _scheduleTH2Loads(
            pathsNeedingLoad,
            projectEpoch: projectEpoch,
            rootConfigPath: rootConfigPath,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(
              context,
              appLocalizations,
              hasProject: rootConfigPath.isNotEmpty,
            ),
            const _THProjectTreeSearchField(),
            if (root == null)
              Expanded(
                child: _buildEmptyState(context, appLocalizations),
              )
            else ...<Widget>[
              if (isParsing) const LinearProgressIndicator(),
              if (allDiagnostics.isNotEmpty)
                _THProjectTreeErrorSummary(
                  errors: allDiagnostics,
                  appLocalizations: appLocalizations,
                ),
              Expanded(
                child: SizedBox(
                  key: _scrollViewportKey,
                  child: ListView.builder(
                  controller: _scrollController,
                  itemCount: visibleRows.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildRow(
                      visibleRows[index],
                      activeSelectedNodeId: activeSelectedNodeId,
                      dirtyFilePaths: dirtyFilePaths,
                    );
                  },
                ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(
    THProjectTreeVisibleRow row, {
    required String? activeSelectedNodeId,
    required Set<String> dirtyFilePaths,
  }) {
    return switch (row) {
      THProjectTreeNodeRow nodeRow => THProjectTreeNodeWidget(
        node: nodeRow.node,
        depth: nodeRow.depth,
        isSelected: nodeRow.node.id == activeSelectedNodeId,
        isDirty: _isDirtyNode(nodeRow.node, dirtyFilePaths),
        dragController: _dragController,
      ),
      TH2ElementTreeRow _ => TH2ElementTreeRowWidget(row: row, dragController: _dragController),
      TH2FileStatusTreeRow _ => TH2ElementTreeRowWidget(row: row, dragController: _dragController),
    };
  }

  /// Flattens the tree. The TH2 callback runs inside the tree observer, so
  /// the rows follow controller creation, loads, reloads and structure
  /// changes. Files that need a tree load are added to [pathsNeedingLoad].
  List<THProjectTreeVisibleRow> _buildVisibleRows(
    THProjectNode? root, {
    required bool filterActive,
    required Set<String> pathsNeedingLoad,
  }) {
    if (root == null) {
      return const <THProjectTreeVisibleRow>[];
    }

    final THProjectTreeUIController uiController =
        mpLocator.thProjectTreeUIController;

    return flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) => uiController.isExpanded(node.id),
      matchesFilter: uiController.matchesFilter,
      filterActive: filterActive,
      th2ElementRowsFor:
          (TH2FileNode node, int depth, {required bool filterActive}) {
            return TH2ElementTreeAux.rowsForFile(
              th2FilePath: node.absolutePath,
              controller: mpLocator.mpGeneralController
                  .getTH2FileEditControllerIfExists(node.absolutePath),
              fileDepth: depth,
              filterActive: filterActive,
              matchesFilterText: uiController.matchesFilterText,
              isScrapCollapsed: uiController.isTH2ScrapCollapsed,
              onNeedsLoad: pathsNeedingLoad.add,
            );
          },
    );
  }

  /// Requests the loads after the frame, never during the build. Each
  /// request is revalidated against the captured project lifecycle and the
  /// current tree right before it runs.
  void _scheduleTH2Loads(
    Set<String> paths, {
    required int projectEpoch,
    required String rootConfigPath,
  }) {
    final List<String> candidates = paths.toList();

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      for (final String path in candidates) {
        mpLocator.thProjectTreeUIController.loadTH2FileIfEligible(
          path,
          projectEpoch: projectEpoch,
          rootConfigPath: rootConfigPath,
        );
      }
    });
  }

  bool _isDirtyNode(
    THProjectNode node,
    Set<String> dirtyFilePaths,
  ) {
    if (node is! THProjectFileNode) {
      return false;
    }

    return dirtyFilePaths.contains(node.absolutePath);
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations appLocalizations, {
    required bool hasProject,
  }) {
    return SizedBox(
      height: mpProjectTreeRowHeight,
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey('THProjectTreeCollapseButton'),
            icon: const Icon(Icons.chevron_left),
            iconSize: mpSmallIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: mpProjectTreeRowHeight,
              minHeight: mpProjectTreeRowHeight,
            ),
            onPressed: () {
              mpLocator.thProjectTreeUIController.setSidebarCollapsed(true);
            },
            tooltip: appLocalizations.projectTreeCollapseSidebarTooltip,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Tooltip(
              key: const ValueKey('THProjectTreeHeaderDrawingOrderTooltip'),
              message: appLocalizations.th2ElementTreeDrawingOrderTooltip,
              child: Text(
                appLocalizations.projectTreeTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const ValueKey('THProjectTreeSearchButton'),
            icon: const Icon(Icons.search),
            iconSize: mpSmallIconSize,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: mpProjectTreeRowHeight,
              minHeight: mpProjectTreeRowHeight,
            ),
            onPressed: () =>
                mpLocator.thProjectTreeUIController.showProjectSearch(),
            tooltip: appLocalizations.projectSearchOpenTooltip,
          ),
          if (hasProject)
            IconButton(
              key: const ValueKey('THProjectTreeCloseProjectButton'),
              icon: const Icon(Icons.close),
              iconSize: mpSmallIconSize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: mpProjectTreeRowHeight,
                minHeight: mpProjectTreeRowHeight,
              ),
              onPressed: () => MPDialogAux.closeOpenProject(context),
              tooltip: appLocalizations.projectTreeCloseProjectTooltip,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(mpOverlayWindowPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(appLocalizations.projectTreeEmptyState),
            const SizedBox(height: mpButtonSpace),
            OutlinedButton.icon(
              key: const ValueKey('THProjectTreeOpenProjectButton'),
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(appLocalizations.projectTreeOpenProjectButton),
              onPressed: () => MPDialogAux.pickProjectFile(context),
            ),
            const SizedBox(height: mpButtonSpace),
            OutlinedButton.icon(
              key: const ValueKey('THProjectTreeNewProjectButton'),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: Text(appLocalizations.projectTreeNewProjectButton),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      appLocalizations.projectTreeNewProjectNotImplemented,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: mpButtonSpace),
            OutlinedButton.icon(
              key: const ValueKey('THProjectTreeRunTherionButton'),
              icon: const Icon(Icons.playlist_add_check_outlined),
              label: Text(appLocalizations.projectTreeRunTherionButton),
              onPressed: () {
                final MPPickProjectAndRunTherion openProjectAndRunTherion =
                    widget.pickProjectAndRunTherion ??
                    MPDialogAux.pickProjectFileAndRunTherion;

                openProjectAndRunTherion(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _THProjectTreeSearchField extends StatefulWidget {
  const _THProjectTreeSearchField();

  @override
  State<_THProjectTreeSearchField> createState() =>
      _THProjectTreeSearchFieldState();
}

class _THProjectTreeSearchFieldState
    extends State<_THProjectTreeSearchField> {
  late final TextEditingController _textController;

  Timer? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: mpLocator.thProjectTreeUIController.filterText,
    );
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return TextField(
      key: const ValueKey('THProjectTreeSearchField'),
      controller: _textController,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: appLocalizations.projectTreeSearchHint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
      ),
    );
  }

  void _onChanged(String value) {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(
      const Duration(milliseconds: mpProjectTreeFilterDebounceMilliseconds),
      () {
        mpLocator.thProjectTreeUIController.setFilterText(value);
      },
    );
  }
}

class _THProjectTreeErrorSummary extends StatefulWidget {
  final List<THProjectParseError> errors;

  final AppLocalizations appLocalizations;

  const _THProjectTreeErrorSummary({
    required this.errors,
    required this.appLocalizations,
  });

  @override
  State<_THProjectTreeErrorSummary> createState() =>
      _THProjectTreeErrorSummaryState();
}

class _THProjectTreeErrorSummaryState
    extends State<_THProjectTreeErrorSummary> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: mpSmallIconSize,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.appLocalizations.projectTreeErrorSummary(
                        widget.errors.length,
                      ),
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: mpSmallIconSize,
                    color: colorScheme.onErrorContainer,
                  ),
                ],
              ),
              if (_isExpanded)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: mpProjectTreeErrorSummaryMaxHeight,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.errors.map((error) => error.message).join('\n'),
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
