import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_platform_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_therion_cache.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

/// Resolves the Therion executable and runs a compile job on Linux.
///
/// On a standard Linux installation therion is typically on the system PATH,
/// so the runner falls back to the bare `therion` command when no
/// user-configured path is available.
///
/// When the app is packaged as a Flatpak (Flathub build, see [mpIsFlathub]),
/// the command must be wrapped with `flatpak-spawn --host` so that therion is
/// executed on the host system rather than inside the sandbox.
///
/// Executable resolution order:
/// 1. Previously cached path ([MPTherionCache]).
/// 2. User-defined path from app settings (if set).
/// 3. Bare [mpTherionExecutableName] expected to be found on the system PATH.
class MPLinuxTherionRunner extends MPPlatformTherionRunner {
  final MPLocator mpLocator;
  final MPTherionProcessRunner processRunner;

  const MPLinuxTherionRunner({
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
    );
    final String commandLine = compileInvocation.commandLine;

    final MPTherionExecutionResult executionResult = await processRunner.run(
      commandLine: commandLine,
      workingDirectory: workingDirectory,
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
  _buildCompileInvocation({required String therionFileName}) {
    final String therionExecutablePath = _resolveTherionExecutablePath();

    if (mpIsFlathub) {
      final List<String> processArguments = <String>[
        mpFlatpakSpawnHostArgument,
        therionExecutablePath,
        therionFileName,
      ];
      final String commandLine = joinNonEmptyParts(<String>[
        mpFlatpakSpawnExecutableName,
        mpFlatpakSpawnHostArgument,
        therionExecutablePath,
        therionFileName,
      ]);

      return (
        commandLine: commandLine,
        executablePath: mpFlatpakSpawnExecutableName,
        processArguments: processArguments,
      );
    }

    final List<String> processArguments = <String>[therionFileName];
    final String commandLine = joinNonEmptyParts(<String>[
      therionExecutablePath,
      therionFileName,
    ]);

    return (
      commandLine: commandLine,
      executablePath: therionExecutablePath,
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

    final String trimmedUserDefinedPath = getUserDefinedTherionExecutablePath();
    final bool hasUserDefinedPath = trimmedUserDefinedPath.isNotEmpty;

    if (hasUserDefinedPath) {
      return trimmedUserDefinedPath;
    }

    MPTherionCache.cacheSearchedTherionExecutablePath(mpTherionExecutableName);

    return mpTherionExecutableName;
  }
}
