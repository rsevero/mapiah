import 'dart:io';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_therion_cache.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

/// Resolves the Therion executable location on macOS and runs a compile job.
///
/// xTherion on macOS uses a bare `therion` command (see global.tcl line 60)
/// because it is normally launched from a terminal that has the user's full
/// PATH. A Flutter app launched from Finder, however, receives only the
/// minimal system PATH (/usr/bin:/bin:/usr/sbin:/sbin), which does **not**
/// include common package-manager prefixes such as Homebrew ARM
/// (/opt/homebrew/bin) or MacPorts (/opt/local/bin).
///
/// This runner mirrors the xTherion behaviour (bare executable, no shell
/// wrapper, direct `-x` flag) while adding a probe over the well-known
/// installation directories listed in [mpTherionMacOSSearchDirectories].
/// The first found path is cached for the lifetime of the process
/// ([_cachedSearchedTherionExecutablePath]).
class MPMacOSTherionRunner {
  final MPLocator mpLocator;
  final MPTherionProcessRunner processRunner;

  const MPMacOSTherionRunner({
    required this.mpLocator,
    required this.processRunner,
  });
  AppLocalizations get appLocalizations => mpLocator.appLocalizations;

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
      List<String> pathSearchLogLines,
    })
    compileInvocationWithDiagnostics =
        _buildCompileInvocationWithPathDiagnostics(
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
    final String pathSearchDiagnosticsText = _buildPathSearchDiagnosticsText(
      compileInvocationWithDiagnostics.pathSearchLogLines,
    );
    final String localizedErrorMessage = _buildLocalizedErrorMessage(
      localizedBaseErrorMessage: localizedBaseErrorMessage,
      pathSearchDiagnosticsText: pathSearchDiagnosticsText,
    );
    final MPTherionExecutionResult localizedResult = executionResult.copyWith(
      localizedErrorMessage: localizedErrorMessage,
    );

    return localizedResult;
  }

  ({
    String commandLine,
    String executablePath,
    List<String> processArguments,
    List<String> pathSearchLogLines,
  })
  _buildCompileInvocationWithPathDiagnostics({
    required String preferredTherionExecutablePath,
    required String therionOptions,
    required String therionFileName,
  }) {
    final ({String executablePath, List<String> pathSearchLogLines})
    executableResolution = _resolveTherionExecutablePathWithDiagnostics(
      preferredTherionExecutablePath: preferredTherionExecutablePath,
    );
    final String executablePath = executableResolution.executablePath;
    final String quotedFileName = _quoteValue(therionFileName);
    final List<String> processArguments = <String>[];
    final String trimmedTherionOptions = therionOptions.trim();
    final bool hasTherionOptions = trimmedTherionOptions.isNotEmpty;

    processArguments.add(mpTherionCompileFlag);

    if (hasTherionOptions) {
      processArguments.add(trimmedTherionOptions);
    }

    processArguments.add(therionFileName);

    final String commandLine = _joinNonEmptyParts(<String>[
      executablePath,
      mpTherionCompileFlag,
      therionOptions,
      quotedFileName,
    ]);

    return (
      commandLine: commandLine,
      executablePath: executablePath,
      processArguments: processArguments,
      pathSearchLogLines: executableResolution.pathSearchLogLines,
    );
  }

  ({String executablePath, List<String> pathSearchLogLines})
  _resolveTherionExecutablePathWithDiagnostics({
    required String preferredTherionExecutablePath,
  }) {
    final List<String> pathSearchLogLines = <String>[];
    final String trimmedPreferredPath = preferredTherionExecutablePath.trim();
    final bool hasPreferredPath = trimmedPreferredPath.isNotEmpty;

    if (hasPreferredPath) {
      return (
        executablePath: trimmedPreferredPath,
        pathSearchLogLines: pathSearchLogLines,
      );
    }

    final String? cachedPath =
        MPTherionCache.cachedSearchedTherionExecutablePath;
    final bool hasCachedPath = (cachedPath != null) && cachedPath.isNotEmpty;

    if (hasCachedPath) {
      pathSearchLogLines.add(mpTherionMacOSPathSearchCacheHitMessage);

      return (
        executablePath: cachedPath,
        pathSearchLogLines: pathSearchLogLines,
      );
    }

    for (final String searchDirectory in mpTherionMacOSSearchDirectories) {
      final String candidatePath = '$searchDirectory/$mpTherionExecutableName';
      final File candidateFile = File(candidatePath);
      final bool candidateExists = candidateFile.existsSync();

      _appendPathSearchDebugLine(
        pathSearchLogLines: pathSearchLogLines,
        candidatePath: candidatePath,
        found: candidateExists,
      );

      if (candidateExists) {
        MPTherionCache.cacheSearchedTherionExecutablePath(candidatePath);

        return (
          executablePath: candidatePath,
          pathSearchLogLines: pathSearchLogLines,
        );
      }
    }

    pathSearchLogLines.add(mpTherionMacOSPathSearchFallbackMessage);
    MPTherionCache.cacheSearchedTherionExecutablePath(mpTherionExecutableName);

    return (
      executablePath: mpTherionExecutableName,
      pathSearchLogLines: pathSearchLogLines,
    );
  }

  // Cache is centralized in `MPTherionCache`.

  void _appendPathSearchDebugLine({
    required List<String> pathSearchLogLines,
    required String candidatePath,
    required bool found,
  }) {
    final String resultStatus = found
        ? mpTherionMacOSPathSearchStatusFound
        : mpTherionMacOSPathSearchStatusMissing;
    final String debugLine =
        '$mpTherionMacOSDebugPrefix path="$candidatePath" result="$resultStatus"';

    pathSearchLogLines.add(debugLine);
  }

  String _buildPathSearchDiagnosticsText(List<String> pathSearchLogLines) {
    if (pathSearchLogLines.isEmpty) {
      return mpEmptyString;
    }

    final List<String> diagnosticsLines = <String>[
      mpTherionMacOSPathSearchHeader,
      ...pathSearchLogLines,
    ];

    return diagnosticsLines.join(mpUnixLineBreak);
  }

  String _buildLocalizedErrorMessage({
    required String localizedBaseErrorMessage,
    required String pathSearchDiagnosticsText,
  }) {
    if (pathSearchDiagnosticsText.isEmpty) {
      return localizedBaseErrorMessage;
    }

    final String localizedErrorMessage =
        '$localizedBaseErrorMessage$mpUnixLineBreak$pathSearchDiagnosticsText';

    return localizedErrorMessage;
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
