import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/mp_thfile_reference_mixin.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';

mixin MPBoundingBoxMixin on MPTHFileReferenceMixin {
  Rect? _boundingBox;

  Rect? getBoundingBox(TH2FileEditController th2FileEditController) {
    _boundingBox ??= calculateBoundingBox(th2FileEditController);

    return _boundingBox;
  }

  void clearBoundingBox() {
    _boundingBox = null;

    if (this is THElement) {
      final THElement element = this as THElement;

      if (thFile != null) {
        final THIsParentMixin parent = element.parent(thFile: thFile);

        if (parent is MPBoundingBoxMixin) {
          (parent as MPBoundingBoxMixin).clearBoundingBox();
        }
      }
    }
  }

  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController);
}
