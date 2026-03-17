// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/mp_thfile_reference_mixin.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';

mixin MPBoundingBoxMixin on MPTH2FileReferenceMixin {
  Rect? _boundingBox;

  Rect? getBoundingBox(TH2FileEditController th2FileEditController) {
    _boundingBox ??= calculateBoundingBox(th2FileEditController);

    return _boundingBox;
  }

  void clearBoundingBox() {
    _boundingBox = null;

    if (this is THElement) {
      final THElement element = this as THElement;

      if (th2File != null) {
        final THIsParentMixin parent = element.parent(th2File: th2File);

        if (parent is MPBoundingBoxMixin) {
          (parent as MPBoundingBoxMixin).clearBoundingBox();
        }
      }
    }
  }

  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController);
}
