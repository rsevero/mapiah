// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_windows_therion_runner.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class _FakeWindowsRegistryReader implements MPWindowsRegistryReader {
  final Map<String, String?> _registryValuesByPath;

  _FakeWindowsRegistryReader(this._registryValuesByPath);

  @override
  String? readString64Bit({
    required String registryPath,
    required String valueName,
  }) {
    return _registryValuesByPath[registryPath];
  }

  @override
  String? readString32Bit({
    required String registryPath,
    required String valueName,
  }) {
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
  group('MPWindowsTherionRunner command building', () {
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

      final String commandLine = windowsTherionRunner.buildCompilerCommand(
        preferredTherionExecutablePath: preferredTherionExecutablePath,
      );

      expect(commandLine, '"$preferredTherionExecutablePath"');
      expect(commandLine, isNot(contains(r'\Program Files\Therion')));
    });
  });
}
