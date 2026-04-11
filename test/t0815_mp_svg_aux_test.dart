// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_svg_aux.dart';

void main() {
  group('MPSVGAux.parseIntrinsicSizeInfo', () {
    test('uses explicit width and height when available', () {
      final MPSVGIntrinsicSizeInfo? info = MPSVGAux.parseIntrinsicSizeInfo(
        '<svg width="120" height="60" xmlns="http://www.w3.org/2000/svg"></svg>',
      );

      expect(info, isNotNull);
      expect(info!.width, 120.0);
      expect(info.height, 60.0);
      expect(info.sourceViewBox, Rect.fromLTWH(0.0, 0.0, 120.0, 60.0));
    });

    test('uses viewBox when width and height are missing', () {
      final MPSVGIntrinsicSizeInfo? info = MPSVGAux.parseIntrinsicSizeInfo(
        '<svg viewBox="-5 10 80 40" xmlns="http://www.w3.org/2000/svg"></svg>',
      );

      expect(info, isNotNull);
      expect(info!.width, 80.0);
      expect(info.height, 40.0);
      expect(info.sourceViewBox, Rect.fromLTWH(-5.0, 10.0, 80.0, 40.0));
    });

    test('returns null when intrinsic size is missing', () {
      final MPSVGIntrinsicSizeInfo? info = MPSVGAux.parseIntrinsicSizeInfo(
        '<svg xmlns="http://www.w3.org/2000/svg"><rect width="10" height="10"/></svg>',
      );

      expect(info, isNull);
    });
  });
}
