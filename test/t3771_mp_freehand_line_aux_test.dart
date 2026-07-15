// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_freehand_line_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';

void main() {
  group('MPFreehandLineAux.isSampleFarEnough', () {
    test('rejects a candidate closer than the minimum spacing', () {
      expect(
        MPFreehandLineAux.isSampleFarEnough(
          candidateScreenPosition: const Offset(0, 0),
          lastAcceptedScreenPosition: Offset(
            mpFreehandMinimumSampleSpacingOnScreen / 2,
            0,
          ),
        ),
        isFalse,
      );
    });

    test('accepts a candidate at or beyond the minimum spacing', () {
      expect(
        MPFreehandLineAux.isSampleFarEnough(
          candidateScreenPosition: const Offset(0, 0),
          lastAcceptedScreenPosition: Offset(
            mpFreehandMinimumSampleSpacingOnScreen,
            0,
          ),
        ),
        isTrue,
      );
    });

    test('honors an explicit enlarged spacing after compaction', () {
      final double enlargedSpacing = mpFreehandMinimumSampleSpacingOnScreen * 2;

      expect(
        MPFreehandLineAux.isSampleFarEnough(
          candidateScreenPosition: const Offset(0, 0),
          // Beyond the original spacing but under the enlarged one.
          lastAcceptedScreenPosition: Offset(
            mpFreehandMinimumSampleSpacingOnScreen * 1.5,
            0,
          ),
          sampleSpacingOnScreen: enlargedSpacing,
        ),
        isFalse,
      );
    });
  });

  group('MPFreehandLineAux.meetsMinimumCommittedStrokeLength', () {
    test('rejects a one-point tap', () {
      expect(
        MPFreehandLineAux.meetsMinimumCommittedStrokeLength(
          firstScreenPosition: const Offset(10, 10),
          lastScreenPosition: const Offset(10, 10),
        ),
        isFalse,
      );
    });

    test('rejects a below-minimum-length stroke', () {
      expect(
        MPFreehandLineAux.meetsMinimumCommittedStrokeLength(
          firstScreenPosition: const Offset(0, 0),
          lastScreenPosition: Offset(
            mpFreehandMinimumCommittedStrokeLengthOnScreen / 2,
            0,
          ),
        ),
        isFalse,
      );
    });

    test('accepts a stroke reaching the minimum length', () {
      expect(
        MPFreehandLineAux.meetsMinimumCommittedStrokeLength(
          firstScreenPosition: const Offset(0, 0),
          lastScreenPosition: Offset(
            mpFreehandMinimumCommittedStrokeLengthOnScreen,
            0,
          ),
        ),
        isTrue,
      );
    });
  });

  group('MPFreehandLineAux.removeConsecutiveDuplicatePoints', () {
    test('removes consecutive duplicates while preserving order', () {
      expect(
        MPFreehandLineAux.removeConsecutiveDuplicatePoints(const [
          Offset(0, 0),
          Offset(0, 0),
          Offset(1, 1),
          Offset(1, 1),
          Offset(1, 1),
          Offset(2, 2),
        ]),
        const [Offset(0, 0), Offset(1, 1), Offset(2, 2)],
      );
    });

    test('keeps non-consecutive repeats (e.g. snap coinciding with start)', () {
      expect(
        MPFreehandLineAux.removeConsecutiveDuplicatePoints(const [
          Offset(0, 0),
          Offset(1, 1),
          Offset(0, 0),
        ]),
        const [Offset(0, 0), Offset(1, 1), Offset(0, 0)],
      );
    });
  });

  group('MPFreehandLineAux.compactSampleBuffer', () {
    test('keeps first point, every second interior point, and last point', () {
      final List<Offset> samples = List<Offset>.generate(
        11,
        (int i) => Offset(i.toDouble(), 0),
      );

      expect(
        MPFreehandLineAux.compactSampleBuffer(samples),
        const [
          Offset(0, 0),
          Offset(1, 0),
          Offset(3, 0),
          Offset(5, 0),
          Offset(7, 0),
          Offset(9, 0),
          Offset(10, 0),
        ],
      );
    });

    test('returns buffers of two or fewer points unchanged', () {
      final List<Offset> twoPoints = const [Offset(0, 0), Offset(1, 1)];

      expect(MPFreehandLineAux.compactSampleBuffer(twoPoints), twoPoints);

      final List<Offset> onePoint = const [Offset(0, 0)];

      expect(MPFreehandLineAux.compactSampleBuffer(onePoint), onePoint);
    });

    test('always retains both ends and accepts later movement', () {
      final List<Offset> samples = List<Offset>.generate(
        mpFreehandMaximumSampleCount,
        (int i) => Offset(i.toDouble(), 0),
      );
      final List<Offset> compacted = MPFreehandLineAux.compactSampleBuffer(
        samples,
      );

      expect(compacted.first, samples.first);
      expect(compacted.last, samples.last);
      expect(compacted.length, lessThan(samples.length));

      // The compacted buffer still has room to accept new samples using a
      // (now doubled, per the caller) spacing before hitting the maximum
      // again.
      expect(compacted.length, lessThan(mpFreehandMaximumSampleCount));
    });
  });

  group('MPFreehandLineAux.computeSimplificationEpsilon', () {
    test('is maxDimension / divisor when that exceeds the floor', () {
      const Rect boundingBox = Rect.fromLTWH(0, 0, 1000, 400);

      expect(
        MPFreehandLineAux.computeSimplificationEpsilon(boundingBox),
        1000 / mpFreehandSimplificationExtentDivisor,
      );
    });

    test('is exactly the floor for a sufficiently small stroke', () {
      const Rect boundingBox = Rect.fromLTWH(0, 0, 0.01, 0.01);

      expect(
        MPFreehandLineAux.computeSimplificationEpsilon(boundingBox),
        mpFreehandMinimumSimplificationEpsilon,
      );
    });

    test('uses the larger bounding-box dimension', () {
      const Rect wide = Rect.fromLTWH(0, 0, 800, 100);
      const Rect tall = Rect.fromLTWH(0, 0, 100, 800);

      expect(
        MPFreehandLineAux.computeSimplificationEpsilon(wide),
        MPFreehandLineAux.computeSimplificationEpsilon(tall),
      );
    });

    test('is independent of zoom (a pure function of canvas extent)', () {
      const Rect boundingBoxAtZoom1 = Rect.fromLTWH(0, 0, 500, 200);
      const Rect boundingBoxAtZoom2 = Rect.fromLTWH(0, 0, 500, 200);

      expect(
        MPFreehandLineAux.computeSimplificationEpsilon(boundingBoxAtZoom1),
        MPFreehandLineAux.computeSimplificationEpsilon(boundingBoxAtZoom2),
      );
    });
  });

  group('MPFreehandLineAux.simplifyStrokeToStraightLineSegments', () {
    const int lineMPID = 1;
    const int decimalPositions = 4;

    test('returns null for a one-point tap', () {
      expect(
        MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
          rawCanvasPoints: const [Offset(0, 0)],
          rawBoundingBox: Rect.zero,
          lineMPID: lineMPID,
          decimalPositions: decimalPositions,
        ),
        isNull,
      );
    });

    test('returns null when every point collapses via duplicate removal', () {
      expect(
        MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
          rawCanvasPoints: const [
            Offset(5, 5),
            Offset(5, 5),
            Offset(5, 5),
          ],
          rawBoundingBox: Rect.zero,
          lineMPID: lineMPID,
          decimalPositions: decimalPositions,
        ),
        isNull,
      );
    });

    test('retains a right-angle corner', () {
      final List<Offset> points = const [
        Offset(0, 0),
        Offset(50, 0),
        Offset(50, 50),
      ];
      final Rect boundingBox = Rect.fromPoints(points.first, points.last);
      final List<THStraightLineSegment> result =
          MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
            rawCanvasPoints: points,
            rawBoundingBox: boundingBox,
            lineMPID: lineMPID,
            decimalPositions: decimalPositions,
          )!;

      expect(
        result.map((THStraightLineSegment s) => s.endPoint.coordinates),
        points,
      );
    });

    test('simplifies a nearly-collinear dense path to start/end only', () {
      final List<Offset> points = List<Offset>.generate(
        50,
        (int i) => Offset(
          i.toDouble(),
          // A tiny wobble, well under the epsilon derived from this
          // stroke's 49-unit-wide bounding box.
          (i.isEven ? 0.0 : 0.0001),
        ),
      );
      final Rect boundingBox = Rect.fromLTRB(0, 0, 49, 0.0001);
      final List<THStraightLineSegment> result =
          MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
            rawCanvasPoints: points,
            rawBoundingBox: boundingBox,
            lineMPID: lineMPID,
            decimalPositions: decimalPositions,
          )!;

      expect(result.length, 2);
      expect(result.first.endPoint.coordinates, points.first);
      expect(result.last.endPoint.coordinates, points.last);
    });

    test('preserves exact first/final endpoints after endpoint snapping', () {
      final List<Offset> points = const [
        Offset(1.23456, 4.5), // snapped start
        Offset(1.23456, 4.5), // duplicate introduced by snapping
        Offset(10, 10),
        Offset(20, 0), // snapped final point
      ];
      final Rect boundingBox = Rect.fromLTRB(1.23456, 0, 20, 10);
      final List<THStraightLineSegment> result =
          MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
            rawCanvasPoints: points,
            rawBoundingBox: boundingBox,
            lineMPID: lineMPID,
            decimalPositions: decimalPositions,
          )!;

      expect(result.first.endPoint.coordinates, const Offset(1.23456, 4.5));
      expect(result.last.endPoint.coordinates, const Offset(20, 0));
    });

    test('every generated segment is a THStraightLineSegment', () {
      final List<Offset> points = const [
        Offset(0, 0),
        Offset(5, 5),
        Offset(10, 0),
      ];
      final Rect boundingBox = Rect.fromLTRB(0, 0, 10, 5);
      final List<THStraightLineSegment> result =
          MPFreehandLineAux.simplifyStrokeToStraightLineSegments(
            rawCanvasPoints: points,
            rawBoundingBox: boundingBox,
            lineMPID: lineMPID,
            decimalPositions: decimalPositions,
          )!;

      expect(
        result.every((THLineSegment s) => s is THStraightLineSegment),
        isTrue,
      );
      expect(
        result.map((THStraightLineSegment s) => s.parentMPID),
        everyElement(lineMPID),
      );
    });

    test(
      'buffer compaction does not change epsilon even if it removes an '
      'extreme point',
      () {
        // Build a raw stroke where the widest point (the bounding-box
        // extreme) sits in the interior and would be dropped by
        // MPFreehandLineAux.compactSampleBuffer's "every second interior
        // point" rule. The bounding box passed in is the one captured
        // *before* compaction, as the freehand controller is required to
        // do, so the epsilon must reflect the true extent regardless.
        final List<Offset> rawPoints = <Offset>[
          const Offset(0, 0),
          const Offset(1, 0),
          const Offset(2, 100), // extreme point, will be dropped below
          const Offset(3, 0),
          const Offset(4, 0),
        ];
        final Rect rawBoundingBox = Rect.fromLTRB(0, 0, 4, 100);
        final List<Offset> compactedPoints = <Offset>[
          rawPoints[0],
          rawPoints[1],
          rawPoints[3],
          rawPoints[4],
        ];

        expect(compactedPoints.contains(const Offset(2, 100)), isFalse);

        final double epsilonFromRawBoundingBox =
            MPFreehandLineAux.computeSimplificationEpsilon(rawBoundingBox);
        final double epsilonFromCompactedPointsBoundingBox =
            MPFreehandLineAux.computeSimplificationEpsilon(
              Rect.fromPoints(
                compactedPoints.reduce(
                  (Offset a, Offset b) => Offset(
                    a.dx < b.dx ? a.dx : b.dx,
                    a.dy < b.dy ? a.dy : b.dy,
                  ),
                ),
                compactedPoints.reduce(
                  (Offset a, Offset b) => Offset(
                    a.dx > b.dx ? a.dx : b.dx,
                    a.dy > b.dy ? a.dy : b.dy,
                  ),
                ),
              ),
            );

        expect(
          epsilonFromRawBoundingBox,
          isNot(epsilonFromCompactedPointsBoundingBox),
        );
      },
    );

  });
}
