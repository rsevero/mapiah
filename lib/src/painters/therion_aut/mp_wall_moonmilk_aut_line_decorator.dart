// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_directional_curve_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_moonmilk_AUT`: a `.4u`-wide bump every `.8u` along the
/// path (each a single directional curve leaving/arriving at 90 degrees
/// from the path's own tangent at its two endpoints — see
/// [MPWallFlowstoneAUTLineDecorator], which shares [buildBumps] and adds a
/// fill), followed by a plain `PenA` stroke of the whole path.
class MPWallMoonmilkAUTLineDecorator extends MPLineDecorator {
  const MPWallMoonmilkAUTLineDecorator();

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
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

    for (final Path bump in buildBumps(path: path, u: u)) {
      canvas.drawPath(bump, strokePaint);
    }

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenA * u,
    );
  }

  /// MetaPost's `A{dir d1}..{dir d2}B` with `d1`/`d2` perpendicular to the
  /// chord traces a near-semicircle; a cubic reproduces that with control
  /// handles ~0.55 of the chord length rather than the `1/3` default used
  /// for gentle curls.
  static const double _semicircleHandleFactor = 0.5523;

  /// Shared with [MPWallFlowstoneAUTLineDecorator].
  static List<Path> buildBumps({required Path path, required double u}) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return const <Path>[];
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return const <Path>[];
    }

    const double symSizeFactor = 0.8;
    const double circleWidthFactor = 0.4;
    final double symSize = symSizeFactor * u;
    final double circleWidth = circleWidthFactor * u;
    final List<Path> bumps = <Path>[];

    for (
      double cur = (symSize - circleWidth) / 2;
      cur <= length + (symSize / 3);
      cur += symSize
    ) {
      final double t1 = cur.clamp(0, length);
      final double t2 = (cur + circleWidth).clamp(0, length);

      if (t2 <= t1) {
        continue;
      }

      final Tangent? tangent1 = metric.getTangentForOffset(t1);
      final Tangent? tangent2 = metric.getTangentForOffset(t2);

      if ((tangent1 == null) || (tangent2 == null)) {
        continue;
      }

      final double angle1 = math.atan2(
        tangent1.vector.dy,
        tangent1.vector.dx,
      );
      final double angle2 = math.atan2(
        tangent2.vector.dy,
        tangent2.vector.dx,
      );

      bumps.add(
        MPDirectionalCurveAux.buildCurvePath(
          start: tangent1.position,
          end: tangent2.position,
          startDirectionDegrees: (angle1 * 180 / math.pi) + 90,
          endDirectionDegrees: (angle2 * 180 / math.pi) - 90,
          handleLengthFactor: _semicircleHandleFactor,
        ),
      );
    }

    return bumps;
  }
}
