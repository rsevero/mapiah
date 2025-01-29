import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/painters/mp_selection_handles_painter.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class MPSelectionHandlesWidget extends StatelessWidget {
  final TH2FileEditStore th2FileEditStore;
  final int thFileMapiahID;

  MPSelectionHandlesWidget({
    required this.th2FileEditStore,
    required super.key,
  }) : thFileMapiahID = th2FileEditStore.thFileMapiahID;

  @override
  Widget build(Object context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          final Map<MPSelectionHandleType, Offset> handleCenters =
              th2FileEditStore.getSelectionHandleCenters();
          final Paint handlePaint = th2FileEditStore.selectionHandlePaint.value;

          final Rect boundingBox = th2FileEditStore.selectedElementsBoundingBox;
          double handleSize =
              th2FileEditStore.selectionHandleSizeOnCanvas.value;
          final double handleSizeThreshold =
              handleSize * thSelectionHandleThresholdMultiplier;
          if ((boundingBox.width > handleSizeThreshold) &&
              (boundingBox.height > handleSizeThreshold)) {
            handleSize = handleSize * thSelectionHandleSizeAmplifier;
          }

          return CustomPaint(
            painter: MPSelectionHandlesPainter(
              th2FileEditStore: th2FileEditStore,
              handleCenters: handleCenters,
              handleSize: handleSize,
              handlePaint: handlePaint,
            ),
          );
        },
      ),
    );
  }
}
