// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/widgets/th_project_tree_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

void main() {
  final MPLocator mpLocator = MPLocator();

  String fixturePath(String relativePath) {
    return p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      'th_project',
      relativePath,
    );
  }

  THProjectLoadResult loadFixture(String relativePath) {
    return THProjectParser.loadProject(fixturePath(relativePath));
  }

  Widget buildTestApp() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: THProjectTreeWidget()),
    );
  }

  THProjectNode firstWhere<T extends THProjectNode>(THProjectNode root) {
    final List<THProjectNode> nodes = <THProjectNode>[];

    void visit(THProjectNode node) {
      nodes.add(node);

      for (final THProjectNode child in node.children) {
        visit(child);
      }
    }

    visit(root);

    return nodes.firstWhere((THProjectNode node) => node is T);
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.thProjectController.closeProject();

    final THProjectTreeUIController uiController =
        mpLocator.thProjectTreeUIController;

    uiController.setFilterText('');
    uiController.expandedNodeIds.clear();
    uiController.setSidebarCollapsed(false);
  });

  testWidgets('shows the empty state and Open Project button without a project', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(
      find.byKey(const ValueKey('THProjectTreeOpenProjectButton')),
      findsOneWidget,
    );
    expect(find.text('No project open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a fixture tree and supports expand/collapse/selection', (
    WidgetTester tester,
  ) async {
    final THProjectFileNode root =
        loadFixture('mixed-logical/cave.th').rootNode;

    mpLocator.thProjectController.projectRootNode = root;

    final THSurveyNode surveyNode =
        firstWhere<THSurveyNode>(root) as THSurveyNode;
    final THProjectNode surveyChild = surveyNode.children.first;

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyNode.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyChild.id}')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(ValueKey('THProjectTreeNodeChevron|${surveyNode.id}')),
    );
    await tester.pump();

    expect(mpLocator.thProjectTreeUIController.isExpanded(surveyNode.id), isTrue);
    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyChild.id}')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyNode.id}')),
    );
    await tester.pump();

    expect(
      mpLocator.thProjectController.activeSelectedNodeId,
      surveyNode.id,
    );
  });

  testWidgets('renders dirty and error status dots', (
    WidgetTester tester,
  ) async {
    final THDataFileNode root =
        loadFixture('mixed-logical/cave.th').rootNode as THDataFileNode;

    mpLocator.thProjectController.projectRootNode = root;

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(
      find.byKey(ValueKey('THProjectTreeNodeDirtyDot|${root.id}')),
      findsNothing,
    );

    mpLocator.thProjectController.dirtyFilePaths.add(root.absolutePath);
    await tester.pump();

    expect(
      find.byKey(ValueKey('THProjectTreeNodeDirtyDot|${root.id}')),
      findsOneWidget,
    );

    mpLocator.thProjectController.dirtyFilePaths.remove(root.absolutePath);
    await tester.pump();

    expect(
      find.byKey(ValueKey('THProjectTreeNodeDirtyDot|${root.id}')),
      findsNothing,
    );
  });

  testWidgets('search narrows the tree and auto-expands ancestor chains', (
    WidgetTester tester,
  ) async {
    final THProjectFileNode root =
        loadFixture('mixed-logical/cave.th').rootNode;

    mpLocator.thProjectController.projectRootNode = root;

    final THSurveyNode surveyNode =
        firstWhere<THSurveyNode>(root) as THSurveyNode;
    final THScrapNode scrapNode =
        firstWhere<THScrapNode>(root) as THScrapNode;
    final THCentrelineNode centrelineNode =
        firstWhere<THCentrelineNode>(root) as THCentrelineNode;

    await tester.pumpWidget(buildTestApp());

    await tester.enterText(
      find.byKey(const ValueKey('THProjectTreeSearchField')),
      scrapNode.label,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${scrapNode.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyNode.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${centrelineNode.id}')),
      findsNothing,
    );
  });

  testWidgets('shows the loading strip while parsing', (
    WidgetTester tester,
  ) async {
    final THProjectFileNode root =
        loadFixture('mixed-logical/cave.th').rootNode;

    mpLocator.thProjectController.projectRootNode = root;
    mpLocator.thProjectController.isParsing = true;

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    mpLocator.thProjectController.isParsing = false;
  });
}
