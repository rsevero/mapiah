// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_aut/mp_flowstone_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_pit_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_survey_cave_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_therion_aut_line_map.dart';
import 'package:mapiah/src/painters/therion_aut/mp_therion_aut_point_map.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_blocks_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_debris_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_flowstone_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_ice_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_moonmilk_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_overlying_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_pebbles_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_pit_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_sand_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_underlying_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_symbol_registry.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_meander_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_pit_floor_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await mpLocator.mpSettingsController.initialized;
  });

  group('Therion AUT Phase 4C symbols', () {
    const MPSymbolUnit symbolUnit = MPSymbolUnit(
      canvasScale: 1,
      devicePixelRatio: 1,
      scrapLengthUnitsPerPoint: 1,
      scrapLengthUnitType: THLengthUnitType.meter,
    );

    Path diagonalTestPath() => Path()
      ..moveTo(0, 0)
      ..lineTo(60, 0)
      ..lineTo(120, 40)
      ..lineTo(180, 40);

    test('maps every AUT point type to its own symbol', () {
      for (final MapEntry<THPointType, MPTherionPointSymbol> entry
          in therionAUTPointSymbols.entries) {
        expect(
          getTherionPointSymbol(
            set: MPTherionSymbolSet.aut,
            pointType: entry.key,
            subtype: 'undefined',
          ),
          entry.value,
          reason: '${entry.key} should resolve to ${entry.value}',
        );
      }
    });

    test(
      'station/station:temporary resolve to the AUT circle, while '
      'station:painted/fixed/natural fall through (aliased to the '
      'unported p_station_fixed_ASF)',
      () {
        for (final String subtype in [mpNoSubtypeID, 'temporary']) {
          expect(
            getTherionAUTPointSymbol(
              pointType: THPointType.station,
              subtype: subtype,
            ),
            MPTherionPointSymbol.stationTemporaryAUT,
            reason: 'station:$subtype should resolve to the AUT circle',
          );
        }

        for (final String subtype in ['painted', 'fixed', 'natural']) {
          expect(
            getTherionAUTPointSymbol(
              pointType: THPointType.station,
              subtype: subtype,
            ),
            isNull,
            reason: 'station:$subtype has no AUT-specific override',
          );
        }
      },
    );

    test('every AUT point symbol has a draw method and a paint entry', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      for (final MPTherionPointSymbol symbol in [
        ...therionAUTPointSymbols.values,
        MPTherionPointSymbol.stationTemporaryAUT,
      ]) {
        final MPTherionSymbolPaint paint = mpTherionSymbolPaints[symbol]!;
        final drawMethod = getTherionPointDrawMethod(symbol);

        expect(drawMethod, isNotNull, reason: '$symbol has no draw method');
        drawMethod!(canvas, const Offset(0, 0), 30, paint);
      }

      recorder.endRecording().dispose();
    });

    test(
      'pit and overhang share the same AUT decorator (l_overhang_AUT is '
      'let-aliased to l_pit_AUT)',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.pit,
          )?.decorator,
          isA<MPPitAUTLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.overhang,
          )?.decorator,
          isA<MPPitAUTLineDecorator>(),
        );
      },
    );

    test(
      'floorStep/contour/ceilingStep/ceilingMeander reuse the already-'
      'ported UIS/SKBB decorators under AUT (uAUT.mp let-aliases them)',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.floorStep,
          )?.decorator,
          isA<MPPitFloorStepLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.contour,
          )?.decorator,
          isA<MPContourLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.ceilingStep,
          )?.decorator,
          isA<MPCeilingStepLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.aut,
            lineType: THLineType.ceilingMeander,
          )?.decorator,
          isA<MPCeilingMeanderLineDecorator>(),
        );
      },
    );

    test('flowstone (standalone) and survey -subtype cave get AUT decorators', () {
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.flowstone,
        )?.decorator,
        isA<MPFlowstoneAUTLineDecorator>(),
      );
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.survey,
        )?.decorator,
        isA<MPSurveyCaveAUTLineDecorator>(),
      );
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.survey,
          subtype: 'cave',
        )?.decorator,
        isA<MPSurveyCaveAUTLineDecorator>(),
      );
      // `survey -subtype surface` has no AUT macro at all, so it falls
      // through to thTrans.mp's own SKBB default.
      expect(
        getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.survey,
          subtype: 'surface',
        )?.decorator,
        isNot(isA<MPSurveyCaveAUTLineDecorator>()),
      );
    });

    test(
      'wall -subtype pit/sand/clay/pebbles/debris/blocks/ice/underlying/'
      'overlying/moonmilk/flowstone get their AUT decorators, other wall '
      'subtypes fall back through thTrans.mp default/UIS/placeholder',
      () {
        const Map<String, Type> expectedDecorators = {
          'pit': MPWallPitAUTLineDecorator,
          'sand': MPWallSandAUTLineDecorator,
          'clay': MPWallSandAUTLineDecorator,
          'pebbles': MPWallPebblesAUTLineDecorator,
          'debris': MPWallDebrisAUTLineDecorator,
          'blocks': MPWallBlocksAUTLineDecorator,
          'ice': MPWallIceAUTLineDecorator,
          'underlying': MPWallUnderlyingAUTLineDecorator,
          'overlying': MPWallOverlyingAUTLineDecorator,
          'moonmilk': MPWallMoonmilkAUTLineDecorator,
          'flowstone': MPWallFlowstoneAUTLineDecorator,
        };

        for (final MapEntry<String, Type> entry
            in expectedDecorators.entries) {
          expect(
            getTherionLineDefinition(
              set: MPTherionSymbolSet.aut,
              lineType: THLineType.wall,
              subtype: entry.key,
            )?.decorator.runtimeType,
            entry.value,
            reason: 'wall -subtype ${entry.key}',
          );
        }

        expect(
          getTherionAUTLineDefinition(
            lineType: THLineType.wall,
            subtype: 'bedrock',
          ),
          isNull,
        );
      },
    );

    test('every new AUT line decorator draws without crashing', () {
      for (final decorator in [
        const MPPitAUTLineDecorator(),
        const MPWallPitAUTLineDecorator(),
        const MPWallSandAUTLineDecorator(),
        const MPWallPebblesAUTLineDecorator(),
        const MPWallDebrisAUTLineDecorator(),
        const MPWallBlocksAUTLineDecorator(),
        const MPWallIceAUTLineDecorator(),
        const MPWallUnderlyingAUTLineDecorator(),
        const MPWallOverlyingAUTLineDecorator(),
        const MPWallMoonmilkAUTLineDecorator(),
        const MPWallFlowstoneAUTLineDecorator(),
        const MPFlowstoneAUTLineDecorator(),
        const MPSurveyCaveAUTLineDecorator(),
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

    test(
      'every AUT area pattern tile resolves and builds without crashing',
      () {
        for (final THAreaType areaType in [
          THAreaType.water,
          THAreaType.sump,
          THAreaType.sand,
          THAreaType.clay,
          THAreaType.pebbles,
          THAreaType.debris,
          THAreaType.ice,
          THAreaType.snow,
          THAreaType.blocks,
          THAreaType.flowstone,
        ]) {
          final definition = getTherionAreaPatternDefinition(
            set: MPTherionSymbolSet.aut,
            areaType: areaType,
          );

          expect(definition, isNotNull, reason: '$areaType');

          final ui.Image tile = definition!.tileBuilder(definition.color);

          expect(tile.width, greaterThan(0));
          tile.dispose();
        }
      },
    );

    test(
      'an AUT-undecorated line type falls back through thTrans.mp default/UIS',
      () {
        // THLineType.gradient has no AUT entry, so it must resolve the
        // same way the therionDefault (no explicit set) chain does.
        final aut = getTherionLineDefinition(
          set: MPTherionSymbolSet.aut,
          lineType: THLineType.gradient,
        );
        final defaultChain = getTherionLineDefinition(
          set: null,
          lineType: THLineType.gradient,
        );

        expect(aut?.decorator.runtimeType, defaultChain?.decorator.runtimeType);
      },
    );
  });
}
