// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_svg_aux.dart';

void main() {
  group('MPSVGAux.parseMetadataInfo', () {
    test('uses explicit width and height when available', () {
      final MPSVGMetadataInfo info = MPSVGAux.parseMetadataInfo(
        '<svg width="120" height="60" xmlns="http://www.w3.org/2000/svg"></svg>',
      );

      expect(info.width, 120.0);
      expect(info.height, 60.0);
      expect(info.sourceViewBox, isNull);
      expect(
        info.resolveIntrinsicSizeInfo()!.sourceViewBox,
        Rect.fromLTWH(0.0, 0.0, 120.0, 60.0),
      );
    });

    test('uses viewBox when width and height are missing', () {
      final MPSVGMetadataInfo info = MPSVGAux.parseMetadataInfo(
        '<svg viewBox="-5 10 80 40" xmlns="http://www.w3.org/2000/svg"></svg>',
      );

      expect(info.width, isNull);
      expect(info.height, isNull);
      expect(info.sourceViewBox, Rect.fromLTWH(-5.0, 10.0, 80.0, 40.0));
      expect(info.resolveIntrinsicSizeInfo()!.width, 80.0);
      expect(info.resolveIntrinsicSizeInfo()!.height, 40.0);
    });

    test(
      'returns metadata with missing values when intrinsic size is missing',
      () {
        final MPSVGMetadataInfo info = MPSVGAux.parseMetadataInfo(
          '<svg xmlns="http://www.w3.org/2000/svg"><rect width="10" height="10"/></svg>',
        );

        expect(info.width, isNull);
        expect(info.height, isNull);
        expect(info.sourceViewBox, isNull);
        expect(info.resolveIntrinsicSizeInfo(), isNull);
      },
    );

    test('accepts manual width and height fallback values', () {
      final MPSVGMetadataInfo info = MPSVGAux.parseMetadataInfo(
        '<svg xmlns="http://www.w3.org/2000/svg"></svg>',
      );
      final MPSVGIntrinsicSizeInfo? intrinsicSizeInfo = info
          .resolveIntrinsicSizeInfo(fallbackWidth: 200.0, fallbackHeight: 80.0);

      expect(intrinsicSizeInfo, isNotNull);
      expect(intrinsicSizeInfo!.width, 200.0);
      expect(intrinsicSizeInfo.height, 80.0);
      expect(
        intrinsicSizeInfo.sourceViewBox,
        Rect.fromLTWH(0.0, 0.0, 200.0, 80.0),
      );
    });

    test('injects missing root metadata for rendering', () {
      final String normalizedSVG = MPSVGAux.ensureRenderableSVGRootMetadata(
        svgText: '<svg xmlns="http://www.w3.org/2000/svg"></svg>',
        intrinsicSizeInfo: const MPSVGIntrinsicSizeInfo(
          width: 200.0,
          height: 80.0,
          sourceViewBox: Rect.fromLTWH(0.0, 0.0, 200.0, 80.0),
        ),
      );

      expect(normalizedSVG, contains('width="200.0"'));
      expect(normalizedSVG, contains('height="80.0"'));
      expect(normalizedSVG, contains('viewBox="0.0 0.0 200.0 80.0"'));
    });
  });
}
