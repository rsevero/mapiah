import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

mixin MPBoundingBoxMixin {
  Rect? _boundingBox;

  Rect getBoundingBox(TH2FileEditController th2FileEditController) {
    _boundingBox ??= calculateBoundingBox(th2FileEditController);

    return _boundingBox!;
  }

  void clearBoundingBox() {
    _boundingBox = null;
  }

  Rect calculateBoundingBox(TH2FileEditController th2FileEditController);
}
