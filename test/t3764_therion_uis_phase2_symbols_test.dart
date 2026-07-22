// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' hide Image, Path;
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/therion_uis/mp_survey_cave_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_point_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'auxiliary/mp_symbol_golden_harness.dart';

void main() {
  group('Therion UIS Phase 2 symbols', () {
    const List<MPTherionPointSymbol> phase2Symbols = <MPTherionPointSymbol>[
      MPTherionPointSymbol.anastomosisUIS,
      MPTherionPointSymbol.archeoMaterialUIS,
      MPTherionPointSymbol.campUIS,
      MPTherionPointSymbol.curtainUIS,
      MPTherionPointSymbol.diskUIS,
      MPTherionPointSymbol.gradientUIS,
      MPTherionPointSymbol.guanoUIS,
      MPTherionPointSymbol.helictiteUIS,
      MPTherionPointSymbol.moonmilkUIS,
      MPTherionPointSymbol.paleoMaterialUIS,
      MPTherionPointSymbol.pebblesUIS,
      MPTherionPointSymbol.popcornUIS,
      MPTherionPointSymbol.scallopUIS,
      MPTherionPointSymbol.waterFlowIntermittentUIS,
      MPTherionPointSymbol.waterFlowPaleoUIS,
      MPTherionPointSymbol.waterFlowPermanentUIS,
    ];

    test('registers and draws every medium-complexity point symbol', () {
      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke;
      final Paint fillPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill;

      for (int index = 0; index < phase2Symbols.length; index++) {
        final MPTherionPointSymbol symbol = phase2Symbols[index];
        final void Function(Canvas, Offset, double, Paint)? drawMethod =
            MPTherionPointSymbolsUIS.drawMethods[symbol];

        expect(drawMethod, isNotNull, reason: '$symbol has no draw method');
        final Offset position = Offset(index * 40.0, 20);

        drawMethod!(canvas, position, 30, fillPaint);
        drawMethod(canvas, position, 30, strokePaint);
      }

      final Picture picture = recorder.endRecording();

      expect(picture, isNotNull);
      picture.dispose();
    });

    testWidgets('renders every Phase 2 point symbol', (
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
      final List<MPSymbolGoldenEntry> entries = phase2Symbols
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
            child: MPSymbolGoldenHarness(
              entries: entries,
              cellSize: cellSize,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MPSymbolGoldenHarness),
        matchesGoldenFile('goldens/therion_uis_phase2_point_symbols.png'),
      );
    });

    test('maps every non-subtyped Phase 2 point type', () {
      const Map<THPointType, MPTherionPointSymbol> expected =
          <THPointType, MPTherionPointSymbol>{
            THPointType.anastomosis: MPTherionPointSymbol.anastomosisUIS,
            THPointType.archeoMaterial: MPTherionPointSymbol.archeoMaterialUIS,
            THPointType.camp: MPTherionPointSymbol.campUIS,
            THPointType.curtain: MPTherionPointSymbol.curtainUIS,
            THPointType.disk: MPTherionPointSymbol.diskUIS,
            THPointType.gradient: MPTherionPointSymbol.gradientUIS,
            THPointType.guano: MPTherionPointSymbol.guanoUIS,
            THPointType.helictite: MPTherionPointSymbol.helictiteUIS,
            THPointType.moonmilk: MPTherionPointSymbol.moonmilkUIS,
            THPointType.paleoMaterial: MPTherionPointSymbol.paleoMaterialUIS,
            THPointType.pebbles: MPTherionPointSymbol.pebblesUIS,
            THPointType.popcorn: MPTherionPointSymbol.popcornUIS,
            THPointType.scallop: MPTherionPointSymbol.scallopUIS,
          };

      for (final MapEntry<THPointType, MPTherionPointSymbol> entry
          in expected.entries) {
        expect(therionUISPointSymbols[entry.key], entry.value);
      }
    });

    test('resolves all water-flow subtypes', () {
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.waterFlow,
          subtype: 'paleo',
        ),
        MPTherionPointSymbol.waterFlowPaleoUIS,
      );
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.waterFlow,
          subtype: 'intermittent',
        ),
        MPTherionPointSymbol.waterFlowIntermittentUIS,
      );
      expect(
        getTherionUISPointSymbol(
          pointType: THPointType.waterFlow,
          subtype: 'permanent',
        ),
        MPTherionPointSymbol.waterFlowPermanentUIS,
      );
    });

    test(
      'keeps oriented symbols upright on the reflected editor canvas',
      () async {
        const int imageSize = 100;
        const double center = imageSize / 2;
        final PictureRecorder recorder = PictureRecorder();
        final Canvas canvas = Canvas(recorder);
        final THPointPaint pointPaint = THPointPaint(
          rotation: mp45DegreesInRad,
          fill: Paint()
            ..color = const Color(0xFF000000)
            ..style = PaintingStyle.fill,
          therionSymbol: MPTherionPointSymbol.waterFlowPermanentUIS,
        );

        canvas.translate(center, center);
        canvas.scale(1, -1);
        MPInteractionAux.drawPoint(
          canvas: canvas,
          position: Offset.zero,
          pointPaint: pointPaint,
          symbolUnit: const MPSymbolUnit(
            canvasScale: 1,
            devicePixelRatio: 1,
          ),
        );

        final Picture picture = recorder.endRecording();
        final Image image = await picture.toImage(imageSize, imageSize);
        final ByteData pixels = (await image.toByteData())!;
        int opaquePixelCount = 0;
        double opaquePixelsYTotal = 0;

        for (int y = 0; y < imageSize; y++) {
          for (int x = 0; x < imageSize; x++) {
            final int alphaIndex = ((y * imageSize) + x) * 4 + 3;

            if (pixels.getUint8(alphaIndex) > 0) {
              opaquePixelCount++;
              opaquePixelsYTotal += y;
            }
          }
        }

        expect(opaquePixelCount, greaterThan(0));

        final double opaquePixelsYCenter =
            opaquePixelsYTotal / opaquePixelCount;

        expect(opaquePixelsYCenter, lessThan(center));

        image.dispose();
        picture.dispose();
      },
    );

    test('survey cave replaces curves with knot-to-knot segments', () {
      const MPSurveyCaveLineDecorator decorator =
          MPSurveyCaveLineDecorator();
      final Path curvedPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(10, 30, 20, 30, 30, 0);
      final Path segmentedPath = decorator.buildBasePath(
        path: curvedPath,
        vertices: const <Offset>[Offset(0, 0), Offset(30, 0)],
      );
      final PathMetric metric = segmentedPath.computeMetrics().single;

      expect(metric.length, closeTo(30, 0.001));

      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      decorator.decorate(
        canvas: canvas,
        path: segmentedPath,
        linePaint: THLinePaint(primaryPaint: Paint()),
        symbolUnit: const MPSymbolUnit(
          canvasScale: 1,
          devicePixelRatio: 1,
        ),
        isReversed: false,
      );
      recorder.endRecording().dispose();
    });
  });
}
