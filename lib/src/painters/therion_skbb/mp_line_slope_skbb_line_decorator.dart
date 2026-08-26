// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_slope_SKBB`: a row of short perpendicular ticks straddling the
/// path, alternating full-length and one-third-length, spaced roughly
/// `1.4u` apart (half that between a long and its following short tick).
/// The path itself is only stroked when `showBorder` is set — `line slope
/// -border on` — confirmed against a real `therion` run: unlike every
/// other line, a bare `line slope` (no `-border` at all) draws no baseline
/// stroke, despite `border`'s own doc comment claiming "default is on".
///
/// Each line point's `l-size` sets the tick length there and `orientation`
/// sets the tick's compass direction there (Therion's `direction` line
/// point attribute, exposed as [THLinePainterLineSegment.orientation]);
/// unset points interpolate between the nearest defined neighbours by arc
/// length, same as `thLine.mp`. The two endpoints always count as defined:
/// `l_slope_SKBB` defaults an unset endpoint direction to perpendicular and
/// an unset endpoint length to a fixed fallback (`1cm` there; Mapiah reuses
/// [mpSlopeLinePointDefaultLSize], its own established slope-line default,
/// rather than inventing a paper/world unit conversion for that literal
/// `1cm`). When no point on the whole line has an explicit `orientation`
/// (the common case), every tick is simply perpendicular to the path at
/// that point — `alw_perpendicular` in `thLine.mp`.
class MPLineSlopeSKBBLineDecorator extends MPLineDecorator {
  const MPLineSlopeSKBBLineDecorator();

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
    if ((lineSegments == null) || (lineSegments.length < 2)) {
      return;
    }

    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double totalLength = metric.length;

    if (totalLength <= 0) {
      return;
    }

    final int pointCount = lineSegments.length;
    final List<Offset> vertexPositions = [
      for (final THLinePainterLineSegment segment in lineSegments)
        Offset(segment.x, segment.y),
    ];

    // Arc-length position of each vertex along [path], approximated from
    // chord distances (exact for straight segments, a close approximation
    // when a segment is a Bézier curve).
    final List<double> chordDistance = [0.0];

    for (int i = 1; i < pointCount; i++) {
      chordDistance.add(
        chordDistance[i - 1] +
            (vertexPositions[i] - vertexPositions[i - 1]).distance,
      );
    }

    final double totalChord = chordDistance.last;

    if (totalChord <= 0) {
      return;
    }

    final double chordToArc = totalLength / totalChord;
    final List<double> vertexArc = [
      for (final double distance in chordDistance)
        (distance * chordToArc).clamp(0.0, totalLength),
    ];

    double tangentAngleAt(double distance) {
      final Tangent? tangent = metric.getTangentForOffset(
        distance.clamp(0.0, totalLength),
      );

      if ((tangent == null) || (tangent.vector.distance == 0)) {
        return 0.0;
      }

      return math.atan2(tangent.vector.dy, tangent.vector.dx);
    }

    // Direction breakpoints: every point with an explicit `orientation`,
    // plus both endpoints (defaulted to perpendicular when unset there).
    final List<double> directionArc = [];
    final List<double> directionAngle = [];
    bool anyExplicitDirection = false;

    for (int i = 0; i < pointCount; i++) {
      final double? azimuth = lineSegments[i].orientation;
      double? angle;

      if (azimuth != null) {
        // Therion azimuth (0=north, clockwise) to this path's plain
        // atan2(dy,dx) angle: `angle(dy,dx) = 90 - azimuth`, the same
        // identity `l_slope_SKBB` itself relies on (`90-dirs[i]`).
        angle = (90.0 - azimuth) * mp1DegreeInRads;
        anyExplicitDirection = true;
      } else if ((i == 0) || (i == (pointCount - 1))) {
        angle = tangentAngleAt(vertexArc[i]) + (math.pi / 2);
      }

      if (angle != null) {
        directionArc.add(vertexArc[i]);
        directionAngle.add(angle);
      }
    }

    // Length breakpoints: every point with an explicit `l-size`, plus both
    // endpoints (defaulted to `mpSlopeLinePointDefaultLSize` when unset).
    final List<double> lengthArc = [];
    final List<double> lengthValue = [];

    for (int i = 0; i < pointCount; i++) {
      final double? lSize =
          lineSegments[i].lSize ??
          (((i == 0) || (i == (pointCount - 1)))
              ? mpSlopeLinePointDefaultLSize
              : null);

      if (lSize != null) {
        lengthArc.add(vertexArc[i]);
        lengthValue.add(lSize);
      }
    }

    double interpolate(List<double> arcs, List<double> values, double at) {
      if (at <= arcs.first) {
        return values.first;
      }
      if (at >= arcs.last) {
        return values.last;
      }

      for (int i = 0; i < (arcs.length - 1); i++) {
        if ((at >= arcs[i]) && (at <= arcs[i + 1])) {
          final double span = arcs[i + 1] - arcs[i];
          final double weight = (span > 0) ? ((at - arcs[i]) / span) : 0.0;

          return values[i] + (weight * (values[i + 1] - values[i]));
        }
      }

      return values.last;
    }

    final double u = symbolUnit.canvasValue;
    final double offset = (totalLength > (3 * u))
        ? (0.3 * u)
        : ((totalLength > u) ? (0.1 * u) : 0.0);
    final double effectiveLength = totalLength - (2 * offset);

    if (effectiveLength <= 0) {
      return;
    }

    final double nominalStep = 1.4 * u;
    final double fullStep = (nominalStep <= (effectiveLength / 2))
        ? (effectiveLength / (effectiveLength / nominalStep).floor())
        : (effectiveLength / 2);
    final double halfStep = fullStep / 2;

    if (halfStep <= 0) {
      return;
    }

    final Path ticks = Path();
    final double lastDistance = effectiveLength + offset;
    double distance = offset;
    bool shortTick = false;

    while (distance <= (lastDistance + mpDoubleComparisonEpsilon)) {
      final double clampedDistance = distance.clamp(0.0, totalLength);
      final Tangent? tangent = metric.getTangentForOffset(clampedDistance);

      if (tangent != null) {
        final double angle = anyExplicitDirection
            ? interpolate(directionArc, directionAngle, clampedDistance)
            : (tangentAngleAt(clampedDistance) + (math.pi / 2));
        final double length =
            interpolate(lengthArc, lengthValue, clampedDistance) *
            (shortTick ? 0.333 : 1.0);
        final Offset direction = Offset(math.cos(angle), math.sin(angle));
        final Offset start = tangent.position;
        final Offset end = start + (direction * length);

        ticks
          ..moveTo(start.dx, start.dy)
          ..lineTo(end.dx, end.dy);
      }

      shortTick = !shortTick;
      distance += halfStep;
    }

    canvas.drawPath(
      ticks,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenD * u,
    );

    if (showBorder) {
      canvas.drawPath(
        path,
        Paint.from(color)
          ..style = PaintingStyle.stroke
          ..strokeWidth = mpTherionPenC * u,
      );
    }
  }
}
