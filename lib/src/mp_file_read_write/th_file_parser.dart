// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_comment.dart';
import 'package:mapiah/src/elements/th_data/th_data_element.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_general.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_equate.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_inline_scrap.dart';
import 'package:mapiah/src/elements/th_data/th_join.dart';
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_data/th_surface.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/mp_file_read_write/th_grammar.dart';
import 'package:petitparser/petitparser.dart';

/// Parser for Therion survey data (`.th`) files.
class THFileParser {
  final THGrammar _grammar = THGrammar();

  late final Parser _statementParser;

  THFileParser() {
    _statementParser = _grammar.buildFrom(_grammar.thDataStatement());
  }

  /// Parses a .th file from the given file path.
  Future<THDataFile> parseFile(String filePath) async {
    final File file = File(filePath);

    if (!await file.exists()) {
      return THDataFile(
        filename: filePath,
        parseErrors: <String>['File not found: $filePath'],
      );
    }

    final String content = await file.readAsString();

    return parseString(content, filename: filePath);
  }

  /// Parses .th file content from a raw string.
  THDataFile parseString(String content, {String filename = ''}) {
    final String lineEnding = content.contains('\r\n')
        ? '\r\n'
        : (content.contains('\n')
            ? '\n'
            : MPDirectoryAux.getDefaultLineEnding());

    final List<String> lines = content.split(RegExp(r'\r?\n'));

    final THDataFile dataFile = THDataFile(
      filename: filename,
      lineEnding: lineEnding,
    );

    final List<THSurvey> surveyStack = <THSurvey>[];
    int lineIndex = 0;

    while (lineIndex < lines.length) {
      final int startLineNumber = lineIndex + 1;
      String currentLine = lines[lineIndex];

      // Handle line continuations (trailing \)
      while (currentLine.trimRight().endsWith(r'\') &&
          ((lineIndex + 1) < lines.length)) {
        lineIndex++;
        currentLine =
            '${currentLine.trimRight().substring(0, currentLine.trimRight().length - 1)} ${lines[lineIndex]}';
      }

      final String originalFullLine = currentLine;
      final String trimmed = currentLine.trim();

      if (trimmed.isEmpty) {
        final THDataComment emptyComment = THDataComment(
          commentText: '',
          isEmptyLine: true,
          lineNumber: startLineNumber,
          originalLine: lines[startLineNumber - 1],
        );
        _addElement(dataFile, surveyStack, emptyComment);
        lineIndex++;
        continue;
      }

      if (trimmed.startsWith('#')) {
        final THDataComment comment = THDataComment(
          commentText: trimmed,
          isEmptyLine: false,
          lineNumber: startLineNumber,
          originalLine: originalFullLine,
        );
        _addElement(dataFile, surveyStack, comment);
        lineIndex++;
        continue;
      }

      // Check if starting centreline block
      if (RegExp(r'^\s*cent(?:re|er)line\b', caseSensitive: false).hasMatch(trimmed)) {
        final List<String> blockLines = <String>[];
        final List<THCentrelineShot> shots = <THCentrelineShot>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endcent(?:re|er)line\b', caseSensitive: false).hasMatch(line)) {
            break;
          }
          blockLines.add(line);

          final Result<dynamic> shotResult = _statementParser.parse(line.trim());
          if (shotResult is Success) {
            final Map<String, dynamic> data = shotResult.value as Map<String, dynamic>;
            if (data['type'] == 'shot') {
              shots.add(
                THCentrelineShot(
                  fromStation: data['from'] as String? ?? '',
                  toStation: data['to'] as String? ?? '',
                  length: data['length'] as double? ?? 0.0,
                  originalLine: line,
                ),
              );
            }
          }

          lineIndex++;
        }

        final String originalBlock = lines
            .sublist(
              blockStart,
              lineIndex < lines.length ? lineIndex + 1 : lines.length,
            )
            .join(lineEnding);

        final THCentreline centreline = THCentreline(
          shots: shots,
          rawDataLines: blockLines,
          lineNumber: startLineNumber,
          originalLine: originalBlock,
        );
        _addElement(dataFile, surveyStack, centreline);

        lineIndex++;
        continue;
      }

      // Check if starting map block
      final RegExpMatch? mapMatch = RegExp(
        r'^\s*map\s+([^\s#]+)',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (mapMatch != null) {
        final String mapId = mapMatch.group(1)!;
        final List<String> blockLines = <String>[];
        final List<String> items = <String>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endmap\b', caseSensitive: false).hasMatch(line)) {
            break;
          }
          final String itemTrimmed = line.trim();
          if (itemTrimmed.isNotEmpty && !itemTrimmed.startsWith('#')) {
            items.add(itemTrimmed);
          }
          blockLines.add(line);
          lineIndex++;
        }

        final String originalBlock = lines
            .sublist(
              blockStart,
              lineIndex < lines.length ? lineIndex + 1 : lines.length,
            )
            .join(lineEnding);

        final THMap map = THMap(
          mapId: mapId,
          items: items,
          lineNumber: startLineNumber,
          originalLine: originalBlock,
        );
        _addElement(dataFile, surveyStack, map);

        lineIndex++;
        continue;
      }

      // Check if starting inline scrap block
      final RegExpMatch? scrapMatch = RegExp(
        r'^\s*scrap\s+([^\s#]+)',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (scrapMatch != null) {
        final String scrapId = scrapMatch.group(1)!;
        final List<String> blockLines = <String>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endscrap\b', caseSensitive: false).hasMatch(line)) {
            break;
          }
          blockLines.add(line);
          lineIndex++;
        }

        final String originalBlock = lines
            .sublist(
              blockStart,
              lineIndex < lines.length ? lineIndex + 1 : lines.length,
            )
            .join(lineEnding);

        final THInlineScrap scrap = THInlineScrap(
          scrapId: scrapId,
          rawLines: blockLines,
          lineNumber: startLineNumber,
          originalLine: originalBlock,
        );
        _addElement(dataFile, surveyStack, scrap);

        lineIndex++;
        continue;
      }

      // Check if starting surface block
      if (RegExp(r'^\s*surface\b', caseSensitive: false).hasMatch(trimmed)) {
        final List<String> blockLines = <String>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endsurface\b', caseSensitive: false).hasMatch(line)) {
            break;
          }
          blockLines.add(line);
          lineIndex++;
        }

        final String originalBlock = lines
            .sublist(
              blockStart,
              lineIndex < lines.length ? lineIndex + 1 : lines.length,
            )
            .join(lineEnding);

        final THSurface surface = THSurface(
          rawLines: blockLines,
          lineNumber: startLineNumber,
          originalLine: originalBlock,
        );
        _addElement(dataFile, surveyStack, surface);

        lineIndex++;
        continue;
      }

      // Single-line statement parsing
      final Result<dynamic> parseResult = _statementParser.parse(currentLine);

      if (parseResult is Success) {
        final Map<String, dynamic> data =
            parseResult.value as Map<String, dynamic>;
        final String type = data['type'] as String? ?? 'general';

        if (type == 'surveyStart') {
          final String surveyId = data['surveyId'] as String? ?? '';
          final THSurvey survey = THSurvey(
            surveyId: surveyId,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, survey);
          surveyStack.add(survey);
        } else if (type == 'surveyEnd') {
          if (surveyStack.isNotEmpty) {
            surveyStack.removeLast().endLine = originalFullLine;
          }
        } else if (type == 'input') {
          final String path = data['filePath'] as String? ?? '';
          final THDataInput input = THDataInput(
            rawPath: path,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, input);
        } else if (type == 'equate') {
          final List<String> stations =
              (data['stations'] as List<dynamic>?)?.cast<String>() ?? <String>[];
          final THEquate equate = THEquate(
            stations: stations,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, equate);
        } else if (type == 'join') {
          final String l1 = data['line1'] as String? ?? '';
          final String l2 = data['line2'] as String? ?? '';
          final THJoin join = THJoin(
            line1: l1,
            line2: l2,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, join);
        } else if (type == 'import') {
          final String path = data['filePath'] as String? ?? '';
          final THImport imp = THImport(
            filePath: path,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, imp);
        } else if (type == 'setting') {
          final String keyword = data['keyword'] as String? ?? '';
          final String rawArgs = data['rawArguments'] as String? ?? '';
          if (keyword.toLowerCase() == 'encoding') {
            dataFile.encoding = rawArgs.split(RegExp(r'\s+')).first;
          }
          final THDataGeneral setting = THDataGeneral(
            keyword: keyword,
            rawArguments: rawArgs,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, setting);
        } else if (type == 'general') {
          final String keyword = data['keyword'] as String? ?? '';
          final String rawArgs = data['rawArguments'] as String? ?? '';
          final THDataGeneral general = THDataGeneral(
            keyword: keyword,
            rawArguments: rawArgs,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          );
          _addElement(dataFile, surveyStack, general);
        }
      } else {
        dataFile.parseErrors.add(
          'Syntax error at line $startLineNumber: ${parseResult.message}',
        );
      }

      lineIndex++;
    }

    return dataFile;
  }

  void _addElement(
    THDataFile dataFile,
    List<THSurvey> surveyStack,
    THDataElement element,
  ) {
    if (surveyStack.isNotEmpty) {
      surveyStack.last.children.add(element);
    } else {
      dataFile.elements.add(element);
    }
  }
}
