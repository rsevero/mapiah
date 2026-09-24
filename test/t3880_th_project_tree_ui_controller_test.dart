// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<MPSettingsController> freshSettingsController() async {
    final MPSettingsController controller = MPSettingsController();

    await controller.initialized;

    return controller;
  }

  THMissingFileNode buildFileNode({
    required String id,
    required String label,
    String absolutePath = '/tmp/example.th',
  }) {
    return THMissingFileNode(
      id: id,
      label: label,
      sourceFilePath: absolutePath,
      lineNumber: 0,
      absolutePath: absolutePath,
      relativePathToProjectRoot: label,
      encoding: 'UTF-8',
      requestedPath: label,
    );
  }

  TH2FileNode buildTH2FileNode({
    required String id,
    required String label,
    String absolutePath = '/tmp/passage.th2',
  }) {
    return TH2FileNode(
      id: id,
      label: label,
      sourceFilePath: absolutePath,
      lineNumber: 0,
      absolutePath: absolutePath,
      relativePathToProjectRoot: label,
      encoding: 'UTF-8',
      isLoaded: false,
    );
  }

  group('THProjectTreeUIController expand/collapse/filter', () {
    test('expand, toggle, collapse, and isExpanded behave as a set', () async {
      final MPSettingsController settings = await freshSettingsController();
      final THProjectTreeUIController controller = THProjectTreeUIController(
        settingsController: settings,
      );

      addTearDown(controller.dispose);

      expect(controller.isExpanded('a'), isFalse);

      controller.expand('a');
      expect(controller.isExpanded('a'), isTrue);

      controller.toggleExpanded('a');
      expect(controller.isExpanded('a'), isFalse);

      controller.expand('a');
      controller.collapse('a');
      expect(controller.isExpanded('a'), isFalse);
    });

    test('filter text is updated exactly when setFilterText is called', () async {
      final MPSettingsController settings = await freshSettingsController();
      final THProjectTreeUIController controller = THProjectTreeUIController(
        settingsController: settings,
      );

      addTearDown(controller.dispose);

      expect(controller.filterText, isEmpty);
      controller.setFilterText('cave');

      expect(controller.filterText, 'cave');
      expect(controller.matchesFilter(buildFileNode(id: 'x', label: 'Cave A')), isTrue);
      expect(controller.matchesFilter(buildFileNode(id: 'y', label: 'Passage')), isFalse);
    });
  });

  group('THProjectTreeUIController layout persistence', () {
    test('sidebar width clamps to configured bounds', () async {
      final MPSettingsController settings = await freshSettingsController();
      final THProjectTreeUIController controller = THProjectTreeUIController(
        settingsController: settings,
      );

      addTearDown(controller.dispose);

      controller.setSidebarWidth(10000);
      expect(controller.sidebarWidth, mpProjectTreeSidebarMaxWidth);

      controller.setSidebarWidth(1);
      expect(controller.sidebarWidth, mpProjectTreeSidebarMinWidth);
    });

    test('collapsed toggle and width are debounced-persisted and restored', () async {
      final MPSettingsController settings = await freshSettingsController();
      final THProjectTreeUIController controller = THProjectTreeUIController(
        settingsController: settings,
      );

      controller.setSidebarCollapsed(true);
      controller.setSidebarWidth(321);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(
        settings.getBoolWithDefault(
          MPSettingID.ProjectTree_SidebarCollapsed,
        ),
        isTrue,
      );
      expect(
        settings.getDoubleWithDefault(MPSettingID.ProjectTree_SidebarWidth),
        321,
      );

      controller.dispose();

      final THProjectTreeUIController restoredController =
          THProjectTreeUIController(settingsController: settings);

      addTearDown(restoredController.dispose);

      expect(restoredController.isSidebarCollapsed, isTrue);
      expect(restoredController.sidebarWidth, 321);
    });
  });

  group('THProjectTreeUIController default expansion', () {
    test('expands all branches down to the shallowest th2 file', () {
      final THProjectController projectController = THProjectController();
      final THMissingFileNode rootNode = buildFileNode(
        id: 'file:/tmp/cave.thconfig',
        label: 'cave.thconfig',
        absolutePath: '/tmp/cave.thconfig',
      );
      final THMissingFileNode surveyWithTH2 = buildFileNode(
        id: 'file:/tmp/survey_with_th2.th',
        label: 'survey_with_th2.th',
        absolutePath: '/tmp/survey_with_th2.th',
      );
      final TH2FileNode th2Node = buildTH2FileNode(
        id: 'file:/tmp/passage.th2',
        label: 'passage.th2',
        absolutePath: '/tmp/passage.th2',
      );
      final THMissingFileNode siblingBranch = buildFileNode(
        id: 'file:/tmp/sibling.th',
        label: 'sibling.th',
        absolutePath: '/tmp/sibling.th',
      );
      final THMissingFileNode siblingChild = buildFileNode(
        id: 'file:/tmp/sibling_child.th',
        label: 'sibling_child.th',
        absolutePath: '/tmp/sibling_child.th',
      );

      surveyWithTH2.addChild(th2Node);
      siblingBranch.addChild(siblingChild);
      rootNode.addChild(surveyWithTH2);
      rootNode.addChild(siblingBranch);

      projectController.projectRootNode = rootNode;

      final THProjectTreeUIController controller = THProjectTreeUIController(
        projectController: projectController,
      );

      addTearDown(controller.dispose);

      expect(controller.isExpanded(rootNode.id), isTrue);
      expect(controller.isExpanded(surveyWithTH2.id), isTrue);
      expect(controller.isExpanded(siblingBranch.id), isTrue);
      expect(controller.isExpanded(th2Node.id), isFalse);
      expect(controller.isExpanded(siblingChild.id), isTrue);

      projectController.projectRootNode = null;

      expect(controller.expandedNodeIds, isEmpty);
    });

    test('uses the shallowest th2 depth, not the first one in walk order', () {
      final THProjectController projectController = THProjectController();
      final THMissingFileNode config = buildFileNode(
        id: 'file:/tmp/main.thconfig',
        label: 'main.thconfig',
        absolutePath: '/tmp/main.thconfig',
      );
      final THMissingFileNode cave = buildFileNode(
        id: 'file:/tmp/cave.th',
        label: 'cave.th',
        absolutePath: '/tmp/cave.th',
      );
      final THMissingFileNode north = buildFileNode(
        id: 'file:/tmp/north.th',
        label: 'north.th',
        absolutePath: '/tmp/north.th',
      );
      final TH2FileNode northTH2 = buildTH2FileNode(
        id: 'file:/tmp/north.th2',
        label: 'north.th2',
        absolutePath: '/tmp/north.th2',
      );
      final TH2FileNode caveTH2 = buildTH2FileNode(
        id: 'file:/tmp/cave.th2',
        label: 'cave.th2',
        absolutePath: '/tmp/cave.th2',
      );

      north.addChild(northTH2);
      cave.addChild(north);
      cave.addChild(caveTH2);
      config.addChild(cave);
      projectController.projectRootNode = config;

      final THProjectTreeUIController controller = THProjectTreeUIController(
        projectController: projectController,
      );

      addTearDown(controller.dispose);

      expect(controller.isExpanded(config.id), isTrue);
      expect(controller.isExpanded(cave.id), isTrue);
      expect(controller.isExpanded(north.id), isTrue);
      expect(controller.isExpanded(northTH2.id), isFalse);
      expect(controller.isExpanded(caveTH2.id), isFalse);
    });

    test('never seeds a th2 file id, whatever the children order', () {
      for (final bool th2First in <bool>[true, false]) {
        final THProjectController projectController = THProjectController();
        final THMissingFileNode root = buildFileNode(
          id: 'file:/tmp/root.th',
          label: 'root.th',
          absolutePath: '/tmp/root.th',
        );
        final TH2FileNode shallowTH2 = buildTH2FileNode(
          id: 'file:/tmp/shallow.th2',
          label: 'shallow.th2',
          absolutePath: '/tmp/shallow.th2',
        );
        final THMissingFileNode branch = buildFileNode(
          id: 'file:/tmp/branch.th',
          label: 'branch.th',
          absolutePath: '/tmp/branch.th',
        );
        final TH2FileNode deepTH2 = buildTH2FileNode(
          id: 'file:/tmp/deep.th2',
          label: 'deep.th2',
          absolutePath: '/tmp/deep.th2',
        );
        final THMissingFileNode deepBranch = buildFileNode(
          id: 'file:/tmp/deep_branch.th',
          label: 'deep_branch.th',
          absolutePath: '/tmp/deep_branch.th',
        );

        branch.addChild(deepTH2);
        branch.addChild(deepBranch);

        if (th2First) {
          root.addChild(shallowTH2);
          root.addChild(branch);
        } else {
          root.addChild(branch);
          root.addChild(shallowTH2);
        }

        projectController.projectRootNode = root;

        final THProjectTreeUIController controller =
            THProjectTreeUIController(projectController: projectController);

        addTearDown(controller.dispose);

        expect(controller.expandedNodeIds, <String>{root.id, branch.id});
        expect(controller.isExpanded(deepBranch.id), isFalse);
      }
    });

    test('expands the whole tree when the project has no th2 file', () {
      final THProjectController projectController = THProjectController();
      final THMissingFileNode rootNode = buildFileNode(
        id: 'file:/tmp/cave.thconfig',
        label: 'cave.thconfig',
        absolutePath: '/tmp/cave.thconfig',
      );
      final THMissingFileNode childNode = buildFileNode(
        id: 'file:/tmp/passage.th',
        label: 'passage.th',
        absolutePath: '/tmp/passage.th',
      );
      final THMissingFileNode grandchildNode = buildFileNode(
        id: 'file:/tmp/passage_child.th',
        label: 'passage_child.th',
        absolutePath: '/tmp/passage_child.th',
      );

      childNode.addChild(grandchildNode);
      rootNode.addChild(childNode);
      projectController.projectRootNode = rootNode;

      final THProjectTreeUIController controller = THProjectTreeUIController(
        projectController: projectController,
      );

      addTearDown(controller.dispose);

      expect(controller.isExpanded(rootNode.id), isTrue);
      expect(controller.isExpanded(childNode.id), isTrue);
      expect(controller.isExpanded(grandchildNode.id), isTrue);
    });
  });
}
