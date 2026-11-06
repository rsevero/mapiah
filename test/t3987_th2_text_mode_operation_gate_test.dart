// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_operation_gate.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p2\n'
    'endscrap\n';

final String _edited = _text.replaceFirst('point 1 1', 'point 7 7');

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  test('the gate admits one operation and isBusy is true exactly while it '
      'runs', () async {
    bool disposed = false;
    final TH2FileOperationGate gate = TH2FileOperationGate(
      isOwnerDisposed: () => disposed,
    );
    final Completer<int> first = Completer<int>();

    expect(gate.isBusy, isFalse);

    final Future<int?> running = gate.run<int>(() => first.future);

    expect(gate.isBusy, isTrue);
    expect(await gate.run<int>(() async => 2), isNull);
    first.complete(1);
    expect(await running, 1);
    expect(gate.isBusy, isFalse);

    /// A throwing body releases the gate.
    await expectLater(
      gate.run<void>(() async => throw StateError('x')),
      throwsStateError,
    );
    expect(gate.isBusy, isFalse);

    disposed = true;
    expect(await gate.run<int>(() async => 3), isNull);
  });

  for (final String operation in <String>[
    'leave',
    'save',
    'saveAs',
    'discard',
    'traversal',
  ]) {
    test('the buffer refuses typing from the start of a $operation until it '
        'ends', () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
        directory: directory,
      );

      if (operation == 'traversal') {
        controller.execute(
          MPCommandFactory.removePointFromExisting(
            existingPointMPID: controller.th2File.mpIDByTHID('p2')!,
            th2File: controller.th2File,
          ),
        );
      }

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      if (operation != 'traversal') {
        TH2TextModeTestAux.edit(controller, _edited);
      }

      picker.result = Uri.file(p.join(directory.path, 'as.th2'));

      final List<bool> lockChanges = <bool>[];
      final ReactionDisposer disposeReaction = reaction<bool>(
        (_) => controller.isBufferLocked,
        lockChanges.add,
      );

      addTearDown(disposeReaction.call);

      final Future<void> running = switch (operation) {
        'leave' => controller.leaveTextMode(),
        'save' => controller.saveTH2File(),
        'saveAs' => controller.saveAsTH2File(),
        'discard' => controller.discardTextEdits(),
        _ => controller.requestCanvasHistory(redo: false),
      };

      expect(controller.isOperationBusy, isTrue);

      /// Discard and the traversal have no await: they already ended.
      if ((operation != 'discard') && (operation != 'traversal')) {
        expect(session.isReadOnly, isTrue);
        expect(session.setContent('scrap x\n'), isFalse);
      }

      await running;

      expect(lockChanges, <bool>[true, false]);
      expect(controller.isOperationBusy, isFalse);
      expect(controller.isBufferLocked, isFalse);
    });
  }

  test('requests made while an operation runs are dropped', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    TH2TextModeTestAux.edit(controller, _edited);

    final Future<void> leaving = controller.leaveTextMode();

    /// All requested before the leave's first await completes.
    final Future<TH2FileSaveStatus> save = controller.saveTH2File();
    final Future<TH2FileSaveStatus> saveAs = controller.saveAsTH2File();
    final List<Future<void>> others = <Future<void>>[
      controller.toggleEditMode(),
      controller.discardTextEdits(),
      controller.requestCanvasHistory(redo: false),
      controller.elementEditController.addImage(),
    ];

    expect(await save, TH2FileSaveStatus.cancelled);
    expect(await saveAs, TH2FileSaveStatus.cancelled);
    await Future.wait(others);
    await leaving;

    expect(controller.editMode, TH2EditMode.canvas);
    expect(session.isOpen, isFalse);
    expect(controller.undoRedoController.undoCount, 1);
    expect(TH2TextModeTestAux.readFile(controller), _text);
  });

  test('canvas undo while the Save As picker is open does nothing', () async {
    final TH2TextModeFakeFilePicker picker = TH2TextModeTestAux.installPicker();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    controller.execute(
      MPCommandFactory.removePointFromExisting(
        existingPointMPID: controller.th2File.mpIDByTHID('p2')!,
        th2File: controller.th2File,
      ),
    );

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final Map<String, dynamic> model = controller.th2File.toMap();

    picker.pending = Completer<Uri?>();

    final Future<TH2FileSaveStatus> saving = controller.saveAsTH2File();

    await pumpEventQueue();
    await session.requestCanvasHistory(redo: false);
    expect(controller.th2File.toMap(), model);
    expect(controller.undoRedoController.undoCount, 1);

    picker.pending!.complete(null);
    expect(await saving, TH2FileSaveStatus.cancelled);
  });

  test('closing a tab while a text-mode Save As picker is open ends the '
      'session at once and the Save As is cancelled', () async {
    final TH2TextModeFakeFilePicker picker = TH2TextModeTestAux.installPicker();
    final Directory directory = TH2TextModeTestAux.tempDirectory();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
      directory: directory,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final String target = p.join(directory.path, 'target');

    TH2TextModeTestAux.edit(controller, _edited);
    picker.pending = Completer<Uri?>();

    final Future<TH2FileSaveStatus> saving = controller.saveAsTH2File();

    await pumpEventQueue();
    controller.close();

    expect(controller.editMode, TH2EditMode.canvas);
    expect(session.isOpen, isFalse);

    File(target).writeAsStringSync('');
    picker.pending!.complete(Uri.file(target));

    expect(await saving, TH2FileSaveStatus.cancelled);
    expect(controller.isBufferLocked, isFalse);
    expect(controller.undoRedoController.undoCount, 0);
    expect(File(target).existsSync(), isTrue);
    expect(File('$target.th2').existsSync(), isFalse);
    expect(TH2TextModeTestAux.readFile(controller), _text);
    expect(controller.th2File.filename, isNot(contains('target')));
  });

  test('a reload while an operation awaits leaves the new controller alone',
      () async {
    final TH2TextModeFakeFilePicker picker = TH2TextModeTestAux.installPicker();
    final Directory directory = TH2TextModeTestAux.tempDirectory();
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
      directory: directory,
    );
    final String path = controller.th2File.filename;

    await TH2TextModeTestAux.enter(controller);
    TH2TextModeTestAux.edit(controller, _edited);
    picker.pending = Completer<Uri?>();

    final Future<TH2FileSaveStatus> saving = controller.saveAsTH2File();

    await pumpEventQueue();

    final TH2FileEditController reloaded = await locator.mpGeneralController
        .reloadTH2File(path);

    picker.pending!.complete(Uri.file(p.join(directory.path, 'x.th2')));
    expect(await saving, TH2FileSaveStatus.cancelled);

    expect(controller.isDisposed, isTrue);
    expect(reloaded.editMode, TH2EditMode.canvas);
    expect(reloaded.undoRedoController.undoCount, 0);
    expect(reloaded.serializeForTextMode().$1, _text);
    expect(File(p.join(directory.path, 'x.th2')).existsSync(), isFalse);
    expect(
      locator.mpGeneralController.getTH2FileEditControllerIfExists(path),
      same(reloaded),
    );
  });


  group('raw session (broken file)', () {
    const String rawBroken =
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 1 1 station -id p1\n'
        '  poin 2 2 station\n'
        'endscrap\n';
    final String rawFixed = rawBroken.replaceFirst('poin 2', 'point 2');

    test('requests made while another operation runs are dropped', () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        rawBroken,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, rawFixed);

      final Completer<void> busy = Completer<void>();
      final Future<void> pending = controller.runGatedOperation<void>(
        () => busy.future,
      );

      expect(await controller.saveTH2File(), TH2FileSaveStatus.cancelled);
      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.cancelled);
      await controller.toggleEditMode();
      await controller.discardTextEdits();

      /// Copy and tree navigation do nothing in a raw session.
      controller.moveTextCursorToElement(controller.th2File.scrapMPIDs.first);

      busy.complete();
      await pending;

      expect(picker.saveFileCalls, 0);
      expect(controller.editMode, TH2EditMode.text);
      expect(session.isOpen, isTrue);
      expect(session.content, rawFixed);
      expect(controller.isBroken, isTrue);
      expect(TH2TextModeTestAux.readFile(controller), rawBroken);
    });

    test('the buffer refuses typing while a raw apply validates', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        rawBroken,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, rawFixed);

      final Future<void> leaving = controller.leaveTextMode();

      expect(session.isReadOnly, isTrue);
      expect(session.setContent(rawBroken), isFalse);
      await leaving;

      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isFalse);
    });

    test('a reload while a raw entry reads the file leaves the new '
        'controller alone', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        rawBroken,
      );
      final String path = controller.th2File.filename;
      final Completer<void> hold = Completer<void>();

      TH2FileEditControllerBase.beforeBrokenTextEntryValidationForTesting =
          () => hold.future;
      addTearDown(
        () => TH2FileEditControllerBase
                .beforeBrokenTextEntryValidationForTesting =
            null,
      );

      final Future<void> entering = controller.enterTextMode();

      await pumpEventQueue();

      final TH2FileEditController reloaded = await locator.mpGeneralController
          .reloadTH2File(path);

      hold.complete();
      await entering;

      expect(controller.isDisposed, isTrue);
      expect(reloaded.editMode, TH2EditMode.canvas);
      expect(reloaded.isBroken, isTrue);
      expect(reloaded.textEditController, isNull);
    });
  });
}
