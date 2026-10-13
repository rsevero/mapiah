// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/mp_undo_redo_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

/// A scrap with [lineCount] lines of [pointsPerLine] points each, and as
/// many unique points.
String _generatedText({int lineCount = 300, int pointsPerLine = 10}) {
  final StringBuffer text = StringBuffer('encoding utf-8\nscrap s1\n');

  for (int line = 0; line < lineCount; line++) {
    text.write('  line wall -id l$line\n');
    for (int point = 0; point < pointsPerLine; point++) {
      text.write('    ${line * 100 + point} ${point * 3}\n');
    }
    text.write('  endline\n');
    text.write('  point $line ${line + 7} station -id p$line\n');
  }
  text.write('endscrap\nscrap s2\nendscrap\n');

  return text.toString();
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

  /// Line text → owner, for the lines whose text is unique in [text].
  Map<String, int> uniqueLineOwners(String text, TH2TextLineMap lineMap) {
    final List<String> lines = TH2TextNormalizationAnalyzer.lineTexts(text);
    final Map<String, int> counts = <String, int>{};

    for (final String line in lines) {
      counts[line] = (counts[line] ?? 0) + 1;
    }

    return <String, int>{
      for (int i = 0; i < lines.length; i++)
        if ((counts[lines[i]] == 1) && (lineMap.ownerOfLine(i) != null))
          lines[i]: lineMap.ownerOfLine(i)!,
    };
  }

  /// Times validation and one apply of [edited] onto [controller], and
  /// returns the apply result.
  Future<TH2TextApplyApplied> timedApply(
    String label,
    TH2FileEditController controller,
    String edited,
  ) async {
    final TH2TextTestSession session = TH2TextTestSession.of(controller);
    final Stopwatch stopwatch = Stopwatch()..start();
    final TH2TextValidationResult result = await session.validationCache
        .validate(
          edited,
          filename: controller.th2File.filename,
          th2FileMPID: controller.th2File.mpID,
          lineEnding: controller.th2File.lineEnding,
        );
    final int uncached = stopwatch.elapsedMilliseconds;

    expect(result.isValid, isTrue, reason: '$label: ${result.diagnostics}');

    stopwatch.reset();
    await session.validationCache.validate(
      edited,
      filename: controller.th2File.filename,
      th2FileMPID: controller.th2File.mpID,
      lineEnding: controller.th2File.lineEnding,
    );

    final int cached = stopwatch.elapsedMilliseconds;

    session.content = edited;
    stopwatch.reset();

    final TH2TextApplyResult applyResult = await controller.applyTextContent(
      edited,
      session: session,
    );

    debugPrint(
      't3971 $label (${edited.length} chars): validation '
      '${uncached}ms uncached, ${cached}ms cached; apply '
      '${stopwatch.elapsedMilliseconds}ms',
    );

    expect(applyResult, isA<TH2TextApplyApplied>(), reason: label);

    return applyResult as TH2TextApplyApplied;
  }

  /// Applies [edit] to [text] and checks that every line unique in both
  /// texts keeps its owner, unless [keepsMPIDs] is false.
  Future<void> measure(
    String label,
    String text,
    String Function(String) edit, {
    bool keepsMPIDs = true,
    String? filename,
  }) async {
    mpLocator.mpGeneralController.reset();

    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      text,
      filename: filename ?? TH2TextApplyTestAux.defaultFilename,
    );
    final (String liveText, TH2TextLineMap liveMap) = controller
        .serializeForTextMode();
    final String edited = edit(liveText);
    final Map<String, int> before = uniqueLineOwners(liveText, liveMap);
    final TH2TextApplyApplied result = await timedApply(
      label,
      controller,
      edited,
    );

    if (!keepsMPIDs) {
      return;
    }

    final Map<String, int> after = uniqueLineOwners(
      controller.serializeForTextMode().$1,
      result.lineMap,
    );
    int kept = 0;

    for (final MapEntry<String, int> entry in before.entries) {
      final int? afterOwner = after[entry.key];

      if (afterOwner == null) {
        continue;
      }

      expect(afterOwner, entry.value, reason: '$label: ${entry.key}');
      kept++;
    }

    expect(kept, greaterThan(0), reason: label);
  }

  List<File> largestFixtures() {
    final List<File> fixtures =
        Directory('test/auxiliary')
            .listSync()
            .whereType<File>()
            .where((File file) => file.path.endsWith('.th2'))
            .toList()
          ..sort(
            (File a, File b) => b.lengthSync().compareTo(a.lengthSync()),
          );

    return fixtures.take(3).toList();
  }

  test('timings and MPID preservation', () async {
    for (final File fixture in largestFixtures()) {
      await measure(
        'small edit, ${fixture.path}',
        fixture.readAsStringSync(),
        (String text) => '$text# t3971\n',
        filename: fixture.absolute.path,
      );
    }

    final String generated = _generatedText();

    expect(generated.split('\n').length, greaterThan(3000));

    await measure(
      'small edit, generated',
      generated,
      (String text) => text.replaceFirst('    0 0\n', '    0 1\n'),
    );
    await measure(
      'wholesale replacement, generated',
      generated,
      (String text) => text.replaceAll('    ', '    1'),
      keepsMPIDs: false,
    );
    await measure(
      'delete and paste a 1,000-line block, generated',
      generated,
      (String text) {
        final List<String> lines = text.split('\n');
        final int start = lines.indexOf('  line wall -id l10');
        final List<String> block = lines.sublist(start, start + 1001);

        lines.removeRange(start, start + 1001);
        lines.insertAll(lines.indexOf('scrap s2') + 1, block);

        return lines.join('\n');
      },
    );

    final String longLine =
        '  point 1 1 label -text "${List<String>.filled(50, 'long text').join(' ')}"\n';
    final String repeated = generated.replaceFirst(
      'endscrap\nscrap s2\n',
      '${List<String>.filled(500, longLine).join()}endscrap\nscrap s2\n',
    );

    await measure(
      'long repeated lines, generated',
      repeated,
      (String text) => text.replaceFirst('    0 0\n', '    0 1\n'),
    );
  });

  group('snapshots', () {
    dynamic deepCopy(dynamic value) {
      if (value is Map) {
        return <dynamic, dynamic>{
          for (final MapEntry<dynamic, dynamic> entry in value.entries)
            entry.key: deepCopy(entry.value),
        };
      }
      if (value is List) {
        return <dynamic>[for (final dynamic item in value) deepCopy(item)];
      }

      return value;
    }

    /// Every snapshot object held by text edit entries of the undo stack.
    Set<Map<String, dynamic>> heldSnapshots(TH2FileEditController controller) {
      final Set<Map<String, dynamic>> snapshots =
          Set<Map<String, dynamic>>.identity();

      for (final MPUndoRedoCommand entry in <MPUndoRedoCommand>[
        ...controller.undoRedoController.undosForTesting,
        ...controller.undoRedoController.redosForTesting,
      ]) {
        for (final Map<String, dynamic> map in <Map<String, dynamic>>[
          entry.mapUndo,
          entry.mapRedo,
        ]) {
          if (map['commandType'] != MPCommandType.replaceTH2FileContents.name) {
            continue;
          }
          snapshots
            ..add(map['before'] as Map<String, dynamic>)
            ..add(map['after'] as Map<String, dynamic>);
        }
      }

      return snapshots;
    }

    test('one apply holds two shared snapshots that nothing mutates', () async {
      final TH2FileEditController controller = await TH2TextApplyTestAux.load(
        _generatedText(lineCount: 20),
      );
      final TH2TextTestSession session = TH2TextTestSession.of(controller);
      final int undoCount = controller.undoRedoController.undoCount;
      final String edited = session.initialContent.replaceFirst(
        '    0 0\n',
        '    0 1\n',
      );

      session.content = edited;
      await controller.applyTextContent(edited, session: session);

      expect(controller.undoRedoController.undoCount, undoCount + 1);

      final MPUndoRedoCommand entry =
          controller.undoRedoController.undosForTesting.last;
      final Map<String, dynamic> before =
          entry.mapRedo['before'] as Map<String, dynamic>;
      final Map<String, dynamic> after =
          entry.mapRedo['after'] as Map<String, dynamic>;

      expect(entry.mapRedo['commandType'], MPCommandType.replaceTH2FileContents.name);
      expect(identical(entry.mapUndo['before'], after), isTrue);
      expect(identical(entry.mapUndo['after'], before), isTrue);

      final dynamic beforeCopy = deepCopy(before);
      final dynamic afterCopy = deepCopy(after);

      controller.undo();
      expect(controller.undoRedoController.redoDescription, isNotEmpty);
      controller.redo();
      expect(controller.undoRedoController.undoDescription, isNotEmpty);
      controller.undo();

      final THPoint point =
          controller.th2File.elementByTHID('p0') as THPoint;

      controller.execute(
        MPMovePointCommand(
          pointMPID: point.mpID,
          fromPosition: point.position,
          toPosition: THPositionPart(coordinates: const Offset(99, 99)),
          fromOriginalLineInTH2File: point.originalLineInTH2File,
          toOriginalLineInTH2File: '',
        ),
      );

      final Set<Map<String, dynamic>> held = heldSnapshots(controller);

      expect(held, hasLength(2));
      expect(held.any((Map<String, dynamic> map) => identical(map, before)), isTrue);
      expect(held.any((Map<String, dynamic> map) => identical(map, after)), isTrue);
      expect(const DeepCollectionEquality().equals(before, beforeCopy), isTrue);
      expect(const DeepCollectionEquality().equals(after, afterCopy), isTrue);
    });
  });
}
