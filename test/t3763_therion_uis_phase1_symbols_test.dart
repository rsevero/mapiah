// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'auxiliary/mp_symbol_golden_harness.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_uis/mp_area_pattern_tiles.dart';
import 'package:mapiah/src/painters/therion_uis/mp_gradient_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_line_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
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
                final MPTherionSymbolPaint paint =
                    (symbol == MPTherionPointSymbol.entranceUIS ||
                        symbol == MPTherionPointSymbol.digUIS)
                    ? MPTherionSymbolPaint(fill: fillPaint)
                    : MPTherionSymbolPaint(border: strokePaint);

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
      'mpTherionSymbolPaints has exactly one entry per MPTherionPointSymbol',
      () {
        expect(
          mpTherionSymbolPaints.keys.toSet(),
          MPTherionPointSymbol.values.toSet(),
        );
      },
    );

    test(
      'mpTherionSymbolPaints only declares a fill for the 10 symbols whose '
      'macro actually thfills something',
      () {
        // p_popcorn_UIS, p_water_UIS, p_paleomaterial_UIS, p_entrance_UIS,
        // p_waterflow_paleo_UIS, p_gradient_UIS, p_waterflow_permanent_UIS,
        // p_camp_UIS, and p_dig_UIS all thfill directly;
        // p_waterflow_intermittent_UIS has no literal thfill but delegates
        // to p_waterflow_permanent_UIS's fill. Every other p_*_UIS macro
        // only thdraws, so mpTherionSymbolPaints leaves its fill null for
        // them — MPTherionPointSymbolsUIS's draw methods rely on that to
        // know a fill pass never happens for them, with no runtime guard.
        const Set<MPTherionPointSymbol> fillUsingSymbols =
            <MPTherionPointSymbol>{
              MPTherionPointSymbol.campUIS,
              MPTherionPointSymbol.digUIS,
              MPTherionPointSymbol.entranceUIS,
              MPTherionPointSymbol.gradientUIS,
              MPTherionPointSymbol.paleoMaterialUIS,
              MPTherionPointSymbol.popcornUIS,
              MPTherionPointSymbol.waterFlowIntermittentUIS,
              MPTherionPointSymbol.waterFlowPaleoUIS,
              MPTherionPointSymbol.waterFlowPermanentUIS,
              MPTherionPointSymbol.waterUIS,
              // Phase 4B SKBB: p_borehole_SKBB thfill's its inner circle,
              // p_noequipment_SKBB thfill's its warning triangle.
              MPTherionPointSymbol.boreholeSKBB,
              MPTherionPointSymbol.noEquipmentSKBB,
            };

        for (final MPTherionPointSymbol symbol
            in MPTherionPointSymbol.values) {
          final bool hasFill = mpTherionSymbolPaints[symbol]!.fill != null;

          expect(
            hasFill,
            fillUsingSymbols.contains(symbol),
            reason: '$symbol',
          );
        }

        // paleoMaterial is the one fill-only symbol (p_paleomaterial_UIS
        // has no thdraw at all).
        expect(
          mpTherionSymbolPaints[MPTherionPointSymbol.paleoMaterialUIS]!
              .border,
          isNull,
        );
        expect(
          mpTherionSymbolPaints[MPTherionPointSymbol.pillarUIS]!.fill,
          isNull,
        );
        expect(
          mpTherionSymbolPaints[MPTherionPointSymbol.pillarUIS]!.border,
          isNotNull,
        );
      },
    );

    test(
      'mpTherionLineColors has exactly one entry per decorator-covered '
      'THLineType (UIS or SKBB-only)',
      () {
        // Mirrors MPVisualControllerBase.getLineDecorator's switch: every
        // THLineType a line decorator exists for, and no others.
        const Set<THLineType> uisDecoratedLineTypes = <THLineType>{
          THLineType.ceilingMeander,
          THLineType.ceilingStep,
          THLineType.chimney,
          THLineType.contour,
          THLineType.floorStep,
          THLineType.pit,
          THLineType.pitch,
          THLineType.flowstone,
          THLineType.gradient,
          THLineType.moonmilk,
          THLineType.rockEdge,
          THLineType.survey,
          THLineType.waterFlow,
        };
        // These have no UIS decorator/macro of their own (Therion aliases
        // their set-neutral macro straight to the SKBB definition, or —
        // for `wall` — the placeholder covers UIS while SKBB subtypes get
        // real decorators), so their color entry is used only by the
        // SKBB-specific decorators sharing this same map; see
        // mpTherionLineColors' own doc comment.
        const Set<THLineType> skbbOnlyDecoratedLineTypes = <THLineType>{
          THLineType.arrow,
          THLineType.border,
          THLineType.fixedLadder,
          THLineType.handrail,
          THLineType.mapConnection,
          THLineType.rope,
          THLineType.ropeLadder,
          THLineType.slope,
          THLineType.steps,
          THLineType.viaFerrata,
          THLineType.wall,
        };

        expect(
          mpTherionLineColors.keys.toSet(),
          uisDecoratedLineTypes.union(skbbOnlyDecoratedLineTypes),
        );
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
              color: linePaint,
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
