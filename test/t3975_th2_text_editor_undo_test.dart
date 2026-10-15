// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_buffer.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'auxiliary/th2_text_edit_fake_owner.dart';
import 'th_test_aux.dart';

/// Longer than Flutter's native undo grouping and initial recording window.
/// Immediate first edits, made before the initial snapshot is recorded, are
/// the parent plan's Phase 7 TODO and are not checked here.
const Duration _historyWindow = Duration(milliseconds: 600);

const Duration _idle = Duration(
  milliseconds: mpTH2TextValidationIdleMilliseconds,
);

const ValueKey<String> _textFieldKey = ValueKey<String>(
  'THTextEditorWidget|TextField',
);

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();
  final List<TH2TextEditController> th2Controllers = <TH2TextEditController>[];

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
  });

  tearDown(() {
    for (final TH2TextEditController controller in th2Controllers) {
      controller.dispose();
    }
    th2Controllers.clear();
  });

  TH2TextEditController th2Controller(
    String content,
    TH2TextEditFakeOwner owner,
  ) {
    final TH2TextEditController controller = th2TextEditControllerWithSession(
      owner,
      content,
    );

    th2Controllers.add(controller);

    return controller;
  }

  Future<void> pumpEditor(WidgetTester tester, THTextEditorBuffer buffer) async {
    await tester.binding.setSurfaceSize(const Size(800, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: THTextEditorWidget(controller: buffer)),
      ),
    );
    await tester.pump();
  }

  Finder editableText() => find.descendant(
    of: find.byKey(_textFieldKey),
    matching: find.byType(EditableText),
  );

  TextEditingController fieldController(WidgetTester tester) =>
      tester.widget<EditableText>(editableText()).controller;

  ScrollPosition fieldScroll(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byKey(_textFieldKey),
          matching: find.byType(Scrollable),
        ),
      )
      .position;

  /// Focuses the main field and lets the initial history window elapse.
  Future<void> focusField(WidgetTester tester, THTextEditorBuffer buffer) async {
    buffer.textFieldFocusNode.requestFocus();
    await tester.pump();
    await tester.pump(_historyWindow);
  }

  /// Types [value] as the platform text input does, then lets the history
  /// group close.
  Future<void> type(WidgetTester tester, TextEditingValue value) async {
    tester.testTextInput.updateEditingValue(value);
    await tester.pump();
    await tester.pump(_historyWindow);
  }

  Future<bool> ctrlZ(WidgetTester tester, {bool shift = false, bool meta = false}) async {
    final LogicalKeyboardKey modifier = meta
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;

    await tester.sendKeyDownEvent(modifier);
    if (shift) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    }

    final bool isHandled = await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);

    if (shift) {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    }
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
    await tester.pump(_historyWindow);

    return isHandled;
  }

  TextEditingValue value(String text, int offset) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
  );

  group('text history', () {
    testWidgets('restores exact text, endings and selection', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner(
        defaultLineEnding: '\r\n',
      );
      final TH2TextEditController controller = th2Controller(
        'scrap s\r\nendscrap',
        owner,
      );

      await pumpEditor(tester, controller);
      await focusField(tester, controller);

      final List<TextEditingValue> values = <TextEditingValue>[
        fieldController(tester).value,
      ];

      /// Typing.
      await type(tester, value('scrap sx\r\nendscrap', 8));
      values.add(fieldController(tester).value);

      /// Paste with a LF.
      await type(tester, value('scrap sx\r\nendscrap\nab', 21));
      values.add(fieldController(tester).value);

      /// Enter.
      fieldController(tester).selection = const TextSelection.collapsed(
        offset: 8,
      );
      await tester.pump(_historyWindow);
      values.add(fieldController(tester).value);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(_historyWindow);
      expect(controller.content, 'scrap sx\r\n  \r\nendscrap\nab');
      values.add(fieldController(tester).value);

      /// Indentation.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(_historyWindow);
      values.add(fieldController(tester).value);

      /// Replace and Replace All.
      controller.find.setFindQuery('ab');
      controller.find.setReplaceQuery('cd');
      controller.find.openFindBar();
      controller.find.replaceActiveMatch();
      await tester.pump();
      await tester.pump(_historyWindow);
      values.add(fieldController(tester).value);
      controller.find.setFindQuery('scrap');
      controller.find.setReplaceQuery('SCRAP');
      controller.find.replaceAllMatches();
      await tester.pump();
      await tester.pump(_historyWindow);
      values.add(fieldController(tester).value);
      controller.find.closeFindBar();
      await tester.pump();
      controller.textFieldFocusNode.requestFocus();
      await tester.pump();

      /// Invalid syntax.
      await type(tester, value('${controller.content}"open', controller.content.length + 5));
      values.add(fieldController(tester).value);

      /// Committed IME input.
      final String beforeIME = controller.content;

      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: '${beforeIME}ka',
          selection: TextSelection.collapsed(offset: beforeIME.length + 2),
          composing: TextRange(start: beforeIME.length, end: beforeIME.length + 2),
        ),
      );
      await tester.pump();
      await type(tester, value('$beforeIMEか', beforeIME.length + 1));
      values.add(fieldController(tester).value);

      expect(controller.hasTextEdits, isTrue);

      final Set<String> distinct = <String>{
        for (final TextEditingValue v in values) v.text,
      };

      expect(distinct.length, greaterThan(6));

      /// Undo walks back through every recorded value.
      for (int index = values.length - 2; index >= 0; index--) {
        if (values[index].text == values[index + 1].text) {
          continue;
        }

        await ctrlZ(tester);
        expect(controller.content, values[index].text, reason: '$index');
        expect(fieldController(tester).text, values[index].text);
      }

      expect(controller.content, 'scrap s\r\nendscrap');
      expect(controller.hasTextEdits, isTrue);
      expect(controller.isDirty, isFalse);

      /// Exhausted text history never reaches the canvas.
      await ctrlZ(tester);
      expect(owner.canvasHistoryRequests, isEmpty);

      /// Redo walks forward again.
      await ctrlZ(tester, shift: true);
      expect(controller.content, 'scrap sx\r\nendscrap');
      expect(
        fieldController(tester).selection,
        const TextSelection.collapsed(offset: 8),
      );
      await tester.pump(_idle);
    });

    testWidgets('selection changes add no edit', (WidgetTester tester) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller(
        'scrap s\nendscrap\n',
        owner,
      );

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      fieldController(tester).selection = const TextSelection(
        baseOffset: 2,
        extentOffset: 5,
      );
      await tester.pump(_historyWindow);
      expect(controller.hasTextEdits, isFalse);

      await ctrlZ(tester);
      expect(owner.canvasHistoryRequests, <bool>[false]);
      expect(controller.content, 'scrap s\nendscrap\n');
    });
  });

  group('routing', () {
    testWidgets('each shortcut routes once before and after the first edit', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller('scrap s\n', owner);

      await pumpEditor(tester, controller);
      await focusField(tester, controller);

      expect(await ctrlZ(tester), isTrue);
      expect(await ctrlZ(tester, meta: true), isTrue);
      expect(await ctrlZ(tester, shift: true), isTrue);
      expect(await ctrlZ(tester, shift: true, meta: true), isTrue);
      expect(owner.canvasHistoryRequests, <bool>[false, false, true, true]);
      expect(controller.content, 'scrap s\n');

      await type(tester, value('scrap sx\n', 8));
      await type(tester, value('scrap sxy\n', 9));
      expect(await ctrlZ(tester), isTrue);
      expect(controller.content, 'scrap sx\n');
      expect(await ctrlZ(tester, meta: true), isTrue);
      expect(controller.content, 'scrap s\n');
      expect(await ctrlZ(tester, shift: true), isTrue);
      expect(controller.content, 'scrap sx\n');
      expect(await ctrlZ(tester, shift: true, meta: true), isTrue);
      expect(controller.content, 'scrap sxy\n');
      expect(owner.canvasHistoryRequests, hasLength(4));
      await tester.pump(_idle);
    });

    testWidgets('dispatched standard intents reach the TH2 handler once', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller('scrap s\n', owner);

      await pumpEditor(tester, controller);
      await focusField(tester, controller);

      final BuildContext fieldContext = tester.element(editableText());

      Actions.invoke(
        fieldContext,
        const UndoTextIntent(SelectionChangedCause.keyboard),
      );
      Actions.invoke(
        fieldContext,
        const RedoTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pump();
      expect(owner.canvasHistoryRequests, <bool>[false, true]);

      await type(tester, value('scrap sx\n', 8));
      Actions.invoke(
        tester.element(editableText()),
        const UndoTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pump();
      await tester.pump(_historyWindow);
      expect(controller.content, 'scrap s\n');
      expect(owner.canvasHistoryRequests, hasLength(2));

      /// Locked standard intents do nothing.
      Actions.invoke(
        tester.element(editableText()),
        const RedoTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pump();
      await tester.pump(_historyWindow);
      expect(controller.content, 'scrap sx\n');
      owner.acquireBufferLock();
      await tester.pump();
      Actions.invoke(
        tester.element(editableText()),
        const UndoTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pump();
      await tester.pump(_historyWindow);
      expect(controller.content, 'scrap sx\n');
      await tester.pump(_idle);
    });

    testWidgets('locked, refused or failing canvas requests are consumed', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller('scrap s\n', owner);

      await pumpEditor(tester, controller);
      await focusField(tester, controller);

      /// An empty canvas stack: the owner does nothing.
      expect(await ctrlZ(tester), isTrue);

      /// A failing request is logged, not thrown.
      owner.onCanvasHistory = (bool redo) async =>
          throw StateError('traversal failed');
      expect(await ctrlZ(tester), isTrue);
      expect(tester.takeException(), isNull);

      /// Locked: nothing reaches the owner or the text.
      owner.acquireBufferLock();
      await tester.pump();
      expect(await ctrlZ(tester), isTrue);
      expect(await ctrlZ(tester, shift: true), isTrue);
      expect(owner.canvasHistoryRequests, <bool>[false, false]);
      expect(controller.content, 'scrap s\n');
      expect(fieldController(tester).text, 'scrap s\n');

      /// Recovery read-only after a text edit: native history is not used.
      owner.releaseBufferLock();
      await tester.pump();
      await type(tester, value('scrap sx\n', 8));
      controller.enterRecoveryReadOnly();
      await tester.pump();
      expect(await ctrlZ(tester), isTrue);
      expect(controller.content, 'scrap sx\n');
      expect(fieldController(tester).text, 'scrap sx\n');
    });

    testWidgets('find and replace fields keep their own histories', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller('scrap s\n', owner);

      await pumpEditor(tester, controller);
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindButton')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindToggleReplaceButton')),
      );
      await tester.pump();

      for (final bool afterFirstEdit in <bool>[false, true]) {
        if (afterFirstEdit) {
          controller.setContent('scrap sx\n');
          await tester.pump();
        }

        for (final String field in <String>['FindField', 'ReplaceField']) {
          final Finder finder = find.byKey(ValueKey('THTextEditorWidget|$field'));

          await tester.tap(finder);
          await tester.pump(_historyWindow);
          await tester.enterText(finder, 'a');
          await tester.pump(_historyWindow);
          await tester.enterText(finder, 'ab');
          await tester.pump(_historyWindow);
          await ctrlZ(tester);
          expect(
            tester.widget<TextField>(finder).controller!.text,
            'a',
            reason: '$field $afterFirstEdit',
          );
        }
      }

      expect(owner.canvasHistoryRequests, isEmpty);
      expect(controller.content, 'scrap sx\n');
      await tester.pump(_idle);
    });
  });

  group('baseline', () {
    testWidgets('a new baseline clears native history and keeps the UI', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final StringBuffer long = StringBuffer();

      for (int index = 0; index < 80; index++) {
        long.write('point $index $index x\n');
      }

      final String text = long.toString();
      final TH2TextEditController controller = th2Controller(text, owner);

      await pumpEditor(tester, controller);
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindButton')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindToggleReplaceButton')),
      );
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        'point 7',
      );
      await tester.enterText(
        find.byKey(const ValueKey('THTextEditorWidget|ReplaceField')),
        'pt',
      );
      await focusField(tester, controller);
      await type(tester, value('x$text', 1));
      expect(controller.hasTextEdits, isTrue);

      fieldScroll(tester).jumpTo(300);
      await tester.pump();

      final int baseline = controller.baselineRevision;

      controller.installBaseline(
        TH2TextEditBaseline(content: text, lineMap: controller.initialLineMap),
      );
      await tester.pump();
      await tester.pump();

      expect(controller.baselineRevision, baseline + 1);
      expect(controller.hasTextEdits, isFalse);
      expect(fieldController(tester).text, text);
      expect(fieldScroll(tester).pixels, 300);
      expect(controller.lastScrollOffset, 300);
      expect(controller.textFieldFocusNode.hasFocus, isTrue);
      expect(controller.find.isFindBarVisible, isTrue);
      expect(controller.find.findQuery, 'point 7');
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('THTextEditorWidget|ReplaceField')),
            )
            .controller!
            .text,
        'pt',
      );

      /// Before the first edit of the new baseline, undo goes to the canvas.
      await tester.pump(_historyWindow);
      expect(await ctrlZ(tester), isTrue);
      expect(owner.canvasHistoryRequests, <bool>[false]);
      expect(controller.content, text);

      /// The new native history never returns to the old baseline's edits.
      await type(tester, value('y$text', 1));
      await ctrlZ(tester);
      expect(controller.content, text);
      await ctrlZ(tester);
      expect(controller.content, text);
      expect(owner.canvasHistoryRequests, <bool>[false]);
      await tester.pump(_idle);
    });

    testWidgets('a baseline with a selection lands on it after the remount', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final StringBuffer long = StringBuffer();

      for (int index = 0; index < 80; index++) {
        long.write('point $index $index x\n');
      }

      final String text = long.toString();
      final TH2TextEditController controller = th2Controller('', owner);

      await pumpEditor(tester, controller);

      final int target = text.indexOf('point 60 ');

      controller.installBaseline(
        TH2TextEditBaseline(
          content: text,
          lineMap: controller.initialLineMap,
          cursorLine: 60,
          selection: TextRange(start: target, end: target + 5),
          selectionRequestsFocus: false,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        fieldController(tester).selection,
        TextSelection(baseOffset: target, extentOffset: target + 5),
      );
      expect(fieldScroll(tester).pixels, greaterThan(0));
      expect(controller.pendingSelectionRange, isNull);
      expect(controller.textFieldFocusNode.hasFocus, isFalse);
    });
  });

  group('project editors', () {
    testWidgets('keep their native undo', (WidgetTester tester) async {
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      addTearDown(controller.dispose);
      controller.setContent('survey a\n');
      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      await type(tester, value('survey ab\n', 9));
      expect(controller.content, 'survey ab\n');

      expect(await ctrlZ(tester), isTrue);
      expect(controller.content, 'survey a\n');
      expect(await ctrlZ(tester, shift: true), isTrue);
      expect(controller.content, 'survey ab\n');
    });
  });
}
