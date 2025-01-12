import 'dart:collection';

import 'package:mapiah/src/stores/th_file_store.dart';

class THStoreStore {
  final HashMap<String, THFileStoreCreateResult> _fileStores =
      HashMap<String, THFileStoreCreateResult>();

  Future<THFileStoreCreateResult> createFileStore(String filename) async {
    if (_fileStores.containsKey(filename)) {
      return _fileStores[filename]!;
    }

    final THFileStoreCreateResult createResult =
        await THFileStoreBase.create(filename);

    _fileStores[filename] = createResult;

    return createResult;
  }

  THFileStore getTHFileStore(String filename) {
    if (!_fileStores.containsKey(filename)) {
      throw Exception('File store for $filename does not exist.');
    }

    return _fileStores[filename]!.thFileStore;
  }

  void removeFileStore(String filename) {
    if (_fileStores.containsKey(filename)) {
      _fileStores.remove(filename);
    }
  }
}
