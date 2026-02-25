import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
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
  final MPLocator mpLocator;
  final MPWindowsRegistryReader windowsRegistryReader;
  final MPWindowsShellProbe windowsShellProbe;
  final MPTherionProcessRunner? windowsProcessRunner;

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
    MPLocator? mpLocator,
    MPWindowsRegistryReader? windowsRegistryReader,
    MPWindowsShellProbe? windowsShellProbe,
    this.windowsProcessRunner,
  }) : mpLocator = mpLocator ?? MPLocator(),
       windowsRegistryReader =
           windowsRegistryReader ?? _MPTherionRunnerWindowsRegistryReader(),
       windowsShellProbe =
           windowsShellProbe ?? _MPTherionRunnerWindowsShellProbe();

  Stream<String> get outputStream => _outputController.stream;

  Future<void> start() async {
    final String workingDirectory = p.dirname(thConfigFilePath);
    int? therionExitCode;
    bool hasExecutionFailure = false;

    isRunningNotifier.value = true;
    statusNotifier.value = MPTherionRunStatus.running;

    try {
      if (_shouldUseWindowsRunner()) {
        final MPTherionExecutionResult windowsExecutionResult =
            await _runUsingWindowsRunner(workingDirectory: workingDirectory);

        hasExecutionFailure = !windowsExecutionResult.success;

        final String? localizedErrorMessage =
            windowsExecutionResult.localizedErrorMessage;
        final bool hasLocalizedErrorMessage =
            localizedErrorMessage != null && localizedErrorMessage.isNotEmpty;

        if (hasLocalizedErrorMessage) {
          _handleOutput('$localizedErrorMessage\n');
        }
      } else {
        therionExitCode = await _runUsingStandardProcess(
          workingDirectory: workingDirectory,
        );
      }
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      _handleOutput('$error\n');
      _escalateStatus(MPTherionRunStatus.error);
      hasExecutionFailure = true;
    } finally {
      _flushPendingLine();
      isRunningNotifier.value = false;

      _finalizeRunStatus(
        hasExecutionFailure: hasExecutionFailure,
        therionExitCode: therionExitCode,
      );
    }
  }

  bool _shouldUseWindowsRunner() {
    final bool isWindowsPlatform = Platform.isWindows;

    return isWindowsPlatform;
  }

  Future<MPTherionExecutionResult> _runUsingWindowsRunner({
    required String workingDirectory,
  }) async {
    final MPTherionProcessRunner processRunner =
        windowsProcessRunner ??
        _MPTherionRunnerWindowsProcessRunner(
          onProcessStarted: (Process process) {
            _process = process;
          },
          onOutput: _handleOutput,
          onError: onError,
        );

    final MPWindowsTherionRunner windowsTherionRunner = MPWindowsTherionRunner(
      mpLocator: mpLocator,
      registryReader: windowsRegistryReader,
      shellProbe: windowsShellProbe,
      processRunner: processRunner,
    );

    final MPTherionExecutionResult windowsExecutionResult =
        await windowsTherionRunner.runCompile(
          therionOptions: mpEmptyString,
          therionFileName: thConfigFilePath,
          workingDirectory: workingDirectory,
        );

    return windowsExecutionResult;
  }

  Future<int> _runUsingStandardProcess({
    required String workingDirectory,
  }) async {
    final ({String executable, List<String> arguments}) executionConfig =
        _buildExecutionConfig();
    final String processExecutable = executionConfig.executable;
    final List<String> processArguments = executionConfig.arguments;

    final Process process = await Process.start(
      processExecutable,
      processArguments,
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

    final int therionExitCode = await process.exitCode;

    return therionExitCode;
  }

  void _finalizeRunStatus({
    required bool hasExecutionFailure,
    required int? therionExitCode,
  }) {
    final bool hasExitCode = therionExitCode != null;
    final bool hasSuccessfulExitCode =
        hasExitCode && (therionExitCode == mpProcessExitCodeSuccess);
    final bool hasFailedExitCode = hasExitCode && !hasSuccessfulExitCode;
    final bool shouldSetErrorStatus = hasExecutionFailure || hasFailedExitCode;

    if (shouldSetErrorStatus) {
      statusNotifier.value = MPTherionRunStatus.error;

      return;
    }

    if (statusNotifier.value == MPTherionRunStatus.running) {
      statusNotifier.value = MPTherionRunStatus.ok;
    }
  }

  ({String executable, List<String> arguments}) _buildExecutionConfig() {
    final String therionExecutable = therionExecutablePath.trim();
    final List<String> therionArguments = <String>[thConfigFilePath];

    if (!mpIsFlathub) {
      return (executable: therionExecutable, arguments: therionArguments);
    }

    final List<String> hostArguments = <String>[
      mpFlatpakSpawnHostArgument,
      therionExecutable,
      ...therionArguments,
    ];

    return (executable: mpFlatpakSpawnExecutableName, arguments: hostArguments);
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

class _MPTherionRunnerWindowsRegistryReader implements MPWindowsRegistryReader {
  @override
  String? readString64Bit({
    required String registryPath,
    required String valueName,
  }) {
    return _readStringWithRegistryView(
      registryPath: registryPath,
      valueName: valueName,
      registryViewSwitch: mpWindowsRegistryQuery64BitSwitch,
    );
  }

  @override
  String? readString32Bit({
    required String registryPath,
    required String valueName,
  }) {
    return _readStringWithRegistryView(
      registryPath: registryPath,
      valueName: valueName,
      registryViewSwitch: mpWindowsRegistryQuery32BitSwitch,
    );
  }

  String? _readStringWithRegistryView({
    required String registryPath,
    required String valueName,
    required String registryViewSwitch,
  }) {
    final List<String> queryArguments = <String>[
      registryPath,
      mpWindowsRegistryQueryValueSwitch,
      valueName,
      registryViewSwitch,
    ];

    final ProcessResult queryResult = Process.runSync(
      mpWindowsRegistryQueryCommand,
      queryArguments,
      runInShell: true,
    );
    final bool hasSuccessfulExitCode =
        queryResult.exitCode == mpProcessExitCodeSuccess;

    if (!hasSuccessfulExitCode) {
      return null;
    }

    final Object? rawStandardOutput = queryResult.stdout;
    if (rawStandardOutput is! String) {
      return null;
    }

    final Iterable<String> outputLines = LineSplitter.split(rawStandardOutput);

    for (final String outputLine in outputLines) {
      final String trimmedLine = outputLine.trimLeft();
      final bool containsRequestedValue = trimmedLine.startsWith(valueName);
      if (!containsRequestedValue) {
        continue;
      }

      final List<String> lineParts = trimmedLine.split(RegExp(r'\s+'));
      final bool hasExpectedTokenCount =
          lineParts.length >= mpWindowsRegistryQueryMinimumTokens;
      if (!hasExpectedTokenCount) {
        continue;
      }

      final String parsedValue = lineParts
          .sublist(mpWindowsRegistryQueryValueStartTokenIndex)
          .join(mpCommandSeparatorSpace)
          .trim();

      if (parsedValue.isEmpty) {
        return null;
      }

      return parsedValue;
    }

    return null;
  }
}

class _MPTherionRunnerWindowsShellProbe implements MPWindowsShellProbe {
  @override
  bool isCmdExeAvailable() {
    final String? systemRootDirectory =
        Platform.environment[mpWindowsSystemRootEnvironmentVariable];
    if (systemRootDirectory == null) {
      return false;
    }

    final String trimmedSystemRootDirectory = systemRootDirectory.trim();
    if (trimmedSystemRootDirectory.isEmpty) {
      return false;
    }

    final String cmdExecutablePath = p.join(
      trimmedSystemRootDirectory,
      mpWindowsSystem32Directory,
      mpWindowsCmdExecutable,
    );
    final File cmdExecutable = File(cmdExecutablePath);
    final bool cmdExecutableExists = cmdExecutable.existsSync();

    return cmdExecutableExists;
  }
}

class _MPTherionRunnerWindowsProcessRunner implements MPTherionProcessRunner {
  final void Function(Process process) onProcessStarted;
  final void Function(String outputText) onOutput;
  final MPTherionRunnerErrorCallback? onError;

  const _MPTherionRunnerWindowsProcessRunner({
    required this.onProcessStarted,
    required this.onOutput,
    required this.onError,
  });

  @override
  Future<MPTherionExecutionResult> run({
    required String commandLine,
    required String workingDirectory,
  }) async {
    final StringBuffer standardOutputBuffer = StringBuffer();
    final StringBuffer standardErrorBuffer = StringBuffer();

    try {
      final Process process = await Process.start(
        commandLine,
        const <String>[],
        workingDirectory: workingDirectory,
        runInShell: true,
      );
      onProcessStarted(process);

      final StreamSubscription<String> stdoutSubscription = utf8.decoder
          .bind(process.stdout)
          .listen(
            (String outputChunk) {
              standardOutputBuffer.write(outputChunk);
              onOutput(outputChunk);
            },
            onError: (Object error, StackTrace stackTrace) {
              final String errorText = '$error';
              standardErrorBuffer.write('$errorText\n');
              onOutput('$errorText\n');
              onError?.call(error, stackTrace);
            },
          );

      final StreamSubscription<String> stderrSubscription = utf8.decoder
          .bind(process.stderr)
          .listen(
            (String outputChunk) {
              standardErrorBuffer.write(outputChunk);
              onOutput(outputChunk);
            },
            onError: (Object error, StackTrace stackTrace) {
              final String errorText = '$error';
              standardErrorBuffer.write('$errorText\n');
              onOutput('$errorText\n');
              onError?.call(error, stackTrace);
            },
          );

      final int processExitCode = await process.exitCode;

      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();

      final bool success = processExitCode == mpProcessExitCodeSuccess;

      return MPTherionExecutionResult(
        success: success,
        commandLine: commandLine,
        standardOutput: standardOutputBuffer.toString(),
        standardError: standardErrorBuffer.toString(),
        localizedErrorMessage: null,
      );
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace);

      final String errorText = '$error';
      onOutput('$errorText\n');

      return MPTherionExecutionResult(
        success: false,
        commandLine: commandLine,
        standardOutput: standardOutputBuffer.toString(),
        standardError: errorText,
        localizedErrorMessage: null,
      );
    }
  }
}
