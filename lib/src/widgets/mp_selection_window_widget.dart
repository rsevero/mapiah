import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/painters/mp_selection_window_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPSelectionWindowWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final int thFileMPID;

  MPSelectionWindowWidget({
    required this.th2FileEditController,
    required super.key,
  }) : thFileMPID = th2FileEditController.thFileMPID;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) => CustomPaint(
          painter: MPSelectionWindowPainter(
            th2FileEditController: th2FileEditController,
            selectionWindowPosition: th2FileEditController
                .selectionController.selectionWindowCanvasCoordinates.value,
            fillPaint: th2FileEditController.selectionWindowFillPaint,
            borderPaint:
                th2FileEditController.selectionWindowBorderPaintComplete,
            dashInterval: th2FileEditController
                .selectionWindowBorderPaintDashIntervalOnCanvas,
            canvasScale: th2FileEditController.canvasScale,
            canvasTranslation: th2FileEditController.canvasTranslation,
          ),
        ),
      ),
    );
  }
}
