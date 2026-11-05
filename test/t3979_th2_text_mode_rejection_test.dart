// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:material_ui/material_ui.dart';

import 'th2_file_tabs_page_test_aux.dart';
import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

const String _invalid =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p1\n'
    'endscrap\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  setUp(TH2TextModeTestAux.setUp);

  test('invalid text stays in text mode with its markers shown at once',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final Map<String, dynamic> modelBefore = controller.th2File.toMap();

    TH2TextModeTestAux.edit(controller, _invalid);
    expect(session.hasPendingIdleValidation, isTrue);
    await controller.leaveTextMode();

    expect(controller.editMode, TH2EditMode.text);
    expect(session.isOpen, isTrue);
    expect(session.isReadOnly, isFalse);
    expect(session.hasPendingIdleValidation, isFalse);
    expect(
      session.diagnostics.where(
        (THTextEditorDiagnostic diagnostic) =>
            diagnostic.severity == THTextEditorDiagnosticSeverity.error,
      ),
      isNotEmpty,
    );
    expect(controller.showTextApplyRejection, isTrue);
    expect(controller.th2File.toMap(), modelBefore);
    expect(controller.undoRedoController.undoCount, 0);

    /// The first edit hides the banner.
    TH2TextModeTestAux.edit(controller, '$_invalid\n');
    expect(controller.showTextApplyRejection, isFalse);

    /// Discard returns with the model unchanged.
    await controller.discardTextEdits();
    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.textApplyRejection, isNull);
    expect(controller.th2File.toMap(), modelBefore);
  });

  test('a lone carriage return blocks the apply and Save', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final String withCR = _text.replaceFirst('p1\n', 'p1\r x\n');
    final String fileBefore = TH2TextModeTestAux.readFile(controller);

    TH2TextModeTestAux.edit(controller, withCR);
    expect(await controller.saveTH2File(), TH2FileSaveStatus.textHasProblems);
    expect(TH2TextModeTestAux.readFile(controller), fileBefore);
    expect(controller.undoRedoController.undoCount, 0);
    expect(
      session.diagnostics.any(
        (THTextEditorDiagnostic diagnostic) => diagnostic.line == 2,
      ),
      isTrue,
    );

    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.text);

    /// Removing it lets the apply go on.
    TH2TextModeTestAux.edit(controller, _text.replaceFirst('p1\n', 'p1 \n'));
    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);
  });

  testWidgets('the banner offers Keep editing and Discard text changes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final TH2FileEditController controller = (await tester.runAsync(
      () => TH2TextModeTestAux.open(_text),
    ))!;

    await tester.pumpWidget(
      buildTH2FileTabsPageTestApp(th2FileEditController: controller),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(controller.editMode, TH2EditMode.text);
    expect(
      find.byKey(const ValueKey<String>('TH2TextEditBodyWidget|CanvasButton')),
      findsOneWidget,
    );

    controller.textEditController!.setContent(_invalid);
    await tester.runAsync(controller.leaveTextMode);
    await tester.pumpAndSettle();

    final Finder banner = find.byKey(
      const ValueKey<String>('TH2TextEditBodyWidget|CantApplyBanner'),
    );

    expect(banner, findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('TH2TextEditBodyWidget|KeepEditingButton'),
      ),
    );
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
    expect(controller.editMode, TH2EditMode.text);
    expect(controller.textEditController!.textFieldFocusNode.hasFocus, isTrue);

    await tester.runAsync(controller.leaveTextMode);
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('TH2TextEditBodyWidget|DiscardButton')),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(banner, findsNothing);
    expect(controller.serializeForTextMode().$1, _text);
  });
}
