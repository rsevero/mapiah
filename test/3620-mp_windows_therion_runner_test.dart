// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';

class _FakeWindowsRegistryReader implements MPWindowsRegistryReader {
  final Map<String, String?> _registryValuesByPath;
  int readString64BitCallCount = 0;
  int readString32BitCallCount = 0;

  _FakeWindowsRegistryReader(this._registryValuesByPath);

  @override
  String? readString64Bit({
    required String registryPath,
    required String valueName,
  }) {
    readString64BitCallCount += 1;

    return _registryValuesByPath[registryPath];
  }

  @override
  String? readString32Bit({
    required String registryPath,
    required String valueName,
  }) {
    readString32BitCallCount += 1;

    return _registryValuesByPath[registryPath];
  }
}

class _FakeWindowsShellProbe implements MPWindowsShellProbe {
  @override
  bool isCmdExeAvailable() {
    return true;
  }
}

class _FakeTherionProcessRunner implements MPTherionProcessRunner {
  @override
  Future<MPTherionExecutionResult> run({
    required String commandLine,
    required String workingDirectory,
    String? executablePath,
    List<String>? arguments,
  }) async {
    return const MPTherionExecutionResult(
      success: true,
      commandLine: '',
      standardOutput: '',
      standardError: '',
      localizedErrorMessage: null,
    );
  }
}

void main() {
  setUpAll(() async {
    await MPLocator().mpSettingsController.initialized;
  });

  group('MPWindowsTherionRunner command building', () {
    setUp(() {
      MPTherionRunner.clearSearchedTherionExecutablePathCache();
      mpLocator.mpGeneralController.reset();
    });

    tearDown(() {
      MPTherionRunner.clearSearchedTherionExecutablePathCache();
    });

    test(
      'buildCompilerCommand uses single backslashes only on Windows path',
      () {
        final MPWindowsTherionRunner windowsTherionRunner =
            MPWindowsTherionRunner(
              mpLocator: MPLocator(),
              registryReader: _FakeWindowsRegistryReader(<String, String?>{
                mpWindowsRegistryTherionMachinePath:
                    r'C:\Program Files\Therion',
              }),
              shellProbe: _FakeWindowsShellProbe(),
              processRunner: _FakeTherionProcessRunner(),
            );

        final String commandLine = windowsTherionRunner.buildCompilerCommand();

        expect(commandLine, isNot(contains(mpWindowsCmdExecutable)));
        expect(commandLine, isNot(contains(mpWindowsShellExecuteFlag)));
        expect(commandLine, contains(r'\Program Files\Therion\therion.exe'));
        expect(commandLine, isNot(contains(r'\\')));
      },
    );

    test('buildCompilerCommand prefers configured executable path', () {
      final MPWindowsTherionRunner windowsTherionRunner =
          MPWindowsTherionRunner(
            mpLocator: MPLocator(),
            registryReader: _FakeWindowsRegistryReader(<String, String?>{
              mpWindowsRegistryTherionMachinePath: r'C:\Program Files\Therion',
            }),
            shellProbe: _FakeWindowsShellProbe(),
            processRunner: _FakeTherionProcessRunner(),
          );

      const String preferredTherionExecutablePath =
          r'D:\custom\therion\therion.exe';

      mpLocator.mpSettingsController.setString(
        MPSettingID.Main_TherionExecutablePath,
        preferredTherionExecutablePath,
      );

      final String commandLine = windowsTherionRunner.buildCompilerCommand();

      expect(commandLine, '"$preferredTherionExecutablePath"');
      expect(commandLine, isNot(contains(r'\Program Files\Therion')));
    });

    test(
      'buildCompilerCommand caches searched path for repeated calls without preferred executable',
      () {
        final _FakeWindowsRegistryReader registryReader =
            _FakeWindowsRegistryReader(<String, String?>{
              mpWindowsRegistryTherionMachinePath: r'C:\Program Files\Therion',
            });
        final MPWindowsTherionRunner firstWindowsTherionRunner =
            MPWindowsTherionRunner(
              mpLocator: MPLocator(),
              registryReader: registryReader,
              shellProbe: _FakeWindowsShellProbe(),
              processRunner: _FakeTherionProcessRunner(),
            );
        final MPWindowsTherionRunner secondWindowsTherionRunner =
            MPWindowsTherionRunner(
              mpLocator: MPLocator(),
              registryReader: registryReader,
              shellProbe: _FakeWindowsShellProbe(),
              processRunner: _FakeTherionProcessRunner(),
            );

        final String firstCommandLine = firstWindowsTherionRunner
            .buildCompilerCommand();
        final String secondCommandLine = secondWindowsTherionRunner
            .buildCompilerCommand();

        expect(
          firstCommandLine,
          contains(r'\Program Files\Therion\therion.exe'),
        );
        expect(secondCommandLine, firstCommandLine);
        expect(registryReader.readString64BitCallCount, 1);
        expect(registryReader.readString32BitCallCount, 0);
      },
    );
  });
}
