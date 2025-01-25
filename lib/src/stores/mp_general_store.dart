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
    _thFileStores.clear();
  }

  final HashMap<String, THFileEditStore> _thFileStores =
      HashMap<String, THFileEditStore>();

  THFileEditStore getTHFileStore(
      {required String filename, bool forceNewStore = false}) {
    if (_thFileStores.containsKey(filename)) {
      if (forceNewStore) {
        _thFileStores.remove(filename);
      } else {
        return _thFileStores[filename]!;
      }
    }

    final THFileEditStore createdStore = THFileEditStoreBase.create(filename);

    _thFileStores[filename] = createdStore;

    return createdStore;
  }
  // Future<THFileStoreCreateResult> createFileStore(String filename) async {
  //   if (_fileStores.containsKey(filename)) {
  //     return _fileStores[filename]!;
  //   }

  //   final THFileStoreCreateResult createResult =
  //       await THFileStoreBase.createAndLoad(filename);

  //   _fileStores[filename] = createResult;

  //   return createResult;
  // }

  void removeFileStore(String filename) {
    if (_thFileStores.containsKey(filename)) {
      _thFileStores.remove(filename);
    }
  }
}
