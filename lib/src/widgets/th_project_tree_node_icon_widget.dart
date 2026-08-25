// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:material_ui/material_ui.dart';

/// Selects the icon used for a project-tree node based on its runtime type.
class THProjectTreeNodeIconWidget extends StatelessWidget {
  final THProjectNode node;

  const THProjectTreeNodeIconWidget({
    super.key,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final IconData iconData = _iconDataFor(node);
    final Color color = node is THMissingFileNode
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Icon(
      iconData,
      size: mpSmallIconSize,
      color: color,
      key: const ValueKey('THProjectTreeNodeIconWidget'),
    );
  }

  IconData _iconDataFor(THProjectNode node) {
    if (node is THConfigFileNode) {
      return Icons.settings_suggest_outlined;
    }

    if (node is THDataFileNode) {
      return Icons.description_outlined;
    }

    if (node is TH2FileNode) {
      return Icons.draw_outlined;
    }

    if (node is THMissingFileNode) {
      return Icons.error_outline;
    }

    if (node is THSurveyNode) {
      return Icons.account_balance_outlined;
    }

    if (node is THCentrelineNode) {
      return Icons.timeline_outlined;
    }

    if (node is THMapNode) {
      return Icons.layers_outlined;
    }

    if (node is THScrapNode) {
      return Icons.map_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }
}
