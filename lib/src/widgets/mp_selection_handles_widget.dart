import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/painters/mp_selection_handles_painter.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';

class MPSelectionHandlesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final int thFileMPID;

  MPSelectionHandlesWidget({
    required this.th2FileEditController,
    required super.key,
  })  : selectionController = th2FileEditController.selectionController,
        thFileMPID = th2FileEditController.thFileMPID;

  @override
  Widget build(Object context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          th2FileEditController.redrawTriggerSelectedElements;

          final Map<MPSelectionHandleType, Offset> handleCenters =
              selectionController.getSelectionHandleCenters();
          final Paint handlePaint = th2FileEditController.selectionHandlePaint;

          final Rect boundingBox =
              selectionController.selectedElementsBoundingBox;
          double handleSize = th2FileEditController.selectionHandleSizeOnCanvas;
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
