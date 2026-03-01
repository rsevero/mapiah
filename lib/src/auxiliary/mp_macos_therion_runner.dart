import 'dart:io';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_platform_therion_runner.dart';
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
class MPMacOSTherionRunner extends MPPlatformTherionRunner {
  final MPLocator mpLocator;
  final MPTherionProcessRunner processRunner;

  const MPMacOSTherionRunner({
    required this.mpLocator,
    required this.processRunner,
  });
  AppLocalizations get appLocalizations => mpLocator.appLocalizations;

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
      List<String> pathSearchLogLines,
    })
    compileInvocationWithDiagnostics =
        _buildCompileInvocationWithPathDiagnostics(
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
    required String therionOptions,
    required String therionFileName,
  }) {
    final ({String executablePath, List<String> pathSearchLogLines})
    executableResolution = _resolveTherionExecutablePathWithDiagnostics();
    final String executablePath = executableResolution.executablePath;
    final String quotedFileName = quoteValue(therionFileName);
    final List<String> processArguments = <String>[];
    final String trimmedTherionOptions = therionOptions.trim();
    final bool hasTherionOptions = trimmedTherionOptions.isNotEmpty;

    processArguments.add(mpTherionCompileFlag);

    if (hasTherionOptions) {
      processArguments.add(trimmedTherionOptions);
    }

    processArguments.add(therionFileName);

    final String commandLine = joinNonEmptyParts(<String>[
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
  _resolveTherionExecutablePathWithDiagnostics() {
    final List<String> pathSearchLogLines = <String>[];

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

    final String trimmedUserDefinedPath =
        MPPlatformTherionRunner.getUserDefinedTherionExecutablePath();
    final bool hasUserDefinedPath = trimmedUserDefinedPath.isNotEmpty;

    if (hasUserDefinedPath) {
      return (
        executablePath: trimmedUserDefinedPath,
        pathSearchLogLines: pathSearchLogLines,
      );
    }

    final String? foundPath = _findTherionInSearchDirectories(
      pathSearchLogLines: pathSearchLogLines,
    );

    if (foundPath != null) {
      MPTherionCache.cacheSearchedTherionExecutablePath(foundPath);

      return (
        executablePath: foundPath,
        pathSearchLogLines: pathSearchLogLines,
      );
    }

    pathSearchLogLines.add(mpTherionMacOSPathSearchFallbackMessage);
    MPTherionCache.cacheSearchedTherionExecutablePath(mpTherionExecutableName);

    return (
      executablePath: mpTherionExecutableName,
      pathSearchLogLines: pathSearchLogLines,
    );
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

  // ---------------------------------------------------------------------------
  // Static probe and shared scan helper — used by both
  // MPTherionRunner.isTherionAvailable() and
  // _resolveTherionExecutablePathWithDiagnostics() so that the filesystem scan
  // is written only once.
  // ---------------------------------------------------------------------------

  /// Returns the best candidate Therion executable path for macOS by scanning
  /// the well-known installation directories listed in
  /// [mpTherionMacOSSearchDirectories]. Falls back to [mpTherionExecutableName]
  /// when no executable file is found. Does NOT validate that the executable
  /// actually runs — that is the caller's responsibility.
  static String probeForTherionExecutablePath() {
    final String? foundPath = _findTherionInSearchDirectories();

    return foundPath ?? mpTherionExecutableName;
  }

  /// Scans [mpTherionMacOSSearchDirectories] and returns the first path where
  /// a `therion` executable file exists, or `null` when none is found.
  ///
  /// When [pathSearchLogLines] is provided, a per-directory debug line is
  /// appended for each candidate that is checked.
  static String? _findTherionInSearchDirectories({
    List<String>? pathSearchLogLines,
  }) {
    for (final String searchDirectory in mpTherionMacOSSearchDirectories) {
      final String candidatePath = '$searchDirectory/$mpTherionExecutableName';
      final File candidateFile = File(candidatePath);
      final bool candidateExists = candidateFile.existsSync();

      if (pathSearchLogLines != null) {
        final String resultStatus = candidateExists
            ? mpTherionMacOSPathSearchStatusFound
            : mpTherionMacOSPathSearchStatusMissing;
        final String debugLine =
            '$mpTherionMacOSDebugPrefix path="$candidatePath" result="$resultStatus"';

        pathSearchLogLines.add(debugLine);
      }

      if (candidateExists) {
        return candidatePath;
      }
    }

    return null;
  }
}
