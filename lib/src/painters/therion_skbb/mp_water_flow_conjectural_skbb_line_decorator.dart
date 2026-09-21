// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:math' as math;
import 'dart:ui';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/helpers/mp_water_flow_meander_aux.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_waterflow_conjectural_SKBB`, which draws the exact same
/// meandering curve as `l_waterflow_permanent_UIS` (bends alternating side
/// every `0.5u` with a randomized `50 ± 15` degree angle) but with
/// `thdrawoptions(dashed withdots scaled (0.5 * optical_zoom) withpen
/// PenB)` instead of a solid stroke — a sparse row of round dots along the
/// wiggly line — before resetting to solid drawing options for the
/// trailing arrowhead, same as the permanent variant.
class MPWaterFlowConjecturalSKBBLineDecorator extends MPLineDecorator {
  const MPWaterFlowConjecturalSKBBLineDecorator();

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
    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final double u = symbolUnit.canvasValue;
    final double step = 0.5 * u;
    final MPSeededRandom random = MPSeededRandom(mpID: mpID, salt: 1);
    final Path meander = MPWaterFlowMeanderAux.buildMeander(
      metric: metric,
      length: length,
      step: step,
      random: random,
    );

    _drawDots(canvas: canvas, meander: meander, color: color, u: u);

    final Tangent? endTangent = metric.getTangentForOffset(length);

    if (endTangent == null) {
      return;
    }

    final double rotation =
        math.atan2(endTangent.vector.dy, endTangent.vector.dx) +
        (math.pi / 2);
    final Paint arrowFillPaint = Paint()
      ..color = color.color
      ..style = PaintingStyle.fill;

    MPSymbolTransform.draw(
      canvas: canvas,
      position: endTangent.position,
      rotation: rotation,
      scale: u,
      drawUnitSymbol: () {
        canvas.drawPath(MPWaterFlowMeanderAux.arrowPath(), arrowFillPaint);
      },
    );
  }

  /// A dash pattern this sparse (period well past the dot's own diameter)
  /// can't be approximated by a dashed `Paint.strokeWidth` stroke with
  /// round caps without the dashes reading as short line segments rather
  /// than dots, so each dot is stamped directly as a filled circle,
  /// stepping along [meander] at fixed arc-length intervals.
  void _drawDots({
    required Canvas canvas,
    required Path meander,
    required Paint color,
    required double u,
  }) {
    final double dotRadius = 0.5 * mpTherionPenB * u;
    final double spacing = 0.3 * u;
    final Paint dotPaint = Paint()
      ..color = color.color
      ..style = PaintingStyle.fill;

    for (final PathMetric metric in meander.computeMetrics()) {
      double distance = 0;

      while (distance <= metric.length) {
        final Tangent? tangent = metric.getTangentForOffset(distance);

        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, dotPaint);
        }

        distance += spacing;
      }
    }
  }
}
