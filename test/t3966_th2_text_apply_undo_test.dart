// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

const String _text =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    '  point 2 2 station -id p2\n'
    '  line wall\n'
    '    1 1\n'
    '    2 2\n'
    '  endline\n'
    'endscrap\n';

/// A validation cache whose validations wait for [release].
class _HeldValidationCache extends TH2TextValidationCache {
  Completer<void> release = Completer<void>();
  final List<String> validated = <String>[];

  @override
  Future<TH2TextValidationResult> validate(
    String content, {
    required String filename,
    required int th2FileMPID,
    required String lineEnding,
  }) async {
    validated.add(content);
    await release.future;

    return super.validate(
      content,
      filename: filename,
      th2FileMPID: th2FileMPID,
      lineEnding: lineEnding,
    );
  }
}

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    mpLocator.mpGeneralController.reset();
  });

  String liveText(TH2FileEditController controller) =>
      controller.serializeForTextMode().$1;

  Future<TH2TextApplyResult> apply(
    TH2FileEditController controller,
    TH2TextTestSession session,
    String text, {
    bool lockBufferOnAccept = false,
  }) {
    session.content = text;

    return controller.applyTextContent(
      text,
      session: session,
      lockBufferOnAccept: lockBufferOnAccept,
    );
  }

  group('one canvas undo step', () {
    test('several edited lines apply once; undo and redo restore the texts', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;
      final String edited = _text
          .replaceFirst('point 2 2', 'point 3 3')
          .replaceFirst('    2 2\n', '    2 2\n    4 4\n')
          .replaceFirst('scrap s1\n', 'scrap s1 -projection plan\n');

      final TH2TextApplyResult result = await apply(
        controller,
        session,
        edited,
      );

      expect(result, isA<TH2TextApplyApplied>());
      expect(controller.undoRedoController.undoCount, undoCount + 1);
      expect(liveText(controller), edited);

      controller.undo();
      expect(liveText(controller), session.initialContent);

      controller.redo();
      expect(liveText(controller), edited);
    });

    test('an older canvas command still undoes and redoes after an apply', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final THPoint point =
          controller.th2File.elementByTHID('p1') as THPoint;

      controller.execute(
        MPMovePointCommand(
          pointMPID: point.mpID,
          fromPosition: point.position,
          toPosition: THPositionPart(coordinates: const Offset(9, 9)),
          fromOriginalLineInTH2File: point.originalLineInTH2File,
          toOriginalLineInTH2File: '',
        ),
      );

      final String moved = liveText(controller);
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final String edited = moved.replaceFirst('point 2 2', 'point 3 3');

      await apply(controller, session, edited);
      expect(liveText(controller), edited);

      controller.undo();
      expect(liveText(controller), moved);

      controller.undo();
      expect(liveText(controller), _text);

      controller.redo();
      expect(liveText(controller), moved);

      controller.redo();
      expect(liveText(controller), edited);
    });

    test('two applies are two steps', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;
      final String first = _text.replaceFirst('point 2 2', 'point 3 3');

      await apply(controller, session, first);
      session.restartFrom(controller);

      final String second = first.replaceFirst('point 3 3', 'point 4 4');

      await apply(controller, session, second);

      expect(controller.undoRedoController.undoCount, undoCount + 2);

      controller.undo();
      expect(liveText(controller), first);
      controller.undo();
      expect(liveText(controller), _text);
    });
  });

  test('an empty buffer resets the active scrap; undo restores one', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _text,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);
    final int activeScrapID = controller.activeScrapID;

    expect(activeScrapID, isNot(0));

    final TH2TextApplyResult result = await apply(controller, session, '');

    expect(result, isA<TH2TextApplyApplied>());
    expect(controller.activeScrapID, 0);
    expect(controller.currentScrapName, '');
    expect(controller.selectionController.getMPSelectableElements(), isEmpty);

    controller.undo();

    expect(controller.activeScrapID, activeScrapID);
    expect(controller.th2File.scrapMPIDs, contains(controller.activeScrapID));
    expect(controller.currentScrapName, 's1');

    controller.redo();

    expect(controller.activeScrapID, 0);
    expect(controller.currentScrapName, '');
  });

  group('unchanged', () {
    test('the initial text adds no command', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;

      final TH2TextApplyResult result = await apply(
        controller,
        session,
        session.initialContent,
      );

      expect(result, isA<TH2TextApplyUnchanged>());
      expect(controller.undoRedoController.undoCount, undoCount);
    });

    test('text that normalizes back adds no command', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;

      session.cursorLine = 6;

      final TH2TextApplyResult result = await apply(
        controller,
        session,
        _text.replaceFirst('    2 2\n', '    2 2\n    2 2\n'),
      );

      expect(result, isA<TH2TextApplyUnchanged>());
      expect((result as TH2TextApplyUnchanged).cursorLine, 6);
      expect(controller.undoRedoController.undoCount, undoCount);
    });
  });

  group('staleness', () {
    Future<
      (
        TH2FileEditController,
        TH2TextTestSession,
        _HeldValidationCache,
        Map<String, dynamic>,
        int,
      )
    >
    held() async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _text,
      );
      final _HeldValidationCache cache = _HeldValidationCache();
      final TH2TextTestSession session = TH2TextTestSession.of(
        controller,
        validationCache: cache,
      );

      return (
        controller,
        session,
        cache,
        controller.th2File.toMap(),
        controller.undoRedoController.undoCount,
      );
    }

    test('a changed buffer is validated before it is applied', () async {
      final (
        TH2FileEditController controller,
        TH2TextTestSession session,
        _HeldValidationCache cache,
        _,
        _,
      ) = await held();
      final String first = _text.replaceFirst('point 2 2', 'point 3 3');
      final String second = _text.replaceFirst('point 2 2', 'point 4 4');
      final Future<TH2TextApplyResult> pending = apply(
        controller,
        session,
        first,
      );

      session.content = second;
      cache.release.complete();

      final TH2TextApplyResult result = await pending;

      expect(result, isA<TH2TextApplyApplied>());
      expect(cache.validated, <String>[first, second]);
      expect(liveText(controller), second);
    });

    for (final String change in <String>['revision', 'closed', 'disposed']) {
      test('a $change session or controller cancels', () async {
        final (
          TH2FileEditController controller,
          TH2TextTestSession session,
          _HeldValidationCache cache,
          Map<String, dynamic> modelBefore,
          int undoCount,
        ) = await held();
        final Future<TH2TextApplyResult> pending = apply(
          controller,
          session,
          _text.replaceFirst('point 2 2', 'point 3 3'),
          lockBufferOnAccept: true,
        );

        switch (change) {
          case 'revision':
            session.sessionRevision++;
          case 'closed':
            session.isOpen = false;
          case 'disposed':
            controller.dispose();
        }
        cache.release.complete();

        expect(await pending, isA<TH2TextApplyCancelled>());
        expect(controller.th2File.toMap(), modelBefore);
        expect(controller.undoRedoController.undoCount, undoCount);
        expect(session.lockBufferCalls, 0);
      });
    }
  });

  test('lockBufferOnAccept locks only applied and unchanged results', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _text,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    await apply(controller, session, _text, lockBufferOnAccept: true);
    expect(session.lockBufferCalls, 1);

    await apply(
      controller,
      session,
      _text.replaceFirst('    2 2\n', '    2 2\n    2 2\n'),
      lockBufferOnAccept: true,
    );
    expect(session.lockBufferCalls, 2);

    await apply(
      controller,
      session,
      _text.replaceFirst('point 1 1', 'poin 1 1'),
      lockBufferOnAccept: true,
    );
    expect(session.lockBufferCalls, 2);

    final TH2TextApplyResult applied = await apply(
      controller,
      session,
      _text.replaceFirst('point 2 2', 'point 3 3'),
      lockBufferOnAccept: true,
    );

    expect(applied, isA<TH2TextApplyApplied>());
    expect(session.lockBufferCalls, 3);

    session.restartFrom(controller);
    await apply(
      controller,
      session,
      _text.replaceFirst('point 2 2', 'point 5 5'),
    );
    expect(session.lockBufferCalls, 3);
  });
}
