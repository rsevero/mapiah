// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'dart:ui';

/// Shared point sampling for Therion line decorators that stamp periodic
/// perpendicular ticks (`l_pit_UIS`, `l_ceilingstep_UIS`, `l_ceilingstep_SKBB`,
/// `l_ceilingmeander_UIS`, `l_contour_UIS`).
abstract final class MPLineTickAux {
  /// Visits the tangent at the center of each of `round(length / step)`
  /// even segments along [path]'s first contour, mirroring Therion's
  /// `adjust_step` MetaPost helper. When [reverseOrigin] is true, segments
  /// are measured from the path's end instead of its start (used by
  /// `l_chimney_UIS`, which decorates `reverse P`).
  static void walkSegmentMidpoints({
    required Path path,
    required double step,
    required bool reverseOrigin,
    required void Function(Offset position, Offset tangent) visit,
  }) {
    assert(step > 0);

    final List<PathMetric> metrics = path.computeMetrics().toList();

    if (metrics.isEmpty) {
      return;
    }

    final PathMetric metric = metrics.first;
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final int segments = math.max(1, (length / step).round());
    final double adjustedStep = length / segments;

    for (int index = 0; index < segments; index++) {
      final double distanceFromOrigin = adjustedStep * (index + 0.5);
      final double distance = reverseOrigin
          ? (length - distanceFromOrigin)
          : distanceFromOrigin;
      final Tangent? tangent = metric.getTangentForOffset(
        distance.clamp(0, length),
      );

      if (tangent == null) {
        continue;
      }

      visit(tangent.position, tangent.vector);
    }
  }

  /// Visits the tangent at [path]'s midpoint, matching `l_contour_UIS`'s
  /// default `pnt = -2` tick position.
  static void walkMidpoint({
    required Path path,
    required void Function(Offset position, Offset tangent) visit,
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

    final Tangent? tangent = metric.getTangentForOffset(length / 2);

    if (tangent == null) {
      return;
    }

    visit(tangent.position, tangent.vector);
  }
}
