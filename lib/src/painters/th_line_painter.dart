import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THLinePainter extends CustomPainter {
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final THLinePaint linePaint;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THLinePainter({
    super.repaint,
    required this.lineSegmentsMap,
    required this.linePaint,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  }) {
    if ((linePaint.primaryPaint == null) &&
        (linePaint.secondaryPaint == null) &&
        (linePaint.fillPaint == null)) {
      throw Exception(
          'Linepaint needs at least one paint property not null in THLinePainter.');
    }
  }

  static final Map<LinePaintType, List<int>> linePaintTypeToDashLengths =
      <LinePaintType, List<int>>{
    LinePaintType.regularDashed: <int>[12, -8],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final Iterable<THLinePainterLineSegment> lineSegments =
        lineSegmentsMap.values;
    bool isFirst = true;
    final Path path = Path();

    for (THLinePainterLineSegment lineSegment in lineSegments) {
      if (isFirst) {
        path.moveTo(lineSegment.x, lineSegment.y);
        isFirst = false;
        continue;
      }

      switch (lineSegment) {
        case THLinePainterBezierCurveLineSegment _:
          path.cubicTo(
            lineSegment.controlPoint1X,
            lineSegment.controlPoint1Y,
            lineSegment.controlPoint2X,
            lineSegment.controlPoint2Y,
            lineSegment.x,
            lineSegment.y,
          );
        case THLinePainterStraightLineSegment _:
          path.lineTo(lineSegment.x, lineSegment.y);
      }
    }

    if (linePaint.fillPaint != null) {
      canvas.drawPath(path, linePaint.fillPaint!);
    }

    if (linePaint.type == LinePaintType.continuous) {
      canvas.drawPath(path, linePaint.primaryPaint!);
    } else {
      _drawDashedPath(canvas, path);
    }
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaint != oldDelegate.linePaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation ||
        !const MapEquality<int, THLinePainterLineSegment>()
            .equals(lineSegmentsMap, oldDelegate.lineSegmentsMap);
  }

  /// Dash code inspired by https://stackoverflow.com/a/71099304/11754455
  void _drawDashedPath(Canvas canvas, Path path) {
    final List<int> dashLengths = linePaintTypeToDashLengths[linePaint.type]!;
    final List<double> dashLengthsOnCanvas = [];

    for (final int length in dashLengths) {
      dashLengthsOnCanvas.add(
        th2FileEditController.scaleScreenToCanvas(
          length.toDouble(),
        ),
      );
    }

    if (linePaint.secondaryPaint != null) {
      final MPDashedPathProperties dashedPathProperties =
          MPDashedPathProperties(
        dashLengths: dashLengthsOnCanvas,
        invert: true,
      );
      final Path dashedPath = _getDashedPath(
        path,
        dashedPathProperties,
      );

      canvas.drawPath(dashedPath, linePaint.secondaryPaint!);
    }

    if (linePaint.primaryPaint != null) {
      final MPDashedPathProperties dashedPathProperties =
          MPDashedPathProperties(
        dashLengths: dashLengthsOnCanvas,
      );
      final Path dashedPath = _getDashedPath(
        path,
        dashedPathProperties,
      );

      canvas.drawPath(dashedPath, linePaint.primaryPaint!);
    }
  }

  Path _getDashedPath(
    Path originalPath,
    MPDashedPathProperties dashedPathProperties,
  ) {
    final Iterator<PathMetric> metricsIterator =
        originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      final PathMetric metric = metricsIterator.current;

      dashedPathProperties.extractedPathLength = 0.0;
      while (dashedPathProperties.extractedPathLength < metric.length) {
        dashedPathProperties.addNext(metric);
      }
    }

    return dashedPathProperties.path;
  }
}
