// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _broken =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -name 1\n'
    '  poin 2 2 station -name 2\n'
    'endscrap\n';

const String _stillBroken =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -name 1\n'
    '  poin 3 3 station -name 2\n'
    'endscrap\n';

const String _fixed =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -name 1\n'
    '  point 2 2 station -name 2\n'
    'endscrap\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  tearDown(() {
    TH2FileEditControllerBase.beforeWriteFileForTesting = null;
  });

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Future<(TH2FileEditController, TH2TextEditController)> enterBroken() async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _broken,
    );

    expect(controller.isBroken, isTrue);

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    return (controller, session);
  }

  group('a broken file with problems left is never saved', () {
    test('Save of an invalid edited buffer writes nothing and keeps the '
        'dirty path', () async {
      final (TH2FileEditController controller, _) = await enterBroken();
      final String path = canonical(controller.th2File.filename);

      TH2TextModeTestAux.edit(controller, _stillBroken);
      expect(controller.canSave, isTrue);
      expect(locator.thProjectController.dirtyFilePaths, contains(path));

      expect(await controller.saveTH2File(), TH2FileSaveStatus.textHasProblems);

      expect(TH2TextModeTestAux.readFile(controller), _broken);
      expect(controller.isBroken, isTrue);
      expect(controller.showTextApplyRejection, isTrue);
      expect(controller.isBufferLocked, isFalse);
      expect(locator.thProjectController.dirtyFilePaths, contains(path));

      /// The text view's toolbar Save and `Ctrl+S` run the same Save.
      await controller.textEditController!.save();
      expect(TH2TextModeTestAux.readFile(controller), _broken);
      expect(locator.thProjectController.dirtyFilePaths, contains(path));
    });

    test('Save All of an invalid edited buffer reports textHasProblems',
        () async {
      final (TH2FileEditController controller, _) = await enterBroken();
      final String path = canonical(controller.th2File.filename);

      TH2TextModeTestAux.edit(controller, _stillBroken);

      final THSaveAllModifiedFilesResult result = await locator
          .thProjectController
          .saveAllModifiedFiles();

      expect(
        (result.results.single as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.textHasProblems,
      );
      expect(TH2TextModeTestAux.readFile(controller), _broken);
      expect(locator.thProjectController.dirtyFilePaths, contains(path));
    });

    test('Save As of an invalid buffer, edited or not, opens no picker',
        () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final (TH2FileEditController controller, _) = await enterBroken();

      /// Unchanged: the banner shows, unlike on a leave.
      expect(
        await controller.saveAsTH2File(),
        TH2FileSaveStatus.textHasProblems,
      );
      expect(picker.saveFileCalls, 0);
      expect(controller.showTextApplyRejection, isTrue);

      TH2TextModeTestAux.edit(controller, _stillBroken);
      expect(
        await controller.saveAsTH2File(),
        TH2FileSaveStatus.textHasProblems,
      );
      expect(picker.saveFileCalls, 0);
      expect(controller.showTextApplyRejection, isTrue);
      expect(TH2TextModeTestAux.readFile(controller), _broken);
    });

    test('Save of an unchanged raw buffer is disabled', () async {
      final (TH2FileEditController controller, _) = await enterBroken();

      expect(controller.canSave, isFalse);
      expect(controller.hasUnsavedChanges, isFalse);
    });
  });

  test('a write failure after a valid raw apply keeps the fixed model, '
      'dirty, and a retry writes without another apply', () async {
    final (TH2FileEditController controller, TH2TextEditController session) =
        await enterBroken();
    final String path = canonical(controller.th2File.filename);

    TH2TextModeTestAux.edit(controller, _fixed);
    TH2FileEditControllerBase.beforeWriteFileForTesting = () =>
        throw const FileSystemException('forced');

    await expectLater(
      controller.saveTH2File(),
      throwsA(isA<FileSystemException>()),
    );

    expect(TH2TextModeTestAux.readFile(controller), _broken);
    expect(controller.isBroken, isFalse);
    expect(controller.serializeForTextMode().$1, _fixed);
    expect(controller.hasUnsavedBaseline, isTrue);
    expect(controller.canSave, isTrue);
    expect(locator.thProjectController.dirtyFilePaths, contains(path));
    expect(controller.editMode, TH2EditMode.text);
    expect(session.isOpen, isTrue);
    expect(session.initialContent, _fixed);
    expect(session.initialLineMap.ownerMPIDs, isNotEmpty);
    expect(controller.isBufferLocked, isFalse);

    TH2FileEditControllerBase.beforeWriteFileForTesting = null;

    final int undoCount = controller.undoRedoController.undoCount;

    expect(await controller.saveTH2File(), TH2FileSaveStatus.saved);
    expect(controller.undoRedoController.undoCount, undoCount);
    expect(TH2TextModeTestAux.readFile(controller), _fixed);
    expect(controller.hasUnsavedBaseline, isFalse);
    expect(locator.thProjectController.dirtyFilePaths, isNot(contains(path)));

    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.isBroken, isFalse);
  });

  test('leaving after a failed write shows the canvas, not the body',
      () async {
    final (TH2FileEditController controller, _) = await enterBroken();

    TH2TextModeTestAux.edit(controller, _fixed);
    TH2FileEditControllerBase.beforeWriteFileForTesting = () =>
        throw const FileSystemException('forced');

    await expectLater(
      controller.saveTH2File(),
      throwsA(isA<FileSystemException>()),
    );
    TH2FileEditControllerBase.beforeWriteFileForTesting = null;

    await controller.leaveTextMode();
    expect(controller.editMode, TH2EditMode.canvas);
    expect(controller.isBroken, isFalse);
    expect(controller.canSave, isTrue);
    expect(File(controller.th2File.filename).readAsStringSync(), _broken);
  });
}
