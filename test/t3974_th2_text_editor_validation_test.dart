// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_diagnostic.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'auxiliary/th2_text_edit_fake_owner.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

const String _baseText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

const String _invalidText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n';

const String _duplicateIDText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n'
    'scrap s1\n'
    'endscrap\n';

const String _duplicateLinePointText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  line wall\n'
    '    1 1\n'
    '    2 2\n'
    '    2 2\n'
    '    3 3\n'
    '  endline\n'
    'endscrap\n';

const Duration _idle = Duration(
  milliseconds: mpTH2TextValidationIdleMilliseconds,
);

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();
  late List<TH2FileEditController> scratches;

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
    scratches = <TH2FileEditController>[];
    TH2TextValidator.onScratchControllerCreatedForTesting = scratches.add;
  });

  tearDown(() {
    TH2TextValidator.onScratchControllerCreatedForTesting = null;
    TH2TextValidator.afterParseForTesting = null;
    mpLocator.mpGeneralController.reset();
  });

  /// A text controller with a session on the live model of [file].
  (TH2TextEditController, TH2TextEditFakeOwner) sessionOf(
    TH2FileEditController file,
  ) {
    final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner.of(file);
    final (String text, TH2TextLineMap lineMap) = file.serializeForTextMode();
    final TH2TextEditController controller = TH2TextEditController(
      owner: owner,
    );

    controller.installBaseline(
      TH2TextEditBaseline(content: text, lineMap: lineMap),
    );

    return (controller, owner);
  }

  List<THTextEditorDiagnosticSeverity> severities(
    TH2TextEditController controller,
  ) => controller.diagnostics
      .map((THTextEditorDiagnostic diagnostic) => diagnostic.severity)
      .toList();

  group('idle validation', () {
    testWidgets('waits for the idle delay while the cursor stays still', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_invalidText);
      await tester.pump(_idle - const Duration(milliseconds: 1));
      expect(scratches, isEmpty);
      expect(controller.diagnostics, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(scratches, hasLength(1));
      expect(controller.diagnostics, isNotEmpty);
      expect(
        controller.diagnostics.first.severity,
        THTextEditorDiagnosticSeverity.error,
      );
      controller.dispose();
    });

    testWidgets('cursor moves neither delay nor trigger validation', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_invalidText);
      await tester.pump(const Duration(milliseconds: 300));
      controller.setCursorPosition(line: 1, column: 0);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(scratches, hasLength(1));

      controller.setCursorPosition(line: 2, column: 0);
      await tester.pump(_idle * 2);
      expect(scratches, hasLength(1));
      controller.dispose();
    });

    testWidgets('only the newest content is validated and shown', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_invalidText);
      await tester.pump(const Duration(milliseconds: 300));
      controller.setContent(_duplicateLinePointText);
      await tester.pump(_idle);
      await tester.pump();
      expect(scratches, hasLength(1));
      expect(severities(controller), <THTextEditorDiagnosticSeverity>[
        THTextEditorDiagnosticSeverity.information,
      ]);
      expect(controller.diagnostics.single.line, 5);
      controller.dispose();
    });

    testWidgets('an edit clears the shown stale diagnostics', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_invalidText);
      await tester.pump(_idle);
      await tester.pump();
      expect(controller.diagnostics, isNotEmpty);

      controller.setContent('$_invalidText ');
      expect(controller.diagnostics, isEmpty);
      await tester.pump(_idle);
      controller.dispose();
    });

    testWidgets('an A→B→A race publishes only the current generation', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);
      bool isEditingDuringValidation = true;

      TH2TextValidator.onScratchControllerCreatedForTesting =
          (TH2FileEditController scratch) {
            scratches.add(scratch);

            if (isEditingDuringValidation) {
              isEditingDuringValidation = false;
              controller.setContent(_baseText);
              controller.setContent(_invalidText);
            }
          };

      controller.setContent(_invalidText);
      await tester.pump(_idle);
      await tester.pump();

      /// The A result arrived for an older generation.
      expect(scratches, hasLength(1));
      expect(controller.diagnostics, isEmpty);

      /// The new idle validation reuses the cached A result.
      await tester.pump(_idle);
      await tester.pump();
      expect(scratches, hasLength(1));
      expect(controller.diagnostics, isNotEmpty);
      controller.dispose();
    });

    testWidgets('an unexpected validation failure is surfaced and logged', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner.of(file);
      final _ThrowingFilenameOwner throwingOwner = _ThrowingFilenameOwner(
        owner,
      );
      final TH2TextEditController controller = TH2TextEditController(
        owner: throwingOwner,
      );
      final (String text, TH2TextLineMap lineMap) = file.serializeForTextMode();

      controller.installBaseline(
        TH2TextEditBaseline(content: text, lineMap: lineMap),
      );
      controller.setContent(_invalidText);
      await tester.pump(_idle);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(controller.diagnostics.single.line, isNull);
      expect(
        controller.diagnostics.single.message,
        AppLocalizationsEn().th2TextDiagnosticValidationFailed,
      );
      controller.dispose();
    });
  });

  group('validation sharing with apply', () {
    testWidgets('an in-flight idle validation is shared', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, TH2TextEditFakeOwner owner) =
          sessionOf(file);
      Future<TH2TextValidationResult>? sharedValidation;

      /// After the parse, the idle validation is the cache's in-flight one.
      TH2TextValidator.afterParseForTesting = () {
        sharedValidation ??= controller.validationCache.validate(
          controller.content,
          filename: owner.filename,
          th2FileMPID: owner.th2FileMPID,
          lineEnding: owner.defaultLineEnding,
        );
      };

      controller.setContent(_duplicateLinePointText);
      await tester.pump(_idle);
      await tester.pump();
      expect(scratches, hasLength(1));

      final TH2TextValidationResult result = await sharedValidation!;

      expect(result.content, _duplicateLinePointText);
      expect(controller.diagnostics, hasLength(1));
      controller.dispose();
    });

    testWidgets('apply reuses the idle result and revalidates a stale one', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);
      final String edited = _baseText.replaceFirst('1 1', '5 5');

      controller.setContent(edited);
      await tester.pump(_idle);
      await tester.pump();
      expect(scratches, hasLength(1));

      final TH2TextApplyResult cached = await file.applyTextContent(
        edited,
        session: controller,
      );

      expect(cached, isA<TH2TextApplyApplied>());
      expect(scratches, hasLength(1));
      file.undo();

      /// A stale cached result is revalidated by apply.
      final String stale = edited.replaceFirst('5 5', '6 6');
      final (TH2TextEditController second, _) = sessionOf(file);

      second.setContent(edited);
      await tester.pump(_idle);
      await tester.pump();
      second.setContent(stale);

      final TH2TextApplyResult revalidated = await file.applyTextContent(
        stale,
        session: second,
      );

      expect(revalidated, isA<TH2TextApplyApplied>());
      expect(scratches, hasLength(3));
      expect(file.serializeForTextMode().$1, contains('6 6'));
      await tester.pump(_idle);
      controller.dispose();
      second.dispose();
    });

    testWidgets('a thrown duplicate-ID parse is cached, then fixed', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_duplicateIDText);
      await tester.pump(_idle);
      await tester.pump();
      expect(severities(controller), <THTextEditorDiagnosticSeverity>[
        THTextEditorDiagnosticSeverity.error,
      ]);
      expect(
        controller.diagnostics.single.message,
        AppLocalizationsEn().th2TextDiagnosticUnreadableText,
      );

      final TH2TextApplyResult rejected = await file.applyTextContent(
        _duplicateIDText,
        session: controller,
      );

      expect(rejected, isA<TH2TextApplyRejected>());
      expect(scratches, hasLength(1));

      controller.setContent(_duplicateIDText.replaceFirst('scrap s1\nendscrap\n', ''));
      await tester.pump(_idle);
      await tester.pump();
      expect(controller.diagnostics, isEmpty);
      controller.dispose();
    });

    testWidgets('normalization records become information diagnostics', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);

      controller.setContent(_duplicateLinePointText);
      await tester.pump(_idle);
      await tester.pump();

      final THTextEditorDiagnostic diagnostic = controller.diagnostics.single;

      expect(diagnostic.severity, THTextEditorDiagnosticSeverity.information);
      expect(
        diagnostic.message,
        AppLocalizationsEn().th2TextDiagnosticRemovedDuplicateLinePoint,
      );
      expect(diagnostic.line, 5);
      controller.dispose();
    });
  });

  group('lock ownership', () {
    test('the lock survives baseline installation and session end', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      controller.lockBuffer();
      expect(controller.isReadOnly, isTrue);
      expect(controller.setContent('x'), isFalse);
      expect(controller.hasTextEdits, isFalse);

      controller.installBaseline(
        TH2TextEditBaseline(
          content: 'scrap t\nendscrap\n',
          lineMap: controller.initialLineMap,
        ),
      );
      expect(controller.isReadOnly, isTrue);
      controller.endSession();
      expect(controller.isReadOnly, isTrue);
      expect(owner.releaseCalls, 0);

      owner.releaseBufferLock();
      expect(controller.isReadOnly, isFalse);
      controller.dispose();
    });

    test('an operation releases a lock it never took', () async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      await owner.runOperation(() async {
        /// A rejected apply takes nothing.
      });
      expect(owner.acquireCalls, 0);
      expect(owner.releaseCalls, 1);
      expect(controller.isReadOnly, isFalse);
      expect(controller.setContent('scrap u\nendscrap\n'), isTrue);
      controller.dispose();
    });

    test('lockBuffer twice in one operation needs one release', () async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      await owner.runOperation(() async {
        controller.lockBuffer();
        controller.lockBuffer();
        expect(controller.isReadOnly, isTrue);
      });
      expect(owner.releaseCalls, 1);
      expect(controller.isReadOnly, isFalse);
      controller.dispose();
    });

    test('recovery read-only is separate from the lock', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      controller.enterRecoveryReadOnly();
      expect(controller.isReadOnly, isTrue);
      expect(controller.canSave, isFalse);
      owner.releaseBufferLock();
      expect(controller.isReadOnly, isTrue);
      expect(controller.setContent('x'), isFalse);
      controller.dispose();
    });
  });

  group('session lifecycle', () {
    test('baseline installation advances both revisions', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');
      final int session = controller.sessionRevision;
      final int baseline = controller.baselineRevision;

      expect(controller.isOpen, isTrue);
      expect(controller.isDirty, isFalse);

      controller.installBaseline(
        TH2TextEditBaseline(
          content: 'scrap t\nendscrap\n',
          lineMap: controller.initialLineMap,
        ),
      );
      expect(controller.sessionRevision, session + 1);
      expect(controller.baselineRevision, baseline + 1);

      controller.endSession();
      expect(controller.sessionRevision, session + 2);
      expect(controller.baselineRevision, baseline + 1);
      expect(controller.isOpen, isFalse);
      expect(controller.isDirty, isFalse);
      controller.dispose();
    });

    test('hasTextEdits is sticky and ignores selection changes', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      controller.setCursorPosition(line: 1, column: 2);
      expect(controller.setContent('scrap s\nendscrap\n'), isTrue);
      expect(controller.hasTextEdits, isFalse);

      controller.setContent('scrap t\nendscrap\n');
      expect(controller.hasTextEdits, isTrue);
      expect(controller.isDirty, isTrue);

      controller.setContent('scrap s\nendscrap\n');
      expect(controller.hasTextEdits, isTrue);
      expect(controller.isDirty, isFalse);
      controller.dispose();
    });

    test('ending a session clears it and keeps the scroll offset', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      controller.lastScrollOffset = 42;
      controller.find.setFindQuery('scrap');
      controller.find.openFindBar();
      controller.setContent('scrap t\nendscrap\n');
      controller.endSession();

      expect(controller.content, isEmpty);
      expect(controller.hasTextEdits, isFalse);
      expect(controller.lineTracker, isNull);
      expect(controller.find.isFindBarVisible, isFalse);
      expect(controller.find.findQuery, isEmpty);
      expect(controller.lastScrollOffset, 42);
      expect(controller.hasPendingIdleValidation, isFalse);
      expect(controller.setContent('x'), isFalse);
      expect(() => controller.initialLineMap, throwsStateError);
      controller.dispose();
    });

    test('a baseline replacement keeps the find bar and query', () {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      controller.find.setFindQuery('scrap');
      controller.find.openFindBar();
      controller.installBaseline(
        TH2TextEditBaseline(
          content: 'point 1 2 x\n',
          lineMap: controller.initialLineMap,
        ),
      );
      expect(controller.find.isFindBarVisible, isTrue);
      expect(controller.find.findQuery, 'scrap');
      expect(controller.find.findMatches, isEmpty);
      expect(controller.find.activeMatchIndex, isNull);
      controller.dispose();
    });

    testWidgets('ending, replacing or disposing before the idle delay', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );

      for (final String action in <String>['end', 'replace', 'dispose']) {
        final (TH2TextEditController controller, _) = sessionOf(file);

        controller.setContent(_invalidText);

        switch (action) {
          case 'end':
            controller.endSession();
          case 'replace':
            controller.installBaseline(
              TH2TextEditBaseline(
                content: _baseText,
                lineMap: controller.initialLineMap,
              ),
            );
          default:
            controller.dispose();
        }

        await tester.pump(_idle * 2);
        expect(scratches, isEmpty, reason: action);
        expect(controller.diagnostics, isEmpty, reason: action);

        if (action != 'dispose') {
          controller.dispose();
        }
      }
    });

    testWidgets('ending, replacing or disposing during validation', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );

      for (final String action in <String>['end', 'replace', 'dispose']) {
        final (TH2TextEditController controller, _) = sessionOf(file);

        TH2TextValidator.onScratchControllerCreatedForTesting =
            (TH2FileEditController scratch) {
              switch (action) {
                case 'end':
                  controller.endSession();
                case 'replace':
                  controller.installBaseline(
                    TH2TextEditBaseline(
                      content: _invalidText,
                      lineMap: controller.initialLineMap,
                    ),
                  );
                default:
                  controller.dispose();
              }
            };

        controller.setContent(_invalidText);
        await tester.pump(_idle);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: action);
        expect(controller.diagnostics, isEmpty, reason: action);
        expect(controller.isOpen, action != 'end', reason: action);
        expect(controller.isDisposed, action == 'dispose', reason: action);

        if (action != 'dispose') {
          controller.dispose();
        }
      }
    });

    testWidgets('editing never changes the model or the canvas stack', (
      WidgetTester tester,
    ) async {
      final TH2FileEditController file = await TH2TextApplyTestAux.load(
        _baseText,
      );
      final (TH2TextEditController controller, _) = sessionOf(file);
      final String before = file.serializeForTextMode().$1;

      controller.setContent(_baseText.replaceFirst('1 1', '9 9'));
      controller.find.setFindQuery('9');
      controller.find.setReplaceQuery('8');
      controller.find.replaceAllMatches();
      await tester.pump(_idle);
      await tester.pump();

      expect(file.serializeForTextMode().$1, before);
      expect(file.hasUndo, isFalse);
      expect(file.hasRedo, isFalse);
      controller.dispose();
    });
  });

  group('owner routing', () {
    test('Save checks canSave, awaits the owner and logs failures', () async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner(
        canSave: false,
      );
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      await controller.save();
      expect(owner.saveCalls, 0);

      owner.canSave = true;
      owner.onSave = () async => throw StateError('write failed');
      await controller.save();
      expect(owner.saveCalls, 1);
      controller.dispose();
    });

    test('Revert awaits the gated Discard', () async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      owner.onDiscard = () async => controller.endSession();
      await controller.revert();
      expect(owner.discardCalls, 1);
      expect(controller.isOpen, isFalse);
      controller.dispose();
    });

    test('canvas history only before the first edit and unlocked', () async {
      final TH2TextEditFakeOwner owner = TH2TextEditFakeOwner();
      final TH2TextEditController controller =
          th2TextEditControllerWithSession(owner, 'scrap s\nendscrap\n');

      await controller.requestCanvasHistory(redo: false);
      owner.acquireBufferLock();
      await controller.requestCanvasHistory(redo: true);
      owner.releaseBufferLock();
      controller.setContent('scrap t\nendscrap\n');
      await controller.requestCanvasHistory(redo: true);

      expect(owner.canvasHistoryRequests, <bool>[false]);
      controller.dispose();
    });
  });
}

/// Delegates to [owner], but throws when validation reads the filename.
class _ThrowingFilenameOwner extends TH2TextEditFakeOwner {
  _ThrowingFilenameOwner(TH2TextEditFakeOwner owner)
    : super(
        th2FileMPID: owner.th2FileMPID,
        defaultLineEnding: owner.defaultLineEnding,
      );

  @override
  String get filename => throw StateError('no filename');
}
