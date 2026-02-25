// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';

void main() {
  group('Dart command resolver', () {
    test('uses resolved executable when it already points to dart', () {
      final String resolvedExecutablePath = r'C:\tools\dart-sdk\bin\dart.exe';

      final String command = _resolveDartCommandForPlatform(
        resolvedExecutablePath: resolvedExecutablePath,
        isWindows: true,
        flutterRootPath: null,
        fileExists: (String _) {
          return false;
        },
      );

      expect(command, resolvedExecutablePath);
    });

    test('falls back to FLUTTER_ROOT dart executable when available', () {
      final String flutterRootPath = r'D:\flutter';
      final String expectedWindowsDartPath =
          r'D:\flutter\bin\cache\dart-sdk\bin\dart.exe';

      final String command = _resolveDartCommandForPlatform(
        resolvedExecutablePath: r'C:\Windows\System32\cmd.exe',
        isWindows: true,
        flutterRootPath: flutterRootPath,
        fileExists: (String path) {
          return path == expectedWindowsDartPath;
        },
      );

      expect(command, expectedWindowsDartPath);
    });
  });

  group('MPTherionRunner monitoring', () {
    test('escalates status from warning to error and records issues', () async {
      final String scriptSource = '''
void main(List<String> arguments) {
  print('normal line');
  print('WaRnInG: first issue');
  print('ERROR: second issue');
}
''';

      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'mapiah_runner_test_',
      );

      try {
        final String scriptPath = await _createScriptFile(
          directory: tempDirectory,
          filename: 'runner_warning_error.dart',
          source: scriptSource,
        );

        final MPTherionRunner runner = MPTherionRunner(
          therionExecutablePath: _dartCommandForPlatform(),
          thConfigFilePath: scriptPath,
        );

        try {
          await runner.start();

          final MPTherionRunStatus finalStatus = runner.statusNotifier.value;
          final List<MPTherionIssue> issues = runner.issuesNotifier.value;

          expect(finalStatus, MPTherionRunStatus.error);
          expect(issues.length, 2);
          expect(issues[0].kind, MPTherionIssueKind.warning);
          expect(issues[0].lineIndex, 1);
          expect(issues[1].kind, MPTherionIssueKind.error);
          expect(issues[1].lineIndex, 2);
        } finally {
          runner.dispose();
        }
      } finally {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('keeps final status as warning when no error exists', () async {
      final String scriptSource = '''
void main(List<String> arguments) {
  print('line one');
  print('warning: only warning issue');
}
''';

      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'mapiah_runner_test_',
      );

      try {
        final String scriptPath = await _createScriptFile(
          directory: tempDirectory,
          filename: 'runner_warning_only.dart',
          source: scriptSource,
        );

        final MPTherionRunner runner = MPTherionRunner(
          therionExecutablePath: _dartCommandForPlatform(),
          thConfigFilePath: scriptPath,
        );

        try {
          await runner.start();

          final MPTherionRunStatus finalStatus = runner.statusNotifier.value;
          final List<MPTherionIssue> issues = runner.issuesNotifier.value;

          expect(finalStatus, MPTherionRunStatus.warning);
          expect(issues.length, 1);
          expect(issues[0].kind, MPTherionIssueKind.warning);
          expect(issues[0].lineIndex, 1);
        } finally {
          runner.dispose();
        }
      } finally {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('finishes with ok status when no warning or error exists', () async {
      final String scriptSource = '''
void main(List<String> arguments) {
  print('line one');
  print('line two');
}
''';

      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'mapiah_runner_test_',
      );

      try {
        final String scriptPath = await _createScriptFile(
          directory: tempDirectory,
          filename: 'runner_ok.dart',
          source: scriptSource,
        );

        final MPTherionRunner runner = MPTherionRunner(
          therionExecutablePath: _dartCommandForPlatform(),
          thConfigFilePath: scriptPath,
        );

        try {
          await runner.start();

          final MPTherionRunStatus finalStatus = runner.statusNotifier.value;
          final List<MPTherionIssue> issues = runner.issuesNotifier.value;

          expect(finalStatus, MPTherionRunStatus.ok);
          expect(issues, isEmpty);
        } finally {
          runner.dispose();
        }
      } finally {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('parses carriage return as line break without blank lines', () async {
      final String scriptSource = '''
import 'dart:io';

void main(List<String> arguments) {
  stdout.write('line one\\rline two\\rline three\\n');
}
''';

      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'mapiah_runner_test_',
      );

      try {
        final String scriptPath = await _createScriptFile(
          directory: tempDirectory,
          filename: 'runner_carriage_return_lines.dart',
          source: scriptSource,
        );

        final MPTherionRunner runner = MPTherionRunner(
          therionExecutablePath: _dartCommandForPlatform(),
          thConfigFilePath: scriptPath,
        );

        try {
          await runner.start();

          final List<String> outputLines = runner.outputLinesNotifier.value;

          expect(outputLines, <String>['line one', 'line two', 'line three']);
        } finally {
          runner.dispose();
        }
      } finally {
        await tempDirectory.delete(recursive: true);
      }
    });

    test(
      'overwrites final status to error when process exit code is non-zero',
      () async {
        final String scriptSource = '''
import 'dart:io';

void main(List<String> arguments) {
  print('warning: only warning issue');
  exitCode = 2;
}
''';

        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'mapiah_runner_test_',
        );

        try {
          final String scriptPath = await _createScriptFile(
            directory: tempDirectory,
            filename: 'runner_non_zero_exit.dart',
            source: scriptSource,
          );

          final MPTherionRunner runner = MPTherionRunner(
            therionExecutablePath: _dartCommandForPlatform(),
            thConfigFilePath: scriptPath,
          );

          try {
            await runner.start();

            final MPTherionRunStatus finalStatus = runner.statusNotifier.value;
            final List<MPTherionIssue> issues = runner.issuesNotifier.value;

            expect(finalStatus, MPTherionRunStatus.error);
            expect(issues.length, 1);
            expect(issues[0].kind, MPTherionIssueKind.warning);
          } finally {
            runner.dispose();
          }
        } finally {
          await tempDirectory.delete(recursive: true);
        }
      },
    );
  });
}

Future<String> _createScriptFile({
  required Directory directory,
  required String filename,
  required String source,
}) async {
  final String scriptPath = '${directory.path}/$filename';
  final File scriptFile = File(scriptPath);

  await scriptFile.writeAsString(source);

  return scriptPath;
}

String _dartCommandForPlatform() {
  final String? flutterRootPath = Platform.environment['FLUTTER_ROOT'];

  return _resolveDartCommandForPlatform(
    resolvedExecutablePath: Platform.resolvedExecutable,
    isWindows: Platform.isWindows,
    flutterRootPath: flutterRootPath,
    fileExists: (String path) {
      final File file = File(path);

      return file.existsSync();
    },
  );
}

String _resolveDartCommandForPlatform({
  required String resolvedExecutablePath,
  required bool isWindows,
  required String? flutterRootPath,
  required bool Function(String path) fileExists,
}) {
  final String normalizedResolvedExecutablePath = resolvedExecutablePath
      .toLowerCase();
  final bool resolvedExecutableIsDart =
      normalizedResolvedExecutablePath.endsWith('dart.exe') ||
      normalizedResolvedExecutablePath.endsWith('/dart');

  if (resolvedExecutableIsDart) {
    return resolvedExecutablePath;
  }

  final bool hasFlutterRootPath =
      flutterRootPath != null && flutterRootPath.isNotEmpty;

  if (hasFlutterRootPath) {
    final String flutterDartExecutablePath = isWindows
        ? '$flutterRootPath\\bin\\cache\\dart-sdk\\bin\\dart.exe'
        : '$flutterRootPath/bin/cache/dart-sdk/bin/dart';
    final bool flutterDartExecutableExists = fileExists(
      flutterDartExecutablePath,
    );

    if (flutterDartExecutableExists) {
      return flutterDartExecutablePath;
    }
  }

  return 'dart';
}
