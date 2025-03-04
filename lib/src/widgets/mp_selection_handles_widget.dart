import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/mp_selection_handles_painter.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';

class MPSelectionHandlesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final int thFileMapiahID;

  MPSelectionHandlesWidget({
    required this.th2FileEditController,
    required super.key,
  }) : thFileMapiahID = th2FileEditController.thFileMapiahID;

  @override
  Widget build(Object context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          th2FileEditController.redrawTriggerSelectedElements;

          final Map<MPSelectionHandleType, Offset> handleCenters =
              th2FileEditController.getSelectionHandleCenters();
          final Paint handlePaint =
              th2FileEditController.selectionHandlePaint.value;

          final Rect boundingBox =
              th2FileEditController.selectedElementsBoundingBox;
          double handleSize =
              th2FileEditController.selectionHandleSizeOnCanvas.value;
          final double handleSizeThreshold =
              handleSize * thSelectionHandleThresholdMultiplier;
          if ((boundingBox.width > handleSizeThreshold) &&
              (boundingBox.height > handleSizeThreshold)) {
            handleSize = handleSize * thSelectionHandleSizeAmplifier;
          }

          return CustomPaint(
            painter: MPSelectionHandlesPainter(
              th2FileEditController: th2FileEditController,
              handleCenters: handleCenters,
              handleSize: handleSize,
              handlePaint: handlePaint,
              canvasScale: th2FileEditController.canvasScale,
              canvasTranslation: th2FileEditController.canvasTranslation,
            ),
          );
        },
      ),
    );
  }
}
