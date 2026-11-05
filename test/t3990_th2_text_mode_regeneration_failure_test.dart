// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:path/path.dart' as p;

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

final String _edited = _text.replaceFirst('point 1 1', 'point 7 7');

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  tearDown(() {
    TH2FileEditControllerBase.beforePrepareTextSessionForTesting = null;
    TH2FileEditControllerBase.beforeWriteFileForTesting = null;
  });

  void failPreparation() {
    TH2FileEditControllerBase.beforePrepareTextSessionForTesting = () =>
        throw StateError('forced preparation failure');
  }

  void expectBackOnCanvas(
    TH2FileEditController controller,
    TH2TextEditController session,
    List<String> messages,
  ) {
    expect(controller.editMode, TH2EditMode.canvas);
    expect(session.isOpen, isFalse);
    expect(controller.isBufferLocked, isFalse);
    expect(controller.isOperationBusy, isFalse);
    expect(messages, <String>[
      locator.appLocalizations.th2TextEditorReopenFailedMessage,
    ]);
  }

  for (final bool changed in <bool>[true, false]) {
    test('a preparation failure after a successful Save with '
        '${changed ? 'applied' : 'unchanged'} text returns to the canvas with '
        'the save complete', () async {
      final List<String> messages = TH2TextModeTestAux.captureUserMessages();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );

      if (!changed) {
        /// Something to save: a model change before entry.
        await TH2TextModeTestAux.enter(controller);
        TH2TextModeTestAux.edit(controller, _edited);
        await controller.leaveTextMode();
      }

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      if (changed) {
        TH2TextModeTestAux.edit(controller, _edited);
      }
      failPreparation();

      final THSaveAllModifiedFilesResult result = await locator
          .thProjectController
          .saveAllModifiedFiles();

      expect(result.isComplete, isTrue);
      expect(
        (result.results.single as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.saved,
      );
      expectBackOnCanvas(controller, session, messages);
      expect(TH2TextModeTestAux.readFile(controller), _edited);
      expect(controller.canSave, isFalse);
      expect(controller.undoRedoController.hasUndo, isFalse);
      expect(locator.thProjectController.dirtyFilePaths, isEmpty);

      /// F2 enters text mode again from the live model.
      TH2FileEditControllerBase.beforePrepareTextSessionForTesting = null;

      final TH2TextEditController again = await TH2TextModeTestAux.enter(
        controller,
      );

      expect(again.content, _edited);
    });
  }

  test('a preparation failure after a successful Save As keeps its '
      'bookkeeping', () async {
    final List<String> messages = TH2TextModeTestAux.captureUserMessages();
    final TH2TextModeFakeFilePicker picker = TH2TextModeTestAux.installPicker();
    final Directory directory = TH2TextModeTestAux.tempDirectory();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
      directory: directory,
    );
    final String target = p.join(directory.path, 'saved.th2');
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    TH2TextModeTestAux.edit(controller, _edited);
    picker.result = Uri.file(target);
    failPreparation();

    expect(await controller.saveAsTH2File(), TH2FileSaveStatus.saved);

    expectBackOnCanvas(controller, session, messages);
    expect(File(target).readAsStringSync(), _edited);
    expect(controller.th2File.filename, target);
    expect(
      locator.mpGeneralController.getTH2FileEditControllerIfExists(target),
      same(controller),
    );
    expect(controller.isFileLoaded, isTrue);
    expect(controller.canSave, isFalse);
  });

  test('after a failed write, the write exception reaches the caller and the '
      'file stays dirty', () async {
    final List<String> messages = TH2TextModeTestAux.captureUserMessages();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    TH2TextModeTestAux.edit(controller, _edited);
    failPreparation();
    TH2FileEditControllerBase.beforeWriteFileForTesting = () =>
        throw const FileSystemException('forced write failure');

    await expectLater(
      controller.saveTH2File(),
      throwsA(isA<FileSystemException>()),
    );

    expectBackOnCanvas(controller, session, messages);
    expect(TH2TextModeTestAux.readFile(controller), _text);
    expect(controller.serializeForTextMode().$1, _edited);
    expect(controller.canSave, isTrue);
    expect(controller.undoRedoController.undoCount, 1);
  });
}
