import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_platform_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_therion_cache.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

/// Resolves the Therion executable and runs a compile job when the app is
/// packaged as a Flatpak.
///
/// Inside the Flatpak sandbox the host filesystem is not directly accessible,
/// so any executable on the host (including therion) must be launched via
/// `flatpak-spawn --host`. This runner wraps all Therion invocations with that
/// prefix automatically.
///
/// Executable resolution order:
/// 1. Previously cached path ([MPTherionCache]).
/// 2. User-defined path from app settings (if set).
/// 3. Bare [mpTherionExecutableName] expected to be found on the host PATH.
class MPFlatpakTherionRunner extends MPPlatformTherionRunner {
  final MPLocator mpLocator;
  final MPTherionProcessRunner processRunner;

  const MPFlatpakTherionRunner({
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
    })
    compileInvocation = _buildCompileInvocation(
      therionFileName: therionFileName,
      workingDirectory: workingDirectory,
    );
    final String commandLine = compileInvocation.commandLine;

    // Use a safe sandbox path for Process.start's own workingDirectory.
    // The actual host working directory for therion is passed explicitly via
    // the --directory= flag to flatpak-spawn, using the original (unresolved)
    // portal path. Letting Dart resolve the working directory through the
    // sandbox mount namespace would produce a /run/flatpak/doc/ path that
    // does not exist on the host.
    final MPTherionExecutionResult executionResult = await processRunner.run(
      commandLine: commandLine,
      workingDirectory: mpFlatpakSandboxSafeWorkingDirectory,
      executablePath: compileInvocation.executablePath,
      arguments: compileInvocation.processArguments,
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

  ({String commandLine, String executablePath, List<String> processArguments})
  _buildCompileInvocation({
    required String therionFileName,
    required String workingDirectory,
  }) {
    final String therionExecutablePath = _resolveTherionExecutablePath();
    final String directoryArgument =
        '$mpFlatpakSpawnDirectoryFlag=$workingDirectory';
    final List<String> processArguments = <String>[
      mpFlatpakSpawnHostArgument,
      directoryArgument,
      therionExecutablePath,
      therionFileName,
    ];
    final String commandLine = joinNonEmptyParts(<String>[
      mpFlatpakSpawnExecutableName,
      mpFlatpakSpawnHostArgument,
      directoryArgument,
      therionExecutablePath,
      therionFileName,
    ]);

    return (
      commandLine: commandLine,
      executablePath: mpFlatpakSpawnExecutableName,
      processArguments: processArguments,
    );
  }

  String _resolveTherionExecutablePath() {
    final String? cachedPath =
        MPTherionCache.cachedSearchedTherionExecutablePath;
    final bool hasCachedPath = (cachedPath != null) && cachedPath.isNotEmpty;

    if (hasCachedPath) {
      return cachedPath;
    }

    final String trimmedUserDefinedPath =
        MPPlatformTherionRunner.getUserDefinedTherionExecutablePath();
    final bool hasUserDefinedPath = trimmedUserDefinedPath.isNotEmpty;

    if (hasUserDefinedPath) {
      return trimmedUserDefinedPath;
    }

    MPTherionCache.cacheSearchedTherionExecutablePath(mpTherionExecutableName);

    return mpTherionExecutableName;
  }

  /// Returns the default Therion executable name for use on the host.
  ///
  /// Used by [MPTherionRunner.isTherionAvailable] to produce a candidate path
  /// that is then validated via `flatpak-spawn --host`.
  static String probeForTherionExecutablePath() {
    return mpTherionExecutableName;
  }
}
