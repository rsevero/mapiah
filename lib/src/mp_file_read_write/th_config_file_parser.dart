// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/elements/th_config/th_config_comment.dart';
import 'package:mapiah/src/elements/th_config/th_config_element.dart';
import 'package:mapiah/src/elements/th_config/th_config_export.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_layout.dart';
import 'package:mapiah/src/elements/th_config/th_config_select.dart';
import 'package:mapiah/src/elements/th_config/th_config_setting.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_grammar.dart';
import 'package:petitparser/petitparser.dart';

/// Parser for Therion configuration (`thconfig`) files.
class THConfigFileParser {
  final THConfigGrammar _grammar = THConfigGrammar();

  late final Parser _statementParser;

  THConfigFileParser() {
    _statementParser = _grammar.buildFrom(_grammar.thConfigStatement());
  }

  /// Parses a thconfig file from the given file path.
  Future<THConfigFile> parseFile(String filePath) async {
    final File file = File(filePath);

    if (!await file.exists()) {
      return THConfigFile(
        filename: filePath,
        parseErrors: <String>['File not found: $filePath'],
      );
    }

    final String content = await file.readAsString();

    return parseString(content, filename: filePath);
  }

  /// Parses thconfig file content from a raw string.
  THConfigFile parseString(String content, {String filename = ''}) {
    final String lineEnding = content.contains('\r\n')
        ? '\r\n'
        : (content.contains('\n')
            ? '\n'
            : MPDirectoryAux.getDefaultLineEnding());

    final List<String> lines = content.split(RegExp(r'\r?\n'));

    final THConfigFile configFile = THConfigFile(
      filename: filename,
      lineEnding: lineEnding,
    );

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
        configFile.elements.add(
          THConfigComment(
            commentText: '',
            isEmptyLine: true,
            lineNumber: startLineNumber,
            originalLine: lines[startLineNumber - 1],
          ),
        );
        lineIndex++;
        continue;
      }

      if (trimmed.startsWith('#')) {
        configFile.elements.add(
          THConfigComment(
            commentText: trimmed,
            isEmptyLine: false,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          ),
        );
        lineIndex++;
        continue;
      }

      // Check if starting multi-line source block
      if (RegExp(r'^\s*source\s*$', caseSensitive: false).hasMatch(trimmed)) {
        final List<String> blockLines = <String>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endsource\b', caseSensitive: false).hasMatch(line)) {
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

        configFile.elements.add(
          THConfigSource(
            filePath: '',
            isMultiLine: true,
            inlineCommands: blockLines,
            lineNumber: startLineNumber,
            originalLine: originalBlock,
          ),
        );

        lineIndex++;
        continue;
      }

      // Check if starting layout block
      final RegExpMatch? layoutMatch = RegExp(
        r'^\s*layout\s+([^\s#]+)',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (layoutMatch != null) {
        final String layoutId = layoutMatch.group(1)!;
        final List<String> blockLines = <String>[];
        final int blockStart = lineIndex;
        lineIndex++;

        while (lineIndex < lines.length) {
          final String line = lines[lineIndex];
          if (RegExp(r'^\s*endlayout\b', caseSensitive: false).hasMatch(line)) {
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

        configFile.elements.add(
          THConfigLayout(
            layoutId: layoutId,
            rawLines: blockLines,
            lineNumber: startLineNumber,
            originalLine: originalBlock,
          ),
        );

        lineIndex++;
        continue;
      }

      // Single-line statement parsing
      final Result<dynamic> parseResult = _statementParser.parse(currentLine);

      if (parseResult is Success) {
        final Map<String, dynamic> data =
            parseResult.value as Map<String, dynamic>;

        final THConfigElement element = _buildElementFromMap(
          data: data,
          lineNumber: startLineNumber,
          originalLine: originalFullLine,
        );

        // Track encoding header if specified
        if ((element is THConfigSetting) &&
            (element.keyword.toLowerCase() == 'encoding') &&
            element.arguments.isNotEmpty) {
          configFile.encoding = element.arguments.first;
        }

        configFile.elements.add(element);
      } else {
        configFile.parseErrors.add(
          'Syntax error at line $startLineNumber: ${parseResult.message}',
        );

        configFile.elements.add(
          THConfigComment(
            commentText: currentLine,
            lineNumber: startLineNumber,
            originalLine: originalFullLine,
          ),
        );
      }

      lineIndex++;
    }

    return configFile;
  }

  THConfigElement _buildElementFromMap({
    required Map<String, dynamic> data,
    required int lineNumber,
    required String originalLine,
  }) {
    final String type = data['type'] as String? ?? 'general';

    switch (type) {
      case 'source':
        return THConfigSource(
          filePath: data['filePath'] as String? ?? '',
          isMultiLine: data['isMultiLine'] as bool? ?? false,
          lineNumber: lineNumber,
          originalLine: originalLine,
        );

      case 'input':
        return THConfigInput(
          filePath: data['filePath'] as String? ?? '',
          lineNumber: lineNumber,
          originalLine: originalLine,
        );

      case 'export':
        final String exportType = data['exportType'] as String? ?? 'map';
        final String rawOpts = data['rawOptions'] as String? ?? '';
        final ({String? output, String? layout, String? projection}) parsed =
            _parseExportOptions(rawOpts);

        return THConfigExport(
          exportType: exportType,
          outputFilePath: parsed.output,
          layoutId: parsed.layout,
          projection: parsed.projection,
          rawOptions: rawOpts.isNotEmpty ? rawOpts.split(RegExp(r'\s+')) : null,
          lineNumber: lineNumber,
          originalLine: originalLine,
        );

      case 'select':
        final bool isSelect = data['isSelect'] as bool? ?? true;
        final String targetId = data['targetId'] as String? ?? '';
        final String rawOpts = data['rawOptions'] as String? ?? '';

        return THConfigSelect(
          isSelect: isSelect,
          targetObjectId: targetId,
          rawOptions: rawOpts.isNotEmpty ? rawOpts.split(RegExp(r'\s+')) : null,
          lineNumber: lineNumber,
          originalLine: originalLine,
        );

      case 'setting':
        final String keyword = data['keyword'] as String? ?? '';
        final String rawArgs = data['rawArguments'] as String? ?? '';
        final List<String> args =
            rawArgs.isNotEmpty ? rawArgs.split(RegExp(r'\s+')) : <String>[];

        return THConfigSetting(
          keyword: keyword,
          arguments: args,
          lineNumber: lineNumber,
          originalLine: originalLine,
        );

      default:
        final String keyword = data['keyword'] as String? ?? '';
        final String rawArgs = data['rawArguments'] as String? ?? '';
        final List<String> args =
            rawArgs.isNotEmpty ? rawArgs.split(RegExp(r'\s+')) : <String>[];

        return THConfigSetting(
          keyword: keyword,
          arguments: args,
          lineNumber: lineNumber,
          originalLine: originalLine,
        );
    }
  }

  ({String? output, String? layout, String? projection}) _parseExportOptions(
    String rawOptions,
  ) {
    String? output;
    String? layout;
    String? projection;

    final RegExp outputRegex = RegExp(
      r'(?:-output|-o)\s+([^\s]+)',
      caseSensitive: false,
    );
    final RegExp layoutRegex = RegExp(
      r'(?:-layout|-l)\s+([^\s]+)',
      caseSensitive: false,
    );
    final RegExp projRegex = RegExp(
      r'(?:-projection|-proj)\s+([^\s]+)',
      caseSensitive: false,
    );

    final RegExpMatch? outMatch = outputRegex.firstMatch(rawOptions);
    if (outMatch != null) {
      output = _cleanQuotes(outMatch.group(1)!);
    }

    final RegExpMatch? layMatch = layoutRegex.firstMatch(rawOptions);
    if (layMatch != null) {
      layout = _cleanQuotes(layMatch.group(1)!);
    }

    final RegExpMatch? prMatch = projRegex.firstMatch(rawOptions);
    if (prMatch != null) {
      projection = _cleanQuotes(prMatch.group(1)!);
    }

    return (output: output, layout: layout, projection: projection);
  }

  String _cleanQuotes(String s) {
    if ((s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      return s.substring(1, s.length - 1);
    }
    return s;
  }
}
