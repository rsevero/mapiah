// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_tick_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_fixedladder_SKBB`: rungs (perpendicular `PenC` ticks, `0.25u`
/// on each side of the path, spaced every `adjust_step`d `0.3u`) between
/// two parallel `PenC` rails offset `0.25u` to each side (`polyline_offset`,
/// a mitred polyline offset). Side-view elevation rendering is out of
/// scope (see the macro's own `TODO`), matching every other SKBB decorator's
/// plan-view-only scope.
///
/// `polyline_offset` walks the line's original knots (`punked`, i.e. its
/// Bézier curves flattened to a polyline first); Mapiah reuses
/// [lineSegments]'s knot positions directly for the same purpose, which is
/// exact for straight lines and an approximation for curved ones.
class MPFixedLadderSKBBLineDecorator extends MPLineDecorator {
  const MPFixedLadderSKBBLineDecorator();

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

    final double u = symbolUnit.canvasValue;
    final double halfWidth = 0.25 * u;
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

    MPLineTickAux.walkSegmentMidpoints(
      path: path,
      step: 0.3 * u,
      reverseOrigin: false,
      visit: (Offset position, Offset tangent, double adjustedStep) {
        final double tangentLength = tangent.distance;

        if (tangentLength == 0) {
          return;
        }

        final Offset unit = tangent / tangentLength;
        final Offset perpendicular = Offset(unit.dy, -unit.dx);

        canvas.drawLine(
          position + (perpendicular * halfWidth),
          position - (perpendicular * halfWidth),
          strokePaint,
        );
      },
    );

    final List<Offset> vertices = [
      for (final THLinePainterLineSegment segment in lineSegments)
        Offset(segment.x, segment.y),
    ];

    canvas.drawPath(
      _pathFromPoints(_polylineOffset(vertices, halfWidth, 90)),
      strokePaint,
    );
    canvas.drawPath(
      _pathFromPoints(_polylineOffset(vertices, halfWidth, -90)),
      strokePaint,
    );
  }

  static Path _pathFromPoints(List<Offset> points) {
    final Path path = Path();

    if (points.isEmpty) {
      return path;
    }

    path.moveTo(points.first.dx, points.first.dy);

    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    return path;
  }

  static Offset _rotate(Offset vector, double degrees) {
    final double radians = degrees * math.pi / 180;
    final double cosValue = math.cos(radians);
    final double sinValue = math.sin(radians);

    return Offset(
      (vector.dx * cosValue) - (vector.dy * sinValue),
      (vector.dx * sinValue) + (vector.dy * cosValue),
    );
  }

  static Offset _unit(Offset vector) {
    final double length = vector.distance;

    return (length == 0) ? vector : (vector / length);
  }

  /// Mirrors `thLine.mp`'s `polyline_offset`: at each knot, offsets by
  /// `amount` along the knot's mitred bisector direction (the average of
  /// its incoming/outgoing unit segment directions, rotated by
  /// [directionDegrees] and scaled by `1/|sin(halfAngle)|` for a proper
  /// miter join), matching an unclosed polyline (`P` here is never
  /// cyclic for a drawn `.th2` line).
  static List<Offset> _polylineOffset(
    List<Offset> points,
    double amount,
    double directionDegrees,
  ) {
    final int lastIndex = points.length - 1;
    final List<Offset> result = [];

    for (int i = 0; i <= lastIndex; i++) {
      final Offset incoming = (i > 0)
          ? _unit(points[i] - points[i - 1])
          : _unit(points[1] - points[0]);
      final Offset outgoing = (i < lastIndex)
          ? _unit(points[i + 1] - points[i])
          : incoming;
      final double incomingAngle =
          math.atan2(incoming.dy, incoming.dx) * 180 / math.pi;
      final double outgoingAngle =
          math.atan2(outgoing.dy, outgoing.dx) * 180 / math.pi;
      final double halfAngle =
          (180 - (incomingAngle - outgoingAngle)) / 2 * math.pi / 180;
      final double divisor = math.sin(halfAngle).abs();
      final Offset average = Offset(
        (incoming.dx + outgoing.dx) / 2,
        (incoming.dy + outgoing.dy) / 2,
      );
      final Offset bisector = _unit(_rotate(average, directionDegrees));
      final double magnitude = (divisor > 1e-9) ? (amount / divisor) : amount;

      result.add(points[i] + (bisector * magnitude));
    }

    return result;
  }
}
