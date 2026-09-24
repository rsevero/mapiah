// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

const String _validContents =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station:fixed -id p2\n'
    'endscrap\n';

const String _brokenContents =
    'encoding utf-8\n'
    'scrap s1\n'
    '  poin 1 1 station\n'
    'endscrap\n';

/// A duplicated scrap id makes the parser throw: an unexpected exception.
const String _throwingContents =
    'encoding utf-8\n'
    'scrap repeated\n'
    'endscrap\n'
    'scrap repeated\n'
    'endscrap\n';

class _FakeFilePicker extends FilePickerPlatform {
  Uri? result;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    return result;
  }
}

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late Directory tempDir;

  String writeFile(String name, String contents) {
    final String path = p.join(tempDir.path, name);

    File(path).writeAsStringSync(contents);

    return path;
  }

  TH2FileEditController controllerFor(String contents, {String? name}) {
    return mpLocator.mpGeneralController.getTH2FileEditController(
      filename: p.join(tempDir.path, name ?? 'in-memory.th2'),
      fileBytes: Uint8List.fromList(utf8.encode(contents)),
    );
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3944_');
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
    tempDir.deleteSync(recursive: true);
  });

  group('load transitions', () {
    test('isFileLoaded fires once for a valid load', () async {
      final TH2FileEditController controller = controllerFor(_validContents);
      int runs = 0;
      final ReactionDisposer dispose = reaction<bool>(
        (_) => controller.isFileLoaded,
        (bool loaded) {
          runs++;
          expect(loaded, isTrue);
          expect(controller.isBroken, isFalse);
        },
      );

      addTearDown(dispose.call);
      await controller.load();

      expect(runs, 1);
    });

    test('isFileLoaded fires once for a broken load, already broken', () async {
      final TH2FileEditController controller = controllerFor(_brokenContents);
      int runs = 0;
      final ReactionDisposer dispose = reaction<bool>(
        (_) => controller.isFileLoaded,
        (bool loaded) {
          runs++;
          expect(controller.isBroken, isTrue);
          expect(controller.problems, isNotEmpty);
        },
      );

      addTearDown(dispose.call);
      await controller.load();

      expect(runs, 1);
    });

    test('a parse error appears once in problems', () async {
      final TH2FileEditController controller = controllerFor(_brokenContents);

      await controller.load();

      expect(
        controller.problems
            .where(
              (TH2FileProblem problem) =>
                  problem.kind == TH2FileProblemKind.parseError,
            )
            .length,
        1,
      );
      expect(controller.problems.single.lineNumber, 3);
    });

    test('structureRevision fires once per load with final state', () async {
      for (final String contents in <String>[_validContents, _brokenContents]) {
        mpLocator.mpGeneralController.reset();

        final TH2FileEditController controller = controllerFor(contents);
        final List<(bool, bool, int)> seen = <(bool, bool, int)>[];
        final ReactionDisposer dispose = reaction<int>(
          (_) => controller.structureRevision,
          (_) => seen.add((
            controller.isFileLoaded,
            controller.isBroken,
            controller.problems.length,
          )),
        );

        await controller.load();
        dispose();

        expect(seen, hasLength(1));
        expect(seen.single.$1, isTrue);
        expect(seen.single.$2, contents == _brokenContents);
        expect(seen.single.$3, (contents == _brokenContents) ? 1 : 0);
      }
    });

    test('the pre-parse transition runs an isLoading reaction once', () async {
      final TH2FileEditController controller = controllerFor(_validContents);
      final List<bool> seen = <bool>[];
      final ReactionDisposer dispose = reaction<bool>(
        (_) => controller.isLoading,
        seen.add,
      );

      addTearDown(dispose.call);

      final Future<TH2FileEditControllerCreateResult> load = controller
          .load();

      expect(seen, <bool>[true]);

      await load;

      expect(seen, <bool>[true, false]);
    });

    test('a controller disposed during its load commits nothing', () async {
      final TH2FileEditController controller = controllerFor(_validContents);
      final Future<TH2FileEditControllerCreateResult> load = controller
          .load();

      mpLocator.mpGeneralController.removeFileController(
        filename: controller.th2File.filename,
      );
      await load;

      expect(controller.isDisposed, isTrue);
      expect(controller.isFileLoaded, isFalse);
      expect(controller.isBroken, isFalse);
      expect(controller.problems, isEmpty);
      expect(controller.structureRevision, 0);
      expect(controller.enableSaveButton, isFalse);
    });

    test('a disposed controller whose load throws records nothing', () async {
      final TH2FileEditController controller = controllerFor(
        _throwingContents,
      );
      final Future<TH2FileEditControllerCreateResult> load = controller
          .load();

      mpLocator.mpGeneralController.removeFileController(
        filename: controller.th2File.filename,
      );

      await expectLater(load, throwsA(anything));
      expect(controller.loadError, isNull);
      expect(controller.isFileLoaded, isFalse);
    });
  });

  group('load failure', () {
    test('an unexpected exception is recorded, not retried', () async {
      final TH2FileEditController controller = controllerFor(
        _throwingContents,
      );
      int loadErrorRuns = 0;
      final ReactionDisposer dispose = reaction<Object?>(
        (_) => controller.loadError,
        (_) => loadErrorRuns++,
      );

      addTearDown(dispose.call);

      final Future<TH2FileEditControllerCreateResult> firstLoad = controller
          .load();

      await expectLater(firstLoad, throwsA(anything));

      expect(controller.loadError, isNotNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isFileLoaded, isFalse);
      expect(controller.problems, isEmpty);
      expect(loadErrorRuns, 1);
      expect(identical(controller.load(), firstLoad), isTrue);
      expect(loadErrorRuns, 1);
    });

    test('Reload after a failed load loads a fresh controller', () async {
      final String path = writeFile('failing.th2', _throwingContents);
      final TH2FileEditController failed = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      await expectLater(failed.load(), throwsA(anything));
      expect(failed.loadError, isNotNull);

      writeFile('failing.th2', _validContents);

      final TH2FileEditController reloaded = await mpLocator
          .mpGeneralController
          .reloadTH2File(path);

      expect(reloaded, isNot(same(failed)));
      expect(reloaded.loadError, isNull);
      expect(reloaded.isFileLoaded, isTrue);
      expect(reloaded.isBroken, isFalse);
    });
  });

  group('th2ControllersRevision', () {
    int revision() => mpLocator.mpGeneralController.th2ControllersRevision;

    test('changes exactly when the registry changes', () async {
      final String path = writeFile('a.th2', _validContents);
      int before = revision();
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      expect(revision(), greaterThan(before));

      before = revision();
      mpLocator.mpGeneralController.getTH2FileEditController(filename: path);
      expect(revision(), before);

      before = revision();
      mpLocator.mpGeneralController.renameFileController(
        oldFilename: path,
        newFilename: p.join(tempDir.path, 'b.th2'),
      );
      expect(revision(), greaterThan(before));
      mpLocator.mpGeneralController.renameFileController(
        oldFilename: p.join(tempDir.path, 'b.th2'),
        newFilename: path,
      );

      await controller.load();

      before = revision();
      await mpLocator.mpGeneralController.reloadTH2File(path);
      expect(revision(), greaterThan(before));

      before = revision();
      mpLocator.mpGeneralController.disposeTablessTH2Controllers(<String>[
        path,
      ]);
      expect(revision(), greaterThan(before));

      mpLocator.mpGeneralController.getTH2FileEditController(filename: path);
      before = revision();
      mpLocator.mpGeneralController.removeFileController(filename: path);
      expect(revision(), greaterThan(before));

      mpLocator.mpGeneralController.getTH2FileEditController(filename: path);
      before = revision();
      mpLocator.mpGeneralController.reset();
      expect(revision(), greaterThan(before));

      before = revision();
      mpLocator.mpGeneralController.reset();
      expect(revision(), before);
    });

    test('a controller lookup reruns on create, reload and remove', () async {
      final String path = writeFile('observed.th2', _validContents);
      final List<TH2FileEditController?> seen = <TH2FileEditController?>[];
      final ReactionDisposer dispose = reaction<TH2FileEditController?>(
        (_) =>
            mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path),
        seen.add,
      );

      addTearDown(dispose.call);

      final TH2FileEditController created = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      expect(seen, <TH2FileEditController?>[created]);

      final TH2FileEditController reloaded = await mpLocator
          .mpGeneralController
          .reloadTH2File(path);

      expect(seen, <TH2FileEditController?>[created, reloaded]);

      mpLocator.mpGeneralController.removeFileController(filename: path);

      expect(seen, <TH2FileEditController?>[created, reloaded, null]);
    });

    test('a lookup reruns once after reset, never for an empty reset', () {
      final String path = writeFile('reset.th2', _validContents);
      final TH2FileEditController created = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);
      final List<TH2FileEditController?> seen = <TH2FileEditController?>[];
      final ReactionDisposer dispose = reaction<TH2FileEditController?>(
        (_) =>
            mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path),
        seen.add,
      );

      addTearDown(dispose.call);

      expect(created.isDisposed, isFalse);

      mpLocator.mpGeneralController.reset();

      expect(seen, <TH2FileEditController?>[null]);

      mpLocator.mpGeneralController.reset();

      expect(seen, <TH2FileEditController?>[null]);
    });

    test('Reload replaces the controller without an intermediate null', () async {
      final String path = writeFile('reload.th2', _validContents);
      final TH2FileEditController original = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      await original.load();

      final List<TH2FileEditController?> seen = <TH2FileEditController?>[];
      final ReactionDisposer dispose = reaction<TH2FileEditController?>(
        (_) =>
            mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path),
        seen.add,
      );

      addTearDown(dispose.call);

      final TH2FileEditController reloaded = await mpLocator
          .mpGeneralController
          .reloadTH2File(path);

      expect(seen, <TH2FileEditController?>[reloaded]);
      expect(original.isDisposed, isTrue);
    });
  });

  group('Reload never changes tab ownership', () {
    test('closing the tab during a Reload keeps it closed', () async {
      final String path = writeFile('tab.th2', _validContents);
      final TH2FileEditController original = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: path);

      await original.load();
      mpLocator.mpGeneralController.addFileTab(path);

      final Future<TH2FileEditController> reload = mpLocator
          .mpGeneralController
          .reloadTH2File(path);

      mpLocator.mpGeneralController.removeFileTab(filename: path);
      await reload;

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    test('switching tabs during a Reload keeps the new active tab', () async {
      final String first = writeFile('first.th2', _validContents);
      final String second = writeFile('second.th2', _validContents);

      for (final String path in <String>[first, second]) {
        await mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path)
            .load();
        mpLocator.mpGeneralController.addFileTab(path);
      }

      final Future<TH2FileEditController> reload = mpLocator
          .mpGeneralController
          .reloadTH2File(first);

      mpLocator.mpGeneralController.setActiveTab(1);
      await reload;

      expect(mpLocator.mpGeneralController.activeTabIndex, 1);
      expect(mpLocator.mpGeneralController.openFileOrder, <String>[
        first,
        second,
      ]);
    });

    test('a tab-less Reload stays tab-less', () async {
      final String path = writeFile('tabless.th2', _validContents);

      await mpLocator.mpGeneralController.reloadTH2File(path);

      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });

    test('overlapping Reloads leave only the newest controller', () async {
      final String path = writeFile('overlap.th2', _validContents);

      mpLocator.mpGeneralController.addFileTab(path);

      final Future<TH2FileEditController> firstReload = mpLocator
          .mpGeneralController
          .reloadTH2File(path);
      final Future<TH2FileEditController> secondReload = mpLocator
          .mpGeneralController
          .reloadTH2File(path);
      final TH2FileEditController second = await secondReload;
      final TH2FileEditController first = await firstReload;

      expect(first.isDisposed, isTrue);
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path),
        same(second),
      );
      expect(mpLocator.mpGeneralController.openFileOrder, <String>[path]);
    });

    test('closing the project during a Reload creates nothing', () async {
      final String config = writeFile('thconfig', 'source cave.th\n');

      writeFile('cave.th', 'survey cave\n  input passage.th2\nendsurvey\n');

      final String path = writeFile('passage.th2', _validContents);

      await mpLocator.thProjectController.openProject(config);

      final Future<TH2FileEditController> reload = mpLocator
          .mpGeneralController
          .reloadTH2File(path);

      mpLocator.thProjectController.closeProject();

      final TH2FileEditController reloaded = await reload;

      expect(reloaded.isDisposed, isTrue);
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path),
        isNull,
      );
      expect(mpLocator.mpGeneralController.openFileOrder, isEmpty);
    });
  });

  group('observable Save As and revisions', () {
    test('Save As of a new file marks it loaded in one transition', () async {
      final FilePickerPlatform previousPicker = FilePickerPlatform.instance;
      final _FakeFilePicker picker = _FakeFilePicker();
      final String target = p.join(tempDir.path, 'saved.th2');

      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = previousPicker);
      picker.result = Uri.file(target);

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'fresh',
            scrapOptions: const <THCommandOption>[],
            encoding: mpDefaultEncoding,
          );
      final List<(String, String)> seen = <(String, String)>[];
      final ReactionDisposer dispose = reaction<bool>(
        (_) => controller.isFileLoaded,
        (_) => seen.add((
          controller.th2File.filename,
          controller.currentScrapName,
        )),
      );

      addTearDown(dispose.call);
      await controller.saveAsTH2File();

      expect(controller.isFileLoaded, isTrue);
      expect(seen, <(String, String)>[(target, 'fresh')]);
    });

    test('subtype-only edits bump structureRevision, other options do not', () async {
      final TH2FileEditController controller = controllerFor(_validContents);

      await controller.load();

      final int point = controller.th2File.mpIDByTHID('p1')!;
      final int start = controller.structureRevision;

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THSubtypeCommandOption(parentMPID: point, subtype: 'fixed'),
        ),
      );
      expect(controller.structureRevision, start + 1);

      controller.undo();
      expect(controller.structureRevision, start + 2);

      controller.execute(
        MPCommandFactory.removeOptionFromElements(
          optionType: THCommandOptionType.subtype,
          parentMPIDs: <int>[controller.th2File.mpIDByTHID('p2')!],
          th2File: controller.th2File,
        ),
      );
      expect(controller.structureRevision, start + 3);

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THStationNameCommandOption(parentMPID: point, name: '1'),
        ),
      );
      expect(controller.structureRevision, start + 3);
    });
  });

  group('canonical paths', () {
    test('new-file names are unchanged', () {
      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'fresh',
            scrapOptions: const <THCommandOption>[],
            encoding: mpDefaultEncoding,
          );

      expect(controller.th2File.filename, startsWith(mpNewFilePrefix));
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          controller.th2File.filename,
        ),
        same(controller),
      );
    });

    test('relative paths with dot segments use the project definition', () {
      for (final String path in <String>[
        'test/./auxiliary/../auxiliary/x.th2',
        './relative.th2',
        '../outside/y.th2',
      ]) {
        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);

        expect(
          controller.th2File.filename,
          THProjectPathResolver.canonicalize(p.absolute(path)),
        );
      }
    });
  });
}
