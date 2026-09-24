// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mobx/mobx.dart';

part 'th_project_tree_ui_controller.g.dart';

class THProjectTreeUIController = THProjectTreeUIControllerBase
    with _$THProjectTreeUIController;

/// Which content the project sidebar shows. Owned solely by
/// [THProjectTreeUIController]; `THProjectSearchController` never changes it.
enum THProjectSidebarMode { tree, projectSearch }

/// UI-only view state for the project tree sidebar.
///
/// Expansion, filtering, and sidebar layout state live here rather than in
/// [THProjectController] so the parsing/re-parsing pipeline never mutates or
/// observes view concerns.
abstract class THProjectTreeUIControllerBase with Store {
  @observable
  ObservableSet<String> expandedNodeIds = ObservableSet<String>();

  /// Row ids (`th2el:<canonicalPath>:<mpID>`) of the TH2 scrap rows the user
  /// collapsed. Scraps start expanded, so only the exception is stored. Kept
  /// apart from [expandedNodeIds] so default expansion never sees TH2 ids.
  @observable
  ObservableSet<String> collapsedTH2ScrapIds = ObservableSet<String>();

  @observable
  String filterText = '';

  @observable
  bool isSidebarCollapsed = false;

  /// Whether the sidebar shows the project tree or the multi-file search view.
  /// This is the only authority for that choice.
  @observable
  THProjectSidebarMode sidebarMode = THProjectSidebarMode.tree;

  /// Monotonically increasing counter incremented every time project search is
  /// (re)requested, even when it is already visible. `THProjectSearchWidget`
  /// consumes each new value after mount to focus/select its query field,
  /// which keeps focus-node ownership in widget state.
  @observable
  int projectSearchFocusRequestGeneration = 0;

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
  void toggleTH2ScrapCollapsed(String scrapRowId) {
    if (!collapsedTH2ScrapIds.add(scrapRowId)) {
      collapsedTH2ScrapIds.remove(scrapRowId);
    }
  }

  bool isTH2ScrapCollapsed(String scrapRowId) =>
      collapsedTH2ScrapIds.contains(scrapRowId);

  /// Whether the project TH2 file at [canonicalPath] has its row expanded.
  /// `false` with no project or for a file outside it.
  bool isTH2FileRowExpanded(String canonicalPath) {
    final THProjectFileNode? node = _projectController.nodeByCanonicalPath(
      canonicalPath,
    );

    return (node is TH2FileNode) && expandedNodeIds.contains(node.id);
  }

  /// Whether a tree load of [canonicalPath] may start now: the project that
  /// scheduled it ([projectEpoch], [rootConfigPath]) is still current and
  /// idle, no filter is active, and the file's row is expanded and visible.
  bool isTH2FileRowLoadEligible(
    String canonicalPath, {
    required int projectEpoch,
    required String rootConfigPath,
  }) {
    final bool isSameProject =
        (_projectController.projectEpoch == projectEpoch) &&
        (_projectController.rootConfigPath == rootConfigPath) &&
        (_projectController.projectRootNode != null);

    if (!isSameProject ||
        _projectController.isParsing ||
        filterText.isNotEmpty ||
        !isTH2FileRowExpanded(canonicalPath)) {
      return false;
    }

    final THProjectFileNode node = _projectController.nodeByCanonicalPath(
      canonicalPath,
    )!;

    return _areAncestorsExpanded(node);
  }

  /// Requests a tab-less load of the TH2 file at [canonicalPath] when
  /// [isTH2FileRowLoadEligible] allows it.
  void loadTH2FileIfEligible(
    String canonicalPath, {
    required int projectEpoch,
    required String rootConfigPath,
  }) {
    if (!isTH2FileRowLoadEligible(
      canonicalPath,
      projectEpoch: projectEpoch,
      rootConfigPath: rootConfigPath,
    )) {
      return;
    }

    MPLocator().mpGeneralController.ensureTH2FileLoaded(canonicalPath);
  }

  bool _areAncestorsExpanded(THProjectNode node) {
    THProjectNode? ancestor = node.parent;

    while (ancestor != null) {
      if (!expandedNodeIds.contains(ancestor.id)) {
        return false;
      }

      ancestor = ancestor.parent;
    }

    return true;
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

  /// Expands the sidebar if needed, switches it to project-search mode, and
  /// issues a fresh query-focus request (even when search mode was already
  /// visible).
  @action
  void showProjectSearch() {
    setSidebarCollapsed(false);
    sidebarMode = THProjectSidebarMode.projectSearch;
    projectSearchFocusRequestGeneration++;
  }

  /// Returns the sidebar to tree mode. Query/options/results survive in
  /// [THProjectSearchController] for the lifetime of the loaded project.
  @action
  void showTree() {
    sidebarMode = THProjectSidebarMode.tree;
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

  bool matchesFilter(THProjectNode node) => matchesFilterText(node.label);

  /// Case-insensitive substring match of the filter against a row's full
  /// label. Project rows and TH2 element rows both use it.
  bool matchesFilterText(String label) {
    if (filterText.isEmpty) {
      return true;
    }

    return label.toLowerCase().contains(filterText.toLowerCase());
  }

  @action
  void _handleProjectRootChanged(THProjectFileNode? root) {
    if (root == null) {
      expandedNodeIds.clear();
      collapsedTH2ScrapIds.clear();

      return;
    }

    if (expandedNodeIds.isNotEmpty) {
      return;
    }

    final int? shallowestTH2Depth = _shallowestTH2FileDepth(root, 0);

    if (shallowestTH2Depth == null) {
      _expandNonTH2NodesUpToDepth(root, 0, _maximumDepth(root, 0));

      return;
    }

    _expandNonTH2NodesUpToDepth(root, 0, shallowestTH2Depth);
  }

  /// The smallest depth of any [TH2FileNode] under [node], or `null` when
  /// there is none. Walk order does not matter.
  int? _shallowestTH2FileDepth(THProjectNode node, int depth) {
    if (node is TH2FileNode) {
      return depth;
    }

    int? shallowestDepth;

    for (final THProjectNode child in node.children) {
      final int? childDepth = _shallowestTH2FileDepth(child, depth + 1);

      if ((childDepth != null) &&
          ((shallowestDepth == null) || (childDepth < shallowestDepth))) {
        shallowestDepth = childDepth;
      }
    }

    return shallowestDepth;
  }

  int _maximumDepth(THProjectNode node, int depth) {
    int deepestDepth = depth;

    for (final THProjectNode child in node.children) {
      final int childDepth = _maximumDepth(child, depth + 1);

      if (childDepth > deepestDepth) {
        deepestDepth = childDepth;
      }
    }

    return deepestDepth;
  }

  /// Expands every non-TH2 node whose depth is at most [maximumDepth]. TH2
  /// file rows are never expanded automatically: expanding one loads it.
  void _expandNonTH2NodesUpToDepth(
    THProjectNode node,
    int depth,
    int maximumDepth,
  ) {
    if ((depth > maximumDepth) || (node is TH2FileNode)) {
      return;
    }

    expandedNodeIds.add(node.id);

    for (final THProjectNode child in node.children) {
      _expandNonTH2NodesUpToDepth(child, depth + 1, maximumDepth);
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
