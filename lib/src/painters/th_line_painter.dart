// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/auxiliary/mp_line_segment_mark_info.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_path_painter.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/widgets/auxiliary/th_line_painter_line_info.dart';
import 'package:material_ui/material_ui.dart';

class THLinePainter extends CustomPainter {
  final THLinePainterLineInfo lineInfo;
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final THLinePaint linePaint;
  final bool showLinePoints;
  final MPLineDecorator? lineDecorator;
  final Paint? lineDecoratorColor;
  final TH2FileEditController th2FileEditController;

  THLinePainter({
    super.repaint,
    required this.lineInfo,
    required this.lineSegmentsMap,
    required this.linePaint,
    this.showLinePoints = false,
    this.lineDecorator,
    this.lineDecoratorColor,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Iterable<THLinePainterLineSegment> lineSegments =
        lineSegmentsMap.values;
    final int lineSegmentsCount = lineSegments.length;

    if (lineSegmentsCount < 2) {
      return;
    }

    final bool addIntermediateLineDirectionTicks =
        lineInfo.addLineDirectionTicks &&
        (lineSegmentsCount > mpLineSegmentsPerDirectionTick * 2);
    final List<Offset> points = [];
    final List<double> distances = [];
    final Path lineDirectionTicksPath = Path();
    final Path path = Path();
    final List<Offset> vertices = <Offset>[];

    bool isFirst = true;
    int i = 0;

    for (THLinePainterLineSegment lineSegment in lineSegments) {
      i++;
      vertices.add(Offset(lineSegment.x, lineSegment.y));

      if (isFirst) {
        path.moveTo(lineSegment.x, lineSegment.y);
        isFirst = false;
        if (lineInfo.addLineDirectionTicks) {
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

    if (lineInfo.showMarksOnLineSegments &&
        lineInfo.lineSegmentsWithMark.isNotEmpty) {
      final THPointPaint markPointPaint = th2FileEditController.visualController
          .getLineSegmentMarkPointPaint();

      for (final MapEntry<int, MPLineSegmentMarkInfo> lineSegmentWithMarkEntry
          in lineInfo.lineSegmentsWithMark.entries) {
        final MPLineSegmentMarkInfo lineSegmentWithMark =
            lineSegmentWithMarkEntry.value;

        MPInteractionAux.drawPoint(
          canvas: canvas,
          position: lineSegmentWithMark.canvasPosition,
          pointPaint: markPointPaint,
        );
      }
    }

    if (lineInfo.addLineDirectionTicks) {
      final List<PathMetric> metrics = path.computeMetrics().toList();

      if (metrics.isNotEmpty) {
        final PathMetric metric = metrics.first;
        final double metricLength = metric.length;
        final double tickLength =
            th2FileEditController.selectionController.isSelected.contains(
              lineInfo.mpID,
            )
            ? th2FileEditController.lineDirectionTickLengthOnCanvas * 1.5
            : th2FileEditController.lineDirectionTickLengthOnCanvas;

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
            final Tangent? tangentBefore = metric.getTangentForOffset(
              distance - mpAverageTangentDelta,
            );
            final Tangent? tangentAfter = metric.getTangentForOffset(
              distance + mpAverageTangentDelta,
            );

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
              final Offset? tangentAtDistance = _getTangentAtDistance(
                metric,
                distance,
              );

              if (tangentAtDistance == null) {
                continue;
              }

              tangentAtPoint = tangentAtDistance;
            }
          }

          // Draw the tick
          final Offset normal = Offset(-tangentAtPoint.dy, tangentAtPoint.dx);
          final Offset tickEnd = lineInfo.isReversed
              ? point - (normal * ((i == 0) ? tickLength * 1.5 : tickLength))
              : point + (normal * ((i == 0) ? tickLength * 1.5 : tickLength));

          lineDirectionTicksPath.moveTo(point.dx, point.dy);
          lineDirectionTicksPath.lineTo(tickEnd.dx, tickEnd.dy);
        }
      }
    }

    final MPSymbolUnit symbolUnit = MPSymbolUnit(
      canvasScale: th2FileEditController.canvasScale,
      devicePixelRatio: th2FileEditController.devicePixelRatio,
      scrapLengthUnitsPerPoint: th2FileEditController.scrapLengthUnitsPerPoint,
      scrapLengthUnitType: th2FileEditController.scrapLengthUnitType,
    );
    final MPLinePathPainter pathPainter = MPLinePathPainter(
      path: path,
      vertices: vertices,
      lineSegments: lineSegmentsMap.values.toList(),
      linePaint: linePaint,
      lineDecorator: lineDecorator,
      lineDecoratorColor: lineDecoratorColor,
      symbolUnit: symbolUnit,
      dashScale: th2FileEditController.scaleScreenToCanvas(
        1.0 / th2FileEditController.devicePixelRatio,
      ),
      isReversed: lineInfo.isReversed,
      mpID: lineInfo.mpID,
      showBorder: lineInfo.slopeBorderOn,
      arrowHead: lineInfo.arrowHead,
    );
    final Path basePath = pathPainter.buildBasePath();

    pathPainter.paintBase(canvas, basePath);

    if (lineInfo.addLineDirectionTicks) {
      canvas.drawPath(
        lineDirectionTicksPath,
        lineInfo.lineDirectionTicksPaint.primaryPaint!,
      );
    }

    pathPainter.paintDecoration(canvas, basePath);

    if (showLinePoints) {
      final double linePointRadius =
          th2FileEditController.lineThicknessOnCanvas *
          mpLinePointRadiusToLineThicknessFactor;

      for (final THLinePainterLineSegment lineSegment in lineSegments) {
        canvas.drawCircle(
          Offset(lineSegment.x, lineSegment.y),
          linePointRadius,
          mpLinePointPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaint != oldDelegate.linePaint ||
        showLinePoints != oldDelegate.showLinePoints ||
        lineDecorator != oldDelegate.lineDecorator ||
        !const MapEquality<int, THLinePainterLineSegment>().equals(
          lineSegmentsMap,
          oldDelegate.lineSegmentsMap,
        );
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
