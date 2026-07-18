// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';

class MPPathMetricSample {
  final Tangent tangent;
  final int contourIndex;
  final double distance;
  final bool isReversed;

  const MPPathMetricSample({
    required this.tangent,
    required this.contourIndex,
    required this.distance,
    required this.isReversed,
  });

  Offset get direction {
    final Offset vector = tangent.vector;

    return isReversed ? -vector : vector;
  }
}

/// Walks every contour of a path using evenly adjusted sample spacing.
abstract final class MPPathMetricWalker {
  static void walk({
    required Path path,
    required double desiredStep,
    required bool reverse,
    required void Function(MPPathMetricSample sample) visit,
  }) {
    assert(desiredStep > 0);

    int contourIndex = 0;

    for (final PathMetric metric in path.computeMetrics()) {
      _walkMetric(
        metric: metric,
        contourIndex: contourIndex,
        desiredStep: desiredStep,
        reverse: reverse,
        visit: visit,
      );
      contourIndex++;

      if (contourIndex >= mpMaximumPathMetricContours) {
        break;
      }
    }
  }

  static void _walkMetric({
    required PathMetric metric,
    required int contourIndex,
    required double desiredStep,
    required bool reverse,
    required void Function(MPPathMetricSample sample) visit,
  }) {
    final double length = metric.length;

    if (length <= 0) {
      return;
    }

    final int requestedIntervals = (length / desiredStep).round().clamp(
      1,
      mpMaximumPathMetricSamplesPerContour,
    );
    final double adjustedStep = length / requestedIntervals;

    for (int index = 0; index <= requestedIntervals; index++) {
      final double forwardDistance = adjustedStep * index;
      final double distance = reverse
          ? length - forwardDistance
          : forwardDistance;
      final Tangent? tangent = metric.getTangentForOffset(
        distance.clamp(0, length),
      );

      if (tangent == null) {
        continue;
      }

      visit(
        MPPathMetricSample(
          tangent: tangent,
          contourIndex: contourIndex,
          distance: distance,
          isReversed: reverse,
        ),
      );
    }
  }
}
