// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/th_project_therion_diagnostics_aux.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  final String workingDirectory = p.normalize(
    p.join(Directory.current.path, 'test', 'auxiliary', 'th_project', 'missing-file'),
  );

  String canonical(String relativeOrAbsolutePath) => THProjectPathResolver.canonicalize(
    p.isAbsolute(relativeOrAbsolutePath)
        ? relativeOrAbsolutePath
        : p.join(workingDirectory, relativeOrAbsolutePath),
  );

  group('parseTherionRunDiagnostics', () {
    test('matches the documented error shape', () {
      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'therion: error -- cave.th [line 42] -- syntax error',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics, hasLength(1));
      expect(diagnostics.single.severity, THProjectParseErrorSeverity.error);
      expect(diagnostics.single.filePath, canonical('cave.th'));
      expect(diagnostics.single.lineNumber, 42);
      expect(diagnostics.single.message, 'syntax error');
    });

    test('matches the documented warning shape', () {
      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'therion: warning -- cave.th [line 7] -- deprecated usage',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics, hasLength(1));
      expect(
        diagnostics.single.severity,
        THProjectParseErrorSeverity.warning,
      );
      expect(diagnostics.single.lineNumber, 7);
      expect(diagnostics.single.message, 'deprecated usage');
    });

    test('is case-insensitive for the error/warning keyword', () {
      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'Therion: ERROR -- cave.th [line 1] -- upper case',
          'therion: Warning -- cave.th [line 2] -- mixed case',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics, hasLength(2));
      expect(diagnostics[0].severity, THProjectParseErrorSeverity.error);
      expect(diagnostics[1].severity, THProjectParseErrorSeverity.warning);
    });

    test('ignores lines without a [line N] location', () {
      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'therion: error -- general failure, no location',
          'some unrelated output line',
          '3 errors, 1 warning',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics, isEmpty);
    });

    test('resolves a relative file path against workingDirectory', () {
      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'therion: error -- cave.th [line 5] -- relative path',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics.single.filePath, canonical('cave.th'));
      expect(p.isAbsolute(diagnostics.single.filePath), isTrue);
    });

    test('keeps an already-absolute file path as-is (canonicalized)', () {
      final String absolutePath = p.join(workingDirectory, 'cave.th');

      final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
        outputLines: <String>[
          'therion: error -- $absolutePath [line 5] -- absolute path',
        ],
        logLines: const <String>[],
        workingDirectory: workingDirectory,
      );

      expect(diagnostics.single.filePath, canonical(absolutePath));
    });

    test(
      'de-duplicates an identical diagnostic seen in both outputLines and '
      'logLines',
      () {
        const String line = 'therion: error -- cave.th [line 9] -- duplicate';

        final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
          outputLines: <String>[line],
          logLines: <String>[line],
          workingDirectory: workingDirectory,
        );

        expect(diagnostics, hasLength(1));
      },
    );

    test(
      'keeps distinct diagnostics that differ only by line number or '
      'message',
      () {
        final List<THProjectParseError> diagnostics = parseTherionRunDiagnostics(
          outputLines: <String>[
            'therion: error -- cave.th [line 9] -- first message',
            'therion: error -- cave.th [line 10] -- first message',
            'therion: error -- cave.th [line 9] -- second message',
          ],
          logLines: const <String>[],
          workingDirectory: workingDirectory,
        );

        expect(diagnostics, hasLength(3));
      },
    );
  });
}
