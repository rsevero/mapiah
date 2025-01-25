import 'dart:collection';

import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';

class MPGeneralStore {
  int _nextMapiahIDForElements = thFirstMapiahIDForElements;
  int _nextMapiahIDForTHFiles = thFirstMapiahIDForTHFiles;

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
    _thFileEditStores.clear();
  }

  final HashMap<String, THFileEditStore> _thFileEditStores =
      HashMap<String, THFileEditStore>();

  THFileEditStore getTHFileEditStore(
      {required String filename, bool forceNewStore = false}) {
    if (_thFileEditStores.containsKey(filename)) {
      if (forceNewStore) {
        _thFileEditStores.remove(filename);
      } else {
        return _thFileEditStores[filename]!;
      }
    }

    final THFileEditStore createdStore = THFileEditStoreBase.create(filename);

    _thFileEditStores[filename] = createdStore;

    return createdStore;
  }

  void removeFileStore(String filename) {
    if (_thFileEditStores.containsKey(filename)) {
      _thFileEditStores.remove(filename);
    }
  }
}
