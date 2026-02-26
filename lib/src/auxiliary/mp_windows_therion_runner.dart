import 'package:mapiah/src/auxiliary/mp_locator.dart';
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

class MPWindowsTherionRunner {
  final MPLocator mpLocator;
  final MPWindowsRegistryReader registryReader;
  final MPWindowsShellProbe shellProbe;
  final MPTherionProcessRunner processRunner;

  static String? _cachedSearchedTherionExecutablePath;

  const MPWindowsTherionRunner({
    required this.mpLocator,
    required this.registryReader,
    required this.shellProbe,
    required this.processRunner,
  });

  AppLocalizations get appLocalizations => mpLocator.appLocalizations;

  static void clearSearchedTherionExecutablePathCache() {
    _cachedSearchedTherionExecutablePath = null;
  }

  String buildCompilerCommand({String preferredTherionExecutablePath = ''}) {
    final String executableCommand = _resolveTherionExecutableCommand(
      preferredTherionExecutablePath: preferredTherionExecutablePath,
    );
    final String compilerCommand = executableCommand;

    return compilerCommand;
  }

  String buildCompileInvocation({
    String preferredTherionExecutablePath = '',
    required String therionOptions,
    required String therionFileName,
  }) {
    final String compilerCommand = buildCompilerCommand(
      preferredTherionExecutablePath: preferredTherionExecutablePath,
    );
    final String quotedFileName = _quoteValue(therionFileName);

    final String compileInvocation = _joinNonEmptyParts(<String>[
      compilerCommand,
      mpTherionCompileFlag,
      therionOptions,
      quotedFileName,
    ]);

    return compileInvocation;
  }

  Future<MPTherionExecutionResult> runCompile({
    String preferredTherionExecutablePath = '',
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
          preferredTherionExecutablePath: preferredTherionExecutablePath,
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

  String _resolveTherionExecutableCommand({
    required String preferredTherionExecutablePath,
  }) {
    final ({
      String executableCommand,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    executableResolution = _resolveTherionExecutableCommandWithDiagnostics(
      preferredTherionExecutablePath: preferredTherionExecutablePath,
    );

    return executableResolution.executableCommand;
  }

  ({
    String executableCommand,
    String executablePath,
    List<String> registrySearchLogLines,
  })
  _resolveTherionExecutableCommandWithDiagnostics({
    required String preferredTherionExecutablePath,
  }) {
    final List<String> registrySearchLogLines = <String>[];
    final String trimmedPreferredTherionExecutablePath =
        preferredTherionExecutablePath.trim();
    final bool hasPreferredTherionExecutablePath =
        trimmedPreferredTherionExecutablePath.isNotEmpty;

    if (hasPreferredTherionExecutablePath) {
      final String preferredExecutableCommand = _quoteValue(
        trimmedPreferredTherionExecutablePath,
      );

      return (
        executableCommand: preferredExecutableCommand,
        executablePath: trimmedPreferredTherionExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String? cachedSearchedTherionExecutablePath =
        _cachedSearchedTherionExecutablePath;

    if (cachedSearchedTherionExecutablePath != null &&
        cachedSearchedTherionExecutablePath.isNotEmpty) {
      final String cachedExecutablePath = cachedSearchedTherionExecutablePath;
      final String cachedExecutableCommand = _quoteValue(cachedExecutablePath);

      registrySearchLogLines.add(mpTherionWindowsRegistryLookupCacheHitMessage);

      return (
        executableCommand: cachedExecutableCommand,
        executablePath: cachedExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String? machineInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionMachinePath,
      registrySearchLogLines: registrySearchLogLines,
    );
    if (machineInstallDirectory != null) {
      final String machineExecutablePath = _buildExecutablePath(
        machineInstallDirectory,
      );
      final String machineExecutableCommand = _quoteValue(
        machineExecutablePath,
      );
      _cacheSearchedTherionExecutablePath(machineExecutablePath);

      return (
        executableCommand: machineExecutableCommand,
        executablePath: machineExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    final String? userInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionUserPath,
      registrySearchLogLines: registrySearchLogLines,
    );
    if (userInstallDirectory != null) {
      final String userExecutablePath = _buildExecutablePath(
        userInstallDirectory,
      );
      final String userExecutableCommand = _quoteValue(userExecutablePath);
      _cacheSearchedTherionExecutablePath(userExecutablePath);

      return (
        executableCommand: userExecutableCommand,
        executablePath: userExecutablePath,
        registrySearchLogLines: registrySearchLogLines,
      );
    }

    registrySearchLogLines.add(mpTherionWindowsRegistryLookupFallbackMessage);
    _cacheSearchedTherionExecutablePath(mpTherionWindowsExecutableName);

    return (
      executableCommand: mpTherionWindowsExecutableName,
      executablePath: mpTherionWindowsExecutableName,
      registrySearchLogLines: registrySearchLogLines,
    );
  }

  void _cacheSearchedTherionExecutablePath(String executablePath) {
    final String trimmedExecutablePath = executablePath.trim();
    final bool hasExecutablePath = trimmedExecutablePath.isNotEmpty;

    if (!hasExecutablePath) {
      return;
    }

    _cachedSearchedTherionExecutablePath = trimmedExecutablePath;
  }

  ({
    String commandLine,
    String executablePath,
    List<String> processArguments,
    List<String> registrySearchLogLines,
  })
  _buildCompileInvocationWithRegistryDiagnostics({
    required String preferredTherionExecutablePath,
    required String therionOptions,
    required String therionFileName,
  }) {
    final ({
      String commandLine,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    compilerCommandWithDiagnostics =
        _buildCompilerCommandWithRegistryDiagnostics(
          preferredTherionExecutablePath: preferredTherionExecutablePath,
        );
    final String quotedFileName = _quoteValue(therionFileName);
    final List<String> processArguments = <String>[];
    final String trimmedTherionOptions = therionOptions.trim();
    final bool hasTherionOptions = trimmedTherionOptions.isNotEmpty;

    processArguments.add(mpTherionCompileFlag);

    if (hasTherionOptions) {
      processArguments.add(trimmedTherionOptions);
    }

    processArguments.add(therionFileName);

    final String compileInvocation = _joinNonEmptyParts(<String>[
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
  _buildCompilerCommandWithRegistryDiagnostics({
    required String preferredTherionExecutablePath,
  }) {
    final ({
      String executableCommand,
      String executablePath,
      List<String> registrySearchLogLines,
    })
    executableResolution = _resolveTherionExecutableCommandWithDiagnostics(
      preferredTherionExecutablePath: preferredTherionExecutablePath,
    );
    final String compilerCommand = executableResolution.executableCommand;

    return (
      commandLine: compilerCommand,
      executablePath: executableResolution.executablePath,
      registrySearchLogLines: executableResolution.registrySearchLogLines,
    );
  }

  String? _readInstallDirectory(
    String registryPath, {
    List<String>? registrySearchLogLines,
  }) {
    final String? installDirectory64Bit = registryReader.readString64Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    _appendRegistryLookupDebugLine(
      registrySearchLogLines: registrySearchLogLines,
      registryPath: registryPath,
      registryView: mpWindowsRegistryQuery64BitSwitch,
      registryValue: installDirectory64Bit,
    );

    if (installDirectory64Bit != null && installDirectory64Bit.isNotEmpty) {
      return installDirectory64Bit;
    }

    final String? installDirectory32Bit = registryReader.readString32Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    _appendRegistryLookupDebugLine(
      registrySearchLogLines: registrySearchLogLines,
      registryPath: registryPath,
      registryView: mpWindowsRegistryQuery32BitSwitch,
      registryValue: installDirectory32Bit,
    );

    if (installDirectory32Bit == null) {
      return null;
    }

    if (installDirectory32Bit.isEmpty) {
      return null;
    }

    return installDirectory32Bit;
  }

  void _appendRegistryLookupDebugLine({
    required List<String>? registrySearchLogLines,
    required String registryPath,
    required String registryView,
    required String? registryValue,
  }) {
    if (registrySearchLogLines == null) {
      return;
    }

    final bool hasRegistryValue =
        registryValue != null && registryValue.trim().isNotEmpty;
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

  String _buildExecutablePath(String installDirectory) {
    final String executablePath = _joinWindowsPath(
      installDirectory,
      mpTherionWindowsExecutableName,
    );
    final String normalizedExecutablePath = _normalizeToWindowsBackslashes(
      executablePath,
    );

    return normalizedExecutablePath;
  }

  String _joinWindowsPath(String baseDirectory, String fileName) {
    final String normalizedBaseDirectory = baseDirectory.replaceAll(
      mpWindowsBackslashPair,
      mpWindowsForwardSlash,
    );

    final bool hasTrailingSeparator = normalizedBaseDirectory.endsWith(
      mpWindowsForwardSlash,
    );

    final String joinedPath = hasTrailingSeparator
        ? '$normalizedBaseDirectory$fileName'
        : '$normalizedBaseDirectory/$fileName';

    return joinedPath;
  }

  String _normalizeToWindowsBackslashes(String value) {
    final String normalizedValue = value.replaceAll(
      mpWindowsForwardSlash,
      mpWindowsBackslashPair,
    );

    return normalizedValue;
  }

  String _quoteValue(String value) {
    final String quotedValue = '"$value"';

    return quotedValue;
  }

  String _joinNonEmptyParts(List<String> values) {
    final List<String> nonEmptyValues = <String>[];

    for (final String value in values) {
      final String trimmedValue = value.trim();
      if (trimmedValue.isEmpty) {
        continue;
      }

      nonEmptyValues.add(trimmedValue);
    }

    final String joinedCommand = nonEmptyValues.join(mpCommandSeparatorSpace);

    return joinedCommand;
  }
}
