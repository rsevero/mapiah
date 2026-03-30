// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const double eps = mpDoubleComparisonEpsilon;

  group('MPGeometryAux.straightSegmentIntersection', () {
    test('X crossing in the middle returns correct point', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(5, -5),
            const Offset(5, 5),
          );

      expect(result, isNotNull);
      expect(result!.point.dx, closeTo(5.0, eps));
      expect(result.point.dy, closeTo(0.0, eps));
      expect(result.tA, closeTo(0.5, eps));
      expect(result.tB, closeTo(0.5, eps));
    });

    test('diagonal crossing returns correct point', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 10),
            const Offset(0, 10),
            const Offset(10, 0),
          );

      expect(result, isNotNull);
      expect(result!.point.dx, closeTo(5.0, eps));
      expect(result.point.dy, closeTo(5.0, eps));
    });

    test('parallel segments return null', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(0, 1),
            const Offset(10, 1),
          );

      expect(result, isNull);
    });

    test('collinear segments return null', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(5, 0),
            const Offset(15, 0),
          );

      expect(result, isNull);
    });

    test('segments that cross only when extended return null', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(4, 0),
            const Offset(5, -5),
            const Offset(5, 5),
          );

      expect(result, isNull);
    });

    test('T-intersection (endpoint on other segment) returns null', () {
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(10, -5),
            const Offset(10, 5),
          );

      expect(result, isNull);
    });

    test('crossing very near endpoint returns null (exclusive bounds)', () {
      const double nearlyOne = 1.0 - 1e-11;
      final MPSegmentIntersection? result =
          MPGeometryAux.straightSegmentIntersection(
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(nearlyOne * 10, -5),
            const Offset(nearlyOne * 10, 5),
          );

      expect(result, isNull);
    });
  });

  group('MPGeometryAux.bezierSegmentStraightSegmentIntersection', () {
    test('Bézier crossing vertical line', () {
      // Quadratic-like Bézier from (0,0) to (10,0) bulging down
      // Line from (5, -10) to (5, 10) — vertical
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(0, 0),
            const Offset(5, -5), // control point 1
            const Offset(5, -5), // control point 2
            const Offset(10, 0),
            const Offset(5, -10),
            const Offset(5, 10),
          );

      expect(results, isNotEmpty);
      expect(results[0].tBezier, inInclusiveRange(0.4, 0.6));
      expect(results[0].point.dx, closeTo(5.0, eps));
    });

    test('Bézier not crossing line returns empty list', () {
      // Quadratic-like Bézier from (0,0) to (10,0) bulging down
      // Line from (5, 5) to (5, 10) — above the Bézier
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(0, 0),
            const Offset(5, -5),
            const Offset(5, -5),
            const Offset(10, 0),
            const Offset(5, 5),
            const Offset(5, 10),
          );

      expect(results, isEmpty);
    });

    test('Bézier intersecting horizontal line', () {
      // Bézier that bulges above and below a horizontal line
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(0, -5),
            const Offset(5, 5), // bulge up
            const Offset(5, 5),
            const Offset(10, -5), // symmetric down
            const Offset(-1, 0),
            const Offset(11, 0), // horizontal line at y=0
          );

      // Should have intersections
      expect(results.length, greaterThan(0));
      // All should be on the line
      for (final BezierStraightIntersection result in results) {
        expect(result.point.dy, closeTo(0.0, eps));
      }
    });

    test('Multiple intersections sorted by t', () {
      // S-curve Bézier that crosses a line multiple times
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(0, -5),
            const Offset(3, 10),
            const Offset(7, -10),
            const Offset(10, 5),
            const Offset(-1, 0),
            const Offset(11, 0), // horizontal line at y=0
          );

      // Check sorted order
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i].tBezier,
          greaterThanOrEqualTo(results[i - 1].tBezier),
        );
      }
    });

    test('Bézier endpoints not included in results (interior check)', () {
      // Bézier from (0,0) to (10,0) that touches y=0 at endpoints
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(0, 0),
            const Offset(5, -5),
            const Offset(5, -5),
            const Offset(10, 0),
            const Offset(-1, 0),
            const Offset(11, 0),
          );

      // Endpoints should be filtered out
      for (final BezierStraightIntersection result in results) {
        expect(result.tBezier, inInclusiveRange(0.01, 0.99));
        expect(result.tLine, inInclusiveRange(0.01, 0.99));
      }
    });

    test('Line endpoints not included in results (interior check)', () {
      // Bézier that would cross the line at line endpoints
      final List<BezierStraightIntersection> results =
          MPGeometryAux.bezierSegmentStraightSegmentIntersection(
            const Offset(-5, 5),
            const Offset(0, -5),
            const Offset(10, -5),
            const Offset(15, 5),
            const Offset(0, 0),
            const Offset(10, 0),
          );

      // Line endpoints (t=0 and t=1) should be filtered
      for (final BezierStraightIntersection result in results) {
        expect(result.tLine, inInclusiveRange(0.01, 0.99));
      }
    });
  });
}
