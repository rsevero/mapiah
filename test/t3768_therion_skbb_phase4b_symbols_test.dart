// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_symbol_registry.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_step_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_floor_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_overhang_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_rope_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_point_map.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_via_ferrata_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_blocks_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_clay_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_debris_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_ice_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_pebbles_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_sand_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_unsurveyed_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_water_flow_conjectural_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_water_flow_intermittent_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_chimney_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_water_flow_permanent_line_decorator.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await mpLocator.mpSettingsController.initialized;
  });

  group('Therion SKBB Phase 4B symbols', () {
    const MPSymbolUnit symbolUnit = MPSymbolUnit(
      canvasScale: 1,
      devicePixelRatio: 1,
    );

    Path diagonalTestPath() => Path()
      ..moveTo(0, 0)
      ..lineTo(60, 0)
      ..lineTo(120, 40)
      ..lineTo(180, 40);

    test('maps every SKBB point type to its own symbol', () {
      for (final MapEntry<THPointType, MPTherionPointSymbol> entry
          in therionSKBBPointSymbols.entries) {
        expect(
          getTherionPointSymbol(
            set: MPTherionSymbolSet.skbb,
            pointType: entry.key,
            subtype: 'undefined',
          ),
          entry.value,
          reason: '${entry.key} should resolve to ${entry.value}',
        );
      }
    });

    test(
      'station/station-name/handrail fall back to UIS/placeholder under SKBB',
      () {
        for (final THPointType pointType in [
          THPointType.station,
          THPointType.stationName,
          THPointType.handrail,
        ]) {
          expect(therionSKBBPointSymbols.containsKey(pointType), isFalse);
        }
      },
    );

    test('every SKBB point symbol has a draw method and a paint entry', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      for (final MPTherionPointSymbol symbol
          in therionSKBBPointSymbols.values) {
        final MPTherionSymbolPaint paint = mpTherionSymbolPaints[symbol]!;
        final drawMethod = getTherionPointDrawMethod(symbol);

        expect(drawMethod, isNotNull, reason: '$symbol has no draw method');
        drawMethod!(canvas, const Offset(0, 0), 30, paint);
      }

      recorder.endRecording().dispose();
    });

    test('chimney and contour reuse the UIS decorator under SKBB', () {
      final chimney = getTherionLineDefinition(
        set: MPTherionSymbolSet.skbb,
        lineType: THLineType.chimney,
      );
      final contour = getTherionLineDefinition(
        set: MPTherionSymbolSet.skbb,
        lineType: THLineType.contour,
      );

      expect(chimney?.decorator, isA<MPChimneyLineDecorator>());
      expect(contour?.decorator, isA<MPContourLineDecorator>());
    });

    test(
      'ceilingStep/ceilingMeander/floorMeander/overhang get SKBB-specific '
      'decorators',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.ceilingStep,
          )?.decorator,
          isA<MPCeilingStepSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.ceilingMeander,
          )?.decorator,
          isA<MPCeilingMeanderSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.floorMeander,
          )?.decorator,
          isA<MPFloorMeanderSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.overhang,
          )?.decorator,
          isA<MPOverhangSKBBLineDecorator>(),
        );
      },
    );

    test('ropeLadder/viaFerrata get their SKBB decorators', () {
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.skbb,
          lineType: THLineType.ropeLadder,
        )?.decorator,
        isA<MPRopeLadderSKBBLineDecorator>(),
      );
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.skbb,
          lineType: THLineType.viaFerrata,
        )?.decorator,
        isA<MPViaFerrataSKBBLineDecorator>(),
      );
    });

    test(
      'waterFlow -subtype conjectural/intermittent get their SKBB '
      'decorators, permanent/no-subtype keep the shared UIS decorator',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.waterFlow,
            subtype: 'conjectural',
          )?.decorator,
          isA<MPWaterFlowConjecturalSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.waterFlow,
            subtype: 'intermittent',
          )?.decorator,
          isA<MPWaterFlowIntermittentSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.waterFlow,
          )?.decorator,
          isA<MPWaterFlowPermanentLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.waterFlow,
            subtype: 'permanent',
          )?.decorator,
          isA<MPWaterFlowPermanentLineDecorator>(),
        );
      },
    );

    test(
      'wall -subtype sand/pebbles/clay/debris/blocks/ice/unsurveyed get '
      'their SKBB decorators, other wall subtypes fall back to the '
      'placeholder (no decorator)',
      () {
        const Map<String, Type> expectedDecorators = {
          'sand': MPWallSandSKBBLineDecorator,
          'pebbles': MPWallPebblesSKBBLineDecorator,
          'clay': MPWallClaySKBBLineDecorator,
          'debris': MPWallDebrisSKBBLineDecorator,
          'blocks': MPWallBlocksSKBBLineDecorator,
          'ice': MPWallIceSKBBLineDecorator,
          'unsurveyed': MPWallUnsurveyedSKBBLineDecorator,
        };

        for (final MapEntry<String, Type> entry
            in expectedDecorators.entries) {
          expect(
            getTherionLineDefinition(
              set: MPTherionSymbolSet.skbb,
              lineType: THLineType.wall,
              subtype: entry.key,
            )?.decorator.runtimeType,
            entry.value,
            reason: 'wall -subtype ${entry.key}',
          );
        }

        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.wall,
            subtype: 'bedrock',
          ),
          isNull,
        );
      },
    );

    test('an SKBB-undecorated line type falls back to UIS', () {
      // THLineType.gradient has no SKBB entry, so it must resolve to the
      // same decorator UIS uses.
      final skbb = getTherionLineDefinition(
        set: MPTherionSymbolSet.skbb,
        lineType: THLineType.gradient,
      );
      final uis = getTherionLineDefinition(
        set: MPTherionSymbolSet.uis,
        lineType: THLineType.gradient,
      );

      expect(skbb?.decorator.runtimeType, uis?.decorator.runtimeType);
    });

    test('every new SKBB line decorator draws without crashing', () {
      for (final decorator in [
        const MPCeilingStepSKBBLineDecorator(),
        const MPCeilingMeanderSKBBLineDecorator(),
        const MPFloorMeanderSKBBLineDecorator(),
        const MPOverhangSKBBLineDecorator(),
        const MPWaterFlowConjecturalSKBBLineDecorator(),
        const MPWaterFlowIntermittentSKBBLineDecorator(),
        const MPWallSandSKBBLineDecorator(),
        const MPWallPebblesSKBBLineDecorator(),
        const MPWallClaySKBBLineDecorator(),
        const MPWallDebrisSKBBLineDecorator(),
        const MPWallBlocksSKBBLineDecorator(),
        const MPWallIceSKBBLineDecorator(),
        const MPWallUnsurveyedSKBBLineDecorator(),
        const MPRopeLadderSKBBLineDecorator(),
        const MPViaFerrataSKBBLineDecorator(),
      ]) {
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);

        decorator.decorate(
          canvas: canvas,
          path: diagonalTestPath(),
          color: Paint(),
          symbolUnit: symbolUnit,
          isReversed: false,
        );
        recorder.endRecording().dispose();
      }
    });

    test('every SKBB area pattern tile resolves and builds without '
        'crashing', () {
      for (final THAreaType areaType in [
        THAreaType.water,
        THAreaType.sump,
        THAreaType.clay,
        THAreaType.ice,
        THAreaType.snow,
        THAreaType.blocks,
        THAreaType.pebbles,
        THAreaType.debris,
      ]) {
        final definition = getTherionAreaPatternDefinition(
          set: MPTherionSymbolSet.skbb,
          areaType: areaType,
        );

        expect(definition, isNotNull, reason: '$areaType');

        final ui.Image tile = definition!.tileBuilder(definition.color);

        expect(tile.width, greaterThan(0));
        tile.dispose();
      }
    });

    test('bedrock stays unpatterned under SKBB (a_bedrock_SKBB is bare '
        'thclean)', () {
      expect(
        getTherionAreaPatternDefinition(
          set: MPTherionSymbolSet.skbb,
          areaType: THAreaType.bedrock,
        ),
        isNull,
      );
    });
  });
}
