import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:path/path.dart' as p;

typedef MPTherionRunnerErrorCallback =
    void Function(Object error, StackTrace stackTrace);

enum MPTherionRunStatus { running, ok, warning, error }

enum MPTherionIssueKind { warning, error }

class MPTherionIssue {
  final MPTherionIssueKind kind;
  final int lineIndex;
  final String lineText;

  const MPTherionIssue({
    required this.kind,
    required this.lineIndex,
    required this.lineText,
  });
}

class MPTherionRunner {
  final String therionExecutablePath;
  final String thConfigFilePath;
  final MPTherionRunnerErrorCallback? onError;

  final StreamController<String> _outputController =
      StreamController<String>.broadcast();

  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<MPTherionRunStatus> statusNotifier =
      ValueNotifier<MPTherionRunStatus>(MPTherionRunStatus.ok);
  final ValueNotifier<List<String>> outputLinesNotifier =
      ValueNotifier<List<String>>(<String>[]);
  final ValueNotifier<List<MPTherionIssue>> issuesNotifier =
      ValueNotifier<List<MPTherionIssue>>(<MPTherionIssue>[]);

  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  String _pendingLine = '';

  static final RegExp _warningRegex = RegExp(
    '\\b$mpTherionWarningWord\\b',
    caseSensitive: false,
  );
  static final RegExp _errorRegex = RegExp(
    '\\b$mpTherionErrorWord\\b',
    caseSensitive: false,
  );

  MPTherionRunner({
    required this.therionExecutablePath,
    required this.thConfigFilePath,
    this.onError,
  });

  Stream<String> get outputStream => _outputController.stream;

  Future<void> start() async {
    final String workingDirectory = p.dirname(thConfigFilePath);
    int? therionExitCode;

    isRunningNotifier.value = true;
    statusNotifier.value = MPTherionRunStatus.running;

    try {
      final Process process = await Process.start(
        therionExecutablePath,
        [thConfigFilePath],
        workingDirectory: workingDirectory,
        runInShell: true,
      );

      _process = process;

      _stdoutSubscription = utf8.decoder
          .bind(process.stdout)
          .listen(
            _handleOutput,
            onError: (Object error) {
              _handleOutput('$error\n');
            },
          );

      _stderrSubscription = utf8.decoder
          .bind(process.stderr)
          .listen(
            _handleOutput,
            onError: (Object error) {
              _handleOutput('$error\n');
            },
          );

      therionExitCode = await process.exitCode;
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      _handleOutput('$error\n');
      _escalateStatus(MPTherionRunStatus.error);
    } finally {
      _flushPendingLine();
      isRunningNotifier.value = false;

      final bool hasExitCode = therionExitCode != null;
      final bool hasSuccessfulExitCode =
          hasExitCode && (therionExitCode == mpProcessExitCodeSuccess);

      if (hasExitCode && !hasSuccessfulExitCode) {
        statusNotifier.value = MPTherionRunStatus.error;
      } else if (statusNotifier.value == MPTherionRunStatus.running) {
        statusNotifier.value = MPTherionRunStatus.ok;
      }
    }
  }

  void stop() {
    if (isRunningNotifier.value) {
      _process?.kill();
    }
  }

  void dispose() {
    _stdoutSubscription?.cancel();
    _stderrSubscription?.cancel();
    stop();
    _outputController.close();
    isRunningNotifier.dispose();
    statusNotifier.dispose();
    outputLinesNotifier.dispose();
    issuesNotifier.dispose();
  }

  void _handleOutput(String text) {
    _emitOutput(text);
    _parseOutput(text);
  }

  void _parseOutput(String text) {
    final String normalizedText = text.replaceAll('\r', '');
    final String combinedText = '$_pendingLine$normalizedText';
    final List<String> splitLines = combinedText.split('\n');

    _pendingLine = splitLines.removeLast();

    for (final String line in splitLines) {
      _registerOutputLine(line);
    }
  }

  void _flushPendingLine() {
    if (_pendingLine.isEmpty) {
      return;
    }

    final String trailingLine = _pendingLine;
    _pendingLine = '';
    _registerOutputLine(trailingLine);
  }

  void _registerOutputLine(String line) {
    final List<String> currentLines = List<String>.from(
      outputLinesNotifier.value,
    );
    final int lineIndex = currentLines.length;

    currentLines.add(line);
    outputLinesNotifier.value = currentLines;

    final bool containsWarning = _warningRegex.hasMatch(line);
    final bool containsError = _errorRegex.hasMatch(line);

    if (!containsWarning && !containsError) {
      return;
    }

    final List<MPTherionIssue> currentIssues = List<MPTherionIssue>.from(
      issuesNotifier.value,
    );

    if (containsWarning) {
      currentIssues.add(
        MPTherionIssue(
          kind: MPTherionIssueKind.warning,
          lineIndex: lineIndex,
          lineText: line,
        ),
      );
      _escalateStatus(MPTherionRunStatus.warning);
    }

    if (containsError) {
      currentIssues.add(
        MPTherionIssue(
          kind: MPTherionIssueKind.error,
          lineIndex: lineIndex,
          lineText: line,
        ),
      );
      _escalateStatus(MPTherionRunStatus.error);
    }

    issuesNotifier.value = currentIssues;
  }

  void _escalateStatus(MPTherionRunStatus nextStatus) {
    final MPTherionRunStatus currentStatus = statusNotifier.value;

    if (currentStatus == MPTherionRunStatus.error) {
      return;
    }

    if (nextStatus == MPTherionRunStatus.error) {
      statusNotifier.value = MPTherionRunStatus.error;

      return;
    }

    if (currentStatus == MPTherionRunStatus.warning) {
      return;
    }

    if (nextStatus == MPTherionRunStatus.warning) {
      statusNotifier.value = MPTherionRunStatus.warning;
    }
  }

  void _emitOutput(String text) {
    if (text.isEmpty || _outputController.isClosed) {
      return;
    }

    _outputController.add(text);
  }
}
