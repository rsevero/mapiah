// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_painter_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/th2_element_type_preview_cache.dart';
import 'package:mapiah/src/painters/th2_element_type_icon_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_fixed_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_line_slope_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_steps_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/widgets/th2_element_type_icon_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

const String _contents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 stalactite -id pt1\n'
    '  point 50 80 stalactite -id pt2 -orientation 45 -scale xl\n'
    '  point 2 2 label -id lb1 -text "Main entrance"\n'
    '  point 3 3 label -id lb2\n'
    '  point 4 4 station:temporary -id st1 -name 1.3@main\n'
    '  point 5 5 station -id st2\n'
    '  point 6 6 handrail -id hr1\n'
    '  line wall -id w1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    '  line wall -id w2 -reverse on -clip off\n'
    '    0 0\n'
    '    50 0\n'
    '    90 40\n'
    '  endline\n'
    '  line pit -id pit1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    '  line border -id b1\n'
    '    0 0\n'
    '    10 0\n'
    '    10 10\n'
    '    0 0\n'
    '  endline\n'
    '  area water -id a1\n'
    '    b1\n'
    '  endarea\n'
    '  line steps -id stp1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    '  line fixed-ladder -id fl1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    '  line slope -id sl1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    'endscrap\n'
    'scrap s2 -projection plan -scale [0 0 39.3701 0 0 0 1 0 m]\n'
    '  point 1 1 stalactite -id pt3\n'
    'endscrap\n';

const List<MPTH2EditVisualizationMethod> _therionMethods =
    <MPTH2EditVisualizationMethod>[
      MPTH2EditVisualizationMethod.therionDefault,
      MPTH2EditVisualizationMethod.therionUIS,
      MPTH2EditVisualizationMethod.therionAUT,
      MPTH2EditVisualizationMethod.therionSKBB,
    ];

void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late Directory tempDir;
  late TH2FileEditController controller;

  final ThemeData lightTheme = ThemeData(brightness: Brightness.light);
  final ThemeData darkTheme = ThemeData(brightness: Brightness.dark);

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    mpLocator.mpGeneralController.reset();
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3952_');
    controller = mpLocator.mpGeneralController.getTH2FileEditController(
      filename: p.join(tempDir.path, 'types.th2'),
      fileBytes: Uint8List.fromList(utf8.encode(_contents)),
    );
    await controller.load();
    expect(controller.isFileLoaded, isTrue);
    expect(controller.isBroken, isFalse);
  });

  tearDown(() {
    mpLocator.disposeTH2ElementTypePreviewCache();
    mpLocator.mpSettingsController.resetEnum(
      MPSettingID.TH2Edit_VisualizationMethod,
    );
    mpLocator.mpSettingsController.resetDouble(MPSettingID.TH2Edit_SymbolUnit);
    mpLocator.mpGeneralController.reset();
    tempDir.deleteSync(recursive: true);
  });

  void setMethod(MPTH2EditVisualizationMethod method) {
    mpLocator.mpSettingsController.setEnum(
      MPSettingID.TH2Edit_VisualizationMethod,
      method,
    );
  }

  THElement element(TH2FileEditController fileController, String thID) {
    return fileController.th2File.elementByMPID(
      fileController.th2File.mpIDByTHID(thID)!,
    );
  }

  TH2ElementTypePreviewKey keyFor(
    THElement element, {
    ThemeData? theme,
    double devicePixelRatio = 1,
  }) {
    return TH2ElementTypeIconWidget.previewKeyFor(
      element: element,
      theme: theme ?? lightTheme,
      devicePixelRatio: devicePixelRatio,
    )!;
  }

  TH2ElementTypePreviewKey typeKey(
    Enum type, {
    String subtype = mpNoSubtypeID,
    ThemeData? theme,
  }) {
    final ThemeData effectiveTheme = theme ?? lightTheme;
    final THElementType kind = switch (type) {
      THPointType _ => THElementType.point,
      THLineType _ => THElementType.line,
      _ => THElementType.area,
    };

    return TH2ElementTypePreviewKey(
      kind: kind,
      type: type,
      subtype: subtype,
      visualizationMethod:
          mpLocator.mpSettingsController.tH2EditVisualizationMethod,
      devicePixelRatio: 1,
      outlineColor: effectiveTheme.colorScheme.outline,
      interiorColor: MPPainterAux.canvasInteriorColor(
        effectiveTheme.brightness,
      ),
    );
  }

  /// Rasterizes the preview of [key] recorded through [fileController].
  Future<Uint8List> previewBytes(
    TH2ElementTypePreviewKey key, {
    TH2FileEditController? fileController,
  }) async {
    final ui.Picture picture = TH2ElementTypePreviewRecorder.record(
      key: key,
      visualController: (fileController ?? controller).visualController,
    );
    final ui.Image image = await picture.toImage(
      mpTH2ElementTypeIconSize.toInt(),
      mpTH2ElementTypeIconSize.toInt(),
    );
    final ByteData data = (await image.toByteData())!;

    picture.dispose();
    image.dispose();

    return data.buffer.asUint8List();
  }

  group('preview key', () {
    test('ignores geometry and unrelated options', () {
      expect(
        keyFor(element(controller, 'pt1')),
        keyFor(element(controller, 'pt2')),
      );
      expect(
        keyFor(element(controller, 'w1')),
        keyFor(element(controller, 'w2')),
      );
      expect(
        keyFor(element(controller, 'lb1')),
        keyFor(element(controller, 'lb2')),
      );
    });

    test('keeps subtype, theme colors and pixel ratio', () {
      expect(
        keyFor(element(controller, 'st1')),
        isNot(keyFor(element(controller, 'st2'))),
      );
      expect(keyFor(element(controller, 'st1')).subtype, 'temporary');
      expect(keyFor(element(controller, 'st2')).subtype, mpNoSubtypeID);
      expect(keyFor(element(controller, 'a1')).subtype, mpNoSubtypeID);
      expect(
        keyFor(element(controller, 'pt1')),
        isNot(keyFor(element(controller, 'pt1'), theme: darkTheme)),
      );
      expect(
        keyFor(element(controller, 'pt1')),
        isNot(keyFor(element(controller, 'pt1'), devicePixelRatio: 2)),
      );

      final ThemeData otherScheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      );

      expect(otherScheme.brightness, lightTheme.brightness);
      expect(
        keyFor(element(controller, 'w1')),
        isNot(keyFor(element(controller, 'w1'), theme: otherScheme)),
      );
    });

    test('follows the visualization method', () {
      final TH2ElementTypePreviewKey placeholderKey = keyFor(
        element(controller, 'pt1'),
      );

      setMethod(MPTH2EditVisualizationMethod.therionUIS);

      expect(keyFor(element(controller, 'pt1')), isNot(placeholderKey));
    });

    test('scrap rows have no key', () {
      expect(
        TH2ElementTypeIconWidget.previewKeyFor(
          element: controller.th2File.getScraps().first,
          theme: lightTheme,
          devicePixelRatio: 1,
        ),
        isNull,
      );
    });
  });

  group('shared paint isolation', () {
    List<Paint> sharedPaints() {
      final List<Paint> paints = <Paint>[];

      void addPointPaint(THPointPaint paint) {
        paints.addAll(<Paint?>[paint.border, paint.fill].whereType<Paint>());
        paints.addAll(paint.highlightBorders);
      }

      void addLinePaint(THLinePaint paint) {
        paints.addAll(
          <Paint?>[
            paint.primaryPaint,
            paint.secondaryPaint,
            paint.fillPaint,
          ].whereType<Paint>(),
        );
        paints.addAll(paint.highlightBorders);
      }

      MPVisualControllerBase.pointTypePaints.values.forEach(addPointPaint);
      MPVisualControllerBase.waterFlowPointSubtypesPaints.values.forEach(
        addPointPaint,
      );
      MPVisualControllerBase.stationSubtypesPaints.values.forEach(addPointPaint);
      MPVisualControllerBase.airDraughtSubtypesPaints.values.forEach(
        addPointPaint,
      );
      MPVisualControllerBase.lineTypePaints.values.forEach(addLinePaint);
      MPVisualControllerBase.borderSubtypesPaints.values.forEach(addLinePaint);
      MPVisualControllerBase.surveySubtypesPaints.values.forEach(addLinePaint);
      MPVisualControllerBase.wallSubtypesPaints.values.forEach(addLinePaint);
      MPVisualControllerBase.waterFlowLineSubtypesPaints.values.forEach(
        addLinePaint,
      );
      MPVisualControllerBase.areaTypePaints.values.forEach(addLinePaint);

      for (final MPTherionSymbolPaint symbolPaint
          in mpTherionSymbolPaints.values) {
        paints.addAll(
          <Paint?>[symbolPaint.border, symbolPaint.fill].whereType<Paint>(),
        );
      }

      return paints;
    }

    List<(double, Color, PaintingStyle)> snapshot(List<Paint> paints) {
      return <(double, Color, PaintingStyle)>[
        for (final Paint paint in paints)
          (paint.strokeWidth, paint.color, paint.style),
      ];
    }

    test('preview resolution and rendering leave shared paints unchanged', () async {
      final List<MPTH2EditVisualizationMethod> methods =
          <MPTH2EditVisualizationMethod>[
            MPTH2EditVisualizationMethod.mapiahPlaceholder,
            ..._therionMethods,
          ];

      controller.setCanvasScale(3.7);

      for (final MPTH2EditVisualizationMethod method in methods) {
        setMethod(method);

        final MPVisualController visualController =
            controller.visualController;

        // The canvas getters widen shared paints to the canvas thickness;
        // run them first so the snapshot holds the canvas state.
        for (final THElement canvasElement in controller.th2File.getPoints()) {
          visualController.getDefaultPointPaint(canvasElement as THPoint);
        }
        for (final THLineType lineType in THLineType.values) {
          if (lineType == THLineType.unknown) {
            continue;
          }
          visualController.getDefaultLinePaintByTypeSubtype(lineType: lineType);
        }

        final List<Paint> paints = sharedPaints();
        final List<(double, Color, PaintingStyle)> before = snapshot(paints);
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(recorder);

        for (final List<Enum> types in <List<Enum>>[
          THPointType.values,
          THLineType.values,
          THAreaType.values,
        ]) {
          for (final Enum type in types) {
            TH2ElementTypePreviewRecorder.paintPreview(
              canvas: canvas,
              key: typeKey(type),
              visualController: visualController,
            );
          }
        }
        recorder.endRecording().dispose();

        expect(snapshot(paints), before, reason: '$method');
      }
    });

    test('preview paints share no Paint or list with the defaults', () {
      final MPVisualController visualController = controller.visualController;
      final THLinePaint shared = MPVisualControllerBase.lineTypePaints.values.first;
      final THLinePaint highlighted = shared.copyWith(
        highlightBorders: <Paint>[Paint()..strokeWidth = 2],
      );
      final THLinePaint copied = highlighted.copyWithCopiedPaints();

      expect(identical(copied.primaryPaint, shared.primaryPaint), isFalse);
      expect(
        identical(copied.highlightBorders, highlighted.highlightBorders),
        isFalse,
      );
      expect(
        identical(
          copied.highlightBorders.single,
          highlighted.highlightBorders.single,
        ),
        isFalse,
      );

      final THPointPaint pointPaint = visualController.getPreviewPointPaint(
        pointType: THPointType.stalactite,
        pointSubtype: mpNoSubtypeID,
        radius: mpTH2ElementTypeIconPointRadius,
        lineThickness: mpTH2ElementTypeIconLineThickness,
      );

      expect(
        identical(
          pointPaint.border,
          MPVisualControllerBase.pointTypePaints[THPointType.stalactite]!.border,
        ),
        isFalse,
      );
      expect(pointPaint.highlightBorders, isEmpty);
      expect(pointPaint.rotation, 0);
      expect(pointPaint.radius, mpTH2ElementTypeIconPointRadius);

      final THLinePaint areaPaint = visualController.getPreviewAreaPaint(
        areaType: THAreaType.water,
        symbolUnit: TH2ElementTypePreviewRecorder.symbolUnit,
        lineThickness: mpTH2ElementTypeIconLineThickness,
      );

      expect(
        identical(
          areaPaint.primaryPaint,
          MPVisualControllerBase.areaTypePaints[THAreaType.water]!.primaryPaint,
        ),
        isFalse,
      );
      expect(areaPaint.primaryPaint!.strokeWidth, mpTH2ElementTypeIconLineThickness);
    });

    test('label-mode points keep their placeholder shape', () {
      setMethod(MPTH2EditVisualizationMethod.therionUIS);

      final THPointPaint pointPaint = controller.visualController
          .getPreviewPointPaint(
            pointType: THPointType.label,
            pointSubtype: mpNoSubtypeID,
            radius: mpTH2ElementTypeIconPointRadius,
            lineThickness: mpTH2ElementTypeIconLineThickness,
          );

      expect(pointPaint.labelPaint, isNull);
      expect(pointPaint.therionSymbol, isNull);
      expect(
        pointPaint.type,
        MPVisualControllerBase.pointTypePaints[THPointType.label]!.type,
      );
    });
  });

  group('fixed scale', () {
    final List<String> thIDs = <String>[
      'pt1',
      'hr1',
      'w1',
      'pit1',
      'a1',
      'stp1',
      'fl1',
      'sl1',
    ];

    Future<Map<String, Uint8List>> renderAll({
      TH2FileEditController? fileController,
    }) async {
      final TH2FileEditController source = fileController ?? controller;

      return <String, Uint8List>{
        for (final String thID in thIDs)
          thID: await previewBytes(
            keyFor(element(controller, thID)),
            fileController: source,
          ),
      };
    }

    for (final MPTH2EditVisualizationMethod method in <MPTH2EditVisualizationMethod>[
      MPTH2EditVisualizationMethod.mapiahPlaceholder,
      MPTH2EditVisualizationMethod.therionUIS,
      MPTH2EditVisualizationMethod.therionSKBB,
    ]) {
      test(
        'zoom, symbol unit and active scrap do not change ${method.name} previews',
        () async {
          setMethod(method);

          final Map<String, Uint8List> reference = await renderAll();

          controller.setCanvasScale(0.25);
          expect(await renderAll(), reference);

          controller.setCanvasScale(8);
          mpLocator.mpSettingsController.setDouble(
            MPSettingID.TH2Edit_SymbolUnit,
            mpDefaultSymbolUnitOnScreen * 3,
          );
          expect(await renderAll(), reference);

          final THScrap scaledScrap = controller.th2File.getScraps().last;

          controller.setActiveScrap(scaledScrap.mpID);
          expect(controller.scrapLengthUnitsPerPoint, isNot(1.0));
          expect(await renderAll(), reference);

          final Directory otherDir = Directory.systemTemp.createTempSync(
            'mapiah_t3952_other_',
          );
          final TH2FileEditController other = mpLocator.mpGeneralController
              .getTH2FileEditController(
                filename: p.join(otherDir.path, 'other.th2'),
                fileBytes: Uint8List.fromList(
                  utf8.encode(
                    'encoding utf-8\n'
                    'scrap o1 -projection plan -scale [0 0 96 0 0 0 200 0 inch]\n'
                    '  point 1 1 stalactite\n'
                    'endscrap\n',
                  ),
                ),
              );

          await other.load();
          addTearDown(() => otherDir.deleteSync(recursive: true));
          expect(await renderAll(fileController: other), reference);
        },
      );
    }
  });

  group('SKBB line samples', () {
    test('steps gets two rails and two end rungs', () {
      final TH2ElementTypeLineSample sample =
          TH2ElementTypeLineSample.forDecorator(
            const MPStepsSKBBLineDecorator(),
          );

      expect(sample.segments, hasLength(5));
      expect(sample.vertices, hasLength(5));
      expect((sample.segments.length - 1).isEven, isTrue);
      expect(
        sample.segments.every(
          (THLinePainterLineSegment segment) =>
              segment is THLinePainterStraightLineSegment,
        ),
        isTrue,
      );
      // Upper rail left to right, then lower rail right to left.
      expect(sample.vertices[1].dy, sample.vertices[2].dy);
      expect(sample.vertices[3].dy, sample.vertices[4].dy);
      expect(sample.vertices[1].dx, lessThan(sample.vertices[2].dx));
      expect(sample.vertices[3].dx, greaterThan(sample.vertices[4].dx));
      expect(sample.vertices[1].dy, greaterThan(sample.vertices[3].dy));
    });

    test('fixed-ladder gets the subdivided S-curve', () {
      final TH2ElementTypeLineSample sample =
          TH2ElementTypeLineSample.forDecorator(
            const MPFixedLadderSKBBLineDecorator(),
          );
      final TH2ElementTypeLineSample whole = TH2ElementTypeLineSample.sCurve();

      expect(
        sample.segments,
        hasLength(mpTH2ElementTypeIconLineSubdivisions + 1),
      );
      expect(sample.vertices.first, whole.vertices.first);
      expect(sample.vertices.last, whole.vertices.last);

      final ui.PathMetric sampleMetric = sample.path.computeMetrics().single;
      final ui.PathMetric wholeMetric = whole.path.computeMetrics().single;

      // Path metrics flatten curves approximately, so lengths and
      // positions agree within flattening tolerance only.
      expect(sampleMetric.length, closeTo(wholeMetric.length, 0.1));

      for (int i = 0; i <= 10; i++) {
        final double fraction = i / 10;

        expect(
          (sampleMetric
                      .getTangentForOffset(sampleMetric.length * fraction)!
                      .position -
                  wholeMetric
                      .getTangentForOffset(wholeMetric.length * fraction)!
                      .position)
              .distance,
          lessThan(0.15),
        );
      }

      // Knots are spread along the curve, not only at its ends.
      for (final Offset knot in sample.vertices) {
        expect(knot.dx.abs(), lessThanOrEqualTo(mpTH2ElementTypeIconLineHalfWidth));
      }
      expect(sample.vertices.toSet(), hasLength(sample.vertices.length));

      for (int i = 0; i < sample.vertices.length; i++) {
        expect(
          Offset(sample.segments[i].x, sample.segments[i].y),
          sample.vertices[i],
        );
      }
    });

    test('slope and other decorators get the single S-curve with l-size', () {
      final TH2ElementTypeLineSample sample =
          TH2ElementTypeLineSample.forDecorator(
            const MPLineSlopeSKBBLineDecorator(),
          );

      expect(sample.segments, hasLength(2));
      expect(
        sample.segments.every(
          (THLinePainterLineSegment segment) =>
              (segment.lSize == mpTH2ElementTypeIconSlopeLSize) &&
              (segment.orientation == null),
        ),
        isTrue,
      );
      expect(TH2ElementTypeLineSample.forDecorator(null).segments, hasLength(2));
      // Full-length ticks fit the frame's inner height around the curve.
      final ui.PathMetric metric = sample.path.computeMetrics().single;
      double curveHalfHeight = 0;

      for (int i = 0; i <= 100; i++) {
        final double y = metric
            .getTangentForOffset(metric.length * i / 100)!
            .position
            .dy
            .abs();

        if (y > curveHalfHeight) {
          curveHalfHeight = y;
        }
      }

      expect(
        curveHalfHeight +
            mpTH2ElementTypeIconSlopeLSize +
            (mpTH2ElementTypeIconLineThickness / 2),
        lessThan(
          (mpTH2ElementTypeIconSize / 2) - mpTH2ElementTypeIconFrameThickness,
        ),
      );
    });

    test('steps preview draws rails instead of the invalid red stroke', () async {
      setMethod(MPTH2EditVisualizationMethod.therionSKBB);

      final Uint8List bytes = await previewBytes(typeKey(THLineType.steps));
      final Color red = THPaint.thPaintMetaPostRed.color;
      int redPixels = 0;
      int inkPixels = 0;

      for (int i = 0; i < bytes.length; i += 4) {
        final Color color = Color.fromARGB(
          bytes[i + 3],
          bytes[i],
          bytes[i + 1],
          bytes[i + 2],
        );

        if (color == red) {
          redPixels++;
        }
        if ((bytes[i] < 200) || (bytes[i + 1] < 200) || (bytes[i + 2] < 200)) {
          inkPixels++;
        }
      }

      expect(redPixels, 0);
      expect(inkPixels, greaterThan(0));
    });

    test('every decorated line type draws within the frame', () async {
      for (final MPTH2EditVisualizationMethod method in _therionMethods) {
        setMethod(method);

        final Uint8List frameOnly = await previewBytes(
          typeKey(THLineType.unknown),
        );

        for (final THLineType lineType in THLineType.values) {
          final MPLineDecorator? decorator = controller.visualController
              .getLineDecorator(lineType);

          if (decorator == null) {
            continue;
          }

          final Uint8List bytes = await previewBytes(typeKey(lineType));

          expect(
            bytes,
            isNot(frameOnly),
            reason: '$lineType under $method drew nothing',
          );
        }
      }
    });
  });

  group('goldens', () {
    final List<(String, Enum)> entries = <(String, Enum)>[
      ('stalactite', THPointType.stalactite),
      ('label', THPointType.label),
      ('station', THPointType.station),
      ('handrail', THPointType.handrail),
      ('wall', THLineType.wall),
      ('pit', THLineType.pit),
      ('pitch', THLineType.pitch),
      ('steps', THLineType.steps),
      ('fixed-ladder', THLineType.fixedLadder),
      ('slope', THLineType.slope),
      ('rope-ladder', THLineType.ropeLadder),
      ('water', THAreaType.water),
      ('blocks', THAreaType.blocks),
      ('clay', THAreaType.clay),
      ('bedrock', THAreaType.bedrock),
    ];
    const double scale = 3;
    const double cell = (mpTH2ElementTypeIconSize + 4) * scale;

    Future<void> pumpGrid(WidgetTester tester, ThemeData theme) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(cell * entries.length, cell);
      addTearDown(tester.view.reset);

      final List<TH2ElementTypePreviewKey> keys = <TH2ElementTypePreviewKey>[
        for (final (String, Enum) entry in entries)
          typeKey(entry.$2, theme: theme),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(cell * entries.length, cell),
              painter: _GridPainter(
                keys: keys,
                visualController: controller.visualController,
                cell: cell,
                scale: scale,
                background: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      );
    }

    for (final MPTH2EditVisualizationMethod method in <MPTH2EditVisualizationMethod>[
      MPTH2EditVisualizationMethod.mapiahPlaceholder,
      MPTH2EditVisualizationMethod.therionUIS,
      MPTH2EditVisualizationMethod.therionSKBB,
    ]) {
      for (final (String, ThemeData) theme in <(String, ThemeData)>[
        ('light', lightTheme),
        ('dark', darkTheme),
      ]) {
        testWidgets('${method.name} ${theme.$1}', (WidgetTester tester) async {
          setMethod(method);
          await pumpGrid(tester, theme.$2);
          await expectLater(
            find.byType(RepaintBoundary).first,
            matchesGoldenFile(
              'goldens/th2_element_type_icons_${method.name}_${theme.$1}.png',
            ),
          );
        });
      }
    }

    test('previews are drawn upright on the Y-up content canvas', () async {
      setMethod(MPTH2EditVisualizationMethod.therionUIS);

      // The UIS stalactite is a stem with a fork on top, so ink spans a
      // wider column range in its upper half when drawn upright.
      final Uint8List bytes = await previewBytes(
        typeKey(THPointType.stalactite),
      );
      const int side = mpTH2ElementTypeIconSize ~/ 1;
      final List<int> upperColumns = <int>[];
      final List<int> lowerColumns = <int>[];

      for (int row = 0; row < side; row++) {
        for (int column = 0; column < side; column++) {
          final int index = ((row * side) + column) * 4;
          final bool isOpaque = bytes[index + 3] == 255;
          final bool isInk =
              isOpaque &&
              ((bytes[index] != 255) ||
                  (bytes[index + 1] != 255) ||
                  (bytes[index + 2] != 255));

          if (!isInk) {
            continue;
          }
          if (row < (side / 2)) {
            upperColumns.add(column);
          } else {
            lowerColumns.add(column);
          }
        }
      }

      int span(List<int> columns) =>
          columns.reduce(math.max) - columns.reduce(math.min);

      expect(span(upperColumns), greaterThan(span(lowerColumns)));
    });

    test('a label with text renders like a label without text', () async {
      for (final MPTH2EditVisualizationMethod method in <MPTH2EditVisualizationMethod>[
        MPTH2EditVisualizationMethod.mapiahPlaceholder,
        MPTH2EditVisualizationMethod.therionUIS,
      ]) {
        setMethod(method);
        expect(
          await previewBytes(keyFor(element(controller, 'lb1'))),
          await previewBytes(keyFor(element(controller, 'lb2'))),
        );
      }
    });

    test('area previews draw fill and outline without decorator', () async {
      setMethod(MPTH2EditVisualizationMethod.therionSKBB);

      final THLinePaint areaPaint = controller.visualController
          .getPreviewAreaPaint(
            areaType: THAreaType.water,
            symbolUnit: TH2ElementTypePreviewRecorder.symbolUnit,
            lineThickness: mpTH2ElementTypeIconLineThickness,
          );

      expect(areaPaint.fillPaint, isNotNull);
      expect(areaPaint.primaryPaint, isNotNull);
      expect(areaPaint.cleanBeforeFill, isTrue);
    });
  });

  group('cache', () {
    void paintThrough(
      TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache,
      TH2ElementTypePreviewKey key,
      List<ui.Picture> recorded,
    ) {
      final ui.PictureRecorder recorder = ui.PictureRecorder();

      cache.draw(
        canvas: Canvas(recorder),
        key: key,
        record: () {
          final ui.Picture picture = TH2ElementTypePreviewRecorder.record(
            key: key,
            visualController: controller.visualController,
          );

          recorded.add(picture);

          return picture;
        },
      );
      recorder.endRecording().dispose();
    }

    test('shares identical keys and evicts least recently used', () {
      final TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache =
          TH2ElementTypePreviewCache<TH2ElementTypePreviewKey>(limit: 2);
      final List<ui.Picture> recorded = <ui.Picture>[];

      paintThrough(cache, keyFor(element(controller, 'pt1')), recorded);
      paintThrough(cache, keyFor(element(controller, 'pt2')), recorded);
      expect(recorded, hasLength(1));
      expect(cache.length, 1);

      paintThrough(cache, typeKey(THLineType.wall), recorded);
      paintThrough(cache, typeKey(THPointType.stalactite), recorded);
      paintThrough(cache, typeKey(THAreaType.water), recorded);
      expect(cache.length, 2);
      expect(recorded, hasLength(3));
      expect(recorded[1].debugDisposed, isTrue);
      expect(recorded[0].debugDisposed, isFalse);

      cache.clear();
      expect(cache.length, 0);
      expect(
        recorded.every((ui.Picture picture) => picture.debugDisposed),
        isTrue,
      );

      cache.dispose();
      expect(cache.isDisposed, isTrue);
      expect(
        () => paintThrough(cache, typeKey(THLineType.wall), recorded),
        throwsStateError,
      );
    });

    test('a visualization change clears the cache', () {
      final TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache =
          TH2ElementTypePreviewCache<TH2ElementTypePreviewKey>();
      final List<ui.Picture> recorded = <ui.Picture>[];

      addTearDown(cache.dispose);
      paintThrough(cache, typeKey(THLineType.wall), recorded);
      expect(cache.length, 1);

      setMethod(MPTH2EditVisualizationMethod.therionUIS);

      expect(cache.length, 0);
      expect(recorded.single.debugDisposed, isTrue);
    });

    test('a pattern picture survives the closing of its file', () async {
      setMethod(MPTH2EditVisualizationMethod.therionSKBB);

      final TH2ElementTypePreviewKey key = typeKey(THAreaType.water);
      final Uint8List direct = await previewBytes(key);
      final TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache =
          TH2ElementTypePreviewCache<TH2ElementTypePreviewKey>();

      addTearDown(cache.dispose);
      paintThrough(cache, key, <ui.Picture>[]);
      expect(
        controller.visualController.patternCache.contains(
          null,
          THAreaType.water,
        ) ||
            controller.visualController.patternCache.imageFor(
                  null,
                  THAreaType.water,
                ) ==
                null,
        isTrue,
      );
      controller.close();

      final ui.PictureRecorder recorder = ui.PictureRecorder();

      cache.draw(
        canvas: Canvas(recorder),
        key: key,
        record: () => fail('the cached picture should be reused'),
      );

      final ui.Picture outer = recorder.endRecording();
      final ui.Image image = await outer.toImage(
        mpTH2ElementTypeIconSize.toInt(),
        mpTH2ElementTypeIconSize.toInt(),
      );
      final Uint8List afterClose = (await image.toByteData())!.buffer
          .asUint8List();

      outer.dispose();
      image.dispose();
      expect(afterClose, direct);
    });
  });

  group('widget', () {
    Future<void> pumpIcon(
      WidgetTester tester, {
      required String thID,
      ThemeData? theme,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme ?? lightTheme,
          home: Center(
            child: TH2ElementTypeIconWidget(
              controller: controller,
              elementMPID: element(controller, thID).mpID,
            ),
          ),
        ),
      );
    }

    TH2ElementTypePreviewKey paintedKey(WidgetTester tester) {
      final CustomPaint customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(TH2ElementTypeIconWidget),
          matching: find.byType(CustomPaint),
        ),
      );

      return (customPaint.painter! as TH2ElementTypeIconPainter).previewKey;
    }

    testWidgets('has the fixed icon footprint', (WidgetTester tester) async {
      await pumpIcon(tester, thID: 'w1');

      expect(
        tester.getSize(find.byType(TH2ElementTypeIconWidget)),
        const Size.square(mpTH2ElementTypeIconSize),
      );
      expect(mpTH2ElementTypeIconSize, mpSmallIconSize);
      expect(mpTH2ElementTypeIconSize, lessThanOrEqualTo(mpProjectTreeRowHeight));
    });

    testWidgets('follows type and subtype edits, undo and redo', (
      WidgetTester tester,
    ) async {
      await pumpIcon(tester, thID: 'st2');
      expect(paintedKey(tester).subtype, mpNoSubtypeID);

      final int stationMPID = element(controller, 'st2').mpID;

      void editTypeSubtype(String typeSubtype) {
        controller.execute(
          MPCommandFactory.editPointsTypeSubtype(
            pointMPIDs: <int>[stationMPID],
            newPointTypeSubtype: typeSubtype,
            th2File: controller.th2File,
          ),
        );
      }

      editTypeSubtype('station:temporary');
      await tester.pump();
      expect(paintedKey(tester).subtype, 'temporary');

      controller.undo();
      await tester.pump();
      expect(paintedKey(tester).subtype, mpNoSubtypeID);

      controller.redo();
      await tester.pump();
      expect(paintedKey(tester).subtype, 'temporary');

      editTypeSubtype('stalactite');
      await tester.pump();
      expect(paintedKey(tester).type, THPointType.stalactite);
      expect(paintedKey(tester).subtype, mpNoSubtypeID);

      controller.undo();
      await tester.pump();
      expect(paintedKey(tester).type, THPointType.station);
      expect(paintedKey(tester).subtype, 'temporary');
    });

    testWidgets('follows the visualization method and the theme', (
      WidgetTester tester,
    ) async {
      setMethod(MPTH2EditVisualizationMethod.mapiahPlaceholder);
      await pumpIcon(tester, thID: 'pt1');
      expect(
        paintedKey(tester).visualizationMethod,
        MPTH2EditVisualizationMethod.mapiahPlaceholder,
      );

      setMethod(MPTH2EditVisualizationMethod.therionUIS);
      await tester.pump();
      expect(
        paintedKey(tester).visualizationMethod,
        MPTH2EditVisualizationMethod.therionUIS,
      );

      await pumpIcon(tester, thID: 'pt1', theme: darkTheme);
      await tester.pumpAndSettle();
      expect(paintedKey(tester).interiorColor, Colors.black);
    });

    testWidgets('a mounted icon repaints after eviction and clearing', (
      WidgetTester tester,
    ) async {
      await pumpIcon(tester, thID: 'w1');

      final TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache =
          mpLocator.th2ElementTypePreviewCache;
      final TH2ElementTypePreviewKey key = paintedKey(tester);

      expect(cache.contains(key), isTrue);

      cache.clear();
      expect(cache.contains(key), isFalse);

      final RenderObject renderObject = tester.renderObject(
        find.descendant(
          of: find.byType(TH2ElementTypeIconWidget),
          matching: find.byType(CustomPaint),
        ),
      );

      renderObject.markNeedsPaint();
      await tester.pump();
      expect(cache.contains(key), isTrue);

      for (int i = 0; i < mpTH2ElementTypeIconCacheLimit + 1; i++) {
        final ui.PictureRecorder recorder = ui.PictureRecorder();

        cache.draw(
          canvas: Canvas(recorder),
          key: TH2ElementTypePreviewKey(
            kind: THElementType.point,
            type: THPointType.stalactite,
            subtype: mpNoSubtypeID,
            visualizationMethod: key.visualizationMethod,
            devicePixelRatio: 1.0 + i,
            outlineColor: key.outlineColor,
            interiorColor: key.interiorColor,
          ),
          record: () {
            final ui.PictureRecorder emptyRecorder = ui.PictureRecorder();

            Canvas(emptyRecorder);

            return emptyRecorder.endRecording();
          },
        );
        recorder.endRecording().dispose();
      }
      expect(cache.contains(key), isFalse);
      expect(cache.length, mpTH2ElementTypeIconCacheLimit);

      renderObject.markNeedsPaint();
      await tester.pump();
      expect(cache.contains(key), isTrue);
      expect(cache.length, mpTH2ElementTypeIconCacheLimit);
    });
  });
}

class _GridPainter extends CustomPainter {
  final List<TH2ElementTypePreviewKey> keys;
  final MPVisualController visualController;
  final double cell;
  final double scale;
  final Color background;

  _GridPainter({
    required this.keys,
    required this.visualController,
    required this.cell,
    required this.scale,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    for (int i = 0; i < keys.length; i++) {
      canvas.save();
      canvas.translate((cell * i) + (2 * scale), 2 * scale);
      canvas.scale(scale);
      TH2ElementTypePreviewRecorder.paintPreview(
        canvas: canvas,
        key: keys[i],
        visualController: visualController,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}
