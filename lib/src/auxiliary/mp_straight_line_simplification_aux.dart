import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPStraightLineSimplificationAux {
  /// Douglas–Peucker line simplification (iterative).
  /// Returns the list of endpoints to be kept.
  static List<THStraightLineSegment> raumerDouglasPeuckerIterative({
    required List<THLineSegment> originalStraightLineSegments,
    required double accuracy,
  }) {
    final List<THStraightLineSegment> result = <THStraightLineSegment>[];
    final int numberOfStraightLineSegmentsLength =
        originalStraightLineSegments.length;

    if (numberOfStraightLineSegmentsLength < 2) {
      throw Exception(
        'At least two line segments are required for simplification at MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative().',
      );
    }

    final double accuracySq = accuracy * accuracy;
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
        final double dSq = MPNumericAux.distanceSquaredToLineSegment(
          point: originalStraightLineSegments[i].endPoint.coordinates,
          segmentStart: a,
          segmentEnd: b,
        );

        if (dSq > dMaxSq) {
          dMaxSq = dSq;
          index = i;
        }
      }

      if ((index != -1) && (dMaxSq > accuracySq)) {
        keep[index] = true;
        stack.add(<int>[start, index]);
        stack.add(<int>[index, end]);
      }
    }

    final THStraightLineSegment firstSegment =
        originalStraightLineSegments[0] is THStraightLineSegment
        ? originalStraightLineSegments[0] as THStraightLineSegment
        : THStraightLineSegment(
            parentMPID: originalStraightLineSegments[0].parentMPID,
            endPoint: originalStraightLineSegments[0].endPoint,
            optionsMap: originalStraightLineSegments[0].optionsMap,
            attrOptionsMap: originalStraightLineSegments[0].attrOptionsMap,
          );

    result.add(firstSegment);
    for (int i = 1; i < numberOfStraightLineSegmentsLength; i++) {
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
}
