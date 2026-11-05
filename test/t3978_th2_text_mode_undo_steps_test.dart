// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

String _text() {
  final StringBuffer buffer = StringBuffer('encoding utf-8\nscrap s1\n');

  for (int index = 0; index < 25; index++) {
    buffer.write('  point $index $index station -id p$index\n');
  }
  buffer.write('endscrap\n');

  return buffer.toString();
}

String _replaceLine(String text, int line, String replacement) {
  final List<String> lines = text.split('\n');

  lines[line] = replacement;

  return lines.join('\n');
}

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  String canonical(TH2FileEditController controller) =>
      THProjectPathResolver.canonicalize(
        p.absolute(controller.th2File.filename),
      );

  test('a session of several edits is one canvas undo step', () async {
    final String text = _text();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      text,
    );
    final Map<String, dynamic> before = controller.th2File.toMap();

    await TH2TextModeTestAux.enter(controller);

    String buffer = _replaceLine(text, 10, '  point 100 10 station -id p8');
    TH2TextModeTestAux.edit(controller, buffer);
    buffer = _replaceLine(buffer, 20, '  point 200 20 station -id p18');
    TH2TextModeTestAux.edit(controller, buffer);
    buffer = _replaceLine(buffer, 10, '  point 101 10 station -id p8');
    TH2TextModeTestAux.edit(controller, buffer);

    await controller.leaveTextMode();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.undoRedoController.undoCount, 1);
    expect(controller.serializeForTextMode().$1, buffer);

    final Map<String, dynamic> after = controller.th2File.toMap();

    controller.undo();
    expect(controller.th2File.toMap(), before);
    controller.redo();
    expect(controller.th2File.toMap(), after);

    /// Another session adds a second step.
    await TH2TextModeTestAux.enter(controller);
    TH2TextModeTestAux.edit(
      controller,
      _replaceLine(buffer, 5, '  point 50 3 station -id p3'),
    );
    await controller.leaveTextMode();
    expect(controller.undoRedoController.undoCount, 2);
  });

  test('after an apply, the dirty state follows the canvas and a canvas Save '
      'clears it', () async {
    final String text = _text();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      text,
    );

    await TH2TextModeTestAux.enter(controller);
    TH2TextModeTestAux.edit(
      controller,
      _replaceLine(text, 3, '  point 9 9 station -id p1'),
    );
    expect(controller.hasUnsavedChanges, isTrue);
    expect(controller.enableSaveButton, isFalse);
    expect(
      locator.thProjectController.dirtyFilePaths,
      contains(canonical(controller)),
    );

    await controller.leaveTextMode();

    expect(controller.hasUnsavedChanges, controller.enableSaveButton);
    expect(controller.canSave, isTrue);
    expect(await controller.saveTH2File(), TH2FileSaveStatus.saved);
    expect(controller.canSave, isFalse);
    expect(controller.hasUnsavedChanges, isFalse);
    expect(
      locator.thProjectController.dirtyFilePaths,
      isNot(contains(canonical(controller))),
    );
  });

  test('leaving with text that normalizes back, unchanged text or Discard '
      'adds no step and leaves the file clean', () async {
    final String text = _text();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      text,
    );

    /// Unchanged.
    await TH2TextModeTestAux.enter(controller);
    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);

    /// Edited, then edited back.
    await TH2TextModeTestAux.enter(controller);
    TH2TextModeTestAux.edit(
      controller,
      _replaceLine(text, 3, '  point 9 9 station -id p1'),
    );
    TH2TextModeTestAux.edit(controller, text);
    await controller.leaveTextMode();
    expect(controller.undoRedoController.undoCount, 0);

    /// Discard.
    await TH2TextModeTestAux.enter(controller);
    TH2TextModeTestAux.edit(
      controller,
      _replaceLine(text, 3, '  point 9 9 station -id p1'),
    );
    expect(controller.hasUnsavedChanges, isTrue);
    await controller.discardTextEdits();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.undoRedoController.undoCount, 0);
    expect(controller.hasUnsavedChanges, isFalse);
    expect(controller.canSave, isFalse);
    expect(controller.serializeForTextMode().$1, text);
    expect(
      locator.thProjectController.dirtyFilePaths,
      isNot(contains(canonical(controller))),
    );
  });
}
