import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPStraightLineSimplificationAux {
  /// Douglas–Peucker line simplification (iterative).
  /// Returns the list of endpoints to be kept.
  static List<THStraightLineSegment> raumerDouglasPeuckerIterative({
    required List<THLineSegment> originalStraightLineSegments,
    required double epsilon,
  }) {
    final List<THStraightLineSegment> result = <THStraightLineSegment>[];
    final int numberOfStraightLineSegmentsLength =
        originalStraightLineSegments.length;

    if (numberOfStraightLineSegmentsLength <= 2) {
      return result;
    }

    final double epsSq = epsilon * epsilon;
    final List<bool> keep = List<bool>.filled(
      numberOfStraightLineSegmentsLength,
      false,
    );

    keep[0] = true;
    keep[numberOfStraightLineSegmentsLength - 1] = true;

    final List<List<int>> stack = <List<int>>[
      <int>[0, numberOfStraightLineSegmentsLength - 1],
    ];

    while (stack.isNotEmpty) {
      final List<int> seg = stack.removeLast();
      final int start = seg[0];
      final int end = seg[1];

      if (end - start <= 1) {
        continue;
      }

      final Offset a = originalStraightLineSegments[start].endPoint.coordinates;
      final Offset b = originalStraightLineSegments[end].endPoint.coordinates;

      double dMaxSq = 0.0;
      int index = -1;

      for (int i = start + 1; i < end; i++) {
        final double dSq = _pointToSegmentDistanceSquared(
          originalStraightLineSegments[i].endPoint.coordinates,
          a,
          b,
        );

        if (dSq > dMaxSq) {
          dMaxSq = dSq;
          index = i;
        }
      }

      if (index != -1 && dMaxSq > epsSq) {
        keep[index] = true;
        stack.add(<int>[start, index]);
        stack.add(<int>[index, end]);
      }
    }

    for (int i = 0; i < numberOfStraightLineSegmentsLength; i++) {
      if (keep[i]) {
        if (originalStraightLineSegments[i] is! THStraightLineSegment) {
          throw Exception(
            'Expected THStraightLineSegment, got ${originalStraightLineSegments[i].runtimeType}',
          );
        }
        result.add(originalStraightLineSegments[i] as THStraightLineSegment);
      }
    }

    return result;
  }

  /// Squared perpendicular distance from point P to segment AB.
  static double _pointToSegmentDistanceSquared(
    Offset point,
    Offset segmentStart,
    Offset segmentEnd,
  ) {
    final double abx = segmentEnd.dx - segmentStart.dx;
    final double aby = segmentEnd.dy - segmentStart.dy;
    final double ab2 = abx * abx + aby * aby;

    if (ab2 == 0.0) {
      final double dx = point.dx - segmentStart.dx;
      final double dy = point.dy - segmentStart.dy;

      return dx * dx + dy * dy;
    }

    final double apx = point.dx - segmentStart.dx;
    final double apy = point.dy - segmentStart.dy;
    final double t = ((apx * abx + apy * aby) / ab2).clamp(0.0, 1.0);
    final double projx = segmentStart.dx + t * abx;
    final double projy = segmentStart.dy + t * aby;
    final double dx = point.dx - projx;
    final double dy = point.dy - projy;

    return dx * dx + dy * dy;
  }
}
