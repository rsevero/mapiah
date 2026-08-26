// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/widgets/th_project_tree_node_icon_widget.dart';
import 'package:material_ui/material_ui.dart';

/// One visible project-tree row.
class THProjectTreeNodeWidget extends StatelessWidget {
  final THProjectNode node;

  final int depth;

  final bool isSelected;

  final bool isDirty;

  const THProjectTreeNodeWidget({
    super.key,
    required this.node,
    required this.depth,
    required this.isSelected,
    required this.isDirty,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isExpanded = mpLocator
        .thProjectTreeUIController
        .isExpanded(node.id);

    return Material(
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
              if (isDirty) _buildStatusDot(colorScheme.tertiary),
              if (node.hasErrors) _buildErrorDot(context),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
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

  void _openTextEditorTab(String filePath, {int? lineNumber}) {
    final THTextEditorController controller = mpLocator.mpGeneralController
        .getTextEditorController(filePath);

    mpLocator.mpGeneralController.addFileTab(filePath);

    if (lineNumber != null) {
      controller.scrollToLine(lineNumber);
    }
  }

  Widget _buildExpandControl(BuildContext context, bool isExpanded) {
    if (node.children.isEmpty) {
      return const SizedBox(width: mpSmallIconSize);
    }

    return GestureDetector(
      key: ValueKey('THProjectTreeNodeChevron|${node.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        mpLocator.thProjectTreeUIController.toggleExpanded(node.id);
      },
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

  Widget _buildErrorDot(BuildContext context) {
    return Tooltip(
      message: '${node.parseErrors.length}',
      child: Container(
        key: ValueKey('THProjectTreeNodeErrorDot|${node.id}'),
        width: mpProjectTreeStatusDotSize,
        height: mpProjectTreeStatusDotSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
