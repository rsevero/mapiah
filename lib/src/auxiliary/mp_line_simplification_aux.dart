import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPLineSimplificationAux {
  /// Douglas–Peucker line simplification (iterative).
  /// Returns the list of endpoints to be removed.
  static List<THStraightLineSegment> raumerDouglasPeuckerIterative({
    required List<THLineSegment> originalStraightLineSegments,
    required double epsilon,
  }) {
    if (originalStraightLineSegments.length <= 2) {
      return List<THStraightLineSegment>.from(originalStraightLineSegments);
    }

    final double epsSq = epsilon * epsilon;
    final int n = originalStraightLineSegments.length;
    final List<bool> keep = List<bool>.filled(n, false);

    keep[0] = true;
    keep[n - 1] = true;

    final List<List<int>> stack = <List<int>>[
      <int>[0, n - 1],
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

    final List<THStraightLineSegment> result = <THStraightLineSegment>[];

    for (int i = 0; i < n; i++) {
      if (!keep[i]) {
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
  static double _pointToSegmentDistanceSquared(Offset p, Offset a, Offset b) {
    final double abx = b.dx - a.dx;
    final double aby = b.dy - a.dy;
    final double ab2 = abx * abx + aby * aby;

    if (ab2 == 0.0) {
      final double dx = p.dx - a.dx;
      final double dy = p.dy - a.dy;

      return dx * dx + dy * dy;
    }

    final double apx = p.dx - a.dx;
    final double apy = p.dy - a.dy;
    final double t = ((apx * abx + apy * aby) / ab2).clamp(0.0, 1.0);
    final double projx = a.dx + t * abx;
    final double projy = a.dy + t * aby;
    final double dx = p.dx - projx;
    final double dy = p.dy - projy;

    return dx * dx + dy * dy;
  }
}
