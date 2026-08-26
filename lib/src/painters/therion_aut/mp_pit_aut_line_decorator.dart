// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_pit_AUT` (`l_overhang_AUT` is `let`-aliased straight to the
/// same macro, so [MPPitAUTLineDecorator] is shared by both `pit` and
/// `overhang`): a strip of `0.5u`-wide filled triangles, apex offset
/// `0.25u` perpendicular from each chord's midpoint, followed by a plain
/// stroke of the whole path. The macro's `ATTR__height >= 10` branch
/// switches between a filled and an outlined triangle; Mapiah has no way
/// to read a line's `height` option here, so this always fills, the same
/// simplification `MPOverhangSKBBLineDecorator` already makes for the
/// equivalent SKBB macro.
class MPPitAUTLineDecorator extends MPLineDecorator {
  const MPPitAUTLineDecorator();

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

    MPPitAUTLineDecorator.drawTriangleStrip(
      canvas: canvas,
      path: path,
      color: color,
      u: u,
    );

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }

  /// Shared with [MPWallPitAUTLineDecorator], which runs this same strip
  /// over an inward-offset copy of the wall path instead of the wall path
  /// itself.
  static void drawTriangleStrip({
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
    final int segments = math.max(1, (length / symSize).round());
    final double adjustedStep = length / segments;
    final Paint fill = Paint.from(color)..style = PaintingStyle.fill;

    for (int index = 0; index < segments; index++) {
      final double d1 = (adjustedStep * index).clamp(0, length);
      final double d2 = (adjustedStep * (index + 1)).clamp(0, length);
      final double dm = ((d1 + d2) / 2).clamp(0, length);
      final Tangent? midTangent = metric.getTangentForOffset(dm);

      if (midTangent == null || d2 <= d1) {
        continue;
      }

      final double tangentLength = midTangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = midTangent.vector / tangentLength;
      final Offset perpendicular = Offset(-unit.dy, unit.dx);
      final Offset apex =
          midTangent.position + (perpendicular * (adjustedStep / 2));
      final Path triangle = metric.extractPath(d1, d2);

      triangle
        ..lineTo(apex.dx, apex.dy)
        ..close();

      canvas.drawPath(triangle, fill);
    }
  }
}
