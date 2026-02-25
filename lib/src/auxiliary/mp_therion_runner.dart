import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

typedef MPTherionRunnerErrorCallback =
    void Function(Object error, StackTrace stackTrace);

class MPTherionRunner {
  final String therionExecutablePath;
  final String thConfigFilePath;
  final MPTherionRunnerErrorCallback? onError;

  final StreamController<String> _outputController =
      StreamController<String>.broadcast();

  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);

  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;

  MPTherionRunner({
    required this.therionExecutablePath,
    required this.thConfigFilePath,
    this.onError,
  });

  Stream<String> get outputStream => _outputController.stream;

  Future<void> start() async {
    final String workingDirectory = p.dirname(thConfigFilePath);

    isRunningNotifier.value = true;

    try {
      final Process process = await Process.start(
        therionExecutablePath,
        [thConfigFilePath],
        workingDirectory: workingDirectory,
        runInShell: true,
      );

      _process = process;

      _stdoutSubscription = utf8.decoder
          .bind(process.stdout)
          .listen(
            _emitOutput,
            onError: (Object error) {
              _emitOutput('$error\n');
            },
          );

      _stderrSubscription = utf8.decoder
          .bind(process.stderr)
          .listen(
            _emitOutput,
            onError: (Object error) {
              _emitOutput('$error\n');
            },
          );

      await process.exitCode;
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      _emitOutput('$error\n');
    } finally {
      isRunningNotifier.value = false;
    }
  }

  void stop() {
    if (isRunningNotifier.value) {
      _process?.kill();
    }
  }

  void dispose() {
    _stdoutSubscription?.cancel();
    _stderrSubscription?.cancel();
    stop();
    _outputController.close();
    isRunningNotifier.dispose();
  }

  void _emitOutput(String text) {
    if (text.isEmpty || _outputController.isClosed) {
      return;
    }

    _outputController.add(text);
  }
}
