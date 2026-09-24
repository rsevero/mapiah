// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/widgets/th_project_tree_node_icon_widget.dart';
import 'package:mapiah/src/widgets/th_project_tree_row_context_menu_widget.dart';
import 'package:mapiah/src/widgets/th2_element_tree_drag_controller.dart';
import 'package:material_ui/material_ui.dart';

/// One visible project-tree row.
class THProjectTreeNodeWidget extends StatelessWidget {
  final THProjectNode node;

  final int depth;

  final bool isSelected;

  final bool isDirty;

  final TH2ElementTreeDragController? dragController;

  const THProjectTreeNodeWidget({
    super.key,
    required this.node,
    required this.depth,
    required this.isSelected,
    required this.isDirty,
    this.dragController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isExpanded = mpLocator
        .thProjectTreeUIController
        .isExpanded(node.id);
    final List<THProjectParseError> nodeErrors = _errorsForNode(node);

    final THProjectNode currentNode = node;
    final Widget row = Material(
      key: ValueKey('THProjectTreeNodeWidget|${node.id}'),
      color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: _onTap,
        child: SizedBox(
          height: mpProjectTreeRowHeight,
          child: Row(
            children: <Widget>[
              SizedBox(width: depth * mpProjectTreeIndent),
              _buildExpandControl(context, isExpanded),
              THProjectTreeNodeIconWidget(node: node),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  node.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (currentNode is TH2FileNode)
                _buildTH2StatusBadge(context, currentNode),
              if (isDirty) _buildStatusDot(colorScheme.tertiary),
              if (nodeErrors.isNotEmpty) _buildErrorDot(context, nodeErrors),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );

    if (currentNode is! TH2FileNode) {
      return row;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget content = THProjectTreeRowContextMenuWidget(
      key: ValueKey('THProjectTreeRowContextMenu|${node.id}'),
      rowId: node.id,
      menuChildrenBuilder: () =>
          THProjectTreeRowContextMenuWidget.reloadMenuChildrenIfBrokenOrFailed(
            rowId: node.id,
            th2FilePath: currentNode.absolutePath,
            appLocalizations: appLocalizations,
          ),
      child: row,
    );
    if (dragController == null) return content;
    return TH2ElementTreeDropTarget(
      controller: dragController!, rowId: node.id,
      th2FilePath: currentNode.absolutePath,
      targetMPID: null, collapsedScrap: false,
      expanded: isExpanded, child: content);

  }

  /// The broken badge (problem count) or load-error mark of a `.th2` file
  /// row. It observes the file's controller on its own, so it also updates
  /// while the row is collapsed.
  Widget _buildTH2StatusBadge(BuildContext context, TH2FileNode th2Node) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Observer(
      builder: (_) {
        final TH2FileEditController? controller = mpLocator
            .mpGeneralController
            .getTH2FileEditControllerIfExists(th2Node.absolutePath);

        if (controller == null) {
          return const SizedBox.shrink();
        }

        if (controller.loadError != null) {
          return Tooltip(
            key: ValueKey('THProjectTreeNodeLoadErrorBadge|${node.id}'),
            message: appLocalizations.th2ElementTreeLoadError,
            child: Icon(
              Icons.error_outline,
              size: mpSmallIconSize,
              color: colorScheme.error,
            ),
          );
        }

        if (!controller.isFileLoaded || !controller.isBroken) {
          return const SizedBox.shrink();
        }

        final List<TH2FileProblem> problems = controller.problems;

        return Tooltip(
          key: ValueKey('THProjectTreeNodeBrokenBadge|${node.id}'),
          message: _brokenBadgeTooltip(appLocalizations, problems),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(mpProjectTreeRowHeight),
            ),
            child: Text(
              '${problems.length}',
              style: TextStyle(color: colorScheme.onError),
            ),
          ),
        );
      },
    );
  }

  /// The problem count, then the first problems, then how many were left
  /// out.
  String _brokenBadgeTooltip(
    AppLocalizations appLocalizations,
    List<TH2FileProblem> problems,
  ) {
    final List<String> lines = <String>[
      appLocalizations.th2ElementTreeBrokenBadgeTooltip(problems.length),
    ];
    final int shownCount =
        (problems.length < mpTH2ElementTreeBadgeTooltipMaxProblems)
        ? problems.length
        : mpTH2ElementTreeBadgeTooltipMaxProblems;

    for (final TH2FileProblem problem in problems.take(shownCount)) {
      lines.add(
        appLocalizations.th2ElementTreeProblemLine(
          problem.lineNumber,
          problem.detail,
        ),
      );
    }

    if (problems.length > shownCount) {
      lines.add(
        appLocalizations.th2ElementTreeMoreProblems(
          problems.length - shownCount,
        ),
      );
    }

    return lines.join('\n');
  }

  /// Toggles the row. Expanding a `.th2` file row requests its tab-less
  /// load and nothing else: no tab, no project-node selection.
  void _onChevronTap() {
    final THProjectTreeUIController uiController =
        mpLocator.thProjectTreeUIController;
    final THProjectNode currentNode = node;

    uiController.toggleExpanded(node.id);

    if ((currentNode is! TH2FileNode) || !uiController.isExpanded(node.id)) {
      return;
    }

    uiController.loadTH2FileIfEligible(
      currentNode.absolutePath,
      projectEpoch: mpLocator.thProjectController.projectEpoch,
      rootConfigPath: mpLocator.thProjectController.rootConfigPath,
    );
  }

  void _onTap() {
    mpLocator.thProjectController.selectNode(node.id);

    final THProjectNode tappedNode = node;

    if (tappedNode is TH2FileNode) {
      mpLocator.mpGeneralController.getTH2FileEditController(
        filename: tappedNode.absolutePath,
      );
      mpLocator.mpGeneralController.addFileTab(tappedNode.absolutePath);
    } else if ((tappedNode is THConfigFileNode) ||
        (tappedNode is THDataFileNode)) {
      _openTextEditorTab((tappedNode as THProjectFileNode).absolutePath);
    } else if ((tappedNode is THSurveyNode) ||
        (tappedNode is THCentrelineNode) ||
        (tappedNode is THMapNode) ||
        ((tappedNode is THScrapNode) && !tappedNode.isFromTH2File)) {
      _openTextEditorTab(
        tappedNode.sourceFilePath,
        lineNumber: tappedNode.lineNumber,
      );
    }
    // THMissingFileNode, and THScrapNode.isFromTH2File (always false today):
    // no-op, matches current behavior.
  }

  /// Compiler diagnostics are attached only at text-editor file nodes
  /// ([THConfigFileNode]/[THDataFileNode]); logical nodes, [TH2FileNode], and
  /// [THMissingFileNode] keep showing only their own parse-time
  /// [THProjectNode.parseErrors].
  List<THProjectParseError> _errorsForNode(THProjectNode currentNode) {
    if ((currentNode is THConfigFileNode) ||
        (currentNode is THDataFileNode)) {
      return <THProjectParseError>[
        ...currentNode.parseErrors,
        ...mpLocator.thProjectController.compilerErrorsForPath(
          (currentNode as THProjectFileNode).absolutePath,
        ),
      ];
    }

    return currentNode.parseErrors;
  }

  void _onErrorDotTap(List<THProjectParseError> nodeErrors) {
    mpLocator.thProjectController.selectNode(node.id);

    if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
      return;
    }

    if (nodeErrors.isEmpty) {
      return;
    }

    final THProjectFileNode fileNode = node as THProjectFileNode;
    final List<THProjectParseError> compilerErrors = mpLocator
        .thProjectController
        .compilerErrorsForPath(fileNode.absolutePath);
    final int targetLine = compilerErrors.isNotEmpty
        ? compilerErrors.first.lineNumber
        : nodeErrors.first.lineNumber;

    _openTextEditorTab(fileNode.absolutePath, lineNumber: targetLine);
  }

  void _openTextEditorTab(String filePath, {int? lineNumber}) {
    final THTextEditorController controller = mpLocator.mpGeneralController
        .getTextEditorController(filePath);

    mpLocator.mpGeneralController.addFileTab(filePath);

    if (lineNumber != null) {
      controller.scrollToLine(lineNumber);
    }
  }

  /// A `.th2` file row always has a chevron: expanding it is what loads the
  /// file's elements.
  Widget _buildExpandControl(BuildContext context, bool isExpanded) {
    if (node.children.isEmpty && (node is! TH2FileNode)) {
      return const SizedBox(width: mpSmallIconSize);
    }

    return GestureDetector(
      key: ValueKey('THProjectTreeNodeChevron|${node.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: _onChevronTap,
      child: SizedBox(
        width: mpSmallIconSize,
        height: mpProjectTreeRowHeight,
        child: Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: mpSmallIconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStatusDot(Color color) {
    return Container(
      key: ValueKey('THProjectTreeNodeDirtyDot|${node.id}'),
      width: mpProjectTreeStatusDotSize,
      height: mpProjectTreeStatusDotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildErrorDot(
    BuildContext context,
    List<THProjectParseError> nodeErrors,
  ) {
    return GestureDetector(
      key: ValueKey('THProjectTreeNodeErrorDot|${node.id}'),
      onTap: () => _onErrorDotTap(nodeErrors),
      child: Tooltip(
        message: '${nodeErrors.length}',
        child: Container(
          width: mpProjectTreeStatusDotSize,
          height: mpProjectTreeStatusDotSize,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
