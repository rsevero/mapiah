// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_project_tree_node_widget.dart';
import 'package:material_ui/material_ui.dart';

/// The project-tree side column shown next to the tab workspace.
class THProjectTreeWidget extends StatelessWidget {
  const THProjectTreeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context);
        final THProjectNode? root = mpLocator
            .thProjectController
            .projectRootNode;
        final bool isParsing = mpLocator.thProjectController.isParsing;
        final List<THProjectParseError> allDiagnostics =
            mpLocator.thProjectController.allDiagnostics;
        final Set<String> dirtyFilePaths = mpLocator
            .thProjectController
            .dirtyFilePaths
            .toSet();
        final String? activeSelectedNodeId =
            mpLocator.thProjectController.activeSelectedNodeId;
        final List<THProjectTreeVisibleNode> visibleNodes =
            _buildVisibleNodes(root);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context, appLocalizations),
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
                child: ListView.builder(
                  itemCount: visibleNodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final THProjectTreeVisibleNode visibleNode =
                        visibleNodes[index];

                    return THProjectTreeNodeWidget(
                      node: visibleNode.node,
                      depth: visibleNode.depth,
                      isSelected:
                          visibleNode.node.id == activeSelectedNodeId,
                      isDirty: _isDirtyNode(
                        visibleNode.node,
                        dirtyFilePaths,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<THProjectTreeVisibleNode> _buildVisibleNodes(THProjectNode? root) {
    if (root == null) {
      return const <THProjectTreeVisibleNode>[];
    }

    return flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) {
        return mpLocator.thProjectTreeUIController.isExpanded(node.id);
      },
      matchesFilter: mpLocator.thProjectTreeUIController.matchesFilter,
      filterActive: mpLocator.thProjectTreeUIController.filterText.isNotEmpty,
    );
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
    AppLocalizations appLocalizations,
  ) {
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
            child: Text(
              appLocalizations.projectTreeTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
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
              onPressed: () => MPDialogAux.pickProjectFile(
                context,
                openTabsPageAfterLoad: false,
              ),
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
