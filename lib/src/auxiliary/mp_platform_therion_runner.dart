import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';

/// Abstract base class for all platform-specific Therion runners.
///
/// Subclasses implement [runCompile] with logic appropriate for their platform
/// (e.g. [MPWindowsTherionRunner], [MPMacOSTherionRunner],
/// [MPLinuxTherionRunner]).
///
/// Common helpers such as [joinNonEmptyParts] and [quoteValue] are defined here
/// to avoid duplicating the same logic in every subclass.
abstract class MPPlatformTherionRunner {
  const MPPlatformTherionRunner();

  Future<MPTherionExecutionResult> runCompile({
    required String therionOptions,
    required String therionFileName,
    required String workingDirectory,
  });

  /// Joins [values] with a single space, skipping empty / blank entries.
  String joinNonEmptyParts(List<String> values) {
    final List<String> nonEmptyValues = <String>[];

    for (final String value in values) {
      final String trimmedValue = value.trim();

      if (trimmedValue.isEmpty) {
        continue;
      }

      nonEmptyValues.add(trimmedValue);
    }

    return nonEmptyValues.join(mpCommandSeparatorSpace);
  }

  /// Wraps [value] in double-quotes.
  String quoteValue(String value) {
    return '"$value"';
  }

  static String getUserDefinedTherionExecutablePath() {
    final String userDefinedPath =
        mpLocator.mpSettingsController
            .getStringIfSet(MPSettingID.Main_TherionExecutablePath)
            ?.trim() ??
        '';

    return userDefinedPath;
  }
}
