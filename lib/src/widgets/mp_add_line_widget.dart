import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPAddLineWidget extends StatelessWidget with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;

  MPAddLineWidget({
    required this.th2FileEditController,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNewLine;

        final segmentsMap = getLineSegmentsMap(
          th2FileEditController.getNewLine(),
          th2FileEditController.thFile,
        );
        final THLinePaint linePaintInfo =
            th2FileEditController.getNewLinePaint();
        final Paint linePaint = linePaintInfo.paint;
        CustomPainter painter = THLinePainter(
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
          th2FileEditController: th2FileEditController,
          canvasScale: th2FileEditController.canvasScale,
          canvasTranslation: th2FileEditController.canvasTranslation,
        );

        return RepaintBoundary(
          child: CustomPaint(
            painter: painter,
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
