// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/painters/helpers/mp_path_metric_walker.dart';
import 'package:mapiah/src/painters/helpers/mp_seeded_random.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_transform.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/helpers/mp_thclean.dart';

import 'auxiliary/mp_symbol_golden_harness.dart';

void main() {
  group('Therion symbol rendering infrastructure', () {
    testWidgets('renders registered symbol prototypes side by side', (
      WidgetTester tester,
    ) async {
      final Paint symbolPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final Path pointUnitPath = Path()
        ..moveTo(-1, 1)
        ..lineTo(0, -1)
        ..lineTo(1, 1);
      final List<MPSymbolGoldenEntry> entries = <MPSymbolGoldenEntry>[
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Path symbolPath = MPSymbolTransform.path(
              unitPath: pointUnitPath,
              position: center,
              rotation: math.pi / 6,
              scale: 12,
            );

            canvas.drawPath(symbolPath, symbolPaint);
          },
        ),
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Path linePath = Path()
              ..moveTo(center.dx - 25, center.dy)
              ..lineTo(center.dx + 25, center.dy);

            canvas.drawPath(linePath, symbolPaint);
            MPPathMetricWalker.walk(
              path: linePath,
              desiredStep: 15,
              reverse: false,
              visit: (MPPathMetricSample sample) {
                final Offset normal = Offset(
                  -sample.direction.dy,
                  sample.direction.dx,
                );

                canvas.drawLine(
                  sample.tangent.position,
                  sample.tangent.position + (normal * 8),
                  symbolPaint,
                );
              },
            );
          },
        ),
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Rect area = Rect.fromCenter(
              center: center,
              width: 48,
              height: 36,
            );

            canvas.save();
            canvas.clipRect(area);
            for (int offset = -40; offset <= 40; offset += 8) {
              canvas.drawLine(
                Offset(center.dx + offset - 20, center.dy + 25),
                Offset(center.dx + offset + 20, center.dy - 25),
                symbolPaint,
              );
            }
            canvas.restore();
          },
        ),
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Rect background = Rect.fromCenter(
              center: center,
              width: 48,
              height: 36,
            );
            final Path cleanPath = Path()
              ..addOval(Rect.fromCircle(center: center, radius: 10));

            canvas.drawRect(
              background,
              Paint()..color = const Color(0xFF000000),
            );
            MPThClean.drawPath(
              canvas: canvas,
              path: cleanPath,
              backgroundColor: const Color(0xFFFFFFFF),
            );
          },
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: MPSymbolGoldenHarness(entries: entries)),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_symbol_infrastructure.png'),
      );
    });

    test(
      'derives the base symbol unit from the TH2Edit_SymbolUnit setting',
      () async {
        addTearDown(
          () => mpLocator.mpSettingsController.resetDouble(
            MPSettingID.TH2Edit_SymbolUnit,
          ),
        );

        await mpLocator.mpSettingsController.initialized;
        mpLocator.mpSettingsController.resetDouble(
          MPSettingID.TH2Edit_SymbolUnit,
        );

        const MPSymbolUnit unitAtOneToOne = MPSymbolUnit(
          canvasScale: 1,
          devicePixelRatio: 2,
        );
        const MPSymbolUnit unitAtZoom = MPSymbolUnit(
          canvasScale: 4,
          devicePixelRatio: 2,
        );

        expect(mpDefaultSymbolUnitOnScreen, 10);
        expect(unitAtOneToOne.canvasValue, 5);
        expect(unitAtZoom.canvasValue, 1.25);
        expect(unitAtZoom.canvasValue * 4 * 2, 10);

        mpLocator.mpSettingsController.setDouble(
          MPSettingID.TH2Edit_SymbolUnit,
          20,
        );

        expect(unitAtOneToOne.canvasValue, 10);
      },
    );

    test('transforms a unit path with scale rotation and position', () {
      final Path unitPath = Path()
        ..moveTo(1, 0)
        ..lineTo(2, 0);
      final Path transformedPath = MPSymbolTransform.path(
        unitPath: unitPath,
        position: const Offset(10, 20),
        rotation: math.pi / 2,
        scale: 2,
      );

      expect(transformedPath.getBounds().left, closeTo(10, 1e-9));
      expect(transformedPath.getBounds().top, closeTo(22, 1e-9));
      expect(transformedPath.getBounds().bottom, closeTo(24, 1e-9));
    });

    test('walks line metrics in either path direction', () {
      final Path path = Path()
        ..moveTo(0, 0)
        ..lineTo(10, 0);
      final List<MPPathMetricSample> forward = <MPPathMetricSample>[];
      final List<MPPathMetricSample> reversed = <MPPathMetricSample>[];

      MPPathMetricWalker.walk(
        path: path,
        desiredStep: 6,
        reverse: false,
        visit: forward.add,
      );
      MPPathMetricWalker.walk(
        path: path,
        desiredStep: 6,
        reverse: true,
        visit: reversed.add,
      );

      expect(forward.map((MPPathMetricSample sample) => sample.distance), <double>[0, 5, 10]);
      expect(reversed.map((MPPathMetricSample sample) => sample.distance), <double>[10, 5, 0]);
      expect(forward.first.direction.dx, 1);
      expect(reversed.first.direction.dx, -1);
    });

    test('generates stable procedural values from MPID and salt', () {
      final MPSeededRandom first = MPSeededRandom(mpID: 42, salt: 7);
      final MPSeededRandom second = MPSeededRandom(mpID: 42, salt: 7);
      final MPSeededRandom different = MPSeededRandom(mpID: 43, salt: 7);
      final List<double> firstValues = <double>[
        first.nextDouble(),
        first.nextGaussian(),
      ];
      final List<double> secondValues = <double>[
        second.nextDouble(),
        second.nextGaussian(),
      ];
      final List<double> differentValues = <double>[
        different.nextDouble(),
        different.nextGaussian(),
      ];

      expect(secondValues, firstValues);
      expect(differentValues, isNot(firstValues));
    });
  });
}
