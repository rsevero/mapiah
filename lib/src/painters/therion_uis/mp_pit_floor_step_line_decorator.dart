// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/helpers/mp_path_metric_walker.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_pit_UIS` and its `l_floorstep_UIS` alias: a continuous `PenC`
/// line with short `PenD` perpendicular ticks stamped every `0.25u`.
class MPPitFloorStepLineDecorator extends MPLineDecorator {
  const MPPitFloorStepLineDecorator();

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
  }) {
    final double u = symbolUnit.canvasValue;
    final Path ticks = Path();

    MPPathMetricWalker.walk(
      path: path,
      desiredStep: mpTherionUISPitFloorStepTickStepUnits * u,
      reverse: false,
      visit: (MPPathMetricSample sample) {
        final Offset direction = sample.direction;
        final double directionLength = direction.distance;

        if (directionLength == 0) {
          return;
        }

        final Offset unit = direction / directionLength;
        final Offset perpendicular = Offset(-unit.dy, unit.dx);
        final Offset position = sample.tangent.position;
        final Offset end =
            position +
            (perpendicular * (mpTherionUISPitFloorStepTickLengthUnits * u));

        ticks
          ..moveTo(position.dx, position.dy)
          ..lineTo(end.dx, end.dy);
      },
    );

    canvas.drawPath(
      ticks,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenD * u,
    );
    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenC * u,
    );
  }
}
