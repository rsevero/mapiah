// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/th_element.dart';

import 'th2_text_mode_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  line border -id b1 -close on\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n'
    '  area water\n'
    '    b1\n'
    '  endarea\n'
    'endscrap\n'
    'scrap s2\n'
    '  point 5 5 station -id p2\n'
    'endscrap\n';

const String _borderBlock =
    '  line border -id b1 -close on\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n';

const String _areaBlock =
    '  area water\n'
    '    b1\n'
    '  endarea\n';

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();
  final List<String> clipboard = <String>[];

  setUp(() async {
    await TH2TextModeTestAux.setUp();
    clipboard.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            clipboard.add(
              (call.arguments as Map<Object?, Object?>)['text']! as String,
            );
          }

          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
  });

  MPCommand removeP1(TH2FileEditController controller) =>
      MPCommandFactory.removePointFromExisting(
        existingPointMPID: controller.th2File.mpIDByTHID('p1')!,
        th2File: controller.th2File,
      );

  test('tree edits refuse a file in text mode and work again on the canvas',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final String path = controller.th2File.filename;

    await TH2TextModeTestAux.enter(controller);

    final int activeTab = locator.mpGeneralController.activeTabIndex;

    expect(locator.mpGeneralController.prepareTH2FileForTreeEdit(path), isNull);
    expect(
      locator.mpGeneralController.prepareTH2FileForTreeOptions(path),
      isNull,
    );
    expect(locator.mpGeneralController.activeTabIndex, activeTab);
    expect(
      locator.mpGeneralController.prepareTH2FileForTreeRead(path),
      same(controller),
    );

    final String encoding = controller.th2File.encoding;

    controller.propertiesController.prepareSetEncoding('ISO8859-1');
    expect(controller.th2File.encoding, encoding);

    await controller.discardTextEdits();
    expect(
      locator.mpGeneralController.prepareTH2FileForTreeEdit(path),
      same(controller),
    );
  });

  test('model commands and stack changes are rejected in text mode before any '
      'change', () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );

    /// One canvas step to undo and revert.
    controller.execute(removeP1(controller));
    controller.undo();
    controller.redo();

    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );
    final Map<String, dynamic> model = controller.th2File.toMap();
    final int undoCount = controller.undoRedoController.undoCount;
    final bool hasRedo = controller.undoRedoController.hasRedo;
    final String content = session.content;
    final int revision = session.sessionRevision;
    final MPCommand command = MPCommandFactory.removePointFromExisting(
      existingPointMPID: controller.th2File.mpIDByTHID('p2')!,
      th2File: controller.th2File,
    );

    void expectNothingChanged() {
      expect(controller.th2File.toMap(), model);
      expect(controller.undoRedoController.undoCount, undoCount);
      expect(controller.undoRedoController.hasRedo, hasRedo);
      expect(session.content, content);
      expect(session.sessionRevision, revision);
      expect(controller.editMode, TH2EditMode.text);
    }

    expect(() => controller.execute(command), throwsA(isA<AssertionError>()));
    expectNothingChanged();
    expect(() => command.execute(controller), throwsA(isA<AssertionError>()));
    expectNothingChanged();
    expect(
      () => controller.executeSubstitutingLastUndo(command),
      throwsA(isA<AssertionError>()),
    );
    expectNothingChanged();
    expect(
      controller.revertLastUndoWithoutRedo,
      throwsA(isA<AssertionError>()),
    );
    expectNothingChanged();
    expect(
      controller.undoRedoController.undo,
      throwsA(isA<AssertionError>()),
    );
    expectNothingChanged();
    expect(
      controller.undoRedoController.redo,
      throwsA(isA<AssertionError>()),
    );
    expectNothingChanged();
    expect(
      () => controller.undoRedoController.add(command),
      throwsA(isA<AssertionError>()),
    );
    expectNothingChanged();

    /// The public undo and redo do nothing, quietly.
    controller.undo();
    controller.redo();
    expectNothingChanged();

    /// Authorized mutations still run.
    controller.runAuthorizedMutation<void>(controller.undo);
    expect(controller.undoRedoController.undoCount, undoCount - 1);
  });

  test('applyTextContent outside a gated operation fails its assertion',
      () async {
    final TH2FileEditController controller = await TH2TextModeTestAux.open(
      _text,
    );
    final TH2TextEditController session = await TH2TextModeTestAux.enter(
      controller,
    );

    expect(
      () => controller.applyTextContent(session.content, session: session),
      throwsA(isA<AssertionError>()),
    );
  });

  group('copyTextFragment', () {
    Future<String> copy(
      TH2FileEditController controller,
      List<String> thIDs,
    ) async {
      await controller.copyTextFragment(<int>[
        for (final String thID in thIDs) controller.th2File.mpIDByTHID(thID)!,
      ]);

      return clipboard.last;
    }

    test('copies blocks in text order, areas with their border lines',
        () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text,
      );

      await TH2TextModeTestAux.enter(controller);

      final THArea area = controller.th2File.elements.values
          .whereType<THArea>()
          .single;

      expect(
        await copy(controller, <String>['p2', 'p1']),
        '  point 1 1 station -id p1\n  point 5 5 station -id p2\n',
      );

      await controller.copyTextFragment(<int>[area.mpID]);
      expect(clipboard.last, '$_borderBlock$_areaBlock');

      await controller.copyTextFragment(<int>[
        area.mpID,
        controller.th2File.mpIDByTHID('b1')!,
      ]);
      expect(clipboard.last, '$_borderBlock$_areaBlock');

      /// A selected ancestor excludes its descendants.
      expect(
        await copy(controller, <String>['s2', 'p2']),
        'scrap s2\n  point 5 5 station -id p2\nendscrap\n',
      );

      /// Mapiah's own clipboard is untouched.
      expect(locator.mpGeneralController.hasClipboardContent, isFalse);
    });

    test('keeps the line endings and uses the baseline text', () async {
      final TH2FileEditController controller = await TH2TextModeTestAux.open(
        _text.replaceAll('\n', '\r\n'),
      );

      await TH2TextModeTestAux.enter(controller);
      TH2TextModeTestAux.edit(
        controller,
        controller.textEditController!.content.replaceFirst('p1', 'px'),
      );

      expect(
        await copy(controller, <String>['p1']),
        '  point 1 1 station -id p1\r\n',
      );
    });
  });
}
