import 'dart:collection';

import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

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
    _t2hFileEditStores.clear();
  }

  final HashMap<String, TH2FileEditStore> _t2hFileEditStores =
      HashMap<String, TH2FileEditStore>();

  TH2FileEditStore getTH2FileEditStore(
      {required String filename, bool forceNewStore = false}) {
    if (_t2hFileEditStores.containsKey(filename)) {
      if (forceNewStore) {
        _t2hFileEditStores.remove(filename);
      } else {
        return _t2hFileEditStores[filename]!;
      }
    }

    final TH2FileEditStore createdStore = TH2FileEditStoreBase.create(filename);

    _t2hFileEditStores[filename] = createdStore;

    return createdStore;
  }

  void removeFileStore({required String filename}) {
    if (_t2hFileEditStores.containsKey(filename)) {
      _t2hFileEditStores.remove(filename);
    }
  }
}
