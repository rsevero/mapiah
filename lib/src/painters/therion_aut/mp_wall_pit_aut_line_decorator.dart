// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_pit_AUT`: the wall path stroked (`PenA`), a second `PenC`
/// path offset `.125u` toward the pit side, and a run of `.5u`-spaced
/// triangles hung off that inner path (`.25u` base, `.25u` tall, apex on
/// the pit side). Therion's default (`ATTR__height < 10`) draws the
/// triangles as outlines over an erased background; Mapiah does the same.
/// Therion's `testcircle` scan that keeps the offset path from
/// self-intersecting at sharp bends is dropped — Mapiah just samples a
/// plain perpendicular offset, which can pinch slightly at tight corners.
class MPWallPitAUTLineDecorator extends MPLineDecorator {
  const MPWallPitAUTLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
    List<THLinePainterLineSegment>? lineSegments,
    bool showBorder = false,
    THOptionChoicesArrowPositionType arrowHead =
        THOptionChoicesArrowPositionType.end,
  }) {
    final double u = symbolUnit.canvasValue;

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );

    final Path? innerPath = _buildOffsetPath(path, 0.125 * u);

    if (innerPath == null) {
      return;
    }

    canvas.drawPath(
      innerPath,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );

    _drawTriangles(canvas: canvas, path: innerPath, color: color, u: u);
  }

  /// Samples [path] and offsets every sample by [offset] toward the pit
  /// side (tangent rotated +90 degrees), i.e. the same side the triangle
  /// apexes point to.
  static Path? _buildOffsetPath(Path path, double offset) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return null;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return null;
    }

    final double step = math.max(1.0, length / 400);
    final Path result = Path();
    bool started = false;

    for (double distance = 0; distance <= length; distance += step) {
      final Tangent? tangent = metric.getTangentForOffset(distance);

      if (tangent == null) {
        continue;
      }

      final double tangentLength = tangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = tangent.vector / tangentLength;
      final Offset side = Offset(-unit.dy, unit.dx);
      final Offset point = tangent.position + (side * offset);

      if (!started) {
        result.moveTo(point.dx, point.dy);
        started = true;
      } else {
        result.lineTo(point.dx, point.dy);
      }
    }

    return started ? result : null;
  }

  static void _drawTriangles({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required double u,
  }) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double symSize = 0.5 * u;
    final int steps = math.max(1, (length / symSize).round());
    final double adjustedStep = length / steps;
    final double halfBase = adjustedStep / 4;
    final double height = adjustedStep / 2;
    final Paint outline = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;
    final Paint erase = Paint()
      ..color = THPaint.thPaintWhiteBackground.color
      ..style = PaintingStyle.fill;

    for (int index = 0; index < steps; index++) {
      final double centre = adjustedStep * (index + 0.5);
      final double d1 = (centre - halfBase).clamp(0, length).toDouble();
      final double d2 = (centre + halfBase).clamp(0, length).toDouble();
      final Tangent? midTangent = metric.getTangentForOffset(
        centre.clamp(0, length).toDouble(),
      );

      if ((midTangent == null) || (d2 <= d1)) {
        continue;
      }

      final double tangentLength = midTangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = midTangent.vector / tangentLength;
      final Offset side = Offset(-unit.dy, unit.dx);
      final Offset apex = midTangent.position + (side * height);
      final Path triangle = metric.extractPath(d1, d2)
        ..lineTo(apex.dx, apex.dy)
        ..close();

      canvas.drawPath(triangle, erase);
      canvas.drawPath(triangle, outline);
    }
  }
}
