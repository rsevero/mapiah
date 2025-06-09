import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPGeneralController {
  int _nextMPIDForElements = thFirstMPIDForElements;
  int _nextMPIDForTHFiles = thFirstMPIDForTHFiles;

  String _lastAccessedDirectory = '';

  String get lastAccessedDirectory => _lastAccessedDirectory;

  final HashMap<String, TH2FileEditController> _t2hFileEditControllers =
      HashMap<String, TH2FileEditController>();

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
        TH2FileEditControllerBase.create(
      filename,
      fileBytes: fileBytes,
    );

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  void removeFileController({required String filename}) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      _t2hFileEditControllers.remove(filename);
    }
  }
}
