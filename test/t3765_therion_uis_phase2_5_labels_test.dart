// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart' hide Path;
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_label_text_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_data.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/helpers/mp_label_painter.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/types/th_label_size.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'auxiliary/mp_symbol_golden_harness.dart';
import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  Future<TH2FileEditController> loadController(String filename) async {
    final TH2FileEditController th2Controller = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: THTestAux.testPath(filename));

    await th2Controller.load();

    return th2Controller;
  }

  group('Therion Phase 2.5 label text resolution', () {
    setUp(() {
      mpLocator.mpGeneralController.reset();
    });

    test('label point splits <br> into separate lines', () async {
      final TH2FileEditController th2Controller = await loadController(
        '2026-07-21-001-point_label_with_br_tag.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;
      final MPLabelData? data = MPLabelTextAux.resolve(point);

      expect(data, isNotNull);
      expect(data!.mode, MPLabelMode.plain);
      expect(data.lines, ['First line', 'Second line']);
    });

    test('date point renders its datetime value', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-00381-point_of_type_date_with_date_value_and_other_options.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;
      final MPLabelData? data = MPLabelTextAux.resolve(point);

      expect(data, isNotNull);
      expect(data!.lines, ['2022.02.05']);
    });

    test('altitude point shows the fix prefix', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-02321-altitude_point_with_value_option_with_fix.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;
      final MPLabelData? data = MPLabelTextAux.resolve(point);

      expect(data, isNotNull);
      expect(data!.lines.single, contains('fix'));
      expect(data.lines.single, contains('1300'));
    });

    test(
      'height point carries the chimney/pit sign and drops the unit',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          'th_file_parser-02350-height_point_with_value_option.th2',
        );
        final THPoint point = th2Controller.th2File.getPoints().single;
        final MPLabelData? data = MPLabelTextAux.resolve(point);

        expect(data, isNotNull);
        expect(data!.lines.single, '40?');
      },
    );

    test(
      'passage-height point resolves to the positive container and drops the unit',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          'th_file_parser-00196-passage_height_point_with_value_option_with_unit_with_plus.th2',
        );
        final THPoint point = th2Controller.th2File.getPoints().single;
        final MPLabelData? data = MPLabelTextAux.resolve(point);

        expect(data, isNotNull);
        expect(data!.mode, MPLabelMode.passageHeightPos);
        expect(data.plusText, '7');
        expect(data.minusText, isNull);
      },
    );

    test('dimensions point combines above/below and unit', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-02361-dimensions_point_with_value_option_with_unit.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;
      final MPLabelData? data = MPLabelTextAux.resolve(point);

      expect(data, isNotNull);
      expect(data!.lines.single, contains('/'));
    });

    test('station points are left unhandled (placeholder rendering)', () async {
      final TH2FileEditController th2Controller = await loadController(
        '2026-04-06-002-point_with_station_option.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;

      expect(point.pointType, THPointType.station);
      expect(MPLabelTextAux.resolve(point), isNull);
    });

    test('station-name points are left unhandled (placeholder rendering)', () async {
      final TH2FileEditController th2Controller = await loadController(
        '2026-07-21-002-point_station-name.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;

      expect(point.pointType, THPointType.stationName);
      expect(MPLabelTextAux.resolve(point), isNull);
    });
  });

  group('Therion Phase 2.5 point paint dispatch', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
      mpLocator.mpSettingsController.resetEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
      );
    });

    test(
      'label point only gets a labelPaint under a Therion visualization method',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2026-07-21-001-point_label_with_br_tag.th2',
        );
        final THPoint point = th2Controller.th2File.getPoints().single;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.mapiahPlaceholder,
        );

        final placeholderPaint = th2Controller.visualController
            .getDefaultPointPaint(point);

        expect(placeholderPaint.labelPaint, isNull);

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        final therionPaint = th2Controller.visualController
            .getDefaultPointPaint(point);

        expect(therionPaint.labelPaint, isNotNull);
        expect(therionPaint.labelPaint!.data.lines, [
          'First line',
          'Second line',
        ]);
      },
    );

    test('station point does not get a Therion label paint', () async {
      final TH2FileEditController th2Controller = await loadController(
        '2026-04-06-002-point_with_station_option.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;

      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );

      final THPointPaint pointPaint = th2Controller.visualController
          .getDefaultPointPaint(point);

      expect(pointPaint.labelPaint, isNull);
    });

    test('point align option is carried into the labelPaint', () async {
      final TH2FileEditController th2Controller = await loadController(
        'th_file_parser-00381-point_of_type_date_with_date_value_and_other_options.th2',
      );
      final THPoint point = th2Controller.th2File.getPoints().single;

      mpLocator.mpSettingsController.setEnum(
        MPSettingID.TH2Edit_VisualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );

      final therionPaint = th2Controller.visualController.getDefaultPointPaint(
        point,
      );

      expect(therionPaint.labelPaint, isNotNull);
      expect(
        therionPaint.labelPaint!.align,
        THOptionChoicesAlignType.bottomLeft,
      );
      final double expectedAnchorRadius =
          th2Controller.lineThicknessOnCanvas *
          mpLinePointRadiusToLineThicknessFactor *
          mpTherionLabelAnchorRadiusToLinePointRadiusFactor;

      expect(therionPaint.labelPaint!.anchorRadius, expectedAnchorRadius);
      expect(
        therionPaint.labelPaint!.anchorFill,
        same(mpTherionLabelAnchorPaint),
      );
    });

    test(
      'passage-height and plain labels both get the small label size',
      () async {
        final TH2FileEditController th2Controller = await loadController(
          '2026-01-05-002-passage-height-point_with_positive_value.th2',
        );
        final THPoint passageHeightPoint = th2Controller.th2File
            .getPoints()
            .single;

        mpLocator.mpSettingsController.setEnum(
          MPSettingID.TH2Edit_VisualizationMethod,
          MPTH2EditVisualizationMethod.therionUIS,
        );

        final THPointPaint passageHeightPaint = th2Controller.visualController
            .getDefaultPointPaint(passageHeightPoint);

        expect(passageHeightPaint.labelPaint, isNotNull);
        expect(passageHeightPaint.labelPaint!.size, THLabelSize.tiny);

        final TH2FileEditController plainController = await loadController(
          'th_file_parser-00381-point_of_type_date_with_date_value_and_other_options.th2',
        );
        final THPoint datePoint = plainController.th2File.getPoints().single;
        final THPointPaint datePaint = plainController.visualController
            .getDefaultPointPaint(datePoint);

        expect(datePaint.labelPaint, isNotNull);
        expect(datePaint.labelPaint!.size, THLabelSize.tiny);
      },
    );
  });

  group('Therion Phase 2.5 label rendering', () {
    Future<ByteData> renderAnchor({
      required MPLabelData data,
      required double markerRadius,
      required int imageSize,
    }) async {
      final double center = imageSize / 2;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final MPLabelPaint labelPaint = MPLabelPaint(
        data: data,
        anchorRadius: markerRadius,
        anchorFill: mpTherionLabelAnchorPaint,
        backgroundFill: THPaint.thPaintWhiteBackground,
        divider: THPaint.thPaintBlackBorder,
        textColor: Colors.black,
      );

      canvas.translate(center, center);
      canvas.scale(1, -1);
      MPInteractionAux.drawPoint(
        canvas: canvas,
        position: Offset.zero,
        pointPaint: THPointPaint(labelPaint: labelPaint, fill: Paint()),
        symbolUnit: const MPSymbolUnit(
          canvasScale: 1,
          devicePixelRatio: 1,
          scrapLengthUnitsPerPoint: 1,
          scrapLengthUnitType: THLengthUnitType.meter,
        ),
      );

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(imageSize, imageSize);
      final ByteData pixels = (await image.toByteData())!;

      image.dispose();
      picture.dispose();

      return pixels;
    }

    /// Plain labels fill a background box (`process_...`'s equivalent never
    /// applies to `passage-height`, see [MPLabelPaint]'s doc), so the anchor
    /// circle must sit above that fill — otherwise the background would
    /// paint over and hide it entirely, unlike the passage-height containers
    /// covered by the next test, which are stroked outlines with nothing to
    /// hide the circle.
    test('draws the anchor circle over a plain label\'s background', () async {
      const int imageSize = 100;
      const double markerRadius = 3;
      // Empty text keeps the background box's fill in place (the margins
      // alone still produce a box) without any glyph at the anchor that
      // could otherwise paint over the circle and confound this assertion.
      final ByteData pixels = await renderAnchor(
        data: const MPLabelData.plain(['']),
        markerRadius: markerRadius,
        imageSize: imageSize,
      );
      final int center = imageSize ~/ 2;
      final int centerPixelIndex = (((center * imageSize) + center) * 4);
      final int markerColor = mpTherionLabelAnchorPaint.color.toARGB32();

      expect(pixels.getUint8(centerPixelIndex), (markerColor >> 16) & 0xFF);
      expect(pixels.getUint8(centerPixelIndex + 1), (markerColor >> 8) & 0xFF);
      expect(pixels.getUint8(centerPixelIndex + 2), markerColor & 0xFF);
      expect(
        pixels.getUint8(centerPixelIndex + 3),
        (markerColor >> 24) & 0xFF,
      );
    });

    /// The anchor circle must stay below the label text itself: for a
    /// non-empty plain label whose text covers the anchor point, the text's
    /// own color — not the marker's — wins at that pixel.
    test('draws the anchor circle below a plain label\'s text', () async {
      const int imageSize = 100;
      const double markerRadius = 3;
      final ByteData pixels = await renderAnchor(
        data: const MPLabelData.plain(['MMMMMMMM']),
        markerRadius: markerRadius,
        imageSize: imageSize,
      );
      final int center = imageSize ~/ 2;
      final int centerPixelIndex = (((center * imageSize) + center) * 4);
      final int markerColor = mpTherionLabelAnchorPaint.color.toARGB32();

      expect(
        pixels.getUint8(centerPixelIndex),
        isNot((markerColor >> 16) & 0xFF),
      );
    });

    testWidgets('renders every label mode side by side', (
      WidgetTester tester,
    ) async {
      mpLocator.appLocalizations = AppLocalizationsEn();

      const double cellSize = 160;
      const double markerRadius = 3;
      const MPSymbolUnit symbolUnit = MPSymbolUnit(
        canvasScale: 1,
        devicePixelRatio: 1,
        scrapLengthUnitsPerPoint: 1,
        scrapLengthUnitType: THLengthUnitType.meter,
      );

      MPLabelPaint paintFor(MPLabelData data) => MPLabelPaint(
        data: data,
        align: THOptionChoicesAlignType.center,
        size: THLabelSize.normal,
        anchorRadius: markerRadius,
        anchorFill: mpTherionLabelAnchorPaint,
        backgroundFill: THPaint.thPaintWhiteBackground,
        divider: THPaint.thPaintBlackBorder,
        textColor: Colors.black,
      );

      /// [TH2FileEditController.transformCanvas] always applies a
      /// `canvas.scale(1, -1)` Y-flip before any element painter runs.
      /// Simulate that here (pivoted at the cell center, same as the real
      /// painter's own coordinate origin) so this golden exercises the same
      /// double-flip cancellation `MPLabelPainter.drawTherionLabel` relies
      /// on in the running app, instead of only the unflipped canvas a bare
      /// `PictureRecorder` would give it.
      MPSymbolGoldenDraw underAmbientYFlip(MPSymbolGoldenDraw draw) {
        return (Canvas canvas, Offset center) {
          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.scale(1, -1);
          canvas.translate(-center.dx, -center.dy);
          draw(canvas, center);
          canvas.restore();
        };
      }

      final List<MPSymbolGoldenEntry> entries = [
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip(
            (Canvas canvas, Offset center) => MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(const MPLabelData.plain(['Station1'])),
              anchor: center,
              symbolUnit: symbolUnit,
            ),
          ),
        ),
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip(
            (Canvas canvas, Offset center) => MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(
                const MPLabelData.plain(['First line', 'Second line']),
              ),
              anchor: center,
              symbolUnit: symbolUnit,
            ),
          ),
        ),
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip(
            (Canvas canvas, Offset center) => MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(
                const MPLabelData.passageHeight(
                  mode: MPLabelMode.passageHeightPos,
                  plusText: '2.5 m',
                ),
              ),
              anchor: center,
              symbolUnit: symbolUnit,
            ),
          ),
        ),
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip(
            (Canvas canvas, Offset center) => MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(
                const MPLabelData.passageHeight(
                  mode: MPLabelMode.passageHeightNeg,
                  minusText: '-1.2 m',
                ),
              ),
              anchor: center,
              symbolUnit: symbolUnit,
            ),
          ),
        ),
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip(
            (Canvas canvas, Offset center) => MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(
                const MPLabelData.passageHeight(
                  mode: MPLabelMode.passageHeightPosNeg,
                  plusText: '2.5 m',
                  minusText: '-1.2 m',
                ),
              ),
              anchor: center,
              symbolUnit: symbolUnit,
            ),
          ),
        ),
        // Demonstrates horiz_labels: the red guide line is drawn under an
        // ambient canvas rotation (as a point's orientation option would
        // apply to a Therion symbol), but the label itself always stays
        // horizontal regardless of that ambient rotation.
        MPSymbolGoldenEntry(
          draw: underAmbientYFlip((Canvas canvas, Offset center) {
            canvas.save();
            canvas.translate(center.dx, center.dy);
            canvas.rotate(1.0);
            canvas.drawLine(
              Offset.zero,
              const Offset(50, 0),
              Paint()
                ..color = Colors.red
                ..strokeWidth = 3,
            );
            canvas.restore();

            MPLabelPainter.drawTherionLabel(
              canvas: canvas,
              labelPaint: paintFor(
                const MPLabelData.plain(['Stays horizontal']),
              ),
              anchor: center,
              symbolUnit: symbolUnit,
            );
          }),
        ),
      ];

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
        matchesGoldenFile('goldens/therion_uis_phase2_5_labels.png'),
      );
    });
  });
}
