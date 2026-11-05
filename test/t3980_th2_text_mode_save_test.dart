// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p2\n'
    'endscrap\n';

const String _imageText =
    'encoding utf-8\n'
    '##XTHERION## xth_me_image_insert {-36 1 1} 28 "croquis/croqui-007.jpg" 0 {}\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

const String _invalid =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p1\n'
    'endscrap\n';

String _edited(String text) => text.replaceFirst('point 1 1', 'point 7 7');

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  tearDown(() {
    TH2FileEditControllerBase.beforeSaveAsExtensionRenameForTesting = null;
    TH2FileEditControllerBase.beforeSaveAsImageRebaseForTesting = null;
    TH2FileEditControllerBase.beforeWriteFileForTesting = null;
  });

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  void editOnCanvas(TH2FileEditController controller) {
    final THPoint point = controller.th2File.elementByTHID('p1') as THPoint;

    controller.execute(
      MPCommandFactory.removePointFromExisting(
        existingPointMPID: point.mpID,
        th2File: controller.th2File,
      ),
    );
  }

  group('text mode Save', () {
    test('saves text-only edits, normalizes the buffer and keeps the cursor',
        () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );
      final String edited = _text.replaceFirst(
        '  point 2 2 station -id p2\n',
        '  point   2 2 station -id p2\n',
      );

      TH2TextModeTestAux.edit(controller, edited);
      session.setCursorPosition(line: 3, column: 0);
      expect(controller.canSave, isTrue);
      expect(
        locator.thProjectController.dirtyFilePaths,
        contains(canonical(controller.th2File.filename)),
      );

      final int revision = session.sessionRevision;

      expect(await controller.saveTH2File(), TH2FileSaveStatus.saved);

      expect(controller.editMode, TH2EditMode.text);
      expect(session.sessionRevision, greaterThan(revision));
      expect(session.content, controller.serializeForTextMode().$1);
      expect(session.content, TH2TextModeTestAux.readFile(controller));
      expect(session.cursorLine, 3);
      expect(session.hasTextEdits, isFalse);
      expect(session.isReadOnly, isFalse);
      expect(controller.canSave, isFalse);
      expect(controller.undoRedoController.hasUndo, isFalse);
      expect(
        locator.thProjectController.dirtyFilePaths,
        isNot(contains(canonical(controller.th2File.filename))),
      );
    });

    test('invalid text writes nothing and reports textHasProblems', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _invalid);

      expect(await controller.saveTH2File(), TH2FileSaveStatus.textHasProblems);
      expect(TH2TextModeTestAux.readFile(controller), _text);
      expect(controller.showTextApplyRejection, isTrue);
      expect(controller.isBufferLocked, isFalse);
      expect(controller.canSave, isTrue);
    });

    test('a write failure after an apply rethrows, stays dirty and keeps a '
        'session of the live model', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, _edited(_text));
      TH2FileEditControllerBase.beforeWriteFileForTesting = () =>
          throw const FileSystemException('forced');

      await expectLater(
        controller.saveTH2File(),
        throwsA(isA<FileSystemException>()),
      );

      expect(TH2TextModeTestAux.readFile(controller), _text);
      expect(controller.undoRedoController.undoCount, 1);
      expect(controller.canSave, isTrue);
      expect(session.isOpen, isTrue);
      expect(session.content, controller.serializeForTextMode().$1);
      expect(session.hasTextEdits, isFalse);
      expect(controller.isBufferLocked, isFalse);
    });

    test('Save All leaves the dirty path of a rejected or dropped save',
        () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );
      final String path = canonical(controller.th2File.filename);

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _invalid);

      THSaveAllModifiedFilesResult result = await locator.thProjectController
          .saveAllModifiedFiles();

      expect(result.isComplete, isFalse);
      expect(
        (result.results.single as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.textHasProblems,
      );
      expect(locator.thProjectController.dirtyFilePaths, contains(path));

      /// A busy gate drops the save.
      TH2TextModeTestAux.edit(controller, _edited(_text));

      final Completer<void> busy = Completer<void>();
      final Future<void> pending = controller.runGatedOperation<void>(
        () => busy.future,
      );

      result = await locator.thProjectController.saveAllModifiedFiles();
      expect(
        (result.results.single as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.cancelled,
      );
      expect(locator.thProjectController.dirtyFilePaths, contains(path));
      busy.complete();
      await pending;

      result = await locator.thProjectController.saveAllModifiedFiles();
      expect(result.isComplete, isTrue);
      expect(locator.thProjectController.dirtyFilePaths, isEmpty);
    });

    test('Save All reports projectChanged when the project changes during '
        'the save', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );

      editOnCanvas(controller);
      TH2FileEditControllerBase.beforeWriteFileForTesting =
          locator.thProjectController.closeProject;

      final THSaveAllModifiedFilesResult result = await locator
          .thProjectController
          .saveAllModifiedFiles();

      expect(
        (result.results.single as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.projectChanged,
      );
    });
  });

  group('Save As', () {
    test('confirming applies the validated text, writes and starts a new '
        'session; the buffer is read-only while the picker is open', () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
        directory: directory,
      );
      final String originalPath = controller.th2File.filename;
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );
      final String target = p.join(directory.path, 'copy.th2');

      picker.pending = Completer<Uri?>();
      TH2TextModeTestAux.edit(controller, _edited(_text));

      final Future<TH2FileSaveStatus> saving = controller.saveAsTH2File();

      await pumpEventQueue();
      expect(picker.saveFileCalls, 1);
      expect(session.isReadOnly, isTrue);
      expect(session.setContent(_invalid), isFalse);

      picker.pending!.complete(Uri.file(target));
      expect(await saving, TH2FileSaveStatus.saved);

      expect(controller.th2File.filename, target);
      expect(File(target).readAsStringSync(), _edited(_text));
      expect(File(originalPath).readAsStringSync(), _text);
      expect(
        locator.mpGeneralController.getTH2FileEditControllerIfExists(target),
        same(controller),
      );
      expect(
        locator.mpGeneralController.getTH2FileEditControllerIfExists(
          originalPath,
        ),
        isNull,
      );
      expect(session.content, _edited(_text));
      expect(session.hasTextEdits, isFalse);
      expect(session.isReadOnly, isFalse);
      expect(controller.canSave, isFalse);
      expect(locator.thProjectController.dirtyFilePaths, isEmpty);
    });

    test('invalid text opens no picker; dismissing the picker changes '
        'nothing', () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, _invalid);
      expect(
        await controller.saveAsTH2File(),
        TH2FileSaveStatus.textHasProblems,
      );
      expect(picker.saveFileCalls, 0);
      expect(controller.showTextApplyRejection, isTrue);
      expect(session.isReadOnly, isFalse);

      TH2TextModeTestAux.edit(controller, _edited(_text));
      picker.result = null;
      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.cancelled);
      expect(picker.saveFileCalls, 1);
      expect(controller.undoRedoController.undoCount, 0);
      expect(session.content, _edited(_text));
      expect(session.hasTextEdits, isTrue);

      await controller.leaveTextMode();
      expect(controller.undoRedoController.undoCount, 1);
    });

    for (final String hook in <String>['rename', 'rebase', 'write']) {
      for (final bool textMode in <bool>[false, true]) {
        test('a forced $hook failure ${textMode ? 'after an apply' : 'on the '
            'canvas'} restores the filename and the image objects', () async {
          final TH2TextModeFakeFilePicker picker =
              TH2TextModeTestAux.installPicker();
          final Directory directory = TH2TextModeTestAux.tempDirectory();
          final TH2FileEditController controller =
              await TH2TextModeTestAux.open(_imageText, directory: directory);
          final String originalPath = controller.th2File.filename;
          final String key = canonical(originalPath);
          final Directory sub = Directory(p.join(directory.path, 'sub'))
            ..createSync();
          final String picked = p.join(sub.path, 'moved');

          File(picked).writeAsStringSync('');
          picker.result = Uri.file(picked);

          /// Captured right before the step that fails or, for the write,
          /// before the rebase: after the apply, which replaces every
          /// element object.
          List<THElement> imagesBefore = const <THElement>[];

          void capture() {
            imagesBefore = controller.th2File
                .getImages()
                .cast<THElement>()
                .toList();
          }

          if (textMode) {
            await TH2TextModeTestAux.enter(controller);
            TH2TextModeTestAux.edit(controller, _edited(_imageText));
          } else {
            editOnCanvas(controller);
          }

          final Set<String> dirtyBefore = locator
              .thProjectController
              .dirtyFilePaths
              .toSet();

          Never fail() => throw const FileSystemException('forced');

          switch (hook) {
            case 'rename':
              TH2FileEditControllerBase.beforeSaveAsExtensionRenameForTesting =
                  () {
                    capture();
                    fail();
                  };
            case 'rebase':
              TH2FileEditControllerBase.beforeSaveAsImageRebaseForTesting =
                  () {
                    capture();
                    fail();
                  };
            case 'write':
              TH2FileEditControllerBase.beforeSaveAsImageRebaseForTesting =
                  capture;
              TH2FileEditControllerBase.beforeWriteFileForTesting = fail;
          }

          await expectLater(
            controller.saveAsTH2File(),
            throwsA(isA<FileSystemException>()),
          );

          expect(controller.th2File.filename, originalPath);

          final List<THElement> imagesAfter = controller.th2File
              .getImages()
              .cast<THElement>()
              .toList();

          expect(imagesBefore, isNotEmpty);
          expect(imagesAfter, hasLength(imagesBefore.length));
          for (int index = 0; index < imagesBefore.length; index++) {
            expect(imagesAfter[index], same(imagesBefore[index]));
          }
          expect(
            locator.mpGeneralController.getTH2FileEditControllerIfExists(key),
            same(controller),
          );
          expect(controller.undoRedoController.undoCount, 1);
          expect(controller.canSave, isTrue);
          expect(locator.thProjectController.dirtyFilePaths, dirtyBefore);

          if (textMode) {
            final TH2TextEditController session =
                controller.textEditController!;

            expect(session.isOpen, isTrue);
            expect(session.content, controller.serializeForTextMode().$1);
            expect(controller.isBufferLocked, isFalse);
          }
        });
      }
    }

    test('Save As to the controller own path succeeds', () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );
      final String path = controller.th2File.filename;

      editOnCanvas(controller);
      picker.result = Uri.file(path);
      picker.emptiesTarget = true;

      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.saved);
      expect(controller.th2File.filename, path);
      expect(
        TH2TextModeTestAux.readFile(controller),
        controller.serializeForTextMode().$1,
      );
      expect(controller.canSave, isFalse);
    });

    test('a canvas Save As of a file with a lone carriage return works',
        () async {
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        '$_text# a comment\n',
        directory: directory,
      );
      final THComment comment = controller.th2File.elements.values
          .whereType<THComment>()
          .single;

      controller.th2File.substituteElement(
        comment.copyWith(originalLineInTH2File: '# a\rcomment\n'),
      );

      final String target = p.join(directory.path, 'cr.th2');

      picker.result = Uri.file(target);
      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.saved);
      expect(File(target).readAsStringSync(), contains('# a\rcomment'));
    });

    for (final bool appendsExtension in <bool>[false, true]) {
      test('a target open in another tab is refused '
          '${appendsExtension ? 'once .th2 is appended ' : ''}and a clean '
          'other file is restored', () async {
        final List<String> messages = TH2TextModeTestAux.captureUserMessages();
        final TH2TextModeFakeFilePicker picker =
            TH2TextModeTestAux.installPicker();
        final Directory directory = TH2TextModeTestAux.tempDirectory();
        final TH2FileEditController controller = await TH2TextModeTestAux.open(
          _text,
          directory: directory,
        );
        final TH2FileEditController other = await TH2TextModeTestAux.open(
          _imageText,
          directory: directory,
          name: 'other.th2',
        );
        final String otherPath = other.th2File.filename;

        editOnCanvas(controller);
        await TH2TextModeTestAux.enter(controller);
        TH2TextModeTestAux.edit(controller, _edited(_text));

        picker.result = Uri.file(
          appendsExtension ? p.withoutExtension(otherPath) : otherPath,
        );
        picker.emptiesTarget = true;

        final Set<String> dirtyBefore = locator
            .thProjectController
            .dirtyFilePaths
            .toSet();

        expect(await controller.saveAsTH2File(), TH2FileSaveStatus.cancelled);

        expect(File(otherPath).readAsStringSync(), _imageText);
        expect(messages, <String>[
          locator.appLocalizations.th2SaveAsTargetOpenMessage('other.th2'),
        ]);
        expect(
          locator.mpGeneralController.getTH2FileEditControllerIfExists(
            otherPath,
          ),
          same(other),
        );
        expect(
          locator.mpGeneralController.getTH2FileEditControllerIfExists(
            canonical(controller.th2File.filename),
          ),
          same(controller),
        );
        expect(controller.undoRedoController.undoCount, 1);
        expect(controller.textEditController!.content, _edited(_text));
        expect(controller.textEditController!.hasTextEdits, isTrue);
        expect(other.undoRedoController.undoCount, 0);
        expect(other.canSave, isFalse);
        expect(locator.thProjectController.dirtyFilePaths, dirtyBefore);
        expect(controller.isBufferLocked, isFalse);
      });
    }

    test('a dirty other file is left for its own Save; a broken one gets '
        'the could-not-restore message', () async {
      final List<String> messages = TH2TextModeTestAux.captureUserMessages();
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
        directory: directory,
      );
      final TH2FileEditController dirty = await TH2TextModeTestAux.open(
        _text,
        directory: directory,
        name: 'dirty.th2',
      );
      final TH2FileEditController broken = await TH2TextModeTestAux.open(
        'encoding utf-8\nscrap s1\n  poin 1 1 station\nendscrap\n',
        directory: directory,
        name: 'broken.th2',
      );

      expect(broken.isBroken, isTrue);
      editOnCanvas(dirty);
      picker.emptiesTarget = true;

      picker.result = Uri.file(dirty.th2File.filename);
      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.cancelled);
      expect(File(dirty.th2File.filename).readAsStringSync(), isEmpty);
      expect(dirty.canSave, isTrue);

      picker.result = Uri.file(broken.th2File.filename);
      expect(await controller.saveAsTH2File(), TH2FileSaveStatus.cancelled);
      expect(messages, <String>[
        locator.appLocalizations.th2SaveAsTargetOpenMessage('dirty.th2'),
        locator.appLocalizations.th2SaveAsTargetOpenEmptiedMessage(
          'broken.th2',
        ),
      ]);
    });

    for (final bool textMode in <bool>[false, true]) {
      test('a new file Save As ${textMode ? 'from text mode ' : ''}moves the '
          'controller from its placeholder key', () async {
        final TH2TextModeFakeFilePicker picker =
            TH2TextModeTestAux.installPicker();
        final Directory directory = TH2TextModeTestAux.tempDirectory();
        final TH2FileEditController controller = locator.mpGeneralController
            .getTH2FileEditControllerForNewFile(
              scrapTHID: 'scrap-new',
              scrapOptions: const [],
              encoding: mpDefaultEncoding,
            );
        final String placeholder = controller.th2File.filename;
        final String target = p.join(directory.path, 'new.th2');

        locator.mpGeneralController.addFileTab(placeholder);

        if (textMode) {
          await TH2TextModeTestAux.enter(controller);
          TH2TextModeTestAux.edit(
            controller,
            controller.textEditController!.content.replaceFirst(
              'endscrap',
              '  point 1 1 station\nendscrap',
            ),
          );
          expect(controller.canSave, isFalse);
          expect(await controller.saveTH2File(), TH2FileSaveStatus.saveFailed);
          expect(File(target).existsSync(), isFalse);
          expect(locator.thProjectController.dirtyFilePaths, isEmpty);
        }

        picker.result = Uri.file(target);
        expect(await controller.saveAsTH2File(), TH2FileSaveStatus.saved);

        expect(controller.th2File.isNewFile, isFalse);
        expect(controller.isFileLoaded, isTrue);
        expect(
          locator.mpGeneralController.getTH2FileEditControllerIfExists(
            placeholder,
          ),
          isNull,
        );
        expect(
          locator.mpGeneralController.getTH2FileEditControllerIfExists(target),
          same(controller),
        );
        expect(locator.thProjectController.dirtyFilePaths, isEmpty);

        if (textMode) {
          expect(File(target).readAsStringSync(), contains('point 1 1'));
        }
      });
    }
  });

  group('page entry points', () {
    testWidgets('Ctrl+S writes once and Ctrl+Shift+S opens one picker on the '
        'canvas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final TH2FileEditController controller = (await tester.runAsync(
        () => TH2TextModeTestAux.open(_text),
      ))!;
      int writes = 0;

      TH2FileEditControllerBase.beforeWriteFileForTesting = () => writes++;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pumpAndSettle();
      editOnCanvas(controller);
      await tester.pump();
      controller.th2FileFocusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(writes, 1);

      picker.result = null;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(picker.saveFileCalls, 1);
    });
  });
}
