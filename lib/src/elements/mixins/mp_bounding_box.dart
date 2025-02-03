import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

mixin MPBoundingBox {
  Rect? _boundingBox;

  Rect getBoundingBox(TH2FileEditStore th2FileEditStore) {
    _boundingBox ??= calculateBoundingBox(th2FileEditStore);

    return _boundingBox!;
  }

  void clearBoundingBox() {
    _boundingBox = null;
  }

  Rect calculateBoundingBox(TH2FileEditStore th2FileEditStore);
}
