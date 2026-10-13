// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_encoding_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_normalization.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';

enum TH2TextDiagnosticSeverity { error, information }

enum TH2TextDiagnosticKind {
  /// Errors.
  unsupportedLineEnding,
  unencodableCharacter,
  unreadableText,
  parseProblem,

  /// Information markers.
  removedDuplicateLinePoint,
  removedShortLine,
  removedBorderOfShortLine,
  removedEmptyArea,
  rewrittenLine,
  genericRewrite,
  movedSetting,
  addedLine,
  addedEnding,
}

/// A diagnostic of a TH2 text buffer. It holds no localized text.
class TH2TextDiagnostic {
  /// 0-based line, or `null` for a line-less diagnostic.
  final int? line;
  final TH2TextDiagnosticSeverity severity;
  final TH2TextDiagnosticKind kind;
  final String? detail;
  final TH2FileProblem? problem;

  /// 0-based line a moved setting was written to.
  final int? destinationLine;

  const TH2TextDiagnostic({
    required this.line,
    required this.severity,
    required this.kind,
    this.detail,
    this.problem,
    this.destinationLine,
  });

  const TH2TextDiagnostic.error({
    required this.line,
    required this.kind,
    this.detail,
    this.problem,
  }) : severity = TH2TextDiagnosticSeverity.error,
       destinationLine = null;

  const TH2TextDiagnostic.information({
    required this.line,
    required this.kind,
    this.detail,
    this.destinationLine,
  }) : severity = TH2TextDiagnosticSeverity.information,
       problem = null;

  bool get isError => severity == TH2TextDiagnosticSeverity.error;

  @override
  String toString() =>
      'TH2TextDiagnostic(line: $line, severity: ${severity.name}, '
      'kind: ${kind.name}, detail: $detail, '
      'destinationLine: $destinationLine)';
}

/// The result of validating a TH2 text buffer. The detached file is never
/// mutated after validation.
class TH2TextValidationResult {
  /// The exact string validated.
  final String content;
  final bool isValid;

  /// Sorted by line, line-less first.
  final List<TH2TextDiagnostic> diagnostics;

  /// Valid results only.
  final TH2File? _detachedFile;
  final String? _normalizedText;
  final TH2TextLineMap? _writerMap;
  final TH2TextLineMap? _parserMap;
  final List<TH2FileNormalization>? _normalizations;
  final TH2TextCursorMapper? _cursorMapper;

  TH2TextValidationResult._({
    required this.content,
    required this.isValid,
    required List<TH2TextDiagnostic> diagnostics,
    TH2File? detachedFile,
    String? normalizedText,
    TH2TextLineMap? writerMap,
    TH2TextLineMap? parserMap,
    List<TH2FileNormalization>? normalizations,
    TH2TextCursorMapper? cursorMapper,
  }) : diagnostics = List<TH2TextDiagnostic>.unmodifiable(
         _sortedDiagnostics(diagnostics),
       ),
       _detachedFile = detachedFile,
       _normalizedText = normalizedText,
       _writerMap = writerMap,
       _parserMap = parserMap,
       _normalizations = normalizations,
       _cursorMapper = cursorMapper;

  factory TH2TextValidationResult.rejected({
    required String content,
    required List<TH2TextDiagnostic> diagnostics,
  }) {
    return TH2TextValidationResult._(
      content: content,
      isValid: false,
      diagnostics: diagnostics,
    );
  }

  factory TH2TextValidationResult.valid({
    required String content,
    required List<TH2TextDiagnostic> diagnostics,
    required TH2File detachedFile,
    required String normalizedText,
    required TH2TextLineMap writerMap,
    required TH2TextLineMap parserMap,
    required List<TH2FileNormalization> normalizations,
    required TH2TextCursorMapper cursorMapper,
  }) {
    return TH2TextValidationResult._(
      content: content,
      isValid: true,
      diagnostics: diagnostics,
      detachedFile: detachedFile,
      normalizedText: normalizedText,
      writerMap: writerMap,
      parserMap: parserMap,
      normalizations: List<TH2FileNormalization>.unmodifiable(normalizations),
      cursorMapper: cursorMapper,
    );
  }

  TH2File get detachedFile => _validOnly(_detachedFile);

  /// N(T): the text the detached model writes.
  String get normalizedText => _validOnly(_normalizedText);

  /// The map of [normalizedText].
  TH2TextLineMap get writerMap => _validOnly(_writerMap);

  /// The map of [content].
  TH2TextLineMap get parserMap => _validOnly(_parserMap);

  List<TH2FileNormalization> get normalizations =>
      _validOnly(_normalizations);

  TH2TextCursorMapper get cursorMapper => _validOnly(_cursorMapper);

  T _validOnly<T>(T? value) {
    if (!isValid || (value == null)) {
      throw StateError('Only a valid TH2 text validation result has this.');
    }

    return value;
  }

  static List<TH2TextDiagnostic> _sortedDiagnostics(
    List<TH2TextDiagnostic> diagnostics,
  ) {
    final List<TH2TextDiagnostic> sorted = List<TH2TextDiagnostic>.of(
      diagnostics,
    );

    /// List.sort isn't stable: sort indexes to keep the order of equal lines.
    final List<int> order = List<int>.generate(sorted.length, (int i) => i);

    order.sort((int a, int b) {
      final int lineA = sorted[a].line ?? -1;
      final int lineB = sorted[b].line ?? -1;
      final int byLine = lineA.compareTo(lineB);

      return (byLine == 0) ? a.compareTo(b) : byLine;
    });

    return <TH2TextDiagnostic>[for (final int i in order) sorted[i]];
  }
}

/// The single entry point of the detached parse of a TH2 text buffer. It
/// never throws: every failure becomes a rejected result.
class TH2TextValidator {
  /// Called at the start of step 5 (the valid result's serialization).
  @visibleForTesting
  static void Function()? afterParseForTesting;

  /// Called right after the scratch controller is created.
  @visibleForTesting
  static void Function(TH2FileEditController)?
  onScratchControllerCreatedForTesting;

  /// Validates [content] as the text of the file [filename], whose `TH2File`
  /// has [th2FileMPID] and [lineEnding]. [lineEnding] only seeds the scratch
  /// file: the text never sets the line ending.
  static Future<TH2TextValidationResult> validate({
    required String content,
    required String filename,
    required int th2FileMPID,
    required String lineEnding,
  }) async {
    final List<TH2TextDiagnostic> diagnostics = <TH2TextDiagnostic>[];
    final List<int> lineStarts = TH2TextLineEndingsAux.lineStartOffsets(
      content,
    );

    /// 1. Lone `\r`.
    final int? loneCarriageReturnOffset =
        TH2TextLineEndingsAux.loneCarriageReturnOffset(content);

    if (loneCarriageReturnOffset != null) {
      return TH2TextValidationResult.rejected(
        content: content,
        diagnostics: <TH2TextDiagnostic>[
          TH2TextDiagnostic.error(
            line: TH2TextLineEndingsAux.lineIndexAtOffset(
              lineStarts,
              loneCarriageReturnOffset,
            ),
            kind: TH2TextDiagnosticKind.unsupportedLineEnding,
          ),
        ],
      );
    }

    /// 2. Encodability.
    final String encoding = TH2FileParser.detectEncodingFromText(
      content,
    ).encoding;
    final List<String> lineTexts = TH2TextNormalizationAnalyzer.lineTexts(
      content,
    );
    final int lineCount = lineTexts.length;

    for (int line = 0; line < lineCount; line++) {
      try {
        MPEncodingAux.encode(lineTexts[line], encoding);
      } catch (_) {
        diagnostics.add(
          TH2TextDiagnostic.error(
            line: line,
            kind: TH2TextDiagnosticKind.unencodableCharacter,
            detail: encoding,
          ),
        );
      }
    }

    /// 3. Parse.
    final TH2FileEditController scratch =
        TH2FileEditControllerBase.createForDetachedParse(
          filename: filename,
          th2FileMPID: th2FileMPID,
          lineEnding: lineEnding,
        );
    final TH2FileParser parser = TH2FileParser();
    bool isParsing = true;

    try {
      onScratchControllerCreatedForTesting?.call(scratch);

      final (_, _, _) = await parser.parse(
        filename,
        contents: content,
        targetController: scratch,
      );
      isParsing = false;

      /// 4. Problems. Parser error strings are not converted: each one is
      /// already a problem on its line.
      for (final TH2FileProblem problem in parser.problems) {
        diagnostics.add(
          TH2TextDiagnostic.error(
            line: (problem.lineNumber < 1) ? null : problem.lineNumber - 1,
            kind: TH2TextDiagnosticKind.parseProblem,
            detail: problem.detail,
            problem: problem,
          ),
        );
      }

      if (diagnostics.any((TH2TextDiagnostic d) => d.isError)) {
        return TH2TextValidationResult.rejected(
          content: content,
          diagnostics: diagnostics,
        );
      }

      /// 5. Valid.
      afterParseForTesting?.call();

      final TH2File detachedFile = scratch.th2File;
      final (String normalizedText, TH2TextLineMap writerMap) =
          TH2FileWriter().serializeWithLineMap(
            detachedFile,
            includeEmptyLines: true,
            useOriginalRepresentation: true,
          );
      final TH2TextLineMap parserMap = TH2TextLineMap.fromParserStartLines(
        lineStarts: parser.lineStarts,
        lineCount: parser.parsedLineCount,
        th2File: detachedFile,
      );
      final List<TH2FileNormalization> normalizations =
          List<TH2FileNormalization>.of(parser.normalizations);
      final TH2TextNormalizationAnalysis analysis =
          TH2TextNormalizationAnalyzer.analyze(
            rawText: content,
            parserMap: parserMap,
            normalizedText: normalizedText,
            writerMap: writerMap,
            normalizations: normalizations,
            detachedFile: detachedFile,
          );

      diagnostics.addAll(analysis.markers);

      return TH2TextValidationResult.valid(
        content: content,
        diagnostics: diagnostics,
        detachedFile: detachedFile,
        normalizedText: normalizedText,
        writerMap: writerMap,
        parserMap: parserMap,
        normalizations: normalizations,
        cursorMapper: analysis.cursorMapper,
      );
    } catch (e, s) {
      final int? lineNumberInProgress = isParsing
          ? parser.lineNumberInProgress
          : null;

      if (kDebugMode) {
        mpLocator.mpLog.e(
          'Detached TH2 text parse failed',
          error: e,
          stackTrace: s,
        );
      }

      diagnostics.add(
        TH2TextDiagnostic.error(
          line: (lineNumberInProgress == null)
              ? null
              : lineNumberInProgress - 1,
          kind: TH2TextDiagnosticKind.unreadableText,
          detail: e.toString(),
        ),
      );

      return TH2TextValidationResult.rejected(
        content: content,
        diagnostics: diagnostics,
      );
    } finally {
      scratch.dispose();
    }
  }
}

/// Holds at most one finished validation and one in-flight validation, each
/// keyed by its exact content string. The line ending isn't part of the key:
/// a file's line ending never changes while it is open.
class TH2TextValidationCache {
  TH2TextValidationResult? _finished;
  String? _inFlightContent;
  Future<TH2TextValidationResult>? _inFlight;
  int _generation = 0;

  /// The finished result when its content is [content], else `null`.
  TH2TextValidationResult? finishedResultFor(String content) {
    final TH2TextValidationResult? finished = _finished;

    return ((finished != null) && (finished.content == content))
        ? finished
        : null;
  }

  Future<TH2TextValidationResult> validate(
    String content, {
    required String filename,
    required int th2FileMPID,
    required String lineEnding,
  }) {
    final TH2TextValidationResult? finished = finishedResultFor(content);

    if (finished != null) {
      return Future<TH2TextValidationResult>.value(finished);
    }

    final Future<TH2TextValidationResult>? inFlight = _inFlight;

    if ((inFlight != null) && (_inFlightContent == content)) {
      return inFlight;
    }

    final int generation = ++_generation;
    final Future<TH2TextValidationResult> validation = TH2TextValidator
        .validate(
          content: content,
          filename: filename,
          th2FileMPID: th2FileMPID,
          lineEnding: lineEnding,
        )
        .then((TH2TextValidationResult result) {
          if (generation == _generation) {
            _finished = result;
            _inFlight = null;
            _inFlightContent = null;
          }

          return result;
        });

    _finished = null;
    _inFlightContent = content;
    _inFlight = validation;

    return validation;
  }

  void clear() {
    _generation++;
    _finished = null;
    _inFlight = null;
    _inFlightContent = null;
  }
}
