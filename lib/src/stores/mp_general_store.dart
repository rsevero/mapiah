import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/aux/mp_listener_widget_inner_state.dart';

class MPGeneralStore {
  int _nextMapiahIDForElements = thFirstMapiahIDForElements;
  int _nextMapiahIDForTHFiles = thFirstMapiahIDForTHFiles;

  String _lastAccessedDirectory = '';

  String get lastAccessedDirectory => _lastAccessedDirectory;

  final HashMap<String, TH2FileEditStore> _t2hFileEditStores =
      HashMap<String, TH2FileEditStore>();

  final Map<Key, MPListenerWidgetInnerState> _mpListenerInnerStates =
      <Key, MPListenerWidgetInnerState>{};

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
    _t2hFileEditStores.clear();
  }

  MPListenerWidgetInnerState getMPListenerInnerState(Key key) {
    if (!_mpListenerInnerStates.containsKey(key)) {
      _mpListenerInnerStates[key] = MPListenerWidgetInnerState();
    }

    return _mpListenerInnerStates[key]!;
  }

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
