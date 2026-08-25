// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mobx/mobx.dart';

part 'th_project_tree_ui_controller.g.dart';

class THProjectTreeUIController = THProjectTreeUIControllerBase
    with _$THProjectTreeUIController;

/// UI-only view state for the project tree sidebar.
///
/// Expansion, filtering, and sidebar layout state live here rather than in
/// [THProjectController] so the parsing/re-parsing pipeline never mutates or
/// observes view concerns.
abstract class THProjectTreeUIControllerBase with Store {
  @observable
  ObservableSet<String> expandedNodeIds = ObservableSet<String>();

  @observable
  String filterText = '';

  @observable
  bool isSidebarCollapsed = false;

  @observable
  double sidebarWidth = mpProjectTreeSidebarDefaultWidth;

  late final THProjectController _projectController;

  late final MPSettingsController _settingsController;

  Timer? _sidebarWidthPersistTimer;

  Timer? _sidebarCollapsedPersistTimer;

  late final ReactionDisposer _projectRootReaction;

  THProjectTreeUIControllerBase({
    THProjectController? projectController,
    MPSettingsController? settingsController,
  }) {
    _projectController = projectController ?? MPLocator().thProjectController;
    _settingsController =
        settingsController ?? MPLocator().mpSettingsController;

    isSidebarCollapsed = _settingsController.getBoolWithDefault(
      MPSettingID.ProjectTree_SidebarCollapsed,
    );
    sidebarWidth = _settingsController
        .getDoubleWithDefault(MPSettingID.ProjectTree_SidebarWidth)
        .clamp(
          mpProjectTreeSidebarMinWidth,
          mpProjectTreeSidebarMaxWidth,
        )
        .toDouble();

    _projectRootReaction = reaction<THProjectFileNode?>(
      (_) => _projectController.projectRootNode,
      _handleProjectRootChanged,
    );
    _handleProjectRootChanged(_projectController.projectRootNode);
  }

  /// Cancels the root reaction and any pending persistence timers.
  ///
  /// The production controller is a long-lived singleton, but tests use this
  /// to avoid leaking timers between cases.
  void dispose() {
    _projectRootReaction();
    _sidebarWidthPersistTimer?.cancel();
    _sidebarCollapsedPersistTimer?.cancel();
  }

  @action
  void toggleExpanded(String nodeId) {
    if (!expandedNodeIds.add(nodeId)) {
      expandedNodeIds.remove(nodeId);
    }
  }

  @action
  void expand(String nodeId) {
    expandedNodeIds.add(nodeId);
  }

  @action
  void collapse(String nodeId) {
    expandedNodeIds.remove(nodeId);
  }

  @action
  void expandAncestorsOf(THProjectNode node) {
    THProjectNode? ancestor = node.parent;

    while (ancestor != null) {
      expandedNodeIds.add(ancestor.id);
      ancestor = ancestor.parent;
    }
  }

  @action
  void setFilterText(String text) {
    if (filterText == text) {
      return;
    }

    filterText = text;
  }

  @action
  void setSidebarCollapsed(bool collapsed) {
    if (isSidebarCollapsed == collapsed) {
      return;
    }

    isSidebarCollapsed = collapsed;
    _scheduleSidebarCollapsedPersistence();
  }

  @action
  void setSidebarWidth(double width) {
    final double clampedWidth = width
        .clamp(mpProjectTreeSidebarMinWidth, mpProjectTreeSidebarMaxWidth)
        .toDouble();

    if (sidebarWidth == clampedWidth) {
      return;
    }

    sidebarWidth = clampedWidth;
    _scheduleSidebarWidthPersistence();
  }

  bool isExpanded(String nodeId) => expandedNodeIds.contains(nodeId);

  bool matchesFilter(THProjectNode node) {
    if (filterText.isEmpty) {
      return true;
    }

    return node.label.toLowerCase().contains(filterText.toLowerCase());
  }

  @action
  void _handleProjectRootChanged(THProjectFileNode? root) {
    if (root == null) {
      expandedNodeIds.clear();

      return;
    }

    if (expandedNodeIds.isNotEmpty) {
      return;
    }

    expandedNodeIds.add(root.id);

    for (final THProjectNode child in root.children) {
      if (child is THProjectFileNode) {
        expandedNodeIds.add(child.id);
      }
    }
  }

  void _scheduleSidebarWidthPersistence() {
    _sidebarWidthPersistTimer?.cancel();
    _sidebarWidthPersistTimer = Timer(
      const Duration(milliseconds: mpProjectTreeUIPersistDebounceMilliseconds),
      () {
        _settingsController.setDouble(
          MPSettingID.ProjectTree_SidebarWidth,
          sidebarWidth,
        );
      },
    );
  }

  void _scheduleSidebarCollapsedPersistence() {
    _sidebarCollapsedPersistTimer?.cancel();
    _sidebarCollapsedPersistTimer = Timer(
      const Duration(milliseconds: mpProjectTreeUIPersistDebounceMilliseconds),
      () {
        _settingsController.setBool(
          MPSettingID.ProjectTree_SidebarCollapsed,
          isSidebarCollapsed,
        );
      },
    );
  }
}
