import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

mixin THCalculateChildrenBoundingBoxMixin {
  Rect calculateChildrenBoundingBox(
    TH2FileEditController th2FileEditController,
    Set<int> childrenMapiahIDs,
  ) {
    final THFile thFile = th2FileEditController.thFile;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    late Rect childBoundingBox;

    for (final int mapiahID in childrenMapiahIDs) {
      final THElement child = thFile.elementByMapiahID(mapiahID);

      switch (child) {
        case THLine _:
        case THPoint _:
        case THScrap _:
          childBoundingBox =
              (child as MPBoundingBox).getBoundingBox(th2FileEditController);
          break;
        default:
          continue;
      }

      if (childBoundingBox.left < minX) {
        minX = childBoundingBox.left;
      }
      if (childBoundingBox.right > maxX) {
        maxX = childBoundingBox.right;
      }
      if (childBoundingBox.top < minY) {
        minY = childBoundingBox.top;
      }
      if (childBoundingBox.bottom > maxY) {
        maxY = childBoundingBox.bottom;
      }
    }

    return MPNumericAux.orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }
}
