import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/xvi_line_painter.dart';

class MPImagesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const MPImagesWidget({
    super.key,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;

        final List<CustomPainter> painters = [];
        final Iterable<THXTherionImageInsertConfig> images =
            th2FileEditController.thFile.getImages();

        for (final THXTherionImageInsertConfig image in images) {
          if (!image.isVisible) continue;

          if (image.isXVI) {
            final XVIFile? xviFile = image.getXVIFile(th2FileEditController);

            if (xviFile != null) {
              // Understaing xTherion variables:
              // shx: The horizontal offset between the image’s position (px) and the grid origin (gx).
              // shy: The vertical offset between the image’s position (py) and the grid origin (gy).
              final double imageGridXOfsset =
                  image.xx.value - xviFile.grid.gx.value;
              final double imageGridYOfsset =
                  image.yy.value - xviFile.grid.gy.value;

              painters.addAll(
                getXVIImagePainters(
                  xviFile: xviFile,
                  x: imageGridXOfsset,
                  y: imageGridYOfsset,
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
      },
    );
  }

  List<CustomPainter> getXVIImagePainters({
    required XVIFile xviFile,
    required double x,
    required double y,
    required TH2FileEditController th2FileEditController,
  }) {
    final List<CustomPainter> painters = [];

    painters.addAll(getXVIGridPainters(xviFile: xviFile, x: x, y: y));
    painters.addAll(getXVIShotsPainters(xviFile: xviFile, x: x, y: y));

    return painters;
  }

  List<CustomPainter> getXVIShotsPainters({
    required XVIFile xviFile,
    required double x,
    required double y,
  }) {
    final List<CustomPainter> painters = [];
    final THLinePaint xviShotPaint =
        th2FileEditController.visualController.getXVIShotLinePaint();
    final Offset gridOffset = Offset(x, y);

    for (final XVIShot shot in xviFile.shots) {
      final Offset start = shot.start.coordinates + gridOffset;
      final Offset end = shot.end.coordinates + gridOffset;

      painters.add(
        XVILinePainter(
          start: start,
          end: end,
          linePaint: xviShotPaint,
        ),
      );
    }

    return painters;
  }

  List<CustomPainter> getXVIGridPainters({
    required XVIFile xviFile,
    required double x,
    required double y,
  }) {
    final List<CustomPainter> painters = [];
    final XVIGrid grid = xviFile.grid;
    final Offset gridOffset = Offset(
      x + xviFile.grid.gx.value,
      y + xviFile.grid.gy.value,
    );
    final double gridX = gridOffset.dx;
    final double gridY = gridOffset.dy;
    final double xIncForXRepetition = grid.gxx.value;
    final double yIncForXRepetition = grid.gxy.value;
    final double xIncForYRepetition = grid.gyx.value;
    final double yIncForYRepetition = grid.gyy.value;
    final double repetitionOnXAxis = grid.ngx.value;
    final double repetitionOnYAxis = grid.ngy.value;
    final double xIncForHorizontalGridLine =
        repetitionOnXAxis * xIncForXRepetition;
    final double yIncForHorizontalGridLine =
        repetitionOnXAxis * yIncForXRepetition;
    final double xIncForVerticalGridLine =
        repetitionOnYAxis * xIncForYRepetition;
    final double yIncForVerticalGridLine =
        repetitionOnYAxis * yIncForYRepetition;
    final THLinePaint xviGridLinePaint =
        th2FileEditController.visualController.getXVIGridLinePaint();

    /// Horizontal grid lines
    for (int i = 0; i <= repetitionOnYAxis; i++) {
      final double leftX = gridX + (i * xIncForYRepetition);
      final double leftY = gridY + (i * yIncForYRepetition);
      final double rightX = leftX + xIncForHorizontalGridLine;
      final double rightY = leftY + yIncForHorizontalGridLine;

      painters.add(
        XVILinePainter(
          start: Offset(
            leftX,
            leftY,
          ),
          end: Offset(
            rightX,
            rightY,
          ),
          linePaint: xviGridLinePaint,
        ),
      );
    }

    /// Vertical grid lines
    for (int j = 0; j <= repetitionOnXAxis; j++) {
      final double topX = gridX + (j * xIncForXRepetition);
      final double topY = gridY + (j * yIncForXRepetition);
      final double bottomX = topX + xIncForVerticalGridLine;
      final double bottomY = topY + yIncForVerticalGridLine;

      painters.add(
        XVILinePainter(
          start: Offset(
            topX,
            topY,
          ),
          end: Offset(
            bottomX,
            bottomY,
          ),
          linePaint: xviGridLinePaint,
        ),
      );
    }

    return painters;
  }
}
