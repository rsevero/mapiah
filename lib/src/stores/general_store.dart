import 'dart:collection';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/stores/th_file_store.dart';

class GeneralStore {
  int _nextMapiahIDForElements = thFirstMapiahIDForElements;
  int _nextMapiahIDForTHFiles = thFirstMapiahIDForTHFiles;

  int nextMapiahIDForElements() {
    return _nextMapiahIDForElements++;
  }

  int nextMapiahIDForTHFiles() {
    return _nextMapiahIDForTHFiles--;
  }

  final HashMap<String, THFileStore> _thFileStores =
      HashMap<String, THFileStore>();

  THFileStore getTHFileStore(String filename) {
    if (_thFileStores.containsKey(filename)) {
      return _thFileStores[filename]!;
    }

    final THFileStore createdStore = THFileStoreBase.create(filename);

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
