// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'auxiliary/mp_symbol_golden_harness.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
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
    test('water hatch uses the increased line spacing', () {
      final ui.Image tile = MPTherionAreaPatternTilesUIS.buildWaterTile(
        const Color(0xFF0000FF),
      );

      final int expectedTileSize =
          (mpTherionUISWaterCellUnits * mpTherionAreaPatternTileUnitPixels)
              .round();

      expect(tile.width, expectedTileSize);
      expect(tile.height, expectedTileSize);
    });

    test('debris pattern uses the increased tick count', () {
      expect(mpTherionUISDebrisTicks, hasLength(6));
    });

    test('moonmilk pattern uses the Therion tile dimensions', () {
      final ui.Image tile = MPTherionAreaPatternTilesUIS.buildMoonmilkTile(
        const Color(0xFF804000),
      );

      expect(
        tile.width,
        (mpTherionUISMoonmilkCellXUnits *
                mpTherionAreaPatternTileUnitPixels)
            .round(),
      );
      expect(
        tile.height,
        (mpTherionUISMoonmilkCellYUnits *
                mpTherionAreaPatternTileUnitPixels)
            .round(),
      );
      expect(mpTherionUISMoonmilkScallopXUnits, hasLength(4));
    });

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
      const Set<MPTherionPointSymbol> phase1Symbols = <MPTherionPointSymbol>{
        MPTherionPointSymbol.continuationUIS,
        MPTherionPointSymbol.crystalUIS,
        MPTherionPointSymbol.digUIS,
        MPTherionPointSymbol.entranceUIS,
        MPTherionPointSymbol.flowstoneUIS,
        MPTherionPointSymbol.fluteUIS,
        MPTherionPointSymbol.iceUIS,
        MPTherionPointSymbol.karrenUIS,
        MPTherionPointSymbol.lowEndUIS,
        MPTherionPointSymbol.narrowEndUIS,
        MPTherionPointSymbol.pillarUIS,
        MPTherionPointSymbol.sandUIS,
        MPTherionPointSymbol.sodaStrawUIS,
        MPTherionPointSymbol.stalactiteUIS,
        MPTherionPointSymbol.stalagmiteUIS,
        MPTherionPointSymbol.wallCalciteUIS,
      };
      final List<MPSymbolGoldenEntry> entries = MPTherionPointSymbol.values
          .where(phase1Symbols.contains)
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

    test(
      'pillar draws nothing on the fill pass, unlike a fill-and-stroke symbol',
      () async {
        // p_pillar_UIS (thPoint.mp) only thdraw's open V-shaped strokes, no
        // thfill; MPInteractionAux._drawTherionPoint calls every symbol's
        // draw method once with a fill-style Paint and once with a
        // stroke-style one, so a symbol with unclosed subpaths must skip
        // the fill pass itself, or Skia's implicit-close-on-fill turns
        // those open V's into solid filled triangles.
        const double imageSize = 100;
        final void Function(Canvas, Offset, double, Paint) drawMethod =
            MPTherionPointSymbolsUIS.drawMethods[MPTherionPointSymbol
                .pillarUIS]!;

        Future<int> countDarkPixels(Paint paint) async {
          final ui.PictureRecorder recorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(recorder);

          drawMethod(canvas, const Offset(50, 50), 30, paint);

          final ui.Picture picture = recorder.endRecording();
          final ui.Image image = await picture.toImage(
            imageSize.toInt(),
            imageSize.toInt(),
          );
          final ByteData pixels = (await image.toByteData())!;
          int darkPixelCount = 0;

          for (int i = 3; i < pixels.lengthInBytes; i += 4) {
            if (pixels.getUint8(i) > 0) {
              darkPixelCount++;
            }
          }

          image.dispose();
          picture.dispose();

          return darkPixelCount;
        }

        final Paint fillPaint = Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.fill;
        final Paint strokePaint = Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        expect(await countDarkPixels(fillPaint), 0);
        expect(await countDarkPixels(strokePaint), greaterThan(0));
      },
    );

    testWidgets('renders the continuous gradient line and arrowhead', (
      WidgetTester tester,
    ) async {
      const double goldenSymbolUnitOnScreen = 10;

      mpLocator.mpSettingsController.setDouble(
        MPSettingID.TH2Edit_SymbolUnit,
        goldenSymbolUnitOnScreen,
      );
      addTearDown(
        () => mpLocator.mpSettingsController.resetDouble(
          MPSettingID.TH2Edit_SymbolUnit,
        ),
      );

      const MPGradientLineDecorator decorator = MPGradientLineDecorator();
      final Paint linePaint = Paint.from(THPaint.thPaint12);
      final List<MPSymbolGoldenEntry> entries = <MPSymbolGoldenEntry>[
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final Path path = Path()
              ..moveTo(center.dx - 25, center.dy + 25)
              ..lineTo(center.dx + 25, center.dy - 25);

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
