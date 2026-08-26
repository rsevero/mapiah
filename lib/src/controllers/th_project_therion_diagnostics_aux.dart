// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

/// Matches Therion's located diagnostic lines, e.g.:
/// `therion: error -- filename.th [line 42] -- syntax error`
/// `therion: warning -- filename.th [line 12] -- some warning`
///
/// Written as a plain (non-raw) string with [mpTherionWarningWord]/
/// [mpTherionErrorWord] interpolated into it, matching the exact idiom
/// `mp_therion_runner.dart`'s own `_warningRegex`/`_errorRegex` already use
/// -- a raw string would not interpolate those constants.
final RegExp _locatedTherionIssueRegex = RegExp(
  '\\btherion\\b\\s*:\\s*($mpTherionWarningWord|$mpTherionErrorWord)\\s*--\\s*'
  '([^\\[\\]]+?)\\s*\\[\\s*(?:line\\s+)?(\\d+)\\s*\\]\\s*--\\s*(.+)\$',
  caseSensitive: false,
);

/// Parses Therion compiler output (live stdout/stderr capture and/or the
/// contents of `therion.log`) into file/line-addressable
/// [THProjectParseError]s. Lines that don't match the located-diagnostic
/// shape (e.g. summary lines, loop-closure reports) are ignored here --
/// they're already surfaced as-is in the run dialog's raw output pane.
List<THProjectParseError> parseTherionRunDiagnostics({
  required List<String> outputLines,
  required List<String> logLines,
  required String workingDirectory,
}) {
  final List<THProjectParseError> diagnostics = <THProjectParseError>[];
  final Set<String> seenKeys = <String>{};

  void collectFrom(List<String> lines) {
    for (final String line in lines) {
      final RegExpMatch? match = _locatedTherionIssueRegex.firstMatch(line);

      if (match == null) {
        continue;
      }

      final bool isError =
          match.group(1)!.toLowerCase() == mpTherionErrorWord;
      final String rawFilePath = match.group(2)!.trim();
      final int lineNumber = int.parse(match.group(3)!);
      final String message = match.group(4)!.trim();
      final String canonicalPath = THProjectPathResolver.canonicalize(
        p.isAbsolute(rawFilePath)
            ? rawFilePath
            : p.join(workingDirectory, rawFilePath),
      );
      final String dedupeKey = '$canonicalPath|$lineNumber|$isError|$message';

      if (!seenKeys.add(dedupeKey)) {
        continue;
      }

      diagnostics.add(
        THProjectParseError(
          message: message,
          severity: isError
              ? THProjectParseErrorSeverity.error
              : THProjectParseErrorSeverity.warning,
          filePath: canonicalPath,
          lineNumber: lineNumber,
        ),
      );
    }
  }

  collectFrom(outputLines);
  collectFrom(logLines);

  return diagnostics;
}
