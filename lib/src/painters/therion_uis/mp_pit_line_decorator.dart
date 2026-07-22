// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_path_metric_walker.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_pit_UIS` (also aliased in Therion as `l_floorstep_UIS`): short
/// perpendicular ticks stamped every `0.25u` along the line.
class MPPitLineDecorator extends MPLineDecorator {
  const MPPitLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final Paint? basePaint = linePaint.primaryPaint ?? linePaint.secondaryPaint;

    if (basePaint == null) {
      return;
    }

    final double u = symbolUnit.canvasValue;
    final Path ticks = Path();

    MPPathMetricWalker.walk(
      path: path,
      desiredStep: 0.25 * u,
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
        final Offset end = position + (perpendicular * (0.2 * u));

        ticks
          ..moveTo(position.dx, position.dy)
          ..lineTo(end.dx, end.dy);
      },
    );

    canvas.drawPath(
      ticks,
      Paint.from(basePaint)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenD * u,
    );
  }
}
