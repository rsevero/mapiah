// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda


import 'dart:math' as math;
import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/painters/helpers/mp_arrow_chevron_aux.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_mapconnection_SKBB`: `thdrawoptions(dashed withdots scaled
/// (0.5*optical_zoom) withpen PenB)` followed by `l_arrow_SKBB(P,3)`,
/// whose body draws `P` again under those dotted options (dot size from
/// `PenB`) and then adds an open two-segment chevron mark — plain
/// (non-dashed) strokes, unaffected by the dotted options — at both ends
/// (`Q=3` is both odd and `>1`), pointing outward past each endpoint.
/// `optical_zoom`'s exact default dot pitch isn't derivable without
/// running MetaPost itself, so the dot spacing/diameter here is an
/// approximation using this set's own established spacing/pen
/// conventions rather than a literal port of that constant. The chevron
/// itself is drawn a little larger and with a bolder (`PenB` instead of
/// the macro's own `PenC`) stroke than a literal port, for legibility.
class MPMapConnectionSKBBLineDecorator extends MPLineDecorator {
  const MPMapConnectionSKBBLineDecorator();

  /// Slightly larger/bolder than a literal port of `l_arrow_SKBB`'s
  /// `(-.1u,-.25u)--(0,0)--(.1u,-.25u)` chevron (`0.1u`/`0.25u`, stroked
  /// with `PenC`) for better on-screen legibility at typical zoom levels.
  static final Path _chevron = Path()
    ..moveTo(-0.13, 0.32)
    ..lineTo(0, 0)
    ..lineTo(0.13, 0.32);

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
    final double dotRadius = 0.5 * mpTherionPenB * u;
    final double dotStep = 0.3 * u;
    final Paint dotPaint = Paint.from(color)..style = PaintingStyle.fill;
    final int dotCount = math.max(1, (length / dotStep).round());
    final double adjustedDotStep = length / dotCount;

    for (int index = 0; index <= dotCount; index++) {
      final double distance = (adjustedDotStep * index).clamp(0.0, length);
      final Tangent? tangent = metric.getTangentForOffset(distance);

      if (tangent != null) {
        canvas.drawCircle(tangent.position, dotRadius, dotPaint);
      }
    }

    final Paint chevronPaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenB;

    // l_mapconnection_SKBB always calls l_arrow_SKBB(P,3) — both ends,
    // regardless of any -head option (mapConnection doesn't support one).
    MPArrowChevronAux.drawAtEnds(
      canvas: canvas,
      metric: metric,
      length: length,
      scale: u,
      chevron: _chevron,
      chevronPaint: chevronPaint,
      drawStart: true,
      drawEnd: true,
    );
  }
}
