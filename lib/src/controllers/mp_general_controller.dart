import 'dart:collection';

import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPGeneralController {
  int _nextMapiahIDForElements = thFirstMapiahIDForElements;
  int _nextMapiahIDForTHFiles = thFirstMapiahIDForTHFiles;

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

  int nextMapiahIDForElements() {
    return _nextMapiahIDForElements++;
  }

  int nextMapiahIDForTHFiles() {
    return _nextMapiahIDForTHFiles--;
  }

  /// Reset the Mapiah ID for elements to the first value.
  /// Should only be used for tests.
  void reset() {
    _nextMapiahIDForElements = thFirstMapiahIDForElements;
    _nextMapiahIDForTHFiles = thFirstMapiahIDForTHFiles;
    _t2hFileEditControllers.clear();
  }

  TH2FileEditController getTH2FileEditController(
      {required String filename, bool forceNewController = false}) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      if (forceNewController) {
        _t2hFileEditControllers.remove(filename);
      } else {
        return _t2hFileEditControllers[filename]!;
      }
    }

    final TH2FileEditController createdController =
        TH2FileEditControllerBase.create(filename);

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  void removeFileController({required String filename}) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      _t2hFileEditControllers.remove(filename);
    }
  }
}
