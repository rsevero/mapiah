import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPGeneralController {
  int _nextMPIDForElements = thFirstMPIDForElements;
  int _nextMPIDForTHFiles = thFirstMPIDForTHFiles;

  String _lastAccessedDirectory = '';

  String get lastAccessedDirectory => _lastAccessedDirectory;

  final HashMap<String, TH2FileEditController> _t2hFileEditControllers =
      HashMap<String, TH2FileEditController>();

  List<String> _availableEncodings = ['ASCII', 'UTF-8'];

  MPGeneralController() {
    updateAvailableEncodingsList();
  }

  set lastAccessedDirectory(String value) {
    if (!value.endsWith('/')) {
      value += '/';
    }
    _lastAccessedDirectory = value;
  }

  int nextMPIDForElements() {
    return _nextMPIDForElements++;
  }

  int nextMPIDForTHFiles() {
    return _nextMPIDForTHFiles--;
  }

  /// Reset the Mapiah ID for elements to the first value.
  /// Should only be used for tests.
  void reset() {
    _nextMPIDForElements = thFirstMPIDForElements;
    _nextMPIDForTHFiles = thFirstMPIDForTHFiles;
    _t2hFileEditControllers.clear();
  }

  TH2FileEditController? getTH2FileEditControllerIfExists(String filename) {
    return _t2hFileEditControllers[filename];
  }

  TH2FileEditController getTH2FileEditController({
    required String filename,
    final Uint8List? fileBytes,
    bool forceNewController = false,
  }) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      if (forceNewController) {
        _t2hFileEditControllers.remove(filename);
      } else {
        return _t2hFileEditControllers[filename]!;
      }
    }

    final TH2FileEditController createdController =
        TH2FileEditControllerBase.create(filename, fileBytes: fileBytes);

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  TH2FileEditController getTH2FileEditControllerForNewFile({
    required String scrapTHID,
    required List<THCommandOption> scrapOptions,
    required String encoding,
  }) {
    final THFile thFile = THFile();
    final int thFileMPID = thFile.mpID;
    final String filename = '${mpNewFilePrefix}_${thFile.mpID.abs()}';
    final THEncoding thEncoding = THEncoding(
      parentMPID: thFileMPID,
      encoding: encoding,
    );
    final THScrap thScrap = THScrap(parentMPID: thFileMPID, thID: scrapTHID);
    final int thScrapMPID = thScrap.mpID;
    final THEndscrap thEndscrap = THEndscrap(parentMPID: thScrapMPID);

    thFile.isNewFile = true;
    thFile.filename = filename;
    thFile.addElement(thEncoding);
    thFile.addElementToParent(thEncoding);
    thFile.addElement(thScrap);
    thFile.addElementToParent(thScrap);
    thFile.addElement(thEndscrap);
    thScrap.addElementToParent(
      thEndscrap,
      elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    for (THCommandOption option in scrapOptions) {
      if (option.parentMPID != thScrapMPID) {
        option = option.copyWith(parentMPID: thScrapMPID);
      }
      thScrap.addUpdateOption(option);
    }

    if (_t2hFileEditControllers.containsKey(filename)) {
      throw Exception(
        'At MPGeneralController.getTH2FileEditControllerForNewFile: controller for new file $filename already exists',
      );
    }

    final TH2FileEditController createdController =
        TH2FileEditControllerBase.createFromNewTHFile(thFile);

    createdController.setActiveScrap(thScrapMPID);
    createdController.setFilename(filename);

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  void renameFileController({
    required String oldFilename,
    required String newFilename,
  }) {
    if (_t2hFileEditControllers.containsKey(oldFilename)) {
      final TH2FileEditController controller = _t2hFileEditControllers.remove(
        oldFilename,
      )!;

      _t2hFileEditControllers[newFilename] = controller;
    }
  }

  void removeFileController({required String filename}) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      _t2hFileEditControllers.remove(filename);
    }
  }

  List<String> getAvailableEncodings() {
    return _availableEncodings;
  }

  void addAvailableEncoding(String encoding) {
    final String newEncoding = encoding.trim().toUpperCase();

    if (newEncoding.isNotEmpty && !_availableEncodings.contains(newEncoding)) {
      _availableEncodings.add(newEncoding);
      _availableEncodings = MPTextToUser.getOrderedChoicesList(
        _availableEncodings,
      );
    }
  }

  Future<void> updateAvailableEncodingsList() async {
    if (kIsWeb ||
        (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
      return;
    }

    try {
      final String exe = Platform.isWindows ? 'therion.exe' : 'therion';
      final ProcessResult result = await Process.run(exe, const [
        '--print-encodings',
      ]);

      if (result.exitCode != 0) {
        return;
      }

      /// Switch expression doing type pattern matching on result.stdout
      /// (dynamic):
      /// * If stdout is already a String (String s => s), use it directly.
      /// * If it is raw bytes (List<int> bytes => utf8.decode(bytes)), decode
      ///   as UTF‑8.
      /// * Otherwise (_ => result.stdout.toString()), fall back to toString().
      /// Result: stdoutString is a normalized String regardless of the original
      /// stdout representation on different platforms.
      final String stdoutString = switch (result.stdout) {
        String s => s,
        List<int> bytes => utf8.decode(bytes),
        _ => result.stdout.toString(),
      };
      final List<String> encodings = _extractEncodingsFromTherionOutput(
        stdoutString,
      );

      for (final String encoding in encodings) {
        addAvailableEncoding(encoding);
      }
    } catch (_) {
      // Ignore (therion not installed or not in PATH)
    }
  }

  List<String> _extractEncodingsFromTherionOutput(String output) {
    final Set<String> set = <String>{};
    final RegExp tokenRegExp = RegExp(r'^[A-Za-z0-9._\-]+$');

    for (final String rawLine in output.split(RegExp(r'[\r\n]+'))) {
      final String line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      for (final String token in line.split(RegExp(r'\s+'))) {
        final String t = token.trim();

        if (t.isEmpty) {
          continue;
        }
        if (tokenRegExp.hasMatch(t)) {
          set.add(t);
        }
      }
    }

    final List<String> list = MPTextToUser.getOrderedChoicesList(set);

    return list;
  }
}
