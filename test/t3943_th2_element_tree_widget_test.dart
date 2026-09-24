// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th2_element_tree_aux.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/widgets/th2_broken_file_body_widget.dart';
import 'package:mapiah/src/widgets/th2_element_tree_row_widget.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th2_element_tree_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();
  final List<TH2TreeTestProject> projects = <TH2TreeTestProject>[];

  THProjectTreeUIController ui() => mpLocator.thProjectTreeUIController;

  TH2TreeTestProject newProject({
    String aContents = th2TreeValidContents,
    String bContents = th2TreeValidContents,
  }) {
    final TH2TreeTestProject project = TH2TreeTestProject.create(
      aContents: aContents,
      bContents: bContents,
    );

    projects.add(project);

    return project;
  }

  TH2FileEditController? controllerOf(String path) =>
      mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path);

  Finder chevronOf(TH2FileNode node) =>
      find.byKey(ValueKey('THProjectTreeNodeChevron|${node.id}'));

  Finder statusRow(String path, TH2FileStatusTreeRowKind kind) => find.byKey(
    ValueKey(
      'TH2FileStatusTreeRow|th2status:$path:${kind.name}',
    ),
  );

  String rowIdOf(String path, String thID) => th2ElementTreeRowId(
    th2FilePath: path,
    elementMPID: controllerOf(path)!.th2File.mpIDByTHID(thID)!,
  );

  Finder elementRow(String path, String thID) =>
      find.byKey(ValueKey('TH2ElementTreeRowWidget|${rowIdOf(path, thID)}'));

  Color? rowColor(WidgetTester tester, String path, String thID) =>
      tester.widget<Material>(elementRow(path, thID)).color;

  Future<void> pumpApp(WidgetTester tester, {Locale? locale}) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      buildTH2TreeTestApp(locale: locale ?? const Locale('en')),
    );
    await tester.pump();
  }

  /// Opens a project, mounts the workspace and expands `a.th2` until it is
  /// loaded.
  Future<TH2TreeTestProject> openAndExpandA(
    WidgetTester tester, {
    String aContents = th2TreeValidContents,
  }) async {
    final TH2TreeTestProject project = newProject(aContents: aContents);

    await pumpApp(tester);
    await openTH2TreeProject(tester, project);
    await tester.tap(chevronOf(th2NodeOf(project, 'a.th2')));
    await tester.pump();
    await settleTH2Load(tester, project.pathOf('a.th2'));

    return project;
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    ui().setFilterText('');
    ui().expandedNodeIds.clear();
    ui().collapsedTH2ScrapIds.clear();
    ui().setSidebarCollapsed(false);
    ui().showTree();
    th2ElementTreeTapTracker.reset();
    th2ElementTreeTapTracker.now = DateTime.now;
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.isParsing = false;
    th2ElementTreeTapTracker.now = DateTime.now;

    for (final TH2TreeTestProject project in projects) {
      project.delete();
    }

    projects.clear();
  });

  group('lazy loading', () {
    testWidgets('opening a project parses no th2 file', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      await settleTH2Tree(tester, maxAttempts: 5);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      expect(chevronOf(aNode), findsOneWidget);
      expect(ui().isExpanded(aNode.id), isFalse);
      expect(controllerOf(project.pathOf('a.th2')), isNull);
      expect(controllerOf(project.pathOf('b.th2')), isNull);
    });

    testWidgets('expanding loads tab-less, showing Loading first', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final int revisionBefore =
          mpLocator.mpGeneralController.th2ControllersRevision;

      await tester.tap(chevronOf(th2NodeOf(project, 'a.th2')));
      await tester.pump();

      expect(statusRow(path, TH2FileStatusTreeRowKind.loading), findsOneWidget);

      final TH2FileEditController first = controllerOf(path)!;

      await tester.pump();
      await tester.pump();

      final TH2FileEditController? loaded = await settleTH2Load(tester, path);

      expect(loaded, same(first));
      expect(
        mpLocator.mpGeneralController.th2ControllersRevision,
        revisionBefore + 1,
      );
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(mpLocator.thProjectController.dirtyFilePaths, isEmpty);
      expect(mpLocator.thProjectController.activeSelectedNodeId, isNull);
      expect(statusRow(path, TH2FileStatusTreeRowKind.loading), findsNothing);
      expect(elementRow(path, 's1'), findsOneWidget);
      expect(elementRow(path, 'l1'), findsOneWidget);
      expect(
        find.byKey(
          ValueKey('THProjectTreeNodeBrokenBadge|${th2NodeOf(project, 'a.th2').id}'),
        ),
        findsNothing,
      );
    });

    testWidgets('a programmatic expansion loads once after the frame', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String aPath = project.pathOf('a.th2');
      final String bPath = project.pathOf('b.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final int revisionBefore =
          mpLocator.mpGeneralController.th2ControllersRevision;

      ui().expand(th2NodeOf(project, 'a.th2').id);
      ui().expand(th2NodeOf(project, 'b.th2').id);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await settleTH2Load(tester, aPath);
      await settleTH2Load(tester, bPath);

      expect(
        mpLocator.mpGeneralController.th2ControllersRevision,
        revisionBefore + 2,
      );
      expect(controllerOf(aPath)!.isFileLoaded, isTrue);
      expect(controllerOf(bPath)!.isFileLoaded, isTrue);
    });

    testWidgets('a stale deferred request creates no controller', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      ui().expand(th2NodeOf(project, 'a.th2').id);
      tester.binding.addPostFrameCallback((Duration _) {
        mpLocator.thProjectController.closeProject();
      });
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 5);

      expect(controllerOf(path), isNull);
    });

    testWidgets('closing and reopening the same root invalidates a request', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      ui().expand(aNode.id);
      tester.binding.addPostFrameCallback((Duration _) {
        mpLocator.thProjectController.closeProject();
        mpLocator.thProjectController.projectRootNode =
            mpLocator.thProjectController.projectRootNode;
      });
      await tester.pump();

      expect(controllerOf(path), isNull);

      await openTH2TreeProject(tester, project);
      ui().expand(th2NodeOf(project, 'a.th2').id);
      await tester.pump();
      await settleTH2Load(tester, path);

      expect(controllerOf(path)!.isFileLoaded, isTrue);
    });

    testWidgets('collapsing or filtering before the callback cancels it', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      ui().expand(aNode.id);
      tester.binding.addPostFrameCallback((Duration _) {
        ui().collapse(aNode.id);
      });
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(controllerOf(path), isNull);

      ui().expand(aNode.id);
      tester.binding.addPostFrameCallback((Duration _) {
        ui().setFilterText('zzz');
      });
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(controllerOf(path), isNull);

      ui().setFilterText('');
      await tester.pump();
      await settleTH2Load(tester, path);

      expect(controllerOf(path)!.isFileLoaded, isTrue);
    });

    testWidgets('collapsing an ancestor before the callback cancels it', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      ui().expand(aNode.id);
      tester.binding.addPostFrameCallback((Duration _) {
        ui().collapse(aNode.parent!.id);
      });
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(controllerOf(path), isNull);
    });

    testWidgets('no automatic load while the project is parsing', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      mpLocator.thProjectController.isParsing = true;
      ui().expand(th2NodeOf(project, 'a.th2').id);
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(controllerOf(path), isNull);

      mpLocator.thProjectController.isParsing = false;
      await tester.pump();
      await settleTH2Load(tester, path);

      expect(controllerOf(path)!.isFileLoaded, isTrue);
    });

    testWidgets('a row kept expanded across a project reload loads again', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController first = controllerOf(path)!;

      await tester.runAsync(
        () => mpLocator.thProjectController.reloadProject(),
      );
      await tester.pump();

      expect(first.isDisposed, isTrue);

      final TH2FileEditController? second = await settleTH2Load(tester, path);

      expect(second, isNot(same(first)));
      expect(second!.isFileLoaded, isTrue);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(elementRow(path, 's1'), findsOneWidget);
    });

    testWidgets('no file loads while a filter is active', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject();
      final String aPath = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      ui().setFilterText('a.th2');
      ui().expand(th2NodeOf(project, 'a.th2').id);
      await tester.pump();
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(
        find.byKey(
          ValueKey('THProjectTreeNodeWidget|${th2NodeOf(project, 'a.th2').id}'),
        ),
        findsOneWidget,
      );
      expect(controllerOf(aPath), isNull);

      ui().setFilterText('');
      await tester.pump();
      await settleTH2Load(tester, aPath);

      expect(controllerOf(aPath)!.isFileLoaded, isTrue);
      expect(controllerOf(project.pathOf('b.th2')), isNull);
    });
  });

  group('broken and failed files', () {
    testWidgets('a broken file shows the badge and status row only', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: th2TreeBrokenContents,
      );
      final String path = project.pathOf('a.th2');
      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      expect(statusRow(path, TH2FileStatusTreeRowKind.broken), findsOneWidget);
      expect(find.byType(TH2ElementTreeRowWidget), findsOneWidget);

      final Finder badge = find.byKey(
        ValueKey('THProjectTreeNodeBrokenBadge|${aNode.id}'),
      );

      expect(badge, findsOneWidget);
      expect(
        find.descendant(of: badge, matching: find.text('2')),
        findsOneWidget,
      );

      final Tooltip tooltip = tester.widget<Tooltip>(badge);

      expect(tooltip.message, startsWith('2 problems\nLine 2: '));
    });

    testWidgets('the badge tooltip truncates long problem lists', (
      WidgetTester tester,
    ) async {
      final String manyProblems = <String>[
        'encoding utf-8',
        for (int index = 0; index < 8; index++) 'point $index 1 station',
        'scrap s1',
        'endscrap',
      ].join('\n');
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: manyProblems,
      );
      final Tooltip tooltip = tester.widget<Tooltip>(
        find.byKey(
          ValueKey(
            'THProjectTreeNodeBrokenBadge|${th2NodeOf(project, 'a.th2').id}',
          ),
        ),
      );
      final List<String> lines = tooltip.message!.split('\n');

      expect(lines.first, '8 problems');
      expect(lines, hasLength(mpTH2ElementTreeBadgeTooltipMaxProblems + 2));
      expect(lines.last, '…and 3 more');
    });

    testWidgets('right-click Reload on a fixed broken file shows its rows', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: th2TreeBrokenContents,
      );
      final String path = project.pathOf('a.th2');
      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');
      final TH2FileEditController broken = controllerOf(path)!;

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.id}')),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();

      final Finder reload = find.byKey(
        ValueKey('THProjectTreeRowContextMenuReload|${aNode.id}'),
      );

      expect(reload, findsOneWidget);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(mpLocator.thProjectController.activeSelectedNodeId, isNull);

      project.write('a.th2', th2TreeValidContents);
      await tester.tap(reload);
      await tester.pump();

      final TH2FileEditController? reloaded = await settleTH2Load(
        tester,
        path,
      );

      expect(reloaded, isNot(same(broken)));
      expect(broken.isDisposed, isTrue);
      expect(reloaded!.isBroken, isFalse);
      expect(elementRow(path, 's1'), findsOneWidget);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('the broken status row also offers Reload', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: th2TreeBrokenContents,
      );
      final String path = project.pathOf('a.th2');
      final String statusRowId = 'th2status:$path:broken';

      await tester.tap(
        statusRow(path, TH2FileStatusTreeRowKind.broken),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(ValueKey('THProjectTreeRowContextMenuReload|$statusRowId')),
        findsOneWidget,
      );
    });

    testWidgets('element rows open an order menu without opening a tab', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      for (final Finder target in <Finder>[
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.id}')),
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.parent!.id}')),
      ]) {
        await tester.tap(target, buttons: kSecondaryButton);
        await tester.pump();
        await tester.pump();
        expect(find.byType(MenuItemButton), findsNothing);
      }

      await tester.tap(elementRow(path, 'p1'), buttons: kSecondaryButton);
      await tester.pump();
      await tester.pump();
      expect(find.byType(MenuItemButton), findsWidgets);
      expect(controllerOf(path)!.selectionController.mpSelectedElementsLogical,
          isNotEmpty);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('a file that turns broken shows Reload on the first click', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject(
        bContents: th2TreeBrokenContents,
      );
      final TH2FileNode bNode;

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      bNode = th2NodeOf(project, 'b.th2');
      await tester.runAsync(
        () => mpLocator.mpGeneralController
            .getTH2FileEditController(filename: project.pathOf('b.th2'))
            .load(),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${bNode.id}')),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(ValueKey('THProjectTreeRowContextMenuReload|${bNode.id}')),
        findsOneWidget,
      );
    });

    testWidgets('a menu request becoming stale before opening is dropped', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject(
        bContents: th2TreeBrokenContents,
      );

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final TH2FileNode bNode = th2NodeOf(project, 'b.th2');
      final String path = project.pathOf('b.th2');

      await tester.runAsync(
        () => mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path)
            .load(),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${bNode.id}')),
        buttons: kSecondaryButton,
      );
      mpLocator.mpGeneralController.removeFileController(filename: path);
      await tester.pump();
      await tester.pump();

      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('a load that throws shows one load-error row, no retries', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: th2TreeThrowingContents,
      );
      final String path = project.pathOf('a.th2');
      final TH2FileEditController failed = controllerOf(path)!;

      expect(failed.loadError, isNotNull);
      expect(
        statusRow(path, TH2FileStatusTreeRowKind.loadError),
        findsOneWidget,
      );

      await settleTH2Tree(tester, maxAttempts: 5);

      expect(controllerOf(path), same(failed));
      expect(
        find.byKey(
          ValueKey(
            'THProjectTreeNodeLoadErrorBadge|${th2NodeOf(project, 'a.th2').id}',
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(
        statusRow(path, TH2FileStatusTreeRowKind.loadError),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();

      final Finder reload = find.byKey(
        ValueKey('THProjectTreeRowContextMenuReload|th2status:$path:loadError'),
      );

      expect(reload, findsOneWidget);

      await tester.tap(reload);
      await tester.pump();
      await settleTH2Tree(
        tester,
        until: () => controllerOf(path)?.loadError != null &&
            !identical(controllerOf(path), failed),
      );

      expect(
        statusRow(path, TH2FileStatusTreeRowKind.loadError),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      project.write('a.th2', th2TreeValidContents);
      await tester.tap(
        statusRow(path, TH2FileStatusTreeRowKind.loadError),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(reload);
      await tester.pump();
      await settleTH2Load(tester, path);

      expect(elementRow(path, 's1'), findsOneWidget);
    });

    testWidgets('a collapsed file row shows the badge after its tab loads', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject(
        aContents: th2TreeBrokenContents,
      );
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.id}')),
      );
      await tester.pump();
      await settleTH2Load(tester, path);

      expect(ui().isExpanded(aNode.id), isFalse);
      expect(
        find.byKey(ValueKey('THProjectTreeNodeBrokenBadge|${aNode.id}')),
        findsOneWidget,
      );
      expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);
    });
  });

  group('open-tab Reload', () {
    Future<TH2TreeTestProject> openBrokenTab(WidgetTester tester) async {
      final TH2TreeTestProject project = newProject(
        aContents: th2TreeBrokenContents,
      );

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      await tester.tap(
        find.byKey(
          ValueKey('THProjectTreeNodeWidget|${th2NodeOf(project, 'a.th2').id}'),
        ),
      );
      await tester.pump();
      await settleTH2Load(tester, project.pathOf('a.th2'));

      expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);

      return project;
    }

    Future<void> sidebarReload(
      WidgetTester tester,
      TH2TreeTestProject project,
    ) async {
      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.id}')),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(
        find.byKey(ValueKey('THProjectTreeRowContextMenuReload|${aNode.id}')),
      );
      await tester.pump();
    }

    testWidgets('broken to valid replaces the tab body', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openBrokenTab(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController broken = controllerOf(path)!;

      project.write('a.th2', th2TreeValidContents);
      await sidebarReload(tester, project);
      await settleTH2Tree(
        tester,
        until: () => find.byType(TH2FileWidget).evaluate().isNotEmpty,
      );

      final TH2FileEditController reloaded = controllerOf(path)!;
      final TH2FileWidget canvas = tester.widget<TH2FileWidget>(
        find.byType(TH2FileWidget),
      );

      expect(reloaded, isNot(same(broken)));
      expect(canvas.th2FileEditController, same(reloaded));
      expect(find.byType(TH2BrokenFileBodyWidget), findsNothing);
      expect(mpLocator.mpGeneralController.openFileOrder, <String>[path]);
    });

    testWidgets('broken to broken shows the new diagnostics', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openBrokenTab(tester);
      final String path = project.pathOf('a.th2');

      expect(find.textContaining('Line 4:'), findsOneWidget);

      project.write('a.th2', th2TreeOtherBrokenContents);
      await sidebarReload(tester, project);
      await settleTH2Tree(
        tester,
        until: () => find.textContaining('Line 4:').evaluate().isNotEmpty &&
            find.textContaining('Line 2:').evaluate().isEmpty,
      );

      final TH2BrokenFileBodyWidget body = tester
          .widget<TH2BrokenFileBodyWidget>(
            find.byType(TH2BrokenFileBodyWidget),
          );

      expect(body.controller, same(controllerOf(path)));
      expect(find.textContaining('Line 2:'), findsNothing);
    });

    testWidgets('an exception during a sidebar Reload shows one dialog', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openBrokenTab(tester);

      project.write('a.th2', th2TreeThrowingContents);
      await sidebarReload(tester, project);
      await settleTH2Tree(
        tester,
        until: () => find.byType(MPErrorDialog).evaluate().isNotEmpty,
      );

      expect(find.byType(MPErrorDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(mpLocator.appLocalizations.buttonClose));
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(find.byType(MPErrorDialog), findsNothing);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('an exception during the tab Reload button shows one dialog', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openBrokenTab(tester);

      project.write('a.th2', th2TreeThrowingContents);
      await tester.tap(find.text('Reload'));
      await tester.pump();
      await settleTH2Tree(
        tester,
        until: () => find.byType(MPErrorDialog).evaluate().isNotEmpty,
      );

      expect(find.byType(MPErrorDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(mpLocator.appLocalizations.buttonClose));
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('a tab whose load throws with its row collapsed closes', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject(
        aContents: th2TreeThrowingContents,
      );
      final String path = project.pathOf('a.th2');

      await pumpApp(tester);
      await openTH2TreeProject(tester, project);
      await tester.tap(
        find.byKey(
          ValueKey('THProjectTreeNodeWidget|${th2NodeOf(project, 'a.th2').id}'),
        ),
      );
      await tester.pump();
      await settleTH2Tree(
        tester,
        until: () => find.byType(MPErrorDialog).evaluate().isNotEmpty,
      );

      expect(find.byType(MPErrorDialog), findsOneWidget);
      expect(controllerOf(path), isNull);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(mpLocator.appLocalizations.buttonClose));
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('an expanded failed file keeps its controller on tab close', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(
        tester,
        aContents: th2TreeThrowingContents,
      );
      final String path = project.pathOf('a.th2');
      final TH2FileEditController failed = controllerOf(path)!;

      await tester.tap(
        find.byKey(
          ValueKey('THProjectTreeNodeWidget|${th2NodeOf(project, 'a.th2').id}'),
        ),
      );
      await tester.pump();
      await settleTH2Tree(
        tester,
        until: () => find.byType(MPErrorDialog).evaluate().isNotEmpty,
      );

      expect(find.byType(MPErrorDialog), findsOneWidget);

      await tester.tap(find.text(mpLocator.appLocalizations.buttonClose));
      await settleTH2Tree(tester, maxAttempts: 5);

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(controllerOf(path), same(failed));
      expect(failed.isDisposed, isFalse);
      expect(
        statusRow(path, TH2FileStatusTreeRowKind.loadError),
        findsOneWidget,
      );
    });
  });

  group('tree to canvas selection', () {
    Future<void> tapRow(WidgetTester tester, Finder row) async {
      await tester.tap(row);
      await tester.pump();
    }

    testWidgets('Ctrl toggles and Shift extends element rows',
        (WidgetTester tester) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final int p1 = controller.th2File.mpIDByTHID('p1')!;
      final int l1 = controller.th2File.mpIDByTHID('l1')!;
      final int p3 = controller.th2File.mpIDByTHID('p3')!;
      await tester.tap(elementRow(path, 'p1'));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(elementRow(path, 'p3'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(controller.selectionController.mpSelectedElementsLogical.keys,
        containsAll(<int>[p1, p3]));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(elementRow(path, 'l1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(controller.selectionController.mpSelectedElementsLogical.keys,
        containsAll(<int>[p1, l1, p3]));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(elementRow(path, 'p1'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(controller.selectionController.mpSelectedElementsLogical.keys,
        isNot(contains(p1)));
    });

    testWidgets('a tab-less tap selects without opening a tab', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final int p2 = controller.th2File.mpIDByTHID('p2')!;
      final int s2 = controller.th2File.mpIDByTHID('s2')!;

      await tapRow(tester, elementRow(path, 'p2'));

      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[p2],
      );
      expect(controller.activeScrapID, s2);
      expect(
        controller.stateController.state,
        isA<MPTH2FileEditStateSelectNonEmptySelection>(),
      );
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(controller.enableSaveButton, isFalse);
      expect(rowColor(tester, path, 'p2'), isNot(Colors.transparent));
      expect(rowColor(tester, path, 'p1'), Colors.transparent);
    });

    testWidgets('a tab-less double tap opens the tab zoomed to the selection', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;

      await tapRow(tester, elementRow(path, 'p2'));
      await tapRow(tester, elementRow(path, 'p2'));
      await settleTH2Tree(
        tester,
        until: () => find.byType(TH2FileWidget).evaluate().isNotEmpty,
      );

      expect(mpLocator.mpGeneralController.openFileOrder, <String>[path]);
      expect(find.byType(TH2FileWidget), findsOneWidget);
      expect(controller.takePendingZoomToFitType(), isNull);

      final Offset center = Offset(
        controller.canvasCenterX,
        controller.canvasCenterY,
      );

      expect(center, const Offset(5, 5));
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[controller.th2File.mpIDByTHID('p2')!],
      );
    });

    testWidgets('an open file tap activates its tab; double tap zooms', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final String bPath = project.pathOf('b.th2');
      final TH2FileEditController controller = controllerOf(path)!;

      mpLocator.mpGeneralController.addFileTab(path);
      await tester.runAsync(
        () => mpLocator.mpGeneralController
            .getTH2FileEditController(filename: bPath)
            .load(),
      );
      mpLocator.mpGeneralController.addFileTab(bPath);
      await settleTH2Tree(tester, maxAttempts: 3);

      expect(mpLocator.mpGeneralController.activeTabIndex, 1);

      await tapRow(tester, elementRow(path, 'p3'));

      expect(mpLocator.mpGeneralController.activeTabIndex, 0);
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[controller.th2File.mpIDByTHID('p3')!],
      );

      await tapRow(tester, elementRow(path, 'p3'));
      await tester.pump();

      expect(
        Offset(controller.canvasCenterX, controller.canvasCenterY),
        const Offset(3, 3),
      );
    });

    testWidgets('taps on different rows or far apart are single taps', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      DateTime now = DateTime(2026);

      th2ElementTreeTapTracker.now = () => now;

      await tapRow(tester, elementRow(path, 'p1'));
      await tapRow(tester, elementRow(path, 'p3'));

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[controller.th2File.mpIDByTHID('p3')!],
      );

      now = now.add(kDoubleTapTimeout + const Duration(milliseconds: 50));
      await tapRow(tester, elementRow(path, 'p3'));

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);

      now = now.add(const Duration(milliseconds: 50));
      await tapRow(tester, elementRow(path, 'p3'));

      expect(mpLocator.mpGeneralController.openFileOrder, <String>[path]);

      mpLocator.mpGeneralController.removeFileTab(filename: path);
      now = now.add(const Duration(milliseconds: 50));
      await tapRow(tester, elementRow(path, 'p3'));

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    testWidgets('a second tap does not reselect nor change the state', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;

      await tapRow(tester, elementRow(path, 'p1'));

      final MPTH2FileEditState state = controller.stateController.state;
      int selectionChanges = 0;

      controller.selectionController.mpSelectedElementsLogical.observe((_) {
        selectionChanges++;
      });

      await tapRow(tester, elementRow(path, 'p1'));

      expect(selectionChanges, 0);
      expect(controller.stateController.state, same(state));
    });

    testWidgets('a second tap after a Reload does nothing', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final Finder p1Row = elementRow(path, 'p1');

      await tapRow(tester, p1Row);
      await tester.runAsync(
        () => mpLocator.mpGeneralController.reloadTH2File(path),
      );
      await tester.pump();

      final TH2FileEditController reloaded = controllerOf(path)!;

      await tester.tap(elementRow(path, 'p1'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
      expect(reloaded.selectionController.mpSelectedElementsLogical, isNotEmpty);
    });

    testWidgets('a tab-less controller in add-point mode switches to select', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;

      controller.stateController.setState(MPTH2FileEditStateType.addPoint);
      await tapRow(tester, elementRow(path, 'l1'));

      expect(
        controller.stateController.state,
        isA<MPTH2FileEditStateSelectNonEmptySelection>(),
      );
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys,
        <int>[controller.th2File.mpIDByTHID('l1')!],
      );
      expect(controller.enableSaveButton, isFalse);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });
  });

  group('canvas to tree highlight', () {
    testWidgets('selection changes move the highlight without flattening', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final int callsBefore = TH2ElementTreeAux.debugRowsForFileCallCount;

      controller.setActiveScrap(controller.th2File.mpIDByTHID('s1')!);
      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p1'),
      ]);
      await tester.pump();

      expect(rowColor(tester, path, 'p1'), isNot(Colors.transparent));
      expect(rowColor(tester, path, 's1'), isNot(Colors.transparent));

      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('l1'),
      ]);
      await tester.pump();

      expect(rowColor(tester, path, 'p1'), Colors.transparent);
      expect(rowColor(tester, path, 'l1'), isNot(Colors.transparent));

      controller.selectionController.clearSelectedElements();
      await tester.pump();

      expect(rowColor(tester, path, 'l1'), Colors.transparent);
      expect(TH2ElementTreeAux.debugRowsForFileCallCount, callsBefore);

      controller.setActiveScrap(controller.th2File.mpIDByTHID('s2')!);
      await tester.pump();

      expect(rowColor(tester, path, 's1'), Colors.transparent);
      expect(rowColor(tester, path, 's2'), isNot(Colors.transparent));
    });

    testWidgets('a collapsed scrap shows a contains-selection dot', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final String s1RowId = rowIdOf(path, 's1');
      final Finder dot = find.byKey(
        ValueKey('TH2ElementTreeScrapContainsSelectionDot|$s1RowId'),
      );

      await tester.tap(
        find.byKey(ValueKey('TH2ElementTreeScrapChevron|$s1RowId')),
      );
      await tester.pump();

      expect(elementRow(path, 'p1'), findsNothing);
      expect(dot, findsNothing);

      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p1'),
      ]);
      await tester.pump();

      expect(dot, findsOneWidget);
      expect(ui().isTH2ScrapCollapsed(s1RowId), isTrue);

      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p2'),
      ]);
      await tester.pump();

      expect(dot, findsNothing);
    });

    testWidgets('a scrap chevron changes nothing but the collapsed state', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final int activeScrap = controller.activeScrapID;

      expect(
        find.byKey(ValueKey('TH2ElementTreeScrapChevron|${rowIdOf(path, 'p1')}')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(
          ValueKey('TH2ElementTreeScrapChevron|${rowIdOf(path, 's2')}'),
        ),
      );
      await tester.pump();

      expect(elementRow(path, 'p2'), findsNothing);
      expect(controller.activeScrapID, activeScrap);
      expect(controller.selectionController.mpSelectedElementsLogical, isEmpty);
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);

      await tester.tap(
        find.byKey(
          ValueKey('TH2ElementTreeScrapChevron|${rowIdOf(path, 's2')}'),
        ),
      );
      await tester.pump();

      expect(elementRow(path, 'p2'), findsOneWidget);
    });
  });

  group('structure changes', () {
    testWidgets('undo and redo change the visible order', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;

      double yOf(String thID) => tester.getTopLeft(elementRow(path, thID)).dy;

      expect(yOf('p1'), lessThan(yOf('l1')));

      controller.elementEditController.bringForward(
        elementMPIDs: <int>[controller.th2File.mpIDByTHID('p1')!],
      );
      await tester.pump();

      expect(yOf('p1'), greaterThan(yOf('l1')));

      controller.undo();
      await tester.pump();

      expect(yOf('p1'), lessThan(yOf('l1')));

      controller.redo();
      await tester.pump();

      expect(yOf('p1'), greaterThan(yOf('l1')));
    });

    testWidgets('a subtype-only change updates the row label', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final int p1 = controller.th2File.mpIDByTHID('p1')!;

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THSubtypeCommandOption(parentMPID: p1, subtype: 'fixed'),
        ),
      );
      await tester.pump();

      final String expected = MPTextToUser.getPointTypeSubtypeFromPoint(
        controller.th2File.elementByMPID(p1) as THPoint,
      );

      expect(expected, contains(':'));
      expect(
        find.descendant(
          of: elementRow(path, 'p1'),
          matching: find.textContaining(expected, findRichText: true),
        ),
        findsOneWidget,
      );
    });

    testWidgets('collapsed scraps survive undo, reset on Reload and close', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final String s2RowId = rowIdOf(path, 's2');

      ui().toggleTH2ScrapCollapsed(s2RowId);
      controller.elementEditController.bringForward(
        elementMPIDs: <int>[controller.th2File.mpIDByTHID('p1')!],
      );
      controller.undo();
      controller.redo();
      await tester.pump();

      expect(elementRow(path, 'p2'), findsNothing);

      await tester.runAsync(
        () => mpLocator.mpGeneralController.reloadTH2File(path),
      );
      await tester.pump();

      expect(elementRow(path, 'p2'), findsOneWidget);

      mpLocator.thProjectController.closeProject();
      await tester.pump();

      expect(ui().collapsedTH2ScrapIds, isEmpty);
    });
  });

  group('closing tabs', () {
    testWidgets('an expanded clean file keeps its controller tab-less', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController controller = controllerOf(path)!;
      final String s2RowId = rowIdOf(path, 's2');

      ui().toggleTH2ScrapCollapsed(s2RowId);
      mpLocator.mpGeneralController.addFileTab(path);
      await settleTH2Tree(tester, maxAttempts: 3);

      controller.setActiveScrap(controller.th2File.mpIDByTHID('s1')!);
      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p1'),
      ]);

      final int revision = mpLocator.mpGeneralController.th2ControllersRevision;

      controller.close();
      await tester.pump();

      expect(controllerOf(path), same(controller));
      expect(controller.isDisposed, isFalse);
      expect(mpLocator.mpGeneralController.th2ControllersRevision, revision);
      expect(ui().isTH2ScrapCollapsed(s2RowId), isTrue);
      expect(rowColor(tester, path, 'p1'), isNot(Colors.transparent));

      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p3'),
      ]);
      await tester.pump();

      expect(rowColor(tester, path, 'p3'), isNot(Colors.transparent));

      mpLocator.thProjectController.closeProject();

      expect(controller.isDisposed, isTrue);
    });

    testWidgets('a dirty or collapsed file loses its controller on close', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');
      final TH2FileEditController dirty = controllerOf(path)!;

      mpLocator.mpGeneralController.addFileTab(path);
      await settleTH2Tree(tester, maxAttempts: 3);
      dirty.elementEditController.bringForward(
        elementMPIDs: <int>[dirty.th2File.mpIDByTHID('p1')!],
      );
      dirty.close();
      await tester.pump();

      expect(dirty.isDisposed, isTrue);

      final TH2FileEditController? reloaded = await settleTH2Load(tester, path);

      expect(reloaded, isNot(same(dirty)));
      expect(reloaded!.enableSaveButton, isFalse);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      await tester.tap(chevronOf(aNode));
      await tester.pump();
      mpLocator.mpGeneralController.addFileTab(path);
      await settleTH2Tree(tester, maxAttempts: 3);
      reloaded.close();
      await tester.pump();

      expect(reloaded.isDisposed, isTrue);
      expect(controllerOf(path), isNull);
    });
  });

  group('presentation', () {
    testWidgets('rows show their icons', (WidgetTester tester) async {
      final TH2TreeTestProject project = await openAndExpandA(tester);
      final String path = project.pathOf('a.th2');

      expect(
        find.descendant(
          of: elementRow(path, 's1'),
          matching: find.byIcon(Icons.map_outlined),
        ),
        findsOneWidget,
      );

      for (final (String, String) entry in <(String, String)>[
        ('p1', mpAddPointButtonImagePath),
        ('l1', mpAddLineButtonImagePath),
      ]) {
        final Image image = tester.widget<Image>(
          find.descendant(
            of: elementRow(path, entry.$1),
            matching: find.byType(Image),
          ),
        );

        expect((image.image as AssetImage).assetName, entry.$2);
      }
    });

    testWidgets('PT strings are used for status rows, badge and menu', (
      WidgetTester tester,
    ) async {
      final TH2TreeTestProject project = newProject(
        aContents: th2TreeBrokenContents,
      );

      await pumpApp(tester, locale: const Locale('pt'));
      await openTH2TreeProject(tester, project);

      final TH2FileNode aNode = th2NodeOf(project, 'a.th2');

      await tester.tap(chevronOf(aNode));
      await tester.pump();

      expect(find.text('Carregando…'), findsOneWidget);

      await settleTH2Load(tester, project.pathOf('a.th2'));

      expect(
        find.text('Arquivo com problemas: corrija-o fora do Mapiah e recarregue'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Tooltip>(
              find.byKey(ValueKey('THProjectTreeNodeBrokenBadge|${aNode.id}')),
            )
            .message,
        startsWith('2 problemas\nLinha 2: '),
      );
      expect(
        tester
            .widget<Tooltip>(
              find.byKey(const ValueKey('THProjectTreeHeaderDrawingOrderTooltip')),
            )
            .message,
        startsWith('As linhas seguem a ordem do arquivo'),
      );

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${aNode.id}')),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Recarregar'), findsOneWidget);
    });
  });
}
