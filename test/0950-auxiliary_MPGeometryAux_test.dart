// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const double eps = 1e-9;

  group('MPGeometryAux.straightSegmentIntersection', () {
    test('X crossing in the middle returns correct point', () {
      final result = MPGeometryAux.straightSegmentIntersection(
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
      final result = MPGeometryAux.straightSegmentIntersection(
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
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(0, 1),
        const Offset(10, 1),
      );

      expect(result, isNull);
    });

    test('collinear segments return null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(5, 0),
        const Offset(15, 0),
      );

      expect(result, isNull);
    });

    test('segments that cross only when extended return null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0),
        const Offset(4, 0),
        const Offset(5, -5),
        const Offset(5, 5),
      );

      expect(result, isNull);
    });

    test('T-intersection (endpoint on other segment) returns null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(10, -5),
        const Offset(10, 5),
      );

      expect(result, isNull);
    });

    test('crossing very near endpoint returns null (exclusive bounds)', () {
      const double nearlyOne = 1.0 - 1e-11;
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(nearlyOne * 10, -5),
        const Offset(nearlyOne * 10, 5),
      );

      expect(result, isNull);
    });
  });
}
