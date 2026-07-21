// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'auxiliary/mp_symbol_golden_harness.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_uis/mp_area_pattern_tiles.dart';
import 'package:mapiah/src/painters/therion_uis/mp_gradient_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

void main() {
  // MPSymbolUnit.canvasValue reads the symbol-unit setting, so the settings
  // controller (with its async Therion-availability check) must finish
  // initializing before any testWidgets() runs, or its still-pending
  // process-spawn future trips the "timer pending after dispose" assertion.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await mpLocator.mpSettingsController.initialized;
  });

  group('Therion UIS Phase 1 symbols', () {
    testWidgets('renders every Phase 1 point symbol', (
      WidgetTester tester,
    ) async {
      const double u = 30;
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke;
      final Paint fillPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill;
      final List<MPSymbolGoldenEntry> entries = MPTherionPointSymbol.values
          .map(
            (MPTherionPointSymbol symbol) => MPSymbolGoldenEntry(
              draw: (Canvas canvas, Offset center) {
                final Paint paint =
                    (symbol == MPTherionPointSymbol.entranceUIS ||
                        symbol == MPTherionPointSymbol.digUIS)
                    ? fillPaint
                    : strokePaint;

                MPTherionPointSymbolsUIS.drawMethods[symbol]!(
                  canvas,
                  center,
                  u,
                  paint,
                );
              },
            ),
          )
          .toList();

      const double cellSize = 100;

      await tester.binding.setSurfaceSize(
        Size(cellSize * entries.length, cellSize),
      );
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MPSymbolGoldenHarness(entries: entries, cellSize: cellSize),
          ),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_uis_phase1_point_symbols.png'),
      );
    });

    testWidgets('renders the gradient line arrowhead decorator', (
      WidgetTester tester,
    ) async {
      const MPGradientLineDecorator decorator = MPGradientLineDecorator();
      final Paint linePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final List<MPSymbolGoldenEntry> entries = <MPSymbolGoldenEntry>[
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Path path = Path()
              ..moveTo(center.dx - 25, center.dy + 25)
              ..lineTo(center.dx + 25, center.dy - 25);

            canvas.drawPath(path, linePaint);
            decorator.decorate(
              canvas: canvas,
              path: path,
              linePaint: THLinePaint(primaryPaint: linePaint),
              symbolUnit: const MPSymbolUnit(
                canvasScale: 1 / 3,
                devicePixelRatio: 1,
              ),
              isReversed: false,
            );
          },
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MPSymbolGoldenHarness(entries: entries, cellSize: 100),
          ),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_uis_gradient_decorator.png'),
      );
    });

    testWidgets('renders every Phase 1 area pattern tile', (
      WidgetTester tester,
    ) async {
      final List<(String name, ui.Image Function() build)> builders =
          <(String, ui.Image Function())>[
            (
              'water',
              () => MPTherionAreaPatternTilesUIS.buildWaterTile(
                const Color(0xFF0000FF),
              ),
            ),
            (
              'sump',
              () => MPTherionAreaPatternTilesUIS.buildSumpTile(
                const Color(0xFF0000FF),
              ),
            ),
            (
              'debris',
              () => MPTherionAreaPatternTilesUIS.buildDebrisTile(
                const Color(0xFF000000),
              ),
            ),
            (
              'flowstone',
              () => MPTherionAreaPatternTilesUIS.buildFlowstoneTile(
                const Color(0xFF804000),
              ),
            ),
            (
              'moonmilk',
              () => MPTherionAreaPatternTilesUIS.buildMoonmilkTile(
                const Color(0xFF804000),
              ),
            ),
          ];
      final List<MPSymbolGoldenEntry> entries = builders
          .map(
            (entry) => MPSymbolGoldenEntry(
              draw: (Canvas canvas, Offset center) {
                final ui.Image tile = entry.$2();
                final Paint paint = Paint()
                  ..shader = ImageShader(
                    tile,
                    TileMode.repeated,
                    TileMode.repeated,
                    Matrix4.identity().storage,
                  );

                canvas.drawRect(
                  Rect.fromCenter(center: center, width: 70, height: 70),
                  paint,
                );
              },
            ),
          )
          .toList();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MPSymbolGoldenHarness(entries: entries, cellSize: 100),
          ),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_uis_area_pattern_tiles.png'),
      );
    });
  });
}
