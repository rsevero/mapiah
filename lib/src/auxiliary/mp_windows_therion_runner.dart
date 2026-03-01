import 'dart:convert';
import 'dart:io';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_platform_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_therion_cache.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

abstract class MPWindowsRegistryReader {
  String? readString64Bit({
    required String registryPath,
    required String valueName,
  });

  String? readString32Bit({
    required String registryPath,
    required String valueName,
  });
}

abstract class MPWindowsShellProbe {
  bool isCmdExeAvailable();
}

abstract class MPTherionProcessRunner {
  Future<MPTherionExecutionResult> run({
    required String commandLine,
    required String workingDirectory,
    String? executablePath,
    List<String>? arguments,
  });
}

class MPTherionExecutionResult {
  final bool success;
  final String commandLine;
  final String standardOutput;
  final String standardError;
  final String? localizedErrorMessage;

  const MPTherionExecutionResult({
    required this.success,
    required this.commandLine,
    required this.standardOutput,
    required this.standardError,
    required this.localizedErrorMessage,
  });

  MPTherionExecutionResult copyWith({
    bool? success,
    String? commandLine,
    String? standardOutput,
    String? standardError,
    String? localizedErrorMessage,
  }) {
    final bool nextSuccess = success ?? this.success;
    final String nextCommandLine = commandLine ?? this.commandLine;
    final String nextStandardOutput = standardOutput ?? this.standardOutput;
    final String nextStandardError = standardError ?? this.standardError;
    final String? nextLocalizedErrorMessage =
        localizedErrorMessage ?? this.localizedErrorMessage;

    return MPTherionExecutionResult(
      success: nextSuccess,
      commandLine: nextCommandLine,
      standardOutput: nextStandardOutput,
      standardError: nextStandardError,
      localizedErrorMessage: nextLocalizedErrorMessage,
    );
  }
}

/// Builds the argument list for a `reg query` command.
List<String> buildWindowsRegistryQueryArguments({
  required String registryPath,
  required String valueName,
  required String registryViewSwitch,
}) {
  final List<String> queryArguments = <String>[
    mpWindowsRegistryQuerySubcommand,
    registryPath,
    mpWindowsRegistryQueryValueSwitch,
    valueName,
    registryViewSwitch,
  ];

  return queryArguments;
}

/// Concrete [MPWindowsRegistryReader] that reads registry values via
/// `reg query` run synchronously through [Process.runSync]. Used in
/// production; inject a test double in unit tests.
class MPDefaultWindowsRegistryReader implements MPWindowsRegistryReader {
  const MPDefaultWindowsRegistryReader();

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
    final List<String> queryArguments = buildWindowsRegistryQueryArguments(
      registryPath: registryPath,
      valueName: valueName,
      registryViewSwitch: registryViewSwitch,
    );

    try {
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

      final Iterable<String> outputLines = LineSplitter.split(
        rawStandardOutput,
      );

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
    } on Object {
      return null;
    }

    return null;
  }
}

class MPWindowsTherionRunner extends MPPlatformTherionRunner {
  final MPLocator mpLocator;
  final MPWindowsRegistryReader registryReader;
  final MPWindowsShellProbe shellProbe;
  final MPTherionProcessRunner processRunner;

  const MPWindowsTherionRunner({
    required this.mpLocator,
    required this.registryReader,
    required this.shellProbe,
    required this.processRunner,
  });

  AppLocalizations get appLocalizations => mpLocator.appLocalizations;

  // Uses centralized cache in `MPTherionCache`.

  String buildCompilerCommand() {
    final String executableCommand = _resolveTherionExecutableCommand();
    final String compilerCommand = executableCommand;

    return compilerCommand;
  }

  String buildCompileInvocation({
    required String therionOptions,
    required String therionFileName,
  }) {
    final String compilerCommand = buildCompilerCommand();
    final String quotedFileName = quoteValue(therionFileName);

    final String compileInvocation = joinNonEmptyParts(<String>[
      compilerCommand,
      mpTherionCompileFlag,
      therionOptions,
      quotedFileName,
    ]);

    return compileInvocation;
  }

  @override
  Future<MPTherionExecutionResult> runCompile({
    required String therionOptions,
    required String therionFileName,
    required String workingDirectory,
  }) async {
    final ({
      String commandLine,
      String executablePath,
      List<String> processArguments,
      List<String> registrySearchLogLines,
    })
    compileInvocationWithDiagnostics =
        _buildCompileInvocationWithRegistryDiagnostics(
          therionOptions: therionOptions,
          therionFileName: therionFileName,
        );
    final String commandLine = compileInvocationWithDiagnostics.commandLine;

    final MPTherionExecutionResult executionResult = await processRunner.run(
      commandLine: commandLine,
      workingDirectory: workingDirectory,
      executablePath: compileInvocationWithDiagnostics.executablePath,
      arguments: compileInvocationWithDiagnostics.processArguments,
    );

    if (executionResult.success) {
      return executionResult;
    }

    final String localizedBaseErrorMessage = appLocalizations
        .mpTherionCannotExecuteCommand(commandLine);
    final String registryLookupDiagnosticsText =
        _buildRegistryLookupDiagnosticsText(
          compileInvocationWithDiagnostics.registrySearchLogLines,
        );
    final String localizedErrorMessage = _buildLocalizedErrorMessage(
      localizedBaseErrorMessage: localizedBaseErrorMessage,
      registryLookupDiagnosticsText: registryLookupDiagnosticsText,
    );

    final MPTherionExecutionResult localizedResult = executionResult.copyWith(
      localizedErrorMessage: localizedErrorMessage,
    );

    return localizedResult;
  }

  String _resolveTherionExecutableCommand() {
    final ({
      String executableCommand,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    executableResolution = _resolveTherionExecutableCommandWithDiagnostics();

    return executableResolution.executableCommand;
  }

  ({
    String executableCommand,
    String executablePath,
    List<String> registrySearchLogLines,
  })
  _resolveTherionExecutableCommandWithDiagnostics() {
    final List<String> registrySearchLogLines = <String>[];

    final String? cachedSearchedTherionExecutablePath =
        MPTherionCache.cachedSearchedTherionExecutablePath;

    if ((cachedSearchedTherionExecutablePath != null) &&
        cachedSearchedTherionExecutablePath.isNotEmpty) {
      final String cachedExecutablePath = cachedSearchedTherionExecutablePath;
      final String cachedExecutableCommand = quoteValue(cachedExecutablePath);

      registrySearchLogLines.add(mpTherionWindowsRegistryLookupCacheHitMessage);

      return (
        executableCommand: cachedExecutableCommand,
        executablePath: cachedExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String trimmedUserDefinedTherionExecutablePath =
        MPPlatformTherionRunner.getUserDefinedTherionExecutablePath();
    final bool hasUserDefinedTherionExecutablePath =
        trimmedUserDefinedTherionExecutablePath.isNotEmpty;

    if (hasUserDefinedTherionExecutablePath) {
      final String userDefinedExecutableCommand = quoteValue(
        trimmedUserDefinedTherionExecutablePath,
      );

      return (
        executableCommand: userDefinedExecutableCommand,
        executablePath: trimmedUserDefinedTherionExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String? machineInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionMachinePath,
      reader: registryReader,
      registrySearchLogLines: registrySearchLogLines,
    );
    if (machineInstallDirectory != null) {
      final String machineExecutablePath = _staticBuildExecutablePath(
        machineInstallDirectory,
      );
      final String machineExecutableCommand = quoteValue(machineExecutablePath);
      MPTherionCache.cacheSearchedTherionExecutablePath(machineExecutablePath);

      return (
        executableCommand: machineExecutableCommand,
        executablePath: machineExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String? userInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionUserPath,
      reader: registryReader,
      registrySearchLogLines: registrySearchLogLines,
    );
    if (userInstallDirectory != null) {
      final String userExecutablePath = _staticBuildExecutablePath(
        userInstallDirectory,
      );
      final String userExecutableCommand = quoteValue(userExecutablePath);
      MPTherionCache.cacheSearchedTherionExecutablePath(userExecutablePath);

      return (
        executableCommand: userExecutableCommand,
        executablePath: userExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    registrySearchLogLines.add(mpTherionWindowsRegistryLookupFallbackMessage);
    MPTherionCache.cacheSearchedTherionExecutablePath(
      mpTherionWindowsExecutableName,
    );

    return (
      executableCommand: mpTherionWindowsExecutableName,
      executablePath: mpTherionWindowsExecutableName,
      registrySearchLogLines: registrySearchLogLines,
    );
  }

  // Cache is centralized in `MPTherionCache`.

  ({
    String commandLine,
    String executablePath,
    List<String> processArguments,
    List<String> registrySearchLogLines,
  })
  _buildCompileInvocationWithRegistryDiagnostics({
    required String therionOptions,
    required String therionFileName,
  }) {
    final ({
      String commandLine,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    compilerCommandWithDiagnostics =
        _buildCompilerCommandWithRegistryDiagnostics();
    final String quotedFileName = quoteValue(therionFileName);
    final List<String> processArguments = <String>[];
    final String trimmedTherionOptions = therionOptions.trim();
    final bool hasTherionOptions = trimmedTherionOptions.isNotEmpty;

    processArguments.add(mpTherionCompileFlag);

    if (hasTherionOptions) {
      processArguments.add(trimmedTherionOptions);
    }

    processArguments.add(therionFileName);

    final String compileInvocation = joinNonEmptyParts(<String>[
      compilerCommandWithDiagnostics.commandLine,
      mpTherionCompileFlag,
      therionOptions,
      quotedFileName,
    ]);

    return (
      commandLine: compileInvocation,
      executablePath: compilerCommandWithDiagnostics.executablePath,
      processArguments: processArguments,
      registrySearchLogLines:
          compilerCommandWithDiagnostics.registrySearchLogLines,
    );
  }

  ({
    String commandLine,
    String executablePath,
    List<String> registrySearchLogLines,
  })
  _buildCompilerCommandWithRegistryDiagnostics() {
    final ({
      String executableCommand,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    executableResolution = _resolveTherionExecutableCommandWithDiagnostics();
    final String compilerCommand = executableResolution.executableCommand;

    return (
      commandLine: compilerCommand,
      executablePath: executableResolution.executablePath,
      registrySearchLogLines: executableResolution.registrySearchLogLines,
    );
  }

  static String? _readInstallDirectory(
    String registryPath, {
    required MPWindowsRegistryReader reader,
    List<String>? registrySearchLogLines,
  }) {
    final String? installDirectory64Bit = reader.readString64Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    _appendRegistryLookupDebugLine(
      registrySearchLogLines: registrySearchLogLines,
      registryPath: registryPath,
      registryView: mpWindowsRegistryQuery64BitSwitch,
      registryValue: installDirectory64Bit,
    );

    if ((installDirectory64Bit != null) && installDirectory64Bit.isNotEmpty) {
      return installDirectory64Bit;
    }

    final String? installDirectory32Bit = reader.readString32Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    _appendRegistryLookupDebugLine(
      registrySearchLogLines: registrySearchLogLines,
      registryPath: registryPath,
      registryView: mpWindowsRegistryQuery32BitSwitch,
      registryValue: installDirectory32Bit,
    );

    if ((installDirectory32Bit == null) || installDirectory32Bit.isEmpty) {
      return null;
    }

    return installDirectory32Bit;
  }

  static void _appendRegistryLookupDebugLine({
    required List<String>? registrySearchLogLines,
    required String registryPath,
    required String registryView,
    required String? registryValue,
  }) {
    if (registrySearchLogLines == null) {
      return;
    }

    final bool hasRegistryValue =
        (registryValue != null) && registryValue.trim().isNotEmpty;
    final String resultStatus = hasRegistryValue
        ? mpTherionWindowsRegistryLookupStatusFound
        : mpTherionWindowsRegistryLookupStatusMissing;
    final String resultValue = hasRegistryValue
        ? registryValue
        : mpTherionWindowsRegistryLookupValueUnavailable;
    final String debugLine =
        '$mpTherionWindowsDebugPrefix path="$registryPath" view="$registryView" value="$mpWindowsRegistryInstallDirValueName" result="$resultStatus" resolved="$resultValue"';

    registrySearchLogLines.add(debugLine);
  }

  String _buildRegistryLookupDiagnosticsText(
    List<String> registrySearchLogLines,
  ) {
    if (registrySearchLogLines.isEmpty) {
      return mpEmptyString;
    }

    final List<String> diagnosticsLines = <String>[
      mpTherionWindowsRegistryLookupHeader,
      ...registrySearchLogLines,
    ];

    return diagnosticsLines.join(mpUnixLineBreak);
  }

  String _buildLocalizedErrorMessage({
    required String localizedBaseErrorMessage,
    required String registryLookupDiagnosticsText,
  }) {
    if (registryLookupDiagnosticsText.isEmpty) {
      return localizedBaseErrorMessage;
    }

    final String localizedErrorMessage =
        '$localizedBaseErrorMessage$mpUnixLineBreak$registryLookupDiagnosticsText';

    return localizedErrorMessage;
  }

  // ---------------------------------------------------------------------------
  // Static probe — used by MPTherionRunner.isTherionAvailable() so that the
  // platform-specific executable search (registry lookup) is encapsulated here.
  // ---------------------------------------------------------------------------

  /// Returns the best candidate Therion executable path for this platform by
  /// consulting the Windows registry (machine-wide install first, then per-user
  /// install). Falls back to [mpTherionWindowsExecutableName] when no registry
  /// entry is found. Does NOT validate that the executable actually runs — that
  /// is the caller's responsibility.
  static String probeForTherionExecutablePath() {
    const MPDefaultWindowsRegistryReader defaultReader =
        MPDefaultWindowsRegistryReader();

    final String? machineInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionMachinePath,
      reader: defaultReader,
    );

    if (machineInstallDirectory != null) {
      return _staticBuildExecutablePath(machineInstallDirectory);
    }

    final String? userInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionUserPath,
      reader: defaultReader,
    );

    if (userInstallDirectory != null) {
      return _staticBuildExecutablePath(userInstallDirectory);
    }

    return mpTherionWindowsExecutableName;
  }

  static String _staticBuildExecutablePath(String installDirectory) {
    final String joinedPath = _staticJoinWindowsPath(
      installDirectory,
      mpTherionWindowsExecutableName,
    );

    return _staticNormalizeToWindowsBackslashes(joinedPath);
  }

  static String _staticJoinWindowsPath(String baseDirectory, String fileName) {
    final String normalizedBaseDirectory = baseDirectory.replaceAll(
      mpWindowsBackslashPair,
      mpWindowsForwardSlash,
    );
    final bool hasTrailingSeparator = normalizedBaseDirectory.endsWith(
      mpWindowsForwardSlash,
    );
    final String joinedPath = hasTrailingSeparator
        ? '$normalizedBaseDirectory$fileName'
        : '$normalizedBaseDirectory$mpWindowsForwardSlash$fileName';

    return joinedPath;
  }

  static String _staticNormalizeToWindowsBackslashes(String value) {
    final String normalizedValue = value.replaceAll(
      mpWindowsForwardSlash,
      mpWindowsBackslashPair,
    );

    return normalizedValue;
  }
}
