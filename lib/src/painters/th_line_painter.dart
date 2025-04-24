import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

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

  static final Map<MPLinePaintType, List<int>> linePaintTypeToDashLengths =
      <MPLinePaintType, List<int>>{
    MPLinePaintType.dot: <int>[2, -6],
    MPLinePaintType.long: <int>[18, -6],
    MPLinePaintType.long2Dots: <int>[18, -6, 2, -6, 2, -6],
    MPLinePaintType.long3Dots: <int>[18, -6, 2, -6, 2, -6, 2, -6],
    MPLinePaintType.longDot: <int>[18, -6, 2, -6],
    MPLinePaintType.shortLongShort: <int>[6, -6, 18, -6, 6, -12],
    MPLinePaintType.medium: <int>[12, -6],
    MPLinePaintType.medium2Dots: <int>[12, -6, 2, -6, 2, -6],
    MPLinePaintType.medium3Dots: <int>[12, -6, 2, -6, 2, -6, 2, -6],
    MPLinePaintType.mediumDot: <int>[12, -6, 2, -6],
    MPLinePaintType.mediumLongMedium: <int>[12, -6, 18, -6, 12, -12],
    MPLinePaintType.short: <int>[6, -6],
    MPLinePaintType.short2Dots: <int>[6, -6, 2, -6, 2, -6],
    MPLinePaintType.short3Dots: <int>[6, -6, 2, -6, 2, -6, 2, -6],
    MPLinePaintType.shortDot: <int>[6, -6, 2, -6],
    MPLinePaintType.shortMediumShort: <int>[6, -6, 12, -6, 6, -12],
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

    if (linePaint.type == MPLinePaintType.continuous) {
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
