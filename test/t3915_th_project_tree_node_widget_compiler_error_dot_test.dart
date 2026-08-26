// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
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

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  testWidgets(
    'a compiler diagnostic on a THDataFileNode shows the error dot with '
    'the combined (parse + compiler) count',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final THDataFileNode dataFileNode = firstWhere<THDataFileNode>(root);

      expect(
        dataFileNode.parseErrors,
        isEmpty,
        reason: 'cave.th itself has no static parse errors in this fixture',
      );

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'compiler error 1',
            severity: THProjectParseErrorSeverity.error,
            filePath: dataFileNode.absolutePath,
            lineNumber: 1,
          ),
          THProjectParseError(
            message: 'compiler error 2',
            severity: THProjectParseErrorSeverity.error,
            filePath: dataFileNode.absolutePath,
            lineNumber: 2,
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      final Finder dotFinder = find.byKey(
        ValueKey('THProjectTreeNodeErrorDot|${dataFileNode.id}'),
      );

      expect(dotFinder, findsOneWidget);

      final Tooltip tooltip = tester.widget<Tooltip>(
        find.descendant(of: dotFinder, matching: find.byType(Tooltip)),
      );

      expect(tooltip.message, '2');
    },
  );

  testWidgets(
    'a compiler diagnostic on a THConfigFileNode with no static parse '
    'errors still shows the dot',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      expect(root, isA<THConfigFileNode>());
      expect(root.parseErrors, isEmpty);

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'compiler error in thconfig',
            severity: THProjectParseErrorSeverity.error,
            filePath: root.absolutePath,
            lineNumber: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(
        find.byKey(ValueKey('THProjectTreeNodeErrorDot|${root.id}')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a TH2FileNode compiler diagnostic does not gain a dot',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('mixed-logical/cave.th').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final TH2FileNode th2Node = firstWhere<TH2FileNode>(root);

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'diagnostic on a th2 file',
            severity: THProjectParseErrorSeverity.error,
            filePath: th2Node.absolutePath,
            lineNumber: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(
        find.byKey(ValueKey('THProjectTreeNodeErrorDot|${th2Node.id}')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'a logical child node does not gain a dot from a compiler diagnostic '
    'in its containing file',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('mixed-logical/cave.th').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final THSurveyNode surveyNode = firstWhere<THSurveyNode>(root);

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'diagnostic in the containing file',
            severity: THProjectParseErrorSeverity.error,
            filePath: surveyNode.sourceFilePath,
            lineNumber: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(
        find.byKey(ValueKey('THProjectTreeNodeErrorDot|${surveyNode.id}')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'tapping the dot selects the file node, opens its text-editor tab, and '
    'scrolls to the first compiler diagnostic when one exists',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final THDataFileNode dataFileNode = firstWhere<THDataFileNode>(root);

      // Give the node a static parse error too, so the test can prove the
      // compiler diagnostic's line -- not the parse error's -- wins.
      dataFileNode.parseErrors.add(
        const THProjectParseError(
          message: 'static parse error',
          severity: THProjectParseErrorSeverity.error,
          filePath: '',
          lineNumber: 99,
        ),
      );

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'compiler error',
            severity: THProjectParseErrorSeverity.error,
            filePath: dataFileNode.absolutePath,
            lineNumber: 5,
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeErrorDot|${dataFileNode.id}')),
      );
      await tester.pump();

      expect(
        mpLocator.thProjectController.activeSelectedNodeId,
        dataFileNode.id,
      );
      expect(
        mpLocator.mpGeneralController.openFileOrder,
        contains(dataFileNode.absolutePath),
      );

      final THTextEditorController? controller = mpLocator.mpGeneralController
          .getTextEditorControllerIfExists(dataFileNode.absolutePath);

      expect(controller, isNotNull);
      // scrollToLine stores a 0-based pendingScrollToLine.
      expect(controller!.pendingScrollToLine, 4);
    },
  );

  testWidgets(
    'tapping the dot scrolls to the first parse error when there is no '
    'compiler diagnostic',
    (WidgetTester tester) async {
      final THProjectFileNode root = loadFixture('missing-file/thconfig').rootNode;

      mpLocator.thProjectController.projectRootNode = root;

      final THDataFileNode dataFileNode = firstWhere<THDataFileNode>(root);

      dataFileNode.parseErrors.add(
        const THProjectParseError(
          message: 'static parse error',
          severity: THProjectParseErrorSeverity.error,
          filePath: '',
          lineNumber: 12,
        ),
      );

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(
        find.byKey(ValueKey('THProjectTreeNodeErrorDot|${dataFileNode.id}')),
      );
      await tester.pump();

      final THTextEditorController? controller = mpLocator.mpGeneralController
          .getTextEditorControllerIfExists(dataFileNode.absolutePath);

      expect(controller, isNotNull);
      expect(controller!.pendingScrollToLine, 11);
    },
  );
}
