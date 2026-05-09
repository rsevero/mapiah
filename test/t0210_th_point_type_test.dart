// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

void main() {
  group('THPointType', () {
    test('recognizes and serializes borehole point type', () {
      final THPointType pointType = THPointType.fromString('borehole');

      expect(pointType, THPointType.borehole);
      expect(THPointType.hasPointType('borehole'), isTrue);
      expect(pointType.toFileString(), 'borehole');
    });
  });
}
