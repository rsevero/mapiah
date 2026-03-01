// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

void main() {
  group('Windows registry query arguments', () {
    test('includes reg query subcommand and required switches', () {
      final List<String> queryArguments = buildWindowsRegistryQueryArguments(
        registryPath: mpWindowsRegistryTherionMachinePath,
        valueName: mpWindowsRegistryInstallDirValueName,
        registryViewSwitch: mpWindowsRegistryQuery64BitSwitch,
      );

      expect(queryArguments[0], mpWindowsRegistryQuerySubcommand);
      expect(queryArguments[1], mpWindowsRegistryTherionMachinePath);
      expect(queryArguments[2], mpWindowsRegistryQueryValueSwitch);
      expect(queryArguments[3], mpWindowsRegistryInstallDirValueName);
      expect(queryArguments[4], mpWindowsRegistryQuery64BitSwitch);
      expect(queryArguments.length, 5);
    });
  });
}
