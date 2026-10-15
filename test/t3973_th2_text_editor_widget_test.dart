// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_buffer.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/widgets/th_text_editor_diagnostic_marker_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_line_number_gutter_widget.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'auxiliary/th2_text_edit_fake_owner.dart';
import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

const double _lineHeight = mpTextEditorFontSize * mpTextEditorLineHeight;

const Duration _idle = Duration(
  milliseconds: mpTH2TextValidationIdleMilliseconds,
);

const ValueKey<String> _textFieldKey = ValueKey<String>(
  'THTextEditorWidget|TextField',
);

const ValueKey<String> _overlayKey = ValueKey<String>(
  'THTextEditorWidget|SyntaxOverlay',
);

/// A valid scrap with [pointCount] points, then [tail].
String _longText({int pointCount = 80, String tail = ''}) {
  final StringBuffer text = StringBuffer('encoding utf-8\nscrap s1\n');

  for (int index = 0; index < pointCount; index++) {
    text.write('  point $index $index station -id p$index\n');
  }
  text.write('endscrap\n$tail');

  return text.toString();
}

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();
  final List<TH2TextEditController> th2Controllers = <TH2TextEditController>[];
  final List<THTextEditorController> projectControllers =
      <THTextEditorController>[];
  Directory? tempDir;

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
  });

  tearDown(() {
    for (final TH2TextEditController controller in th2Controllers) {
      controller.dispose();
    }
    th2Controllers.clear();
    for (final THTextEditorController controller in projectControllers) {
      controller.cancelPendingReparse();
      controller.dispose();
    }
    projectControllers.clear();
    mpLocator.thProjectController.closeProject();

    final Directory? dir = tempDir;

    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  TH2TextEditController th2Controller(
    String content, {
    TH2TextEditFakeOwner? owner,
  }) {
    final TH2TextEditController controller = th2TextEditControllerWithSession(
      owner ?? TH2TextEditFakeOwner(),
      content,
    );

    th2Controllers.add(controller);

    return controller;
  }

  /// An unbound project text editor controller holding [content].
  THTextEditorController projectController(String content) {
    final THTextEditorController controller = THTextEditorController(
      projectController: mpLocator.thProjectController,
    );

    controller.setContent(content);
    projectControllers.add(controller);

    return controller;
  }

  Future<void> pumpEditor(
    WidgetTester tester,
    THTextEditorBuffer buffer, {
    List<Widget> leadingToolbarActions = const <Widget>[],
    Widget? extra,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Column(
            children: <Widget>[
              ?extra,
              Expanded(
                child: THTextEditorWidget(
                  key: ObjectKey(buffer),
                  controller: buffer,
                  leadingToolbarActions: leadingToolbarActions,
                ),
              ),
            ],
          ),
        ),
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

  RenderEditable renderEditable(WidgetTester tester) =>
      tester.state<EditableTextState>(editableText()).renderEditable;

  ScrollPosition fieldScroll(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byKey(_textFieldKey),
          matching: find.byType(Scrollable),
        ),
      )
      .position;

  ScrollPosition overlayScroll(WidgetTester tester) => tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byKey(_overlayKey),
          matching: find.byType(Scrollable),
        ),
      )
      .position;

  /// The overlay text's global top.
  double overlayTop(WidgetTester tester) => tester
      .renderObject<RenderBox>(
        find.descendant(
          of: find.byKey(_overlayKey),
          matching: find.byType(RichText),
        ),
      )
      .localToGlobal(Offset.zero)
      .dy;

  /// The global caret rectangle at [offset].
  Rect caretRect(WidgetTester tester, int offset) {
    final RenderEditable editable = renderEditable(tester);
    final Rect local = editable.getLocalRectForCaret(
      TextPosition(offset: offset),
    );

    return local.shift(editable.localToGlobal(Offset.zero));
  }

  Future<void> focusField(WidgetTester tester, THTextEditorBuffer buffer) async {
    buffer.textFieldFocusNode.requestFocus();
    await tester.pump();
  }

  Future<void> setSelection(WidgetTester tester, TextSelection selection) async {
    fieldController(tester).selection = selection;
    await tester.pump();
  }

  Future<void> shiftKey(
    WidgetTester tester,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
  }

  group('auto-indent openers', () {
    test('TH2 and project openers', () {
      expect(thTextEditorBlockOpeners(THTextEditorLanguage.th2), <String>{
        'scrap',
        'line',
        'area',
        'comment',
      });
      expect(thTextEditorBlockOpeners(THTextEditorLanguage.therion), <String>{
        'survey',
        'centreline',
        'map',
        'scrap',
        'layout',
      });
    });

    testWidgets('Enter indents after TH2 block openers', (
      WidgetTester tester,
    ) async {
      for (final (String line, String indent) in <(String, String)>[
        ('scrap s', '  '),
        ('  line wall', '    '),
        ('  AREA water', '    '),
        ('comment', '  '),
        ('  point 1 2 x', '  '),
        ('endscrap', ''),
      ]) {
        final TH2TextEditController controller = th2Controller(line);

        await pumpEditor(tester, controller);
        await focusField(tester, controller);
        await setSelection(
          tester,
          TextSelection.collapsed(offset: line.length),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(controller.content, '$line\n$indent', reason: line);
        await tester.pump(_idle);
      }
    });
  });

  group('Enter', () {
    testWidgets('every Enter variant inserts one line ending', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller('a');

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      await setSelection(tester, const TextSelection.collapsed(offset: 1));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
      await shiftKey(tester, LogicalKeyboardKey.enter);
      await shiftKey(tester, LogicalKeyboardKey.numpadEnter);
      await tester.pump();
      expect(controller.content, 'a\n\n\n\n');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'a\n\n\n\n\n\n');
      expect(fieldController(tester).selection.baseOffset, 7);
      await tester.pump(_idle);
    });

    testWidgets('Enter replaces the selection', (WidgetTester tester) async {
      final TH2TextEditController controller = th2Controller('scrap sXYZ');

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      await setSelection(
        tester,
        const TextSelection(baseOffset: 7, extentOffset: 10),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(controller.content, 'scrap s\n  ');
      expect(
        fieldController(tester).selection,
        const TextSelection.collapsed(offset: 10),
      );
      await tester.pump(_idle);
    });

    testWidgets('a CRLF file gets CRLF and no caret inside an ending', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller(
        'scrap s\r\nendscrap',
        owner: TH2TextEditFakeOwner(defaultLineEnding: '\r\n'),
      );

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      await setSelection(tester, const TextSelection.collapsed(offset: 7));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'scrap s\r\n  \r\nendscrap');
      expect(
        fieldController(tester).selection,
        const TextSelection.collapsed(offset: 11),
      );

      /// Between a CR and its LF, Enter goes before the CR.
      await setSelection(tester, const TextSelection.collapsed(offset: 12));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'scrap s\r\n  \r\n  \r\nendscrap');
      expect(
        fieldController(tester).selection,
        const TextSelection.collapsed(offset: 15),
      );
      await tester.pump(_idle);
    });

    testWidgets('pasted LF and CRLF keep their endings and get no indent', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller('scrap s');

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'scrap s\n',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      await tester.pump();
      expect(controller.content, 'scrap s\n');

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'scrap s\nx\r\n',
          selection: TextSelection.collapsed(offset: 11),
        ),
      );
      await tester.pump();
      expect(controller.content, 'scrap s\nx\r\n');
      await tester.pump(_idle);
    });

    testWidgets('Enter confirming an IME composition inserts no line', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller('scrap s');

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'scrap sab',
          selection: TextSelection.collapsed(offset: 9),
          composing: TextRange(start: 7, end: 9),
        ),
      );
      await tester.pump();
      expect(controller.content, 'scrap sab');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'scrap sab');

      /// A collapsed composing range doesn't block Enter.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'scrap sab',
          selection: TextSelection.collapsed(offset: 9),
          composing: TextRange(start: 9, end: 9),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'scrap sab\n  ');
      await tester.pump(_idle);
    });

    testWidgets('Enter in the find field still finds the next match', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller(
        'scrap a\nscrap b\n',
      );

      await pumpEditor(tester, controller);
      await tester.tap(find.byKey(const ValueKey('THTextEditorWidget|FindButton')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('THTextEditorWidget|FindField')),
        'scrap',
      );
      await tester.pump();
      expect(controller.find.activeMatchIndex, 0);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(controller.find.activeMatchIndex, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controller.content, 'scrap a\nscrap b\n');
      expect(controller.hasTextEdits, isFalse);
    });
  });

  group('read-only', () {
    testWidgets('mutations are refused and Replace buttons disabled', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller(
        'scrap s\n',
        owner: owner,
      );

      await pumpEditor(tester, controller);
      await tester.tap(find.byKey(const ValueKey('THTextEditorWidget|FindButton')));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|FindToggleReplaceButton')),
      );
      await tester.pump();
      controller.find.setFindQuery('scrap');
      controller.find.setReplaceQuery('point');
      owner.acquireBufferLock();
      await tester.pump();

      expect(tester.widget<TextField>(find.byKey(_textFieldKey)).readOnly, isTrue);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('THTextEditorWidget|ReplaceButton')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('THTextEditorWidget|ReplaceAllButton')),
            )
            .onPressed,
        isNull,
      );

      controller.find.replaceAllMatches();
      controller.find.replaceActiveMatch();
      await focusField(tester, controller);
      await setSelection(tester, const TextSelection.collapsed(offset: 7));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(controller.content, 'scrap s\n');
      expect(fieldController(tester).text, 'scrap s\n');

      /// Find and navigation stay available.
      controller.find.findNext();
      expect(controller.find.activeMatchIndex, isNotNull);
    });

    testWidgets('a key event between the lock and the next frame', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller = th2Controller(
        'scrap s\n',
        owner: owner,
      );

      await pumpEditor(tester, controller);
      await focusField(tester, controller);
      owner.acquireBufferLock();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'scrap sx\n',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(controller.content, 'scrap s\n');
      expect(fieldController(tester).text, 'scrap s\n');
      expect(controller.hasTextEdits, isFalse);
      await tester.pump();
      expect(fieldController(tester).text, 'scrap s\n');
    });

    testWidgets('a project editor puts a refused change back', (
      WidgetTester tester,
    ) async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');

      await tester.runAsync(
        () => mpLocator.thProjectController.openProject(thconfigPath),
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      projectControllers.add(controller);
      await controller.loadFile(thconfigPath);
      await pumpEditor(tester, controller);

      final String original = controller.content;

      mpLocator.thProjectController.closeProject();
      fieldController(tester).value = TextEditingValue(
        text: '${original}x',
        selection: TextSelection.collapsed(offset: original.length + 1),
      );
      expect(controller.content, original);
      expect(fieldController(tester).text, original);
    });
  });

  group('alignment', () {
    for (final bool isTH2 in <bool>[true, false]) {
      final String editor = isTH2 ? 'TH2' : 'project';

      testWidgets('$editor: text, caret, overlay and markers line up', (
        WidgetTester tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(800, 400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final String text = _longText(tail: 'endscrap\n');
        late final THTextEditorBuffer buffer;

        if (isTH2) {
          final TH2TextEditController controller = th2Controller(_longText());

          buffer = controller;
          controller.setContent(text);
        } else {
          tempDir = THProjectControllerTestAux.copyFixtureToTemp(
            'single-config',
          );

          final String thconfigPath = p.join(tempDir!.path, 'thconfig');

          await tester.runAsync(
            () => mpLocator.thProjectController.openProject(thconfigPath),
          );

          final THTextEditorController controller = THTextEditorController(
            projectController: mpLocator.thProjectController,
          );

          projectControllers.add(controller);
          await controller.loadFile(thconfigPath);
          controller.setContent(text);
          controller.cancelPendingReparse();
          mpLocator.thProjectController.applyTherionRunDiagnostics(
            <THProjectParseError>[
              THProjectParseError(
                message: 'compiler error',
                severity: THProjectParseErrorSeverity.error,
                filePath: THProjectPathResolver.canonicalize(thconfigPath),
                lineNumber: 83,
              ),
            ],
          );
          buffer = controller;
        }

        await pumpEditor(tester, buffer);
        await tester.pump(_idle);
        await tester.pump();

        final int errorLine = buffer.diagnostics.single.line!;
        final double lineHeight = renderEditable(tester).preferredLineHeight;
        final List<String> lines = text.split('\n');

        int lineStart(int line) => lines
            .take(line)
            .fold(0, (int offset, String text) => offset + text.length + 1);

        /// The caret of [line]'s first character is on [line]'s overlay row.
        void expectCaretOnRow(int line) {
          final Rect caret = caretRect(tester, lineStart(line));
          final double rowTop = overlayTop(tester) + line * lineHeight;

          expect(caret.center.dy, greaterThanOrEqualTo(rowTop), reason: '$line');
          expect(caret.center.dy, lessThan(rowTop + lineHeight), reason: '$line');
        }

        expect(
          renderEditable(tester).localToGlobal(Offset.zero).dy,
          moreOrLessEquals(overlayTop(tester)),
        );
        expectCaretOnRow(0);
        expectCaretOnRow(5);

        fieldScroll(tester).jumpTo(60 * lineHeight);
        await tester.pump();

        expect(overlayScroll(tester).pixels, fieldScroll(tester).pixels);
        expectCaretOnRow(62);
        expectCaretOnRow(errorLine);

        final double markerTop = tester
            .getTopLeft(find.byType(THTextEditorDiagnosticMarkerWidget))
            .dy;

        expect(
          markerTop,
          moreOrLessEquals(overlayTop(tester) + errorLine * lineHeight),
        );
        await tester.pump(_idle);
      });
    }
  });

  group('toolbar', () {
    testWidgets('leading actions come first', (WidgetTester tester) async {
      final TH2TextEditController controller = th2Controller('scrap s\n');

      await pumpEditor(
        tester,
        controller,
        leadingToolbarActions: <Widget>[
          IconButton(
            key: const ValueKey('leading'),
            icon: const Icon(Icons.map),
            onPressed: () {},
          ),
        ],
      );

      expect(
        tester.getTopLeft(find.byKey(const ValueKey('leading'))).dx,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('THTextEditorWidget|SaveButton')),
              )
              .dx,
        ),
      );
    });

    testWidgets('project Save follows isDirty and Revert keeps its tooltip', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      projectControllers.add(controller);
      await pumpEditor(tester, controller);

      IconButton button(String name) => tester.widget<IconButton>(
        find.byKey(ValueKey('THTextEditorWidget|$name')),
      );

      expect(button('SaveButton').onPressed, isNull);
      expect(
        button('RevertButton').tooltip,
        AppLocalizationsEn().textEditorRevertTooltip,
      );

      controller.setContent('survey x\n');
      await tester.pump();
      expect(button('SaveButton').onPressed, isNotNull);
      expect(button('RevertButton').onPressed, isNotNull);
    });

    testWidgets('TH2 Save and Revert delegate to the owner', (
      WidgetTester tester,
    ) async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner(canSave: false);
      final TH2TextEditController controller = th2Controller(
        'scrap s\n',
        owner: owner,
      );

      await pumpEditor(tester, controller);

      IconButton button(String name) => tester.widget<IconButton>(
        find.byKey(ValueKey('THTextEditorWidget|$name')),
      );

      expect(button('SaveButton').onPressed, isNull);
      expect(button('RevertButton').onPressed, isNull);
      expect(
        button('RevertButton').tooltip,
        AppLocalizationsEn().th2TextEditorDiscardTooltip,
      );

      owner.canSave = true;
      controller.setContent('scrap t\n');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('THTextEditorWidget|SaveButton')));
      await tester.pump();
      expect(owner.saveCalls, 1);

      owner.onSave = () async => throw StateError('write failed');
      owner.onDiscard = () async => throw StateError('discard failed');
      await tester.tap(find.byKey(const ValueKey('THTextEditorWidget|SaveButton')));
      await tester.tap(
        find.byKey(const ValueKey('THTextEditorWidget|RevertButton')),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(owner.saveCalls, 2);
      expect(owner.discardCalls, 1);

      owner.acquireBufferLock();
      await tester.pump();
      expect(button('RevertButton').onPressed, isNull);
      await tester.pump(_idle);
    });
  });

  group('diagnostics', () {
    testWidgets('a line marker shows all messages, most severe first', (
      WidgetTester tester,
    ) async {
      final List<THTextEditorDiagnostic> diagnostics =
          thTextEditorDiagnosticsBySeverity(const <THTextEditorDiagnostic>[
            THTextEditorDiagnostic(
              line: 0,
              message: 'info a',
              severity: THTextEditorDiagnosticSeverity.information,
            ),
            THTextEditorDiagnostic(
              line: 0,
              message: 'error',
              severity: THTextEditorDiagnosticSeverity.error,
            ),
            THTextEditorDiagnostic(
              line: 0,
              message: 'warning',
              severity: THTextEditorDiagnosticSeverity.warning,
            ),
            THTextEditorDiagnostic(
              line: 0,
              message: 'info b',
              severity: THTextEditorDiagnosticSeverity.information,
            ),
          ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: THTextEditorDiagnosticMarkerWidget(
              diagnostics: diagnostics,
              height: _lineHeight,
            ),
          ),
        ),
      );

      expect(find.byTooltip('error\nwarning\ninfo a\ninfo b'), findsOneWidget);

      final BuildContext context = tester.element(
        find.byType(THTextEditorDiagnosticMarkerWidget),
      );
      final BoxDecoration decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(THTextEditorDiagnosticMarkerWidget),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      expect(
        decoration.border!.bottom.color,
        Theme.of(context).colorScheme.error,
      );
    });

    testWidgets('the gutter dot follows the most severe diagnostic', (
      WidgetTester tester,
    ) async {
      final Map<int, THTextEditorDiagnosticSeverity> lines =
          thTextEditorDiagnosticLines(const <THTextEditorDiagnostic>[
            THTextEditorDiagnostic(
              line: 0,
              message: 'i',
              severity: THTextEditorDiagnosticSeverity.information,
            ),
            THTextEditorDiagnostic(
              line: 1,
              message: 'i',
              severity: THTextEditorDiagnosticSeverity.information,
            ),
            THTextEditorDiagnostic(
              line: 1,
              message: 'e',
              severity: THTextEditorDiagnosticSeverity.error,
            ),
            THTextEditorDiagnostic(
              line: null,
              message: 'x',
              severity: THTextEditorDiagnosticSeverity.error,
            ),
          ]);

      expect(lines, <int, THTextEditorDiagnosticSeverity>{
        0: THTextEditorDiagnosticSeverity.information,
        1: THTextEditorDiagnosticSeverity.error,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: THTextEditorLineNumberGutterWidget(
              lineCount: 3,
              currentLine: 0,
              diagnosticLines: lines,
              scrollController: ScrollController(),
            ),
          ),
        ),
      );

      final BuildContext context = tester.element(
        find.byType(THTextEditorLineNumberGutterWidget),
      );
      final List<Color?> dotColors = tester
          .widgetList<Container>(find.byType(Container))
          .map((Container container) => container.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.color)
          .toList();

      expect(dotColors, <Color?>[
        thTextEditorInformationDiagnosticColor,
        Theme.of(context).colorScheme.error,
      ]);
    });

    testWidgets('TH2 line-less feedback is shown under the toolbar', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = TH2TextEditController(
        owner: _ThrowingFilenameOwner(),
      );

      th2Controllers.add(controller);
      controller.installBaseline(
        TH2TextEditBaseline(
          content: 'scrap s\n',
          lineMap: th2EmptyTextLineMap(),
        ),
      );
      await pumpEditor(tester, controller);
      controller.setContent('scrap t\n');
      await tester.pump(_idle);
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('THTextEditorWidget|LinelessDiagnostics')),
          matching: find.text(
            AppLocalizationsEn().th2TextDiagnosticValidationFailed,
          ),
        ),
        findsOneWidget,
      );
      expect(find.byType(THTextEditorDiagnosticMarkerWidget), findsNothing);
    });

    testWidgets('project line-less errors are shown under the toolbar', (
      WidgetTester tester,
    ) async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('single-config');

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');

      await tester.runAsync(
        () => mpLocator.thProjectController.openProject(thconfigPath),
      );
      mpLocator.thProjectController.applyTherionRunDiagnostics(
        <THProjectParseError>[
          THProjectParseError(
            message: 'line-less error',
            severity: THProjectParseErrorSeverity.error,
            filePath: THProjectPathResolver.canonicalize(thconfigPath),
            lineNumber: 0,
          ),
        ],
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      projectControllers.add(controller);
      await controller.loadFile(thconfigPath);
      await pumpEditor(tester, controller);

      expect(controller.diagnostics.single.line, isNull);
      expect(controller.diagnostics.single.lineNumber, 0);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('THTextEditorWidget|LinelessDiagnostics')),
          matching: find.text('line-less error'),
        ),
        findsOneWidget,
      );
    });
  });

  group('find and focus', () {
    testWidgets('find matches follow buffer edits in an Observer', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller('scrap a\n');

      controller.find.setFindQuery('scrap');
      await pumpEditor(
        tester,
        controller,
        extra: Observer(
          builder: (_) => Text(
            'matches: ${controller.find.findMatches.length}',
            textDirection: TextDirection.ltr,
          ),
        ),
      );
      expect(find.text('matches: 1'), findsOneWidget);

      controller.setContent('scrap a\nscrap b\n');
      await tester.pump();
      expect(find.text('matches: 2'), findsOneWidget);

      controller.find.setFindCaseSensitive(true);
      controller.find.setFindQuery('SCRAP');
      await tester.pump();
      expect(find.text('matches: 0'), findsOneWidget);
      await tester.pump(_idle);
    });

    testWidgets('a pending selection focuses the typing field', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller(
        'scrap a\nscrap b\n',
      );

      await pumpEditor(tester, controller);
      controller.revealRange(const TextRange(start: 8, end: 13));
      await tester.pump();
      await tester.pump();

      expect(controller.textFieldFocusNode.hasFocus, isTrue);
      expect(
        fieldController(tester).selection,
        const TextSelection(baseOffset: 8, extentOffset: 13),
      );
      expect(controller.pendingSelectionRange, isNull);
    });

    testWidgets('a focus-free pending selection moves only the selection', (
      WidgetTester tester,
    ) async {
      final TH2TextEditController controller = th2Controller(
        'scrap a\nscrap b\n',
      );

      await pumpEditor(tester, controller);
      controller.revealRange(
        const TextRange(start: 8, end: 13),
        requestFocus: false,
      );
      await tester.pump();
      await tester.pump();

      expect(controller.textFieldFocusNode.hasFocus, isFalse);
      expect(
        fieldController(tester).selection,
        const TextSelection(baseOffset: 8, extentOffset: 13),
      );
      expect(controller.pendingSelectionRequestsFocus, isTrue);
    });

    testWidgets('project pending selection focuses the typing field', (
      WidgetTester tester,
    ) async {
      final THTextEditorController controller = projectController(
        'survey a\nendsurvey\n',
      );

      await pumpEditor(tester, controller);
      controller.revealRange(const TextRange(start: 9, end: 18));
      await tester.pump();
      await tester.pump();

      expect(controller.textFieldFocusNode.hasFocus, isTrue);
      expect(
        tester.widget<TextField>(find.byKey(_textFieldKey)).focusNode,
        controller.textFieldFocusNode,
      );
    });
  });
}

/// Throws when validation reads the filename.
class _ThrowingFilenameOwner extends TH2TextEditFakeOwner {
  @override
  String get filename => throw StateError('no filename');
}
