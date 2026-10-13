// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

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

  Uint8List savedBytes(TH2FileEditController controller) =>
      TH2FileWriter().toBytes(
        controller.th2File,
        includeEmptyLines: true,
        useOriginalRepresentation: true,
      );

  Future<TH2TextApplyResult> apply(
    TH2FileEditController controller,
    String text,
  ) async {
    final TH2TextTestSession session = TH2TextTestSession.of(controller);

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
    );

    expect(result, isA<TH2TextApplyApplied>());

    return result;
  }

  test('a CRLF file keeps its line ending and bytes through apply, undo and redo', () async {
    const String text =
        'encoding utf-8\r\n'
        'scrap s1\r\n'
        '  line wall\r\n'
        '    1 1\r\n'
        '    2 2\r\n'
        '  endline\r\n'
        'endscrap\r\n';
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      text,
    );
    final Uint8List bytes = savedBytes(controller);

    expect(controller.th2File.lineEnding, mpWindowsLineBreak);

    /// The line option moves into the header, which the writer generates.
    final String edited = text.replaceFirst(
      '  line wall\r\n',
      '  line wall\r\n    close on\r\n',
    );

    await apply(controller, edited);

    expect(controller.th2File.lineEnding, mpWindowsLineBreak);
    expect(liveText(controller), contains('  line wall -close on\r\n'));
    expect(liveText(controller), isNot(contains(RegExp('[^\r]\n'))));

    final Uint8List appliedBytes = savedBytes(controller);

    controller.undo();
    expect(controller.th2File.lineEnding, mpWindowsLineBreak);
    expect(savedBytes(controller), bytes);

    controller.redo();
    expect(controller.th2File.lineEnding, mpWindowsLineBreak);
    expect(savedBytes(controller), appliedBytes);
  });

  group('the text never sets the line ending', () {
    final String fileEnding =
        (MPDirectoryAux.getDefaultLineEnding() == mpUnixLineBreak)
        ? mpWindowsLineBreak
        : mpUnixLineBreak;
    final String text =
        'encoding utf-8$fileEnding'
        '##XTHERION## xth_me_area_adjust 0 0 100 100$fileEnding'
        'scrap s1$fileEnding'
        'endscrap$fileEnding';

    for (final (String name, String edited) in <(String, String)>[
      ('a deleted encoding line', text.replaceFirst('encoding utf-8$fileEnding', '')),
      ('a first line turned into a comment', '# $text'),
    ]) {
      test(name, () async {
        final TH2FileEditController controller = await TH2TextApplyTestAux
            .load(text);

        expect(controller.th2File.lineEnding, fileEnding);

        await apply(controller, edited);

        expect(controller.th2File.lineEnding, fileEnding);
        expect(liveText(controller), startsWith('encoding UTF-8$fileEnding'));

        controller.undo();
        expect(controller.th2File.lineEnding, fileEnding);
        expect(liveText(controller), text);

        controller.redo();
        expect(controller.th2File.lineEnding, fileEnding);
        expect(liveText(controller), startsWith('encoding UTF-8$fileEnding'));
      });
    }
  });

  group('one apply for the final text', () {
    const String text =
        'encoding utf-8\n'
        'scrap s1\n'
        '  point 1 1 station\n'
        'endscrap\n'
        '# trailing comment\n';

    test('temporarily invalid text', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;
      const String invalid =
          'encoding utf-8\n'
          'scrap s1\n'
          '  poin 1 1 station\n'
          'endscrap\n'
          '# trailing comment\n';
      final TH2TextValidationResult rejected = await session.validationCache
          .validate(
            invalid,
            filename: controller.th2File.filename,
            th2FileMPID: controller.th2File.mpID,
            lineEnding: controller.th2File.lineEnding,
          );

      expect(rejected.isValid, isFalse);

      const String valid =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 2 station\n'
          'endscrap\n'
          '# trailing comment\n';

      session.content = valid;

      final TH2TextApplyResult result = await controller.applyTextContent(
        valid,
        session: session,
      );

      expect(result, isA<TH2TextApplyApplied>());
      expect(controller.undoRedoController.undoCount, undoCount + 1);
    });

    test('a moved endscrap', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        text,
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;
      const String withoutEndscrap =
          'encoding utf-8\n'
          'scrap s1\n'
          '  point 1 1 station\n'
          '# trailing comment\n';
      final TH2TextValidationResult rejected = await session.validationCache
          .validate(
            withoutEndscrap,
            filename: controller.th2File.filename,
            th2FileMPID: controller.th2File.mpID,
            lineEnding: controller.th2File.lineEnding,
          );

      expect(rejected.isValid, isFalse);

      const String moved = '${withoutEndscrap}endscrap\n';

      session.content = moved;

      final TH2TextApplyResult result = await controller.applyTextContent(
        moved,
        session: session,
      );

      expect(result, isA<TH2TextApplyApplied>());
      expect(controller.undoRedoController.undoCount, undoCount + 1);
      expect(liveText(controller), moved);
    });
  });

  test('mixed endings: only the edited lines change in the bytes', () async {
    const String text =
        'encoding utf-8\r\n'
        'scrap s1\r\n'
        '  point 1 1 station\n'
        '  point 2 2 station\r\n'
        '  point 3 3 station\n'
        'endscrap';
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      text,
    );

    expect(controller.th2File.lineEnding, mpWindowsLineBreak);
    expect(utf8.decode(savedBytes(controller)), text);

    final String edited = text
        .replaceFirst(
          '  point 1 1 station\n',
          '  point 1 5 station\n'
              '  point 7 7 station\r\n'
              '  point 8 8 station\n',
        )
        .replaceFirst('  point 3 3 station\n', '');

    await apply(controller, edited);

    expect(utf8.decode(savedBytes(controller)), edited);

    await apply(controller, '$edited\r\n');

    expect(utf8.decode(savedBytes(controller)), '$edited\r\n');
  });
}
