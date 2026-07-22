// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'auxiliary/mp_symbol_golden_harness.dart';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_uis/mp_area_pattern_tiles.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_meander_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_chimney_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_flowstone_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_moonmilk_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_pit_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_point_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_water_flow_permanent_line_decorator.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  // MPSymbolUnit.canvasValue reads the symbol-unit setting, so the settings
  // controller (with its async Therion-availability check) must finish
  // initializing before any testWidgets() runs, or its still-pending
  // process-spawn future trips the "timer pending after dispose" assertion.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await mpLocator.mpSettingsController.initialized;
  });

  group('Therion UIS Phase 3 point symbols', () {
    const List<MPTherionPointSymbol> phase3Symbols = <MPTherionPointSymbol>[
      MPTherionPointSymbol.airDraughtUIS,
      MPTherionPointSymbol.airDraughtWinterUIS,
      MPTherionPointSymbol.airDraughtSummerUIS,
      MPTherionPointSymbol.blocksUIS,
      MPTherionPointSymbol.pillarsUIS,
      MPTherionPointSymbol.stalactitesUIS,
      MPTherionPointSymbol.stalagmitesUIS,
      MPTherionPointSymbol.waterUIS,
    ];

    test('registers and draws every complex point symbol', () {
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke;
      final Paint fillPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill;

      for (int index = 0; index < phase3Symbols.length; index++) {
        final MPTherionPointSymbol symbol = phase3Symbols[index];
        final void Function(Canvas, Offset, double, Paint)? drawMethod =
            MPTherionPointSymbolsUIS.drawMethods[symbol];

        expect(drawMethod, isNotNull, reason: '$symbol has no draw method');

        final Offset position = Offset(index * 40.0, 20);

        drawMethod!(canvas, position, 30, fillPaint);
        drawMethod(canvas, position, 30, strokePaint);
      }

      final ui.Picture picture = recorder.endRecording();

      expect(picture, isNotNull);
      picture.dispose();
    });

    testWidgets('renders every Phase 3 point symbol', (
      WidgetTester tester,
    ) async {
      const double cellSize = 100;
      const double u = 30;
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke;
      final Paint fillPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill;
      final List<MPSymbolGoldenEntry> entries = phase3Symbols
          .map(
            (MPTherionPointSymbol symbol) => MPSymbolGoldenEntry(
              draw: (Canvas canvas, Offset center) {
                final void Function(Canvas, Offset, double, Paint) drawMethod =
                    MPTherionPointSymbolsUIS.drawMethods[symbol]!;

                drawMethod(canvas, center, u, fillPaint);
                drawMethod(canvas, center, u, strokePaint);
              },
            ),
          )
          .toList();

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
        matchesGoldenFile('goldens/therion_uis_phase3_point_symbols.png'),
      );
    });

    test('maps every non-subtyped Phase 3 point type', () {
      const Map<THPointType, MPTherionPointSymbol> expected =
          <THPointType, MPTherionPointSymbol>{
            THPointType.blocks: MPTherionPointSymbol.blocksUIS,
            THPointType.pillars: MPTherionPointSymbol.pillarsUIS,
            THPointType.stalactites: MPTherionPointSymbol.stalactitesUIS,
            THPointType.stalagmites: MPTherionPointSymbol.stalagmitesUIS,
            THPointType.water: MPTherionPointSymbol.waterUIS,
          };

      for (final MapEntry<THPointType, MPTherionPointSymbol> entry
          in expected.entries) {
        expect(therionUISPointSymbols[entry.key], entry.value);
      }
    });

    test('resolves all air-draught subtypes', () {
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.airDraught,
          subtype: 'winter',
        ),
        MPTherionPointSymbol.airDraughtWinterUIS,
      );
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.airDraught,
          subtype: 'summer',
        ),
        MPTherionPointSymbol.airDraughtSummerUIS,
      );
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.airDraught,
          subtype: 'undefined',
        ),
        MPTherionPointSymbol.airDraughtUIS,
      );
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.airDraught,
          subtype: 'anything-else',
        ),
        MPTherionPointSymbol.airDraughtUIS,
      );
    });
  });

  group('Therion UIS Phase 3 line decorators', () {
    Path diagonalTestPath() =>
        Path()
          ..moveTo(0, 0)
          ..lineTo(80, 0)
          ..lineTo(80, 80);

    const MPSymbolUnit symbolUnit = MPSymbolUnit(
      canvasScale: 1,
      devicePixelRatio: 1,
    );

    test('pit decorator draws ticks without crashing', () {
      const MPPitLineDecorator decorator = MPPitLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('chimney decorator draws ticks without crashing', () {
      const MPChimneyLineDecorator decorator = MPChimneyLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('ceiling step decorator draws ticks without crashing', () {
      const MPCeilingStepLineDecorator decorator =
          MPCeilingStepLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('ceiling meander decorator draws rungs without crashing', () {
      const MPCeilingMeanderLineDecorator decorator =
          MPCeilingMeanderLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('contour decorator draws a midpoint tick without crashing', () {
      const MPContourLineDecorator decorator = MPContourLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('flowstone decorator draws curls without crashing', () {
      const MPFlowstoneLineDecorator decorator = MPFlowstoneLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test('moonmilk decorator draws curls without crashing', () {
      const MPMoonmilkLineDecorator decorator = MPMoonmilkLineDecorator();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: diagonalTestPath(),
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: symbolUnit,
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });

    test(
      'water-flow permanent decorator draws a stable meander and arrowhead',
      () {
        const MPWaterFlowPermanentLineDecorator decorator =
            MPWaterFlowPermanentLineDecorator();
        final ui.PictureRecorder recorderA = ui.PictureRecorder();
        final Canvas canvasA = Canvas(recorderA);

        decorator.decorate(
          canvas: canvasA,
          path: diagonalTestPath(),
          linePaint: THLinePaint(primaryPaint: Paint()),
          symbolUnit: symbolUnit,
          isReversed: false,
          mpID: 42,
        );

        final ui.Picture pictureA = recorderA.endRecording();

        final ui.PictureRecorder recorderB = ui.PictureRecorder();
        final Canvas canvasB = Canvas(recorderB);

        decorator.decorate(
          canvas: canvasB,
          path: diagonalTestPath(),
          linePaint: THLinePaint(primaryPaint: Paint()),
          symbolUnit: symbolUnit,
          isReversed: false,
          mpID: 42,
        );

        final ui.Picture pictureB = recorderB.endRecording();

        expect(pictureA, isNotNull);
        expect(pictureB, isNotNull);
        pictureA.dispose();
        pictureB.dispose();
      },
    );
  });

  group('Therion UIS Phase 3 sand area pattern', () {
    testWidgets('renders the sand area pattern tile', (
      WidgetTester tester,
    ) async {
      final List<MPSymbolGoldenEntry> entries = <MPSymbolGoldenEntry>[
        MPSymbolGoldenEntry(
          draw: (Canvas canvas, Offset center) {
            final ui.Image tile = MPTherionAreaPatternTilesUIS.buildSandTile(
              const Color(0xFF7F5500),
            );
            final Paint paint = Paint()
              ..shader = ImageShader(
                tile,
                TileMode.repeated,
                TileMode.repeated,
                // Scale the shader down so this preview shows several tile
                // repeats instead of a fraction of one oversized tile.
                Matrix4.diagonal3Values(0.4, 0.4, 1).storage,
              );

            canvas.drawRect(
              Rect.fromCenter(center: center, width: 150, height: 150),
              paint,
            );
          },
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MPSymbolGoldenHarness(entries: entries, cellSize: 180),
          ),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_uis_phase3_sand_pattern.png'),
      );
    });
  });

  group('Therion UIS Phase 3 dispatch', () {
    final MPLocator mpLocator = MPLocator();

    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.mpSettingsController.resetEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
      );
    });

    Future<TH2FileEditController> loadController(String filename) async {
      final TH2FileEditController th2Controller = mpLocator.mpGeneralController
          .getTH2FileEditController(filename: THTestAux.testPath(filename));

      await th2Controller.load();

      return th2Controller;
    }

    test(
      'complex line types get their Phase 3 decorators only under the Therion UIS method',
      () async {
        PathProviderPlatform.instance = _FakePathProviderPlatform();

        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );

        expect(
          th2Controller.visualController.getLineDecorator(THLineType.pit),
          isNull,
        );

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        expect(
          th2Controller.visualController.getLineDecorator(THLineType.pit),
          isA<MPPitLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.floorStep,
          ),
          isA<MPPitLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(THLineType.chimney),
          isA<MPChimneyLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.ceilingStep,
          ),
          isA<MPCeilingStepLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.ceilingMeander,
          ),
          isA<MPCeilingMeanderLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.contour,
          ),
          isA<MPContourLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.flowstone,
          ),
          isA<MPFlowstoneLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.moonmilk,
          ),
          isA<MPMoonmilkLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.waterFlow,
            subtype: 'permanent',
          ),
          isA<MPWaterFlowPermanentLineDecorator>(),
        );
        expect(
          th2Controller.visualController.getLineDecorator(
            THLineType.waterFlow,
            subtype: 'intermittent',
          ),
          isNull,
        );
      },
    );

    test(
      'sand area gets a pattern shader fill without a background erase',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2025-05-24-point_narrow-end.th2',
        );

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        final therionSandPaint = th2Controller.visualController
            .getDefaultAreaPaint(areaType: THAreaType.sand);

        expect(therionSandPaint.fillPaint?.shader, isNotNull);
        expect(therionSandPaint.cleanBeforeFill, isFalse);
      },
    );
  });
}
