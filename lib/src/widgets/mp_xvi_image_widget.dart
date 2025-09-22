import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_sketchline.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/painters/xvi_line_painter.dart';
import 'package:mapiah/src/painters/xvi_sketchline_painter.dart';

class MPXVIImageWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final THXTherionImageInsertConfig image;

  const MPXVIImageWidget({
    super.key,
    required this.th2FileEditController,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    if (!image.isXVI || !image.isVisible) {
      return SizedBox.shrink();
    }

    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerImages;

        final List<CustomPainter> painters = [];

        _drawXVIFile(image, painters);

        return CustomPaint(
          painter: THElementsPainter(
            painters: painters,
            th2FileEditController: th2FileEditController,
          ),
          size: th2FileEditController.screenSize,
        );
      },
    );
  }

  void _drawXVIFile(
    THXTherionImageInsertConfig image,
    List<CustomPainter> painters,
  ) {
    final XVIFile? xviFile = image.getXVIFile(th2FileEditController);

    if (xviFile == null) {
      return;
    }

    final double xx = image.xviRootedXX;
    final double yy = image.xviRootedYY;
    final Offset imageGridOffset = Offset(xx, yy);
    // Understaing xTherion variables:
    // shx: The horizontal offset between the image’s position (px) and the grid origin (gx).
    // shy: The vertical offset between the image’s position (py) and the grid origin (gy).
    // These original xTherion variables are used to calculate imageGridOffset.
    final Offset imageOffset =
        imageGridOffset - Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);

    setXVIGridPainters(
      xviFile: xviFile,
      imageOffset: imageGridOffset,
      painters: painters,
    );
    setXVIShotsPainters(
      xviFile: xviFile,
      imageGridOffset: imageOffset,
      painters: painters,
    );
    setXVIStationsPainters(
      xviFile: xviFile,
      imageGridOffset: imageOffset,
      painters: painters,
    );
    setXVISketchLinesPainters(
      xviFile: xviFile,
      imageGridOffset: imageOffset,
      painters: painters,
    );
  }

  void setXVISketchLinesPainters({
    required XVIFile xviFile,
    required Offset imageGridOffset,
    required List<CustomPainter> painters,
  }) {
    final Map<String, THLinePaint> xviSketchLinesPaints = {};
    final Map<String, THPointPaint> xviSketchPointsPaints = {};
    final MPVisualController visualController =
        th2FileEditController.visualController;

    for (final XVISketchLine sketchLine in xviFile.sketchLines) {
      final List<Offset> coordinates = [
        sketchLine.start.coordinates + imageGridOffset,
      ];
      THLinePaint sketchLinePaint;
      THPointPaint pointPaint;

      for (final THPositionPart point in sketchLine.points) {
        coordinates.add(point.coordinates + imageGridOffset);
      }

      if (xviSketchLinesPaints.containsKey(sketchLine.color)) {
        sketchLinePaint = xviSketchLinesPaints[sketchLine.color]!;
      } else {
        sketchLinePaint = visualController.getXVISketchLinePaint(
          sketchLine.color,
        );
        xviSketchLinesPaints[sketchLine.color] = sketchLinePaint;
      }

      if (xviSketchPointsPaints.containsKey(sketchLine.color)) {
        pointPaint = xviSketchPointsPaints[sketchLine.color]!;
      } else {
        pointPaint = visualController.getXVISketchPointPaint(sketchLine.color);
        xviSketchPointsPaints[sketchLine.color] = pointPaint;
      }

      painters.add(
        XVISketchLinePainter(
          coordinates: coordinates,
          linePaint: sketchLinePaint,
          pointPaint: pointPaint,
        ),
      );
    }
  }

  void setXVIStationsPainters({
    required XVIFile xviFile,
    required Offset imageGridOffset,
    required List<CustomPainter> painters,
  }) {
    final THPointPaint xviStationPaint = th2FileEditController.visualController
        .getXVIStationPointPaint();

    for (final XVIStation station in xviFile.stations) {
      final Offset stationPosition =
          station.position.coordinates + imageGridOffset;

      painters.add(
        THPointPainter(
          position: stationPosition,
          pointPaint: xviStationPaint,
          th2FileEditController: th2FileEditController,
        ),
      );
    }
  }

  void setXVIShotsPainters({
    required XVIFile xviFile,
    required Offset imageGridOffset,
    required List<CustomPainter> painters,
  }) {
    final THLinePaint xviShotPaint = th2FileEditController.visualController
        .getXVIShotLinePaint();

    for (final XVIShot shot in xviFile.shots) {
      final Offset start = shot.start.coordinates + imageGridOffset;
      final Offset end = shot.end.coordinates + imageGridOffset;

      painters.add(
        XVILinePainter(start: start, end: end, linePaint: xviShotPaint),
      );
    }
  }

  void setXVIGridPainters({
    required XVIFile xviFile,
    required Offset imageOffset,
    required List<CustomPainter> painters,
  }) {
    final XVIGrid grid = xviFile.grid;
    final THLinePaint xviGridLinePaint = th2FileEditController.visualController
        .getXVIGridLinePaint();

    final List<({Offset end, Offset start})> lines = grid.calculateGridLines(
      origin: imageOffset,
    );

    for (final ({Offset end, Offset start}) line in lines) {
      painters.add(
        XVILinePainter(
          start: line.start,
          end: line.end,
          linePaint: xviGridLinePaint,
        ),
      );
    }
  }
}
