// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

const String _baseText =
    'encoding utf-8\n'
    'scrap s1\n'
    '  point 1 1 station -id p1\n'
    'endscrap\n';

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    TH2TextValidator.onScratchControllerCreatedForTesting = null;
    TH2TextValidator.afterParseForTesting = null;
    TH2FileParser.beforeCleanUpForTesting = null;
    mpLocator.mpGeneralController.reset();
  });

  Future<TH2TextValidationResult> validate(String content) {
    return TH2TextValidator.validate(
      content: content,
      filename: '/tmp/t3969.th2',
      th2FileMPID: -1000,
      lineEnding: mpUnixLineBreak,
    );
  }

  List<(TH2TextDiagnosticKind, int?)> errorsOf(TH2TextValidationResult r) =>
      <(TH2TextDiagnosticKind, int?)>[
        for (final TH2TextDiagnostic diagnostic in r.diagnostics)
          if (diagnostic.isError) (diagnostic.kind, diagnostic.line),
      ];

  /// Applies [text] to a controller loaded from [_baseText] and checks that
  /// it is rejected with the model and undo stack unchanged.
  Future<TH2TextApplyRejected> expectRejectedApply(String text) async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);
    final Map<String, dynamic> modelBefore = controller.th2File.toMap();
    final int undoCount = controller.undoRedoController.undoCount;

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
      lockBufferOnAccept: true,
    );

    expect(result, isA<TH2TextApplyRejected>());
    expect(controller.th2File.toMap(), modelBefore);
    expect(controller.undoRedoController.undoCount, undoCount);
    expect(session.lockBufferCalls, 0);

    return result as TH2TextApplyRejected;
  }

  test('parse problems and errors are shown once, on their lines', () async {
    const String text =
        'encoding utf-8\n'
        'scrap s1\n'
        '  poin 1 1 station\n'
        '  point 2 2 station -bad option\n'
        'endscrap\n';
    final TH2TextValidationResult result = await validate(text);

    expect(result.isValid, isFalse);
    expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
      (TH2TextDiagnosticKind.parseProblem, 2),
      (TH2TextDiagnosticKind.parseProblem, 3),
    ]);
    expect(
      result.diagnostics.every((TH2TextDiagnostic d) => d.problem != null),
      isTrue,
    );

    final TH2TextApplyRejected rejected = await expectRejectedApply(text);

    expect(rejected.diagnostics, hasLength(2));
  });

  test('a structure problem is rejected on its line', () async {
    const String text =
        'encoding utf-8\n'
        'point 1 1 station\n';
    final TH2TextValidationResult result = await validate(text);

    expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
      (TH2TextDiagnosticKind.parseProblem, 1),
    ]);
    await expectRejectedApply(text);
  });

  group('encodability', () {
    test('ç in an ASCII file', () async {
      const String text =
          'encoding ascii\n'
          'scrap s1 -title "ç"\n'
          'endscrap\n';
      final TH2TextValidationResult result = await validate(text);

      expect(result.isValid, isFalse);
      expect(result.diagnostics, hasLength(1));
      expect(
        result.diagnostics.single.kind,
        TH2TextDiagnosticKind.unencodableCharacter,
      );
      expect(result.diagnostics.single.line, 1);
      expect(result.diagnostics.single.detail, 'ASCII');
      await expectRejectedApply(text);
    });

    test('a character outside ISO8859-2, also with a parse problem', () async {
      const String text =
          'encoding iso8859-2\n'
          'scrap s1 -title "日"\n'
          '  poin 1 1 station\n'
          'endscrap\n';
      final TH2TextValidationResult result = await validate(text);

      expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
        (TH2TextDiagnosticKind.unencodableCharacter, 1),
        (TH2TextDiagnosticKind.parseProblem, 2),
      ]);
      expect(result.diagnostics.first.detail, 'ISO8859-2');
    });

    test('characters ISO8859-2 holds are accepted', () async {
      final TH2TextValidationResult result = await validate(
        'encoding iso8859-2\n'
        'scrap s1 -title "ąčř"\n'
        'endscrap\n',
      );

      expect(result.isValid, isTrue);
    });
  });

  group('lone carriage return', () {
    for (final (String name, String text, int line) in <(String, String, int)>[
      ('mid-line', 'encoding utf-8\nscrap s1\r x\nendscrap\n', 1),
      ('at the end', 'encoding utf-8\nscrap s1\nendscrap\r', 2),
    ]) {
      test(name, () async {
        int scratches = 0;

        TH2TextValidator.onScratchControllerCreatedForTesting =
            (TH2FileEditController _) => scratches++;

        final TH2TextValidationResult result = await validate(text);

        expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
          (TH2TextDiagnosticKind.unsupportedLineEnding, line),
        ]);
        expect(scratches, 0);
      });
    }
  });

  test('a duplicated scrap id is unreadable text on its line', () async {
    const String text =
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 1 1 station -id p1\n'
        'endscrap\n'
        'scrap s1\n'
        'endscrap\n';
    final List<TH2FileEditController> scratches = <TH2FileEditController>[];

    TH2TextValidator.onScratchControllerCreatedForTesting = scratches.add;

    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
    );

    expect(result, isA<TH2TextApplyRejected>());

    final TH2TextDiagnostic diagnostic =
        (result as TH2TextApplyRejected).diagnostics.single;

    expect(diagnostic.kind, TH2TextDiagnosticKind.unreadableText);
    expect(diagnostic.line, 4);
    expect(diagnostic.detail, contains('s1'));
    expect(scratches, hasLength(1));
    expect(scratches.single.isDisposed, isTrue);

    final TH2TextValidationResult cached = await session.validationCache
        .validate(
          text,
          filename: controller.th2File.filename,
          th2FileMPID: controller.th2File.mpID,
          lineEnding: controller.th2File.lineEnding,
        );

    expect(cached.isValid, isFalse);
    expect(scratches, hasLength(1));
  });

  test('a throw from a clean-up pass is line-less unreadable text', () async {
    TH2FileParser.beforeCleanUpForTesting = () {
      throw StateError('forced clean-up failure');
    };

    final TH2TextValidationResult result = await validate(_baseText);

    expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
      (TH2TextDiagnosticKind.unreadableText, null),
    ]);
    expect(result.diagnostics.single.detail, contains('forced clean-up'));
  });

  test('a throw after the parse is line-less unreadable text', () async {
    final List<TH2FileEditController> scratches = <TH2FileEditController>[];

    TH2TextValidator.onScratchControllerCreatedForTesting = scratches.add;
    TH2TextValidator.afterParseForTesting = () {
      throw StateError('forced serialization failure');
    };

    final TH2TextValidationResult result = await validate(_baseText);

    expect(errorsOf(result), <(TH2TextDiagnosticKind, int?)>[
      (TH2TextDiagnosticKind.unreadableText, null),
    ]);
    expect(scratches.single.isDisposed, isTrue);
  });

  test('loading a file with duplicate scrap ids still sets loadError', () async {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(
          filename: '/tmp/t3969_duplicate.th2',
          fileBytes: Uint8List.fromList(
            utf8.encode('encoding utf-8\nscrap s1\nendscrap\nscrap s1\nendscrap\n'),
          ),
        );

    await expectLater(controller.load(), throwsA(anything));
    expect(controller.loadError, isNotNull);
  });
}
