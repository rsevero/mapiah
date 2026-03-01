import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_linux_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_macos_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_platform_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_therion_cache.dart';
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
  static void clearSearchedTherionExecutablePathCache() {
    MPTherionCache.clearSearchedTherionExecutablePathCache();
  }

  /// Checks whether a viable Therion executable is available.
  ///
  /// The check prefers a cached path from a previous successful check (via
  /// `MPTherionCache`), then checks the user-configured setting (via
  /// `mpLocator`), and finally attempts an automatic probe (default executable
  /// name / platform probes). Results are cached for the process lifetime; call
  /// `clearSearchedTherionExecutablePathCache()` to force a re-check.
  static Future<bool> isTherionAvailable() async {
    final String? cached = MPTherionCache.cachedSearchedTherionExecutablePath;

    if ((cached != null) && cached.isNotEmpty) {
      return true;
    }

    Future<bool> validateExecutable(String executable) async {
      try {
        final ProcessResult result = await Process.run(executable, <String>[
          '--version',
        ]);

        final bool success = result.exitCode == mpProcessExitCodeSuccess;
        if (success) {
          MPTherionCache.cacheSearchedTherionExecutablePath(executable);
        }

        return success;
      } on Object {
        return false;
      }
    }

    final String configured =
        MPPlatformTherionRunner.getUserDefinedTherionExecutablePath();

    if (configured.isNotEmpty) {
      final bool configuredOk = await validateExecutable(configured);

      if (configuredOk) {
        return true;
      }
    }

    // Automatic probe: delegate to the platform-specific runner so that the
    // full search strategy (registry lookup on Windows, filesystem scan on
    // macOS, PATH-based default on Linux/other) is encapsulated in each
    // subclass rather than hardcoded here.
    final String candidate;

    if (Platform.isWindows) {
      candidate = MPWindowsTherionRunner.probeForTherionExecutablePath();
    } else if (Platform.isMacOS) {
      candidate = MPMacOSTherionRunner.probeForTherionExecutablePath();
    } else {
      candidate = MPLinuxTherionRunner.probeForTherionExecutablePath();
    }

    return validateExecutable(candidate);
  }

  final String therionExecutablePath;
  final String thConfigFilePath;
  final MPTherionRunnerErrorCallback? onError;
  final MPLocator mpLocator = MPLocator();

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
    this.therionExecutablePath = 'therion',
    required this.thConfigFilePath,
    this.onError,
  });

  Stream<String> get outputStream => _outputController.stream;

  Future<void> start() async {
    final String workingDirectory = p.dirname(thConfigFilePath);

    bool hasExecutionFailure = false;

    isRunningNotifier.value = true;
    statusNotifier.value = MPTherionRunStatus.running;

    try {
      final MPPlatformTherionRunner platformRunner = _createPlatformRunner();
      final MPTherionExecutionResult executionResult = await platformRunner
          .runCompile(
            therionOptions: mpEmptyString,
            therionFileName: thConfigFilePath,
            workingDirectory: workingDirectory,
          );

      hasExecutionFailure = !executionResult.success;

      final String? localizedErrorMessage =
          executionResult.localizedErrorMessage;
      final bool hasLocalizedErrorMessage =
          (localizedErrorMessage != null) && localizedErrorMessage.isNotEmpty;

      if (hasLocalizedErrorMessage) {
        _handleOutput('$localizedErrorMessage\n');
      }
    } on Object catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      _handleOutput('$error\n');
      _escalateStatus(MPTherionRunStatus.error);
      hasExecutionFailure = true;
    } finally {
      _flushPendingLine();
      isRunningNotifier.value = false;
      _finalizeRunStatus(hasExecutionFailure: hasExecutionFailure);
    }
  }

  MPPlatformTherionRunner _createPlatformRunner() {
    final bool isWindowsPlatform = Platform.isWindows;
    final bool isMacOSPlatform = Platform.isMacOS;
    final String configFileExtension = p
        .extension(thConfigFilePath)
        .toLowerCase();
    final bool isTherionConfigFile =
        configFileExtension == mpTherionConfigFileExtension;

    if (isWindowsPlatform && isTherionConfigFile) {
      return MPWindowsTherionRunner(
        mpLocator: mpLocator,
        registryReader: MPDefaultWindowsRegistryReader(),
        shellProbe: _MPTherionRunnerWindowsShellProbe(),
        processRunner: _MPTherionRunnerWindowsProcessRunner(
          onProcessStarted: (Process process) {
            _process = process;
          },
          onOutput: _handleOutput,
          onError: onError,
        ),
      );
    }

    if (isMacOSPlatform && isTherionConfigFile) {
      return MPMacOSTherionRunner(
        mpLocator: mpLocator,
        processRunner: _MPUnixLikeTherionRunnerProcessRunner(
          onProcessStarted: (Process process) {
            _process = process;
          },
          onOutput: _handleOutput,
          onError: onError,
        ),
      );
    }

    // Default: Linux (and other Unix-like platforms).
    return MPLinuxTherionRunner(
      mpLocator: mpLocator,
      processRunner: _MPUnixLikeTherionRunnerProcessRunner(
        onProcessStarted: (Process process) {
          _process = process;
        },
        onOutput: _handleOutput,
        onError: onError,
      ),
    );
  }

  void _finalizeRunStatus({required bool hasExecutionFailure}) {
    if (hasExecutionFailure) {
      statusNotifier.value = MPTherionRunStatus.error;

      return;
    }

    if (statusNotifier.value == MPTherionRunStatus.running) {
      statusNotifier.value = MPTherionRunStatus.ok;
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
    final String normalizedText = _normalizeOutputLineBreaks(text);
    final String combinedText = '$_pendingLine$normalizedText';
    final List<String> splitLines = combinedText.split(mpUnixLineBreak);

    _pendingLine = splitLines.removeLast();

    for (final String line in splitLines) {
      _registerOutputLine(line);
    }
  }

  String _normalizeOutputLineBreaks(String text) {
    final String normalizedWindowsLineBreakText = text.replaceAll(
      mpWindowsLineBreak,
      mpUnixLineBreak,
    );
    final String normalizedText = normalizedWindowsLineBreakText.replaceAll(
      mpCarriageReturn,
      mpUnixLineBreak,
    );

    return normalizedText;
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

// Explanation:

// Purpose: _MPTherionRunnerWindowsProcessRunner is a private implementation of
// MPTherionProcessRunner used to run Therion (or shell commands) on Windows.
// It's used by MPTherionRunner when Windows-specific execution is needed.

// Constructor:

// Requires three callbacks:
// onProcessStarted(Process process): notified immediately after the Process is
// created so the caller can retain/inspect it.
// onOutput(String outputText): called whenever a chunk of stdout/stderr is
// received.
// onError(MPTherionRunnerErrorCallback? onError): optional callback invoked
// when stream errors or process-start exceptions occur.
// run(...) behavior:

// Parameters: commandLine, workingDirectory, optional executablePath, optional
// arguments.
// If executablePath is provided and non-empty (trimmed), the runner starts that
// executable directly with processArguments (the arguments list).
// If no executablePath is given, it constructs shellArguments =
// [mpWindowsShellExecuteFlag, commandLine] and starts mpWindowsCmdExecutable
// (typically cmd.exe) with those shell args. This uses Windows shell execution
// (cmd /c <commandLine>).
// It sets workingDirectory and runInShell: false for Process.start.
// Output handling:

// Uses utf8.decoder.bind(process.stdout).listen(...) and similarly for
//  process.stderr.
// For each chunk received, it appends to standardOutputBuffer or
// standardErrorBuffer and invokes onOutput(outputChunk).
// Stream onError handlers record the error text, call onOutput with an
// error-looking line, and invoke the provided onError callback with the
// exception and stack trace.
// Completion and return:

// Waits for process.exitCode, then cancels both stdout/stderr subscriptions.
// Determines success by comparing processExitCode to mpProcessExitCodeSuccess.
// Returns MPTherionExecutionResult containing:
// success (bool),
// commandLine (the input commandLine),
// standardOutput and standardError (the collected buffers),
// localizedErrorMessage: null (not produced here).
// Error handling:

// A try/catch surrounds the process start and stream setup. If an exception is
// thrown, the code:
// Calls onError?.call(error, stackTrace),
// Calls onOutput with the error text,
// Returns a failure MPTherionExecutionResult with standardError set to the
// error text.
// Resource management:

// Subscriptions are awaited/cancelled after process exit to avoid leaking
// stream listeners.
// onProcessStarted gives the caller the Process reference so it can be
// killed/stopped elsewhere.
// Important notes / edge cases:

// The runner passes raw chunk strings to onOutput (not line-normalized), so
// consumers should handle partial lines.
// When using shell mode (cmd.exe), the commandLine is passed to the shell; when
// executablePath is used, commandLine is not executed by a shell—arguments are
// used instead.
// No localized error messages are produced here; any localization is handled
// upstream if needed.
// The implementation expects the constants mpWindowsCmdExecutable,
// mpWindowsShellExecuteFlag, and mpProcessExitCodeSuccess from
// mp_constants.dart.

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
    String? executablePath,
    List<String>? arguments,
  }) async {
    final StringBuffer standardOutputBuffer = StringBuffer();
    final StringBuffer standardErrorBuffer = StringBuffer();
    final String? trimmedExecutablePath = executablePath?.trim();
    final bool hasExecutablePath =
        trimmedExecutablePath != null && trimmedExecutablePath.isNotEmpty;
    final List<String> processArguments = arguments ?? const <String>[];

    try {
      final Process process;

      if (hasExecutablePath) {
        process = await Process.start(
          trimmedExecutablePath,
          processArguments,
          workingDirectory: workingDirectory,
          runInShell: false,
        );
      } else {
        final List<String> shellArguments = <String>[
          mpWindowsShellExecuteFlag,
          commandLine,
        ];

        process = await Process.start(
          mpWindowsCmdExecutable,
          shellArguments,
          workingDirectory: workingDirectory,
          runInShell: false,
        );
      }

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

class _MPUnixLikeTherionRunnerProcessRunner implements MPTherionProcessRunner {
  final void Function(Process process) onProcessStarted;
  final void Function(String outputText) onOutput;
  final MPTherionRunnerErrorCallback? onError;

  const _MPUnixLikeTherionRunnerProcessRunner({
    required this.onProcessStarted,
    required this.onOutput,
    required this.onError,
  });

  @override
  Future<MPTherionExecutionResult> run({
    required String commandLine,
    required String workingDirectory,
    String? executablePath,
    List<String>? arguments,
  }) async {
    final StringBuffer standardOutputBuffer = StringBuffer();
    final StringBuffer standardErrorBuffer = StringBuffer();
    final String? trimmedExecutablePath = executablePath?.trim();
    final bool hasExecutablePath =
        trimmedExecutablePath != null && trimmedExecutablePath.isNotEmpty;
    final String resolvedExecutablePath = hasExecutablePath
        ? trimmedExecutablePath
        : mpTherionExecutableName;
    final List<String> processArguments = arguments ?? const <String>[];

    try {
      final Process process = await Process.start(
        resolvedExecutablePath,
        processArguments,
        workingDirectory: workingDirectory,
        runInShell: false,
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
