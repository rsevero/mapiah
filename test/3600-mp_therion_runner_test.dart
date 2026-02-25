// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';

void main() {
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
  if (Platform.isWindows) {
    return 'dart.exe';
  }

  return 'dart';
}
