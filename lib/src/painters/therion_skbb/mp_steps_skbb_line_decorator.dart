// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Ports `l_steps_SKBB`'s non-`ATTR__elevation` (plan view) branch.
///
/// The macro takes `ATTR_c` (rung count, default `2`) and `ATTR_l` (first
/// rail's point count, default `(length(P)-2)/2`) as free-form line
/// attributes; Mapiah's [MPLineDecorator] has no plumbing from a line's
/// `attr` options down to `decorate`, so this port only covers Therion's
/// own *default* case — no `attr c`/`attr l` set on the line — which is
/// also what every symbol in the SKBB showcase fixture uses.
///
/// With defaults, `c` is always `2` (always valid), so the only
/// remaining validity condition is geometric: the path needs at least 4
/// segments (5 points) and an even segment count, so `l` divides evenly.
/// A line that fails this — including the common 2-segment (3-point) or
/// 3-segment (4-point) case most hand-drawn "steps" lines start as —
/// hits Therion's own "Invalid stairs definition" branch: a plain solid
/// `PenA` stroke *forced to red*, overriding this decorator's assigned
/// color, exactly like `l_ropeladder_SKBB`/`l_viaferrata_SKBB`'s stub
/// red lines elsewhere in this set.
///
/// When valid, point 0 is discarded (per the macro) and the remaining
/// `2l+2` points split into two rails of `l+1` points each — points
/// `1..l+1` and, reversed, `(l+2)..(N-1)` — joined by `c=2` end-to-end
/// rungs (`l_border_visible_SKBB`, a plain `PenC` stroke, same as every
/// other stroke here since `l_border_visible` aliases straight to its
/// SKBB definition in `thTrans.mp`).
class MPStepsSKBBLineDecorator extends MPLineDecorator {
  const MPStepsSKBBLineDecorator();

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
    if ((lineSegments == null) || (lineSegments.length < 2)) {
      return;
    }

    final double u = symbolUnit.canvasValue;
    final int pointCount = lineSegments.length;
    final int segmentCount = pointCount - 1;

    if ((segmentCount < 4) || (segmentCount.isOdd)) {
      canvas.drawPath(
        path,
        Paint()
          ..color = THPaint.thPaintMetaPostRed.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = mpTherionPenA * u,
      );

      return;
    }

    final int l = (segmentCount - 2) ~/ 2;
    final List<Offset> vertices = [
      for (final THLinePainterLineSegment segment in lineSegments)
        Offset(segment.x, segment.y),
    ];
    final Paint strokePaint = Paint.from(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpTherionPenC * u;

    Path railBetween(int fromIndex, int toIndex) {
      final Path rail = Path()
        ..moveTo(vertices[fromIndex].dx, vertices[fromIndex].dy);

      for (int i = fromIndex + 1; i <= toIndex; i++) {
        rail.lineTo(vertices[i].dx, vertices[i].dy);
      }

      return rail;
    }

    canvas.drawPath(railBetween(1, 1 + l), strokePaint);
    canvas.drawPath(railBetween(l + 2, pointCount - 1), strokePaint);
    canvas.drawLine(vertices[1], vertices[pointCount - 1], strokePaint);
    canvas.drawLine(vertices[1 + l], vertices[l + 2], strokePaint);
  }
}
