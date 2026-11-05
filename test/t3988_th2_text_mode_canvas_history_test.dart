// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 0 0 station -id p0\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p2\n'
    'endscrap\n';

int _lineOf(String text, String fragment) =>
    text.split('\n').indexWhere((String line) => line.contains(fragment));

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  tearDown(() {
    TH2FileEditControllerBase.beforePrepareTextSessionForTesting = null;
  });

  void removePoint(TH2FileEditController controller, String thID) {
    controller.execute(
      MPCommandFactory.removePointFromExisting(
        existingPointMPID: controller.th2File.mpIDByTHID(thID)!,
        th2File: controller.th2File,
      ),
    );
  }

  test('before the first text edit, undo and redo traverse the canvas '
      'history in text mode', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final Map<String, dynamic> original = controller.th2File.toMap();

    removePoint(controller, 'p2');

    final Map<String, dynamic> afterC1 = controller.th2File.toMap();
    final String afterC1Text = controller.serializeForTextMode().$1;

    removePoint(controller, 'p0');

    final String afterC2Text = controller.serializeForTextMode().$1;
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(session.content, afterC2Text);

    /// The cursor on p1 follows it when p0 comes back above it.
    session.setCursorPosition(line: _lineOf(afterC2Text, '-id p1'), column: 3);
    await session.requestCanvasHistory(redo: false);

    expect(controller.editMode, TH2EditMode.text);
    expect(session.content, afterC1Text);
    expect(controller.th2File.toMap(), afterC1);
    expect(session.cursorLine, _lineOf(afterC1Text, '-id p1'));
    expect(session.cursorColumn, 3);
    expect(session.hasTextEdits, isFalse);
    expect(controller.undoRedoController.undoCount, 1);
    expect(controller.undoRedoController.hasRedo, isTrue);

    await session.requestCanvasHistory(redo: false);
    expect(session.content, _text);
    expect(controller.th2File.toMap(), original);
    expect(controller.undoRedoController.hasUndo, isFalse);

    /// Nothing left to undo.
    final int revision = session.sessionRevision;

    await session.requestCanvasHistory(redo: false);
    expect(session.sessionRevision, revision);

    await session.requestCanvasHistory(redo: true);
    expect(session.content, afterC1Text);
    expect(controller.undoRedoController.undoCount, 1);

    /// After a text edit, canvas history is out of reach.
    TH2TextModeTestAux.edit(
      controller,
      session.content.replaceFirst('point 1 1', 'point 1 3'),
    );
    await session.requestCanvasHistory(redo: false);
    await controller.requestCanvasHistory(redo: false);
    expect(controller.undoRedoController.undoCount, 1);
    expect(controller.th2File.toMap(), afterC1);

    /// Leaving adds one command whose undo restores the model after C1.
    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);
    /// The pending C2 redo stays in the undo history under the existing
    /// policy (as its redo and its undo), then the apply.
    expect(controller.undoRedoController.undoCount, 4);
    expect(controller.undoRedoController.hasRedo, isFalse);
    controller.undo();
    expect(controller.th2File.toMap(), afterC1);
  });

  test('Discard keeps the traversals made in the session', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    removePoint(controller, 'p2');

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await session.requestCanvasHistory(redo: false);
    await controller.discardTextEdits();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.serializeForTextMode().$1, _text);
    expect(controller.undoRedoController.hasRedo, isTrue);
  });

  test('a preparation failure returns to the canvas with the message and '
      'publishes no partial baseline', () async {
    final List<String> messages = TH2TextModeTestAux.captureUserMessages();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    removePoint(controller, 'p2');

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final int baselineRevision = session.baselineRevision;

    TH2FileEditControllerBase.beforePrepareTextSessionForTesting = () =>
        throw StateError('forced');
    await session.requestCanvasHistory(redo: false);

    expect(controller.editMode, TH2EditMode.canvas);
    expect(session.isOpen, isFalse);
    expect(session.baselineRevision, baselineRevision);
    expect(controller.isBufferLocked, isFalse);
    expect(messages, <String>[
      locator.appLocalizations.th2TextEditorReopenFailedMessage,
    ]);

    /// The undo itself is not rolled back.
    expect(controller.serializeForTextMode().$1, _text);
  });

  test('restoring an element with a lone carriage return returns to the '
      'canvas with the line-ending message', () async {
    final List<String> messages = TH2TextModeTestAux.captureUserMessages();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      '$_text# a comment\n',
    );
    final THComment comment = controller.th2File.elements.values
        .whereType<THComment>()
        .single;

    controller.th2File.substituteElement(
      comment.copyWith(originalLineInTH2File: '# a\rcomment\n'),
    );
    controller.execute(
      MPCommandFactory.removeElementFromExisting(
        existingElementMPID: comment.mpID,
        th2File: controller.th2File,
      ),
    );

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    await session.requestCanvasHistory(redo: false);

    expect(controller.editMode, TH2EditMode.canvas);
    expect(session.isOpen, isFalse);
    expect(messages, <String>[
      locator.appLocalizations.th2TextUnsupportedLineEndingMessage,
    ]);
    expect(controller.th2File.hasElementByMPID(comment.mpID), isTrue);
  });
}
