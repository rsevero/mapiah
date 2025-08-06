import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/xvi_grid_line_painter.dart';

class MPImagesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const MPImagesWidget({
    super.key,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    final List<CustomPainter> painters = [];
    final Iterable<THXTherionImageInsertConfig> images =
        th2FileEditController.thFile.getImages();

    for (final THXTherionImageInsertConfig image in images) {
      if (!image.isVisible) continue;

      if (image.isXVI) {
        final XVIFile? xviFile = image.getXVIFile(th2FileEditController);

        if (xviFile != null) {
          painters.addAll(
            getXVIImagePainters(
              xviFile: xviFile,
              x: image.xx.value,
              y: image.yy.value,
              th2FileEditController: th2FileEditController,
            ),
          );
        }
      } else {
        // Handle regular images
        // painters.add(
        //   THImagePainter(
        //     filename: image.filename,
        //     position: image.position.coordinates,
        //     th2FileEditController: th2FileEditController,
        //   ),
        // );
      }
    }

    return RepaintBoundary(
      child: CustomPaint(
        painter: THElementsPainter(
          painters: painters,
          th2FileEditController: th2FileEditController,
        ),
        size: th2FileEditController.screenSize,
      ),
    );
  }

  List<CustomPainter> getXVIImagePainters({
    required XVIFile xviFile,
    required double x,
    required double y,
    required TH2FileEditController th2FileEditController,
  }) {
    final List<CustomPainter> painters = [];

    painters.addAll(getXVIGridPainters(
      xviFile: xviFile,
      x: x,
      y: y,
      th2FileEditController: th2FileEditController,
    ));

    return painters;
  }

  List<CustomPainter> getXVIGridPainters({
    required XVIFile xviFile,
    required double x,
    required double y,
    required TH2FileEditController th2FileEditController,
  }) {
    final List<CustomPainter> painters = [];
    final XVIGrid grid = xviFile.grid;
    // final double gridX = grid.gx.value;
    // final double gridY = grid.gy.value;
    final double xIncForXRepetition = grid.gxx.value;
    final double yIncForXRepetition = grid.gxy.value;
    final double xIncForYRepetition = grid.gyx.value;
    final double yIncForYRepetition = grid.gyy.value;
    final double repetitionOnXAxis = grid.ngx.value;
    final double repetitionOnYAxis = grid.ngy.value;
    final double xSizeOfHorizontalGridLine =
        repetitionOnXAxis * xIncForXRepetition;
    final double ySizeOfHorizontalGridLine =
        repetitionOnXAxis * yIncForXRepetition;
    final double xSizeOfVerticalGridLine =
        repetitionOnYAxis * xIncForYRepetition;
    final double ySizeOfVerticalGridLine =
        repetitionOnYAxis * yIncForYRepetition;

    /// Horizontal grid lines
    for (int i = 0; i < repetitionOnYAxis; i++) {
      final double leftX = x + (i * xIncForYRepetition);
      final double leftY = y + (i * yIncForYRepetition);
      final double rightX = leftX + xSizeOfHorizontalGridLine;
      final double rightY = leftY + ySizeOfHorizontalGridLine;

      painters.add(
        XVIGridLinePainter(
          start: Offset(
            leftX,
            leftY,
          ),
          end: Offset(
            rightX,
            rightY,
          ),
        ),
      );
    }

    /// Vertical grid lines
    for (int j = 0; j < repetitionOnXAxis; j++) {
      final double topX = x + (j * xIncForXRepetition);
      final double topY = y + (j * yIncForXRepetition);
      final double bottomX = topX + xSizeOfVerticalGridLine;
      final double bottomY = topY + ySizeOfVerticalGridLine;

      painters.add(
        XVIGridLinePainter(
          start: Offset(
            topX,
            topY,
          ),
          end: Offset(
            bottomX,
            bottomY,
          ),
          vertical: true,
        ),
      );
    }

    return painters;
  }
}
