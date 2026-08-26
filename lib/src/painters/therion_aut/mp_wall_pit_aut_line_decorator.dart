// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_aut/mp_pit_aut_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_wall_pit_AUT`: the outer wall path stroked (`PenA`), plus the
/// same `.5u` triangle strip as [MPPitAUTLineDecorator], run over an
/// inner path offset `.125u` inward. Therion's own macro also special-cases
/// sharp bends (its `testcircle` scan) so the offset path never
/// self-intersects there; Mapiah approximates with a plain per-sample
/// perpendicular offset instead, which can pinch slightly at tight bends —
/// an accepted simplification, the same kind already made for the
/// randomized-placement wall marks.
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

    final Path? innerPath = _buildInwardOffsetPath(path, 0.125 * u);

    if (innerPath != null) {
      canvas.drawPath(
        innerPath,
        Paint.from(color)
          ..style = PaintingStyle.stroke
          ..strokeWidth = mpTherionPenC * u,
      );
      MPPitAUTLineDecorator.drawTriangleStrip(
        canvas: canvas,
        path: innerPath,
        color: color,
        u: u,
      );
    }
  }

  static Path? _buildInwardOffsetPath(Path path, double offset) {
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return null;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return null;
    }

    const int samples = 64;
    final Path result = Path();
    bool started = false;

    for (int index = 0; index <= samples; index++) {
      final double distance = (length * index / samples).clamp(0, length);
      final Tangent? tangent = metric.getTangentForOffset(distance);

      if (tangent == null) {
        continue;
      }

      final double tangentLength = tangent.vector.distance;

      if (tangentLength == 0) {
        continue;
      }

      final Offset unit = tangent.vector / tangentLength;
      final Offset inward = Offset(unit.dy, -unit.dx);
      final Offset point = tangent.position + (inward * offset);

      if (!started) {
        result.moveTo(point.dx, point.dy);
        started = true;
      } else {
        result.lineTo(point.dx, point.dy);
      }
    }

    return started ? result : null;
  }
}
