import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/helpers/mp_dashed_properties.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

class THLinePainter extends CustomPainter {
  final THLine line;
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final THLinePaint linePaint;
  final bool showLineDirectionTicks;
  final TH2FileEditController th2FileEditController;

  THLinePainter({
    super.repaint,
    required this.line,
    required this.lineSegmentsMap,
    required this.linePaint,
    required this.showLineDirectionTicks,
    required this.th2FileEditController,
  });

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
  @override
  void paint(Canvas canvas, Size size) {
    final Iterable<THLinePainterLineSegment> lineSegments =
        lineSegmentsMap.values;
    final int lineSegmentsCount = lineSegments.length;

    if (lineSegmentsCount < 2) {
      return;
    }

    final bool addLineDirectionTicks =
        showLineDirectionTicks && th2FileEditController.isFromActiveScrap(line);
    final bool addIntermediateLineDirectionTicks = addLineDirectionTicks &&
        (lineSegmentsCount > mpLineSegmentsPerDirectionTick * 2);
    late final THLinePaint lineDirectionTicksPaint;
    late final bool reverse;
    final List<Offset> points = [];
    final List<double> distances = [];
    final Path lineDirectionTicksPath = Path();
    final Path path = Path();
    bool isFirst = true;

    int i = 0;

    for (THLinePainterLineSegment lineSegment in lineSegments) {
      i++;

      if (isFirst) {
        path.moveTo(lineSegment.x, lineSegment.y);
        isFirst = false;
        if (addLineDirectionTicks) {
          points.add(Offset(lineSegment.x, lineSegment.y));
          distances.add(0.0);
        }
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

      if ((addIntermediateLineDirectionTicks &&
              (i % mpLineSegmentsPerDirectionTick == 0)) ||
          (i == lineSegmentsCount)) {
        points.add(Offset(lineSegment.x, lineSegment.y));
        distances.add(path.computeMetrics().first.length);
      }
    }

    if (addLineDirectionTicks) {
      final List<PathMetric> metrics = path.computeMetrics().toList();

      if (metrics.isNotEmpty) {
        final PathMetric metric = metrics.first;
        final double metricLength = metric.length;
        final double tickLength = th2FileEditController
                .selectionController.isSelected[line.mpID]!.value
            ? th2FileEditController.lineDirectionTickLengthOnCanvas * 1.5
            : th2FileEditController.lineDirectionTickLengthOnCanvas;

        reverse = MPCommandOptionAux.isReverse(line);
        lineDirectionTicksPaint =
            th2FileEditController.visualController.getLineDirectionTickPaint(
          line: line,
          reverse: reverse,
        );

        for (int i = 0; i < points.length; i++) {
          final Offset point = points[i];
          final double distance = distances[i];
          final double distanceBefore = distance - mpAverageTangentDelta;
          final double distanceAfter = distance + mpAverageTangentDelta;
          Offset tangentAtPoint;

          if ((distanceBefore < 0) || (distanceAfter > metricLength)) {
            final Offset? tangentAt = _getTangentAtDistance(metric, distance);

            if (tangentAt == null) {
              continue;
            }

            tangentAtPoint = tangentAt;
          } else {
            final Tangent? tangentBefore =
                metric.getTangentForOffset(distance - mpAverageTangentDelta);
            final Tangent? tangentAfter =
                metric.getTangentForOffset(distance + mpAverageTangentDelta);

            if ((tangentBefore != null) && (tangentAfter != null)) {
              // Calculate the average tangent direction
              final Offset v1 = tangentBefore.vector;
              final Offset v2 = tangentAfter.vector;
              final double v1Len = v1.distance;
              final double v2Len = v2.distance;

              if ((v1Len > 0) && (v2Len > 0)) {
                final Offset n1 = v1 / v1Len;
                final Offset n2 = v2 / v2Len;
                final Offset avg = (n1 + n2) / 2.0;
                final double avgLen = avg.distance;

                if (avgLen > 0) {
                  tangentAtPoint = avg / avgLen;
                  // avgNorm is the average tangent direction between tangentBefore and tangentAfter
                } else {
                  continue;
                }
              } else {
                continue;
              }
            } else {
              final Offset? tangentAtDistance =
                  _getTangentAtDistance(metric, distance);

              if (tangentAtDistance == null) {
                continue;
              }

              tangentAtPoint = tangentAtDistance;
            }
          }

          // Draw the tick
          final Offset normal = Offset(-tangentAtPoint.dy, tangentAtPoint.dx);
          final Offset tickEnd = reverse
              ? point - (normal * (i == 0 ? tickLength * 1.5 : tickLength))
              : point + (normal * (i == 0 ? tickLength * 1.5 : tickLength));

          lineDirectionTicksPath.moveTo(point.dx, point.dy);
          lineDirectionTicksPath.lineTo(tickEnd.dx, tickEnd.dy);
        }
      }
    }

    if (linePaint.fillPaint != null) {
      canvas.drawPath(path, linePaint.fillPaint!);
    }

    if (linePaint.type == MPLinePaintType.continuous) {
      if (linePaint.primaryPaint != null) {
        canvas.drawPath(path, linePaint.primaryPaint!);
      } else if (linePaint.secondaryPaint != null) {
        canvas.drawPath(path, linePaint.secondaryPaint!);
      }
    } else {
      _drawDashedPath(canvas, path);
    }

    if (addLineDirectionTicks) {
      canvas.drawPath(
        lineDirectionTicksPath,
        lineDirectionTicksPaint.primaryPaint!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaint != oldDelegate.linePaint ||
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

  Offset? _getTangentAtDistance(PathMetric metric, double distance) {
    final Tangent? tangentAtDistance = metric.getTangentForOffset(distance);

    if (tangentAtDistance == null) {
      return null;
    }

    final Offset direction = tangentAtDistance.vector;

    return direction / direction.distance;
  }
}
