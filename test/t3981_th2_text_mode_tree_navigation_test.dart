// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/th2_file_edit_bottom_status_bar_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'th2_element_tree_test_aux.dart';
import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

int _lineOf(String text, String fragment) =>
    text.split('\n').indexWhere((String line) => line.contains(fragment));

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(() async {
    await TH2TextModeTestAux.setUp();
    locator.thProjectTreeUIController.setFilterText('');
    locator.thProjectTreeUIController.expandedNodeIds.clear();
    locator.thProjectTreeUIController.expandedTH2ScrapIds.clear();
    locator.thProjectTreeUIController.setSidebarCollapsed(false);
  });

  group('moveTextCursorToElement', () {
    test('moves to the element line through edits, without touching the '
        'canvas', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        th2TreeValidContents,
      );
      final int s1 = controller.th2File.mpIDByTHID('s1')!;
      final THElement p3 = controller.th2File.elementByTHID('p3');

      controller.setActiveScrap(s1);
      controller.selectionController.setSelectedElements(<THElement>[
        controller.th2File.elementByTHID('p1'),
      ], setState: true);

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );
      final Set<int> selectedBefore = controller
          .selectionController
          .mpSelectedElementsLogical
          .keys
          .toSet();

      controller.moveTextCursorToElement(p3.mpID);

      final int p3Line = _lineOf(th2TreeValidContents, '-id p3');

      expect(session.pendingScrollToLine, p3Line);
      expect(
        th2TreeValidContents
            .substring(session.pendingSelectionRange!.start)
            .startsWith('point 3 3'),
        isTrue,
      );
      expect(session.pendingSelectionRequestsFocus, isTrue);

      /// Two lines added above it.
      final String edited = th2TreeValidContents.replaceFirst(
        'scrap s1 -projection plan\n',
        'scrap s1 -projection plan\n# one\n# two\n',
      );

      TH2TextModeTestAux.edit(controller, edited);
      controller.moveTextCursorToElement(p3.mpID, requestFocus: false);
      expect(session.pendingScrollToLine, p3Line + 2);
      expect(session.pendingSelectionRequestsFocus, isFalse);

      /// Its own first line edited: the nearest unedited line above.
      final String ownLineEdited = edited.replaceFirst(
        'point 3 3 station',
        'point 3 4 station',
      );

      TH2TextModeTestAux.edit(controller, ownLineEdited);
      controller.moveTextCursorToElement(p3.mpID);
      expect(session.pendingScrollToLine, p3Line + 1);

      /// A scrap row puts it on the scrap line.
      controller.moveTextCursorToElement(
        controller.th2File.mpIDByTHID('s2')!,
      );
      expect(
        session.pendingScrollToLine,
        _lineOf(ownLineEdited, 'scrap s2'),
      );

      expect(controller.activeScrapID, s1);
      expect(
        controller.selectionController.mpSelectedElementsLogical.keys.toSet(),
        selectedBefore,
      );
    });

    test('does nothing while an operation runs', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        th2TreeValidContents,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );
      final Completer<void> busy = Completer<void>();
      final Future<void> pending = controller.runGatedOperation<void>(
        () => busy.future,
      );

      controller.moveTextCursorToElement(
        controller.th2File.mpIDByTHID('p3')!,
      );
      expect(session.pendingScrollToLine, isNull);
      busy.complete();
      await pending;
    });

    test('eye buttons work in text mode without touching the session or the '
        'active scrap', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        th2TreeValidContents,
      );
      final int s1 = controller.th2File.mpIDByTHID('s1')!;
      final int s2 = controller.th2File.mpIDByTHID('s2')!;

      controller.setActiveScrap(s1);

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );
      final int revision = session.sessionRevision;

      controller.hideElementController.toggleScrapVisibility(s2);
      expect(controller.hideElementController.isScrapVisible(s2), isFalse);
      controller.hideElementController.toggleScrapVisibility(s1);
      expect(controller.hideElementController.isScrapVisible(s1), isTrue);
      expect(controller.activeScrapID, s1);
      expect(session.sessionRevision, revision);
      expect(session.content, th2TreeValidContents);
    });
  });

  group('workspace', () {
    late TH2TreeTestProject project;

    setUp(() {
      project = TH2TreeTestProject.create();
      addTearDown(project.delete);
    });

    Future<TH2FileEditController> pumpWorkspace(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(buildTH2TreeTestApp());
      await openTH2TreeProject(tester, project);
      await tester.tap(
        find.byKey(
          ValueKey(
            'THProjectTreeNodeChevron|${th2NodeOf(project, 'a.th2').id}',
          ),
        ),
      );
      await tester.pump();

      final TH2FileEditController controller = (await settleTH2Load(
        tester,
        project.pathOf('a.th2'),
      ))!;

      expandTH2TreeScraps(project.pathOf('a.th2'));
      locator.mpGeneralController.addFileTab(project.pathOf('a.th2'));
      await tester.pumpAndSettle();

      return controller;
    }

    Finder row(TH2FileEditController controller, String thID) {
      final int id = controller.th2File.mpIDByTHID(thID)!;

      return find.byKey(
        ValueKey(
          'TH2ElementTreeRowWidget|'
          '${th2ElementTreeRowId(th2FilePath: project.pathOf('a.th2'), elementMPID: id)}',
        ),
      );
    }

    Future<void> pressF2(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    testWidgets('F2 and the buttons switch modes; text mode hides the canvas '
        'widgets', (WidgetTester tester) async {
      final TH2FileEditController controller = await pumpWorkspace(tester);

      expect(find.byType(TH2FileEditBottomStatusBarWidget), findsOneWidget);
      controller.th2FileFocusNode.requestFocus();
      await tester.pump();
      await pressF2(tester);
      expect(controller.editMode, TH2EditMode.text);
      expect(find.byType(TH2FileEditBottomStatusBarWidget), findsNothing);
      expect(controller.textEditController!.textFieldFocusNode.hasFocus, isTrue);

      /// F2 from the text field.
      await pressF2(tester);
      expect(controller.editMode, TH2EditMode.canvas);
      expect(find.byType(TH2FileEditBottomStatusBarWidget), findsOneWidget);

      await tester.tap(
        find.byTooltip(locator.appLocalizations.th2EditModeTextTooltip),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(controller.editMode, TH2EditMode.text);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('TH2TextEditBodyWidget|CanvasButton'),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(controller.editMode, TH2EditMode.canvas);
    });

    testWidgets('a tree click moves the cursor and focuses the field; the '
        'context menu moves it without focus and gives it back on close', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController controller = await pumpWorkspace(tester);
      final int s1 = controller.th2File.mpIDByTHID('s1')!;

      controller.setActiveScrap(s1);
      controller.th2FileFocusNode.requestFocus();
      await tester.pump();
      await pressF2(tester);

      final TH2TextEditController session = controller.textEditController!;

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(row(controller, 'p2'));
      await tester.pumpAndSettle();

      expect(session.cursorLine, _lineOf(th2TreeValidContents, '-id p2'));
      expect(session.textFieldFocusNode.hasFocus, isTrue);
      expect(controller.activeScrapID, s1);
      expect(controller.selectionController.mpSelectedElementsLogical, isEmpty);

      /// Typed keys reach the buffer.
      tester.testTextInput.enterText('$th2TreeValidContents# typed\n');
      await tester.pump();
      expect(session.content, endsWith('# typed\n'));

      /// The context menu.
      await tester.tap(row(controller, 'p1'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(session.cursorLine, _lineOf(th2TreeValidContents, '-id p1'));
      expect(
        find.byKey(
          ValueKey(
            'THProjectTreeRowContextMenuCopy|'
            '${th2ElementTreeRowId(th2FilePath: project.pathOf('a.th2'), elementMPID: controller.th2File.mpIDByTHID('p1')!)}',
          ),
        ),
        findsOneWidget,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(session.textFieldFocusNode.hasFocus, isTrue);
      expect(controller.selectionController.mpSelectedElementsLogical, isEmpty);
    });

    testWidgets('closing a tab in text mode reopens it on the canvas', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController controller = await pumpWorkspace(tester);

      controller.th2FileFocusNode.requestFocus();
      await tester.pump();
      await pressF2(tester);
      expect(controller.editMode, TH2EditMode.text);

      controller.close();
      await tester.pumpAndSettle();
      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.textEditController!.isOpen, isFalse);

      final TH2FileEditController reopened = locator.mpGeneralController
          .getTH2FileEditController(filename: project.pathOf('a.th2'));

      locator.mpGeneralController.addFileTab(project.pathOf('a.th2'));
      await settleTH2Load(tester, project.pathOf('a.th2'));
      await tester.pumpAndSettle();
      expect(reopened.editMode, TH2EditMode.canvas);
    });
  });
}
