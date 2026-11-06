// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/widgets/th2_broken_file_body_widget.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:mapiah/src/widgets/th2_text_edit_body_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

/// Line 1 (0-based) is outside a scrap and line 4 doesn't parse.
const String _broken =
    'encoding utf-8\n'
    'point 10 20 station -name 1\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    '  poin 150 250 station -name 3\n'
    'endscrap\n';

/// [_broken] fixed, with a second scrap.
const String _fixed =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    '  point 150 250 station -name 3\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 1 1 station -name 4\n'
    'endscrap\n';

/// [_broken] with an edit that doesn't fix it.
const String _stillBroken =
    'encoding utf-8\n'
    'point 10 20 station -name 1\n'
    'scrap s1\n'
    '  point 30 40 station -name 2\n'
    '  poin 150 251 station -name 3\n'
    'endscrap\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUp(TH2TextModeTestAux.setUp);

  tearDown(() {
    TH2TextValidator.onScratchControllerCreatedForTesting = null;
    TH2FileEditControllerBase.beforeBrokenTextEntryValidationForTesting = null;
  });

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  /// Counts the parses of text validation for this test.
  List<int> countParses() {
    final List<int> count = <int>[0];

    TH2TextValidator.onScratchControllerCreatedForTesting =
        (TH2FileEditController _) {
          count[0]++;
        };

    return count;
  }

  Future<TH2FileEditController> openBroken([String text = _broken]) async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      text,
    );

    expect(controller.isBroken, isTrue);

    return controller;
  }

  Future<TH2FileEditController> openBrokenBytes(List<int> bytes) async {
    final Directory directory = TH2TextModeTestAux.tempDirectory();
    final String path = p.join(directory.path, 'file.th2');

    File(path).writeAsBytesSync(bytes);

    final TH2FileEditController controller = locator.mpGeneralController
        .getTH2FileEditController(filename: path);

    await controller.load();
    locator.mpGeneralController.addFileTab(path);
    expect(controller.isBroken, isTrue);

    return controller;
  }

  Set<int?> errorLines(TH2TextEditController session) => <int?>{
    for (final diagnostic in session.diagnostics)
      if (diagnostic.severity.name == 'error') diagnostic.line,
  };

  group('entry', () {
    test('opens the disk text byte for byte with the problems marked and '
        'the cursor on the first error', () async {
      const String text =
          'encoding utf-8\r\n'
          'scrap s1\n'
          '  point 1 1 station -name 1\r\n'
          '  poin 2 2 station -name 2\n'
          'endscrap';
      final TH2FileEditController controller = await openBroken(text);
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      expect(session.content, text);
      expect(session.initialContent, text);
      expect(session.isDirty, isFalse);
      expect(session.cursorLine, 3);
      expect(session.cursorColumn, 2);
      expect(errorLines(session), contains(3));
      expect(session.initialLineMap.ownerMPIDs, isEmpty);
      expect(session.initialLineMap.lineCount, 5);
      expect(controller.isBroken, isTrue);
      expect(controller.canSave, isFalse);
    });

    test('a file changed on disk after the load opens on its new text',
        () async {
      final TH2FileEditController controller = await openBroken();

      const String changed =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 30 40 station -name 2\n'
          'endscrap\n'
          '  poin 1 1 station\n';

      File(controller.th2File.filename).writeAsStringSync(changed);

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      expect(session.content, changed);
      expect(session.cursorLine, 4);
      expect(errorLines(session), <int?>{4});
    });

    test('a lone carriage return stays on the broken-file body', () async {
      final List<String> messages = TH2TextModeTestAux.captureUserMessages();
      final TH2FileEditController controller = await openBroken(
        '# a\rb\nencoding utf-8\nscrap s1\n  poin 1 1\nendscrap\n',
      );

      await controller.enterTextMode();

      expect(controller.editMode, TH2EditMode.canvas);
      expect(messages, <String>[
        locator.appLocalizations.th2TextUnsupportedLineEndingMessage,
      ]);
    });

    final List<({String label, List<int> bytes, String encoding})>
    invalidEncodings = <({String label, List<int> bytes, String encoding})>[
      (
        label: 'invalid UTF-8 with an encoding line',
        bytes: <int>[...'encoding utf-8\nscrap s1 \xff\nendscrap\n'.codeUnits],
        encoding: 'UTF-8',
      ),
      (
        label: 'invalid UTF-8 with no encoding line',
        bytes: <int>[...'scrap s1 \xff\nendscrap\n'.codeUnits],
        encoding: 'UTF-8',
      ),
      (
        label: 'a byte above 0x7f in ASCII',
        bytes: <int>[...'encoding ASCII\nscrap s1 \xe9\nendscrap\n'.codeUnits],
        encoding: 'ASCII',
      ),
      (
        label: 'byte 0x81 in CP1252',
        bytes: <int>[...'encoding cp1252\nscrap s1 \x81\nendscrap\n'.codeUnits],
        encoding: 'CP1252',
      ),
    ];

    for (final ({String label, List<int> bytes, String encoding}) testCase
        in invalidEncodings) {
      test('${testCase.label} stays on the body with the invalid-encoding '
          'message', () async {
        final List<String> messages = TH2TextModeTestAux.captureUserMessages();
        final TH2FileEditController controller = await openBrokenBytes(
          testCase.bytes,
        );

        await controller.enterTextMode();

        expect(controller.editMode, TH2EditMode.canvas);
        expect(controller.isOperationBusy, isFalse);
        expect(messages, <String>[
          locator.appLocalizations.th2BrokenFileTextInvalidEncodingMessage(
            'file.th2',
            testCase.encoding,
          ),
        ]);
      });
    }

    test('an unknown encoding with invalid UTF-8 gets the unknown-encoding '
        'message', () async {
      final List<String> messages = TH2TextModeTestAux.captureUserMessages();
      final TH2FileEditController controller = await openBrokenBytes(<int>[
        ...'encoding foo\nscrap s1 \xff\nendscrap\n'.codeUnits,
      ]);

      await controller.enterTextMode();

      expect(controller.editMode, TH2EditMode.canvas);
      expect(messages, <String>[
        locator.appLocalizations.th2BrokenFileTextUnknownEncodingMessage(
          'file.th2',
          'FOO',
        ),
      ]);
    });

    test('a file deleted after the load gets the unreadable message', () async {
      final List<String> messages = TH2TextModeTestAux.captureUserMessages();
      final TH2FileEditController controller = await openBroken();

      File(controller.th2File.filename).deleteSync();
      await controller.enterTextMode();

      expect(controller.editMode, TH2EditMode.canvas);
      expect(messages, <String>[
        locator.appLocalizations.th2BrokenFileTextUnreadableMessage('file.th2'),
      ]);
    });

    test('a second entry while the first one runs starts no second '
        'validation', () async {
      final List<int> parses = countParses();
      final TH2FileEditController controller = await openBroken();
      final Completer<void> hold = Completer<void>();

      TH2FileEditControllerBase.beforeBrokenTextEntryValidationForTesting =
          () => hold.future;

      final Future<void> first = controller.enterTextMode();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.isOperationBusy, isTrue);

      final Future<void> second = controller.enterTextMode();

      hold.complete();
      await first;
      await second;

      expect(controller.editMode, TH2EditMode.text);
      expect(parses[0], 1);
    });
  });

  group('leaving and discarding', () {
    test('an unchanged buffer returns to the body with no parse and no '
        'banner', () async {
      final List<int> parses = countParses();
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      expect(parses[0], 1);

      await controller.leaveTextMode();

      expect(parses[0], 1);
      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isTrue);
      expect(controller.showTextApplyRejection, isFalse);
      expect(controller.textApplyRejection, isNull);
    });

    for (final bool idleBeforeLeave in <bool>[false, true]) {
      test('a buffer edited and undone returns to the body with no banner '
          '(${idleBeforeLeave ? 'after' : 'before'} its idle '
          'validation)', () async {
        final List<int> parses = countParses();
        final TH2FileEditController controller = await openBroken();

        await TH2TextModeTestAux.enter(controller);
        TH2TextModeTestAux.edit(controller, _stillBroken);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        expect(parses[0], 2);
        TH2TextModeTestAux.edit(controller, _broken);

        if (idleBeforeLeave) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          expect(parses[0], 3);
        }

        await controller.leaveTextMode();

        expect(parses[0], 3);
        expect(controller.editMode, TH2EditMode.canvas);
        expect(controller.isBroken, isTrue);
        expect(controller.textApplyRejection, isNull);
      });
    }

    test('an edited invalid buffer shows the banner; Discard returns to the '
        'body', () async {
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _stillBroken);
      expect(controller.canSave, isTrue);

      await controller.leaveTextMode();

      expect(controller.editMode, TH2EditMode.text);
      expect(controller.showTextApplyRejection, isTrue);
      expect(
        controller.textEditController!.diagnostics.any(
          (diagnostic) => diagnostic.line == 4,
        ),
        isTrue,
      );
      expect(controller.isBroken, isTrue);
      expect(TH2TextModeTestAux.readFile(controller), _broken);

      await controller.discardTextEdits();

      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isTrue);
      expect(controller.canSave, isFalse);
      expect(TH2TextModeTestAux.readFile(controller), _broken);
    });

    test('a file fixed on disk after the load applies with an unchanged '
        'buffer from the cached validation', () async {
      final List<int> parses = countParses();
      final TH2FileEditController controller = await openBroken();

      File(controller.th2File.filename).writeAsStringSync(_fixed);

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      expect(errorLines(session), isEmpty);
      expect(parses[0], 1);

      await controller.leaveTextMode();

      expect(parses[0], 1);
      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isFalse);
      expect(controller.hasUnsavedBaseline, isTrue);
      expect(controller.canSave, isTrue);
    });
  });

  group('the broken-file baseline', () {
    test('a fix applies as a new baseline set up as a valid load', () async {
      final TH2FileEditController controller = await openBroken();
      final String path = canonical(controller.th2File.filename);
      final List<bool> dirtyChanges = <bool>[];
      final ReactionDisposer disposer = reaction(
        (_) => locator.thProjectController.dirtyFilePaths.contains(path),
        (bool isDirty) => dirtyChanges.add(isDirty),
      );

      addTearDown(disposer.call);

      /// A reader of the station cache while the file is broken.
      controller.updateScreenSize(const Size(1000, 1000));
      controller.zoomToFit(zoomFitToType: MPZoomToFitType.file);
      expect(
        controller.userInteractionController
            .getTherionStationPointNameCoordinateCache(),
        isNotEmpty,
      );

      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, _fixed);
      session.setCursorPosition(line: 3, column: 2);
      await controller.leaveTextMode();

      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isFalse);
      expect(controller.problems, isEmpty);
      expect(controller.errorMessages, isEmpty);
      expect(controller.serializeForTextMode().$1, _fixed);
      expect(controller.activeScrapID, controller.th2File.scrapMPIDs.first);
      expect(controller.currentScrapName, 's1');
      expect(controller.hasMultipleScraps, isTrue);
      expect(controller.selectionController.getMPSelectableElements(), isNotEmpty);
      expect(controller.undoRedoController.hasUndo, isFalse);
      expect(controller.hasUnsavedBaseline, isTrue);
      expect(controller.enableSaveButton, isTrue);
      expect(controller.canSave, isTrue);
      expect(locator.thProjectController.dirtyFilePaths, contains(path));
      expect(dirtyChanges, <bool>[true]);

      final List<MPStationPointNameCoordinateRecord> stations = controller
          .userInteractionController
          .getTherionStationPointNameCoordinateCache();

      /// Not the broken model's stations.
      expect(stations, isNotEmpty);
      for (final MPStationPointNameCoordinateRecord record in stations) {
        expect(controller.th2File.hasElementByMPID(record.elementMPID!), isTrue);
      }

      /// The leave's cursor selects the point on its line.
      final THPoint selected =
          controller.selectionController.mpSelectedElementsLogical.values
                  .single
                  .originalElementClone
              as THPoint;

      expect(selected.position.coordinates, const Offset(150, 250));

      /// Undo can't reach behind the baseline.
      controller.undo();
      expect(controller.serializeForTextMode().$1, _fixed);
      expect(controller.isBroken, isFalse);
    });

    test('the next text session after the baseline is one canvas step',
        () async {
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _fixed);
      await controller.leaveTextMode();

      /// The next text session is one canvas step, which undoes back to the
      /// fixed text and no further.
      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(
        controller,
        _fixed.replaceFirst('point 1 1', 'point 7 7'),
      );
      await controller.leaveTextMode();

      expect(controller.undoRedoController.undoCount, 1);
      controller.undo();
      expect(controller.serializeForTextMode().$1, _fixed);
      expect(controller.undoRedoController.hasUndo, isFalse);
    });

    test('a canvas edit after the baseline undoes back to the fixed text',
        () async {
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _fixed);
      await controller.leaveTextMode();

      final THPoint point = controller.th2File.getPoints().first;

      controller.execute(
        MPCommandFactory.removePointFromExisting(
          existingPointMPID: point.mpID,
          th2File: controller.th2File,
        ),
      );
      expect(controller.serializeForTextMode().$1, isNot(_fixed));
      controller.undo();
      expect(controller.serializeForTextMode().$1, _fixed);
      expect(controller.undoRedoController.hasUndo, isFalse);
      expect(controller.isBroken, isFalse);
    });

    test('a Properties encoding change on the body is dropped by the '
        'baseline', () async {
      final TH2FileEditController controller = await openBroken();

      controller.propertiesController.prepareSetEncoding('ISO8859-1');
      expect(controller.undoRedoController.hasUndo, isTrue);

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _fixed);
      await controller.leaveTextMode();

      expect(controller.th2File.encoding, 'UTF-8');
      expect(controller.undoRedoController.hasUndo, isFalse);
      controller.undo();
      expect(controller.th2File.encoding, 'UTF-8');
    });

    test('Save writes the fixed text and leaves an ordinary session',
        () async {
      final TH2FileEditController controller = await openBroken();
      final TH2TextEditController session = await TH2TextModeTestAux.enter(
        controller,
      );

      TH2TextModeTestAux.edit(controller, _fixed);

      expect(await controller.saveTH2File(), TH2FileSaveStatus.saved);

      expect(TH2TextModeTestAux.readFile(controller), _fixed);
      expect(controller.isBroken, isFalse);
      expect(controller.hasUnsavedBaseline, isFalse);
      expect(controller.canSave, isFalse);
      expect(controller.editMode, TH2EditMode.text);
      expect(session.isOpen, isTrue);
      expect(session.content, _fixed);
      expect(session.initialLineMap.ownerMPIDs, isNotEmpty);
      expect(
        locator.thProjectController.dirtyFilePaths,
        isNot(contains(canonical(controller.th2File.filename))),
      );

      await controller.leaveTextMode();
      expect(controller.editMode, TH2EditMode.canvas);
      expect(controller.isBroken, isFalse);
    });

    test('Save on a broken file with no session writes nothing', () async {
      final TH2FileEditController controller = await openBroken();

      expect(await controller.saveTH2File(), TH2FileSaveStatus.saveFailed);
      expect(TH2TextModeTestAux.readFile(controller), _broken);
    });

    test('Reload after an unsaved fix brings back the broken file', () async {
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _fixed);
      await controller.leaveTextMode();
      expect(controller.isBroken, isFalse);

      final TH2FileEditController reloaded = await locator.mpGeneralController
          .reloadTH2File(controller.th2File.filename);

      expect(controller.isDisposed, isTrue);
      expect(reloaded.isBroken, isTrue);
      expect(reloaded.hasUnsavedBaseline, isFalse);
      expect(reloaded.canSave, isFalse);
    });
  });

  group('Run Therion', () {
    test('an unsaved fix is still listed as broken; a saved one is not',
        () async {
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final String config = p.join(directory.path, 'thconfig');

      File(config).writeAsStringSync('source cave.th\n');
      File(
        p.join(directory.path, 'cave.th'),
      ).writeAsStringSync('survey cave\n  input file.th2\nendsurvey\n');
      File(p.join(directory.path, 'file.th2')).writeAsStringSync(_broken);
      await locator.thProjectController.openProject(config);

      final TH2FileEditController controller = locator.mpGeneralController
          .getTH2FileEditController(
            filename: p.join(directory.path, 'file.th2'),
          );

      await controller.load();
      locator.mpGeneralController.addFileTab(controller.th2File.filename);

      final String path = canonical(controller.th2File.filename);

      expect(
        locator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
        <String>[path],
      );

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(controller, _fixed);
      await controller.leaveTextMode();
      expect(controller.isBroken, isFalse);
      expect(
        locator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
        <String>[path],
      );

      expect(await controller.saveTH2File(), TH2FileSaveStatus.saved);
      expect(
        locator.mpGeneralController.loadedBrokenProjectTH2FilePaths(),
        isEmpty,
      );
    });
  });

  group('widgets', () {
    void setViewSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    /// Lets the real file I/O and validation of an entry or leave finish.
    Future<void> settle(WidgetTester tester) async {
      for (int attempt = 0; attempt < 10; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
    }

    Future<TH2FileEditController> pumpBrokenTab(
      WidgetTester tester, [
      String text = _broken,
    ]) async {
      setViewSize(tester);

      final TH2FileEditController controller = (await tester.runAsync(
        () => TH2TextModeTestAux.open(text, openTab: false),
      ))!;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await settle(tester);

      return controller;
    }

    final Finder editAsText = find.byKey(
      const ValueKey('TH2BrokenFileBodyEditAsTextButton'),
    );
    final Finder canvasButton = find.byKey(
      const ValueKey<String>('TH2TextEditBodyWidget|CanvasButton'),
    );

    testWidgets('Edit as text opens the raw session; F2 returns to the body',
        (WidgetTester tester) async {
      final TH2FileEditController controller = await pumpBrokenTab(tester);

      expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);
      await tester.tap(editAsText);
      await settle(tester);

      expect(controller.editMode, TH2EditMode.text);
      expect(find.byType(TH2TextEditBodyWidget), findsOneWidget);
      expect(controller.textEditController!.diagnostics, isNotEmpty);
      expect(
        tester.widget<IconButton>(canvasButton).tooltip,
        locator.appLocalizations.th2TextLeaveBrokenFileTooltip,
      );
      expect(
        (tester.widget<IconButton>(canvasButton).icon as Icon).icon,
        Icons.draw_outlined,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);

      expect(controller.editMode, TH2EditMode.canvas);
      expect(find.byType(TH2BrokenFileBodyWidget), findsOneWidget);
      expect(controller.th2FileFocusNode.hasPrimaryFocus, isTrue);
    });

    /// A tab whose controller loads only once the page shows it.
    Future<TH2FileEditController> unloadedController(
      String text,
      String name,
    ) async {
      final Directory directory = TH2TextModeTestAux.tempDirectory();
      final String path = p.join(directory.path, name);

      File(path).writeAsStringSync(text);

      return locator.mpGeneralController.getTH2FileEditController(
        filename: path,
      );
    }

    testWidgets('a freshly opened broken tab has the focus, and F2 opens it '
        'as text', (WidgetTester tester) async {
      setViewSize(tester);

      final TH2FileEditController controller = (await tester.runAsync(
        () => unloadedController(_broken, 'file.th2'),
      ))!;

      expect(controller.isFileLoaded, isFalse);
      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await settle(tester);

      expect(controller.isBroken, isTrue);
      expect(controller.th2FileFocusNode.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);

      expect(controller.editMode, TH2EditMode.text);
      expect(
        controller.textEditController!.textFieldFocusNode.hasFocus,
        isTrue,
      );
    });

    testWidgets('a broken tab loaded in the background takes no focus', (
      WidgetTester tester,
    ) async {
      setViewSize(tester);

      final TH2FileEditController valid = (await tester.runAsync(
        () => TH2TextModeTestAux.open(_fixed, name: 'valid.th2', openTab: false),
      ))!;

      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: valid),
      );
      await settle(tester);

      final TH2FileEditController broken = (await tester.runAsync(
        () => unloadedController(_broken, 'broken.th2'),
      ))!;

      locator.mpGeneralController.addFileTab(broken.th2File.filename);
      locator.mpGeneralController.setActiveTab(0);
      await tester.pump();
      valid.th2FileFocusNode.requestFocus();
      await settle(tester);

      expect(broken.isBroken, isTrue);
      expect(find.byType(TH2BrokenFileBodyWidget, skipOffstage: false),
          findsOneWidget);
      expect(broken.th2FileFocusNode.hasFocus, isFalse);
      expect(valid.th2FileFocusNode.hasPrimaryFocus, isTrue);
    });

    testWidgets('Edit as text is disabled with a spinner while the entry '
        'runs', (WidgetTester tester) async {
      final List<int> parses = countParses();
      final TH2FileEditController controller = await pumpBrokenTab(tester);
      final Completer<void> hold = Completer<void>();

      TH2FileEditControllerBase.beforeBrokenTextEntryValidationForTesting =
          () => hold.future;

      await tester.tap(editAsText);
      await settle(tester);

      expect(controller.isOperationBusy, isTrue);
      expect(
        tester.widget<ElevatedButton>(editAsText).onPressed,
        isNull,
      );
      expect(
        find.descendant(
          of: editAsText,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      hold.complete();
      await settle(tester);

      expect(controller.editMode, TH2EditMode.text);
      expect(parses[0], 1);
    });

    testWidgets('after a refused entry the button is enabled again', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController controller = await pumpBrokenTab(tester);

      File(controller.th2File.filename).deleteSync();
      await tester.tap(editAsText);
      await settle(tester);

      expect(controller.editMode, TH2EditMode.canvas);
      expect(tester.widget<ElevatedButton>(editAsText).onPressed, isNotNull);
      expect(
        find.descendant(of: editAsText, matching: find.byIcon(Icons.edit_note)),
        findsOneWidget,
      );
    });

    testWidgets('a fix shows the canvas; after a Save from text mode the '
        'leave button says Canvas', (WidgetTester tester) async {
      final TH2FileEditController controller = await pumpBrokenTab(tester);

      await tester.tap(editAsText);
      await settle(tester);
      controller.textEditController!.setContent(_fixed);
      await tester.runAsync(controller.saveTH2File);
      await settle(tester);

      expect(controller.isBroken, isFalse);
      expect(controller.editMode, TH2EditMode.text);
      expect(
        tester.widget<IconButton>(canvasButton).tooltip,
        locator.appLocalizations.th2EditModeCanvasTooltip,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);

      expect(controller.editMode, TH2EditMode.canvas);
      expect(find.byType(TH2BrokenFileBodyWidget), findsNothing);
      expect(find.byType(TH2FileWidget), findsOneWidget);
    });

  });

  group('Save As', () {
    test('an unchanged raw buffer opens no picker, shows the banner and '
        'reuses the entry validation', () async {
      final List<int> parses = countParses();
      final TH2TextModeFakeFilePicker picker =
          TH2TextModeTestAux.installPicker();
      final TH2FileEditController controller = await openBroken();

      await TH2TextModeTestAux.enter(controller);
      expect(parses[0], 1);

      expect(
        await controller.saveAsTH2File(),
        TH2FileSaveStatus.textHasProblems,
      );

      expect(parses[0], 1);
      expect(picker.saveFileCalls, 0);
      expect(controller.showTextApplyRejection, isTrue);
    });
  });

  test('raw bytes decode as the load parsed them, NULs stripped', () {
    final Uint8List bytes = Uint8List.fromList(<int>[
      ...'encoding utf-8\nscrap s1\u0000\nendscrap\n'.codeUnits,
    ]);

    expect(
      TH2FileParser.decodeSourceBytes(bytes),
      'encoding utf-8\nscrap s1\nendscrap\n',
    );
    expect(
      () => TH2FileParser.decodeSourceBytes(
        Uint8List.fromList(<int>[...'scrap \xff\n'.codeUnits]),
      ),
      throwsA(
        isA<TH2SourceDecodingException>()
            .having((e) => e.encoding, 'encoding', 'UTF-8')
            .having((e) => e.isKnownEncoding, 'isKnownEncoding', isTrue),
      ),
    );
  });
}
