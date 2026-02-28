import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';

/// This class should be substituted by MPPlatformTherionRunner, which will
/// delegate to the appropriate platform-specific implementation (e.g.
/// MPMacOSTherionRunner, MPWindowsTherionRunner) based on the current platform.
///
/// It exists now to help the transition from the old MPTherionRunner to the new
/// platform-specific runners.
abstract class MPBaseTherionRunner {
  const MPBaseTherionRunner();

  String getUserDefinedTherionExecutablePath() {
    final String userDefinedPath =
        mpLocator.mpSettingsController
            .getStringIfSet(MPSettingID.Main_TherionExecutablePath)
            ?.trim() ??
        '';

    return userDefinedPath;
  }
}
