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

  const MPWindowsTherionRunner({
    required this.mpLocator,
    required this.registryReader,
    required this.shellProbe,
    required this.processRunner,
  });

  AppLocalizations get appLocalizations => mpLocator.appLocalizations;

  String buildCompilerCommand() {
    final String executableCommand = _resolveTherionExecutableCommand();
    final bool cmdExecutableAvailable = shellProbe.isCmdExeAvailable();
    final String selectedShellExecutable = cmdExecutableAvailable
        ? mpWindowsCmdExecutable
        : mpWindowsCommandExecutable;

    final String compilerCommand = _joinNonEmptyParts(<String>[
      selectedShellExecutable,
      mpWindowsShellExecuteFlag,
      executableCommand,
    ]);

    return compilerCommand;
  }

  String buildCompileInvocation({
    required String therionOptions,
    required String therionFileName,
  }) {
    final String compilerCommand = buildCompilerCommand();
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
    required String therionOptions,
    required String therionFileName,
    required String workingDirectory,
  }) async {
    final String commandLine = buildCompileInvocation(
      therionOptions: therionOptions,
      therionFileName: therionFileName,
    );

    final MPTherionExecutionResult executionResult = await processRunner.run(
      commandLine: commandLine,
      workingDirectory: workingDirectory,
    );

    if (executionResult.success) {
      return executionResult;
    }

    final String localizedErrorMessage = appLocalizations
        .mpTherionCannotExecuteCommand(commandLine);

    final MPTherionExecutionResult localizedResult = executionResult.copyWith(
      localizedErrorMessage: localizedErrorMessage,
    );

    return localizedResult;
  }

  String _resolveTherionExecutableCommand() {
    final String? machineInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionMachinePath,
    );
    if (machineInstallDirectory != null) {
      final String machineExecutableCommand = _buildQuotedExecutableCommand(
        machineInstallDirectory,
      );
      return machineExecutableCommand;
    }

    final String? userInstallDirectory = _readInstallDirectory(
      mpWindowsRegistryTherionUserPath,
    );
    if (userInstallDirectory != null) {
      final String userExecutableCommand = _buildQuotedExecutableCommand(
        userInstallDirectory,
      );
      return userExecutableCommand;
    }

    return mpTherionExecutableName;
  }

  String? _readInstallDirectory(String registryPath) {
    final String? installDirectory64Bit = registryReader.readString64Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    if (installDirectory64Bit != null && installDirectory64Bit.isNotEmpty) {
      return installDirectory64Bit;
    }

    final String? installDirectory32Bit = registryReader.readString32Bit(
      registryPath: registryPath,
      valueName: mpWindowsRegistryInstallDirValueName,
    );

    if (installDirectory32Bit == null) {
      return null;
    }

    if (installDirectory32Bit.isEmpty) {
      return null;
    }

    return installDirectory32Bit;
  }

  String _buildQuotedExecutableCommand(String installDirectory) {
    final String executablePath = _joinWindowsPath(
      installDirectory,
      mpTherionExecutableName,
    );
    final String normalizedExecutablePath = _normalizeToWindowsBackslashes(
      executablePath,
    );
    final String quotedExecutablePath = _quoteValue(normalizedExecutablePath);

    return quotedExecutablePath;
  }

  String _joinWindowsPath(String baseDirectory, String fileName) {
    final String normalizedBaseDirectory = baseDirectory.replaceAll('\\', '/');

    final bool hasTrailingSeparator = normalizedBaseDirectory.endsWith(
      mpWindowsForwardSlash,
    );

    final String joinedPath = hasTrailingSeparator
        ? '$normalizedBaseDirectory$fileName'
        : '$normalizedBaseDirectory/${fileName}';

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
