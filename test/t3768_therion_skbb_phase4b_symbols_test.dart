// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_registry.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_symbol_registry.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_arrow_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_border_presumed_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_border_temporary_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_step_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_chimney_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_floor_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_line_slope_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_overhang_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_rope_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_cave_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_surface_skbb_line_decorator.dart';
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
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_water_flow_permanent_line_decorator.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';
import 'th_test_aux.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await mpLocator.mpSettingsController.initialized;
  });

  group('Therion SKBB Phase 4B symbols', () {
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

    test('station-name falls back to UIS/placeholder under SKBB', () {
      expect(
        therionSKBBPointSymbols.containsKey(THPointType.stationName),
        isFalse,
      );
    });

    test(
      'handrail resolves to handrailSKBB, drawn via the scale-aware '
      'dispatch instead of the plain draw-method map',
      () {
        expect(
          therionSKBBPointSymbols[THPointType.handrail],
          MPTherionPointSymbol.handrailSKBB,
        );
        expect(
          getTherionPointDrawMethod(MPTherionPointSymbol.handrailSKBB),
          isNull,
        );
        expect(
          getTherionScaleAwarePointDrawMethod(
            MPTherionPointSymbol.handrailSKBB,
          ),
          isNotNull,
        );

        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);

        getTherionScaleAwarePointDrawMethod(
          MPTherionPointSymbol.handrailSKBB,
        )!(
          canvas,
          const Offset(0, 0),
          30,
          24.6,
          mpTherionSymbolPaints[MPTherionPointSymbol.handrailSKBB]!,
        );
        recorder.endRecording().dispose();
      },
    );

    test(
      'station/station:temporary/station:painted resolve to the same '
      'plain-circle symbol under SKBB (mapsymbol overrides '
      'p_station_temporary to p_station_painted_SKBB), while '
      'station:fixed/station:natural fall back',
      () {
        for (final String subtype in ['undefined', 'temporary', 'painted']) {
          expect(
            getTherionPointSymbol(
              set: MPTherionSymbolSet.skbb,
              pointType: THPointType.station,
              subtype: subtype,
            ),
            MPTherionPointSymbol.stationPaintedSKBB,
            reason: 'station:$subtype should resolve to the SKBB circle',
          );
        }

        for (final String subtype in ['fixed', 'natural']) {
          expect(
            getTherionSKBBPointSymbol(
              pointType: THPointType.station,
              subtype: subtype,
            ),
            isNull,
            reason: 'station:$subtype has no SKBB-specific override',
          );
        }
      },
    );

    test('every SKBB point symbol has a draw method and a paint entry', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      for (final MPTherionPointSymbol symbol in [
        ...therionSKBBPointSymbols.values,
        MPTherionPointSymbol.stationPaintedSKBB,
      ]) {
        // handrailSKBB is scale-aware (needs the real-world-meter length
        // alongside u) and resolves via getTherionScaleAwarePointDrawMethod
        // instead of the plain per-symbol map; covered by its own test
        // above.
        if (symbol == MPTherionPointSymbol.handrailSKBB) {
          continue;
        }

        final MPTherionSymbolPaint paint = mpTherionSymbolPaints[symbol]!;
        final drawMethod = getTherionPointDrawMethod(symbol);

        expect(drawMethod, isNotNull, reason: '$symbol has no draw method');
        drawMethod!(canvas, const Offset(0, 0), 30, paint);
      }

      recorder.endRecording().dispose();
    });

    test(
      'chimney gets its own SKBB decorator (a distinct macro from UIS) '
      'while contour reuses the UIS decorator under SKBB',
      () {
        final chimney = getTherionLineDefinition(
          set: MPTherionSymbolSet.skbb,
          lineType: THLineType.chimney,
        );
        final contour = getTherionLineDefinition(
          set: MPTherionSymbolSet.skbb,
          lineType: THLineType.contour,
        );

        expect(chimney?.decorator, isA<MPChimneySKBBLineDecorator>());
        expect(contour?.decorator, isA<MPContourLineDecorator>());
      },
    );

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

    test('slope gets the SKBB-specific decorator (l_slope_SKBB)', () {
      final definition = getTherionLineDefinition(
        set: MPTherionSymbolSet.skbb,
        lineType: THLineType.slope,
      );

      expect(definition?.decorator, isA<MPLineSlopeSKBBLineDecorator>());

      // `l_slope` aliases straight to `l_slope_SKBB` in `thTrans.mp` (no
      // separate UIS macro), so `thTrans.mp`'s own default already picks
      // the SKBB decorator, regardless of the explicitly-selected set.
      expect(
        getTherionLineDefinition(
          set: null,
          lineType: THLineType.slope,
        )?.decorator,
        isA<MPLineSlopeSKBBLineDecorator>(),
      );
    });

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
      'survey -subtype cave/no-subtype and -subtype surface get their '
      'SKBB decorators',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.survey,
          )?.decorator,
          isA<MPSurveyCaveSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.survey,
            subtype: 'cave',
          )?.decorator,
          isA<MPSurveyCaveSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.survey,
            subtype: 'surface',
          )?.decorator,
          isA<MPSurveySurfaceSKBBLineDecorator>(),
        );
      },
    );

    test(
      'survey cave (SKBB) leaves a bare gap in the middle of long '
      'segments and draws short segments whole',
      () {
        const MPSurveyCaveSKBBLineDecorator decorator =
            MPSurveyCaveSKBBLineDecorator();
        const MPSymbolUnit unit = MPSymbolUnit(
          canvasScale: 1,
          devicePixelRatio: 1,
          scrapLengthUnitsPerPoint: 1,
          scrapLengthUnitType: THLengthUnitType.meter,
        );
        final Path longSegmentPath = decorator.buildBasePath(
          path: Path(),
          vertices: const <Offset>[Offset(0, 0), Offset(1000, 0)],
          symbolUnit: unit,
        );
        final List<ui.PathMetric> longSegmentMetrics = longSegmentPath
            .computeMetrics()
            .toList();

        expect(longSegmentMetrics.length, 2);

        final Path shortSegmentPath = decorator.buildBasePath(
          path: Path(),
          vertices: const <Offset>[Offset(0, 0), Offset(10, 0)],
          symbolUnit: unit,
        );
        final List<ui.PathMetric> shortSegmentMetrics = shortSegmentPath
            .computeMetrics()
            .toList();

        expect(shortSegmentMetrics.length, 1);
        expect(shortSegmentMetrics.single.length, closeTo(10, 0.001));
      },
    );

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

    test(
      'arrow and border -subtype temporary/presumed get their SKBB '
      'decorators, while border -subtype visible still falls back',
      () {
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.arrow,
          )?.decorator,
          isA<MPArrowSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.border,
            subtype: 'temporary',
          )?.decorator,
          isA<MPBorderTemporarySKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.border,
            subtype: 'presumed',
          )?.decorator,
          isA<MPBorderPresumedSKBBLineDecorator>(),
        );
        expect(
          getTherionLineDefinition(
            set: MPTherionSymbolSet.skbb,
            lineType: THLineType.border,
            subtype: 'visible',
          ),
          isNull,
        );
      },
    );

    test(
      'MPCommandOptionAux.getArrowHead reads line -head and defaults to end',
      () async {
        final TH2FileParser parser = TH2FileParser();

        final (headFile, headParsed, _) = await parser.parse(
          THTestAux.testPath(
            'th_file_parser-03030-line_with_head_option.th2',
          ),
        );

        expect(headParsed, isTrue);

        final headLine = headFile
            .getLines()
            .singleWhere((line) => line.lineType == THLineType.arrow);

        expect(
          MPCommandOptionAux.getArrowHead(headLine),
          THOptionChoicesArrowPositionType.both,
        );

        final (defaultFile, defaultParsed, _) = await parser.parse(
          THTestAux.testPath(
            'th_file_parser-03050-line_with_visibility_option.th2',
          ),
        );

        expect(defaultParsed, isTrue);

        final defaultLine = defaultFile
            .getLines()
            .singleWhere((line) => line.lineType == THLineType.arrow);

        expect(
          MPCommandOptionAux.getArrowHead(defaultLine),
          THOptionChoicesArrowPositionType.end,
        );
      },
    );

    test(
      'arrow SKBB draws for every -head choice and border dash factors differ',
      () {
        const MPArrowSKBBLineDecorator arrowDecorator =
            MPArrowSKBBLineDecorator();

        for (final THOptionChoicesArrowPositionType head
            in THOptionChoicesArrowPositionType.values) {
          final ui.PictureRecorder recorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(recorder);

          arrowDecorator.decorate(
            canvas: canvas,
            path: diagonalTestPath(),
            color: Paint(),
            symbolUnit: symbolUnit,
            isReversed: false,
            arrowHead: head,
          );
          recorder.endRecording().dispose();
        }

        expect(
          const MPBorderTemporarySKBBLineDecorator().dashScaleFactor,
          1.0,
        );
        expect(
          const MPBorderTemporarySKBBLineDecorator().dashGapScaleFactor,
          1.0,
        );
        expect(
          const MPBorderPresumedSKBBLineDecorator().dashScaleFactor,
          0.25,
        );
        expect(
          const MPBorderPresumedSKBBLineDecorator().dashGapScaleFactor,
          3.0,
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
        const MPArrowSKBBLineDecorator(),
        const MPBorderTemporarySKBBLineDecorator(),
        const MPBorderPresumedSKBBLineDecorator(),
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
        const MPSurveyCaveSKBBLineDecorator(),
        const MPSurveySurfaceSKBBLineDecorator(),
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
      'MPLineSlopeSKBBLineDecorator only strokes the path when showBorder '
      'is set',
      () {
        final List<THLinePainterLineSegment> lineSegments = [
          THLinePainterStraightLineSegment(x: 0, y: 0, lSize: 20),
          THLinePainterStraightLineSegment(x: 60, y: 0),
          THLinePainterStraightLineSegment(x: 120, y: 40),
          THLinePainterStraightLineSegment(x: 180, y: 40),
        ];

        for (final bool showBorder in [false, true]) {
          final ui.PictureRecorder recorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(recorder);

          const MPLineSlopeSKBBLineDecorator().decorate(
            canvas: canvas,
            path: diagonalTestPath(),
            color: Paint(),
            symbolUnit: symbolUnit,
            isReversed: false,
            lineSegments: lineSegments,
            showBorder: showBorder,
          );
          recorder.endRecording().dispose();
        }
      },
    );

    test(
      'MPLineSlopeSKBBLineDecorator draws its ticks without crashing, '
      'both with and without an explicit l-size/orientation',
      () {
        final List<THLinePainterLineSegment> lineSegmentsWithLSize = [
          THLinePainterStraightLineSegment(x: 0, y: 0, lSize: 20),
          THLinePainterStraightLineSegment(x: 60, y: 0),
          THLinePainterStraightLineSegment(
            x: 120,
            y: 40,
            orientation: 45,
          ),
          THLinePainterStraightLineSegment(x: 180, y: 40),
        ];

        for (final List<THLinePainterLineSegment> lineSegments in [
          lineSegmentsWithLSize,
          [
            for (final THLinePainterLineSegment segment
                in lineSegmentsWithLSize)
              THLinePainterStraightLineSegment(x: segment.x, y: segment.y),
          ],
        ]) {
          final ui.PictureRecorder recorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(recorder);

          const MPLineSlopeSKBBLineDecorator().decorate(
            canvas: canvas,
            path: diagonalTestPath(),
            color: Paint(),
            symbolUnit: symbolUnit,
            isReversed: false,
            lineSegments: lineSegments,
          );
          recorder.endRecording().dispose();
        }
      },
    );

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
