// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
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

  T firstWhere<T extends THProjectNode>(THProjectNode root) {
    final List<THProjectNode> nodes = <THProjectNode>[];

    void visit(THProjectNode node) {
      nodes.add(node);

      for (final THProjectNode child in node.children) {
        visit(child);
      }
    }

    visit(root);

    return nodes.firstWhere((THProjectNode node) => node is T) as T;
  }

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.closeProject();

    final THProjectTreeUIController uiController =
        mpLocator.thProjectTreeUIController;

    uiController.setFilterText('');
    uiController.expandedNodeIds.clear();
    uiController.setSidebarCollapsed(false);
  });

  testWidgets('tapping a THDataFileNode opens a text-editor tab with no '
      'pending scroll', (WidgetTester tester) async {
    final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

    mpLocator.thProjectController.projectRootNode = root;

    final THDataFileNode dataFileNode = firstWhere<THDataFileNode>(root);

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    await tester.tap(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${dataFileNode.id}')),
    );
    await tester.pump();

    expect(
      mpLocator.mpGeneralController.openFileOrder,
      contains(dataFileNode.absolutePath),
    );

    final THTextEditorController? controller = mpLocator.mpGeneralController
        .getTextEditorControllerIfExists(dataFileNode.absolutePath);

    expect(controller, isNotNull);
    expect(controller!.pendingScrollToLine, isNull);
  });

  testWidgets('tapping THMissingFileNode is a no-op', (
    WidgetTester tester,
  ) async {
    final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

    mpLocator.thProjectController.projectRootNode = root;

    final THMissingFileNode missingNode = firstWhere<THMissingFileNode>(root);

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    await tester.tap(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${missingNode.id}')),
    );
    await tester.pump();

    expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    expect(
      mpLocator.thProjectController.activeSelectedNodeId,
      missingNode.id,
    );
  });

  testWidgets(
    'tapping a logical node opens the containing file tab with a pending '
    'scroll target',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('mixed-logical/cave.th').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final THSurveyNode surveyNode = firstWhere<THSurveyNode>(root);

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${surveyNode.id}')),
      );
      await tester.pump();

      expect(
        mpLocator.mpGeneralController.openFileOrder,
        contains(surveyNode.sourceFilePath),
      );

      final THTextEditorController? controller = mpLocator.mpGeneralController
          .getTextEditorControllerIfExists(surveyNode.sourceFilePath);

      expect(controller, isNotNull);
      expect(controller!.pendingScrollToLine, surveyNode.lineNumber - 1);
    },
  );

  testWidgets(
    'tapping the file node itself (as opposed to a logical child) opens '
    'with no pending scroll',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('mixed-logical/cave.th').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeWidget|${root.id}')),
      );
      await tester.pump();

      final THTextEditorController? controller = mpLocator.mpGeneralController
          .getTextEditorControllerIfExists(root.absolutePath);

      expect(controller, isNotNull);
      expect(controller!.pendingScrollToLine, isNull);
    },
  );

  testWidgets('tapping a THCentrelineNode opens with a pending scroll '
      'target too', (WidgetTester tester) async {
    final THProjectFileNode root = loadFixture('mixed-logical/cave.th').rootNode;

    mpLocator.thProjectController.projectRootNode = root;

    final THCentrelineNode centrelineNode = firstWhere<THCentrelineNode>(root);

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    await tester.tap(
      find.byKey(ValueKey('THProjectTreeNodeWidget|${centrelineNode.id}')),
    );
    await tester.pump();

    final THTextEditorController? controller = mpLocator.mpGeneralController
        .getTextEditorControllerIfExists(centrelineNode.sourceFilePath);

    expect(controller, isNotNull);
    expect(controller!.pendingScrollToLine, centrelineNode.lineNumber - 1);
  });
}
