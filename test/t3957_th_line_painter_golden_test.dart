// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/widgets/auxiliary/th_line_painter_line_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'auxiliary/mp_symbol_golden_harness.dart';
import 'th_test_aux.dart';

const String _lineContents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  line wall -id w1\n'
    '    0 0\n'
    '    10 10\n'
    '  endline\n'
    'endscrap\n';

const double _cellSize = 160;

/// Canvas-painter baselines for [THLinePainter]: they invoke the painter
/// itself with controller-resolved paints, so a refactor of its paint core
/// must leave continuous strokes, dashes, decoration, patterned fills with
/// `cleanBeforeFill`, direction ticks and their painting order unchanged.
void main() {
  if (!THTestAux.ensureTestEnvironment()) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  late Directory tempDir;
  late TH2FileEditController controller;

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
    tempDir = Directory.systemTemp.createTempSync('mapiah_t3957_');
    controller = mpLocator.mpGeneralController.getTH2FileEditController(
      filename: p.join(tempDir.path, 'line.th2'),
      fileBytes: Uint8List.fromList(utf8.encode(_lineContents)),
    );
    await controller.load();
  });

  tearDown(() {
    mpLocator.mpSettingsController.resetEnum(
      MPSettingID.TH2Edit_VisualizationMethod,
    );
    mpLocator.mpGeneralController.reset();
    tempDir.deleteSync(recursive: true);
  });

  void setMethod(MPTH2EditVisualizationMethod method) {
    mpLocator.mpSettingsController.setEnum(
      MPSettingID.TH2Edit_VisualizationMethod,
      method,
    );
  }

  /// A wavy multi-segment sample centered on the origin, long enough for
  /// intermediate direction ticks.
  LinkedHashMap<int, THLinePainterLineSegment> sampleSegments() {
    final LinkedHashMap<int, THLinePainterLineSegment> segments =
        LinkedHashMap<int, THLinePainterLineSegment>();
    const int segmentCount = 12;
    const double halfWidth = 65;
    const double step = (halfWidth * 2) / segmentCount;

    segments[0] = THLinePainterStraightLineSegment(x: -halfWidth, y: 0);

    for (int i = 1; i <= segmentCount; i++) {
      final double x = -halfWidth + (step * i);
      final double y = i.isEven ? 0 : 18;

      segments[i] = i.isEven
          ? THLinePainterBezierCurveLineSegment(
              x: x,
              y: y,
              controlPoint1X: x - (step * 0.66),
              controlPoint1Y: 30,
              controlPoint2X: x - (step * 0.33),
              controlPoint2Y: -12,
            )
          : THLinePainterStraightLineSegment(x: x, y: y);
    }

    return segments;
  }

  /// A closed sample for area fills.
  LinkedHashMap<int, THLinePainterLineSegment> closedSegments() {
    return LinkedHashMap<int, THLinePainterLineSegment>.of(
      <int, THLinePainterLineSegment>{
        0: THLinePainterStraightLineSegment(x: -60, y: -50),
        1: THLinePainterBezierCurveLineSegment(
          x: 60,
          y: -50,
          controlPoint1X: -20,
          controlPoint1Y: -75,
          controlPoint2X: 20,
          controlPoint2Y: -25,
        ),
        2: THLinePainterStraightLineSegment(x: 55, y: 50),
        3: THLinePainterStraightLineSegment(x: -60, y: 50),
        4: THLinePainterStraightLineSegment(x: -60, y: -50),
      },
    );
  }

  THLinePainterLineInfo lineInfo({required bool ticks}) {
    final THLine line = controller.th2File.getLines().single;

    return THLinePainterLineInfo(
      line: line,
      showLineDirectionTicks: ticks,
      showMarksOnLineSegments: false,
      showSizeOrientationOnLineSegments: false,
      th2FileEditController: controller,
    );
  }

  MPSymbolGoldenEntry entryFor(THLinePainter painter, {bool backdrop = false}) {
    return MPSymbolGoldenEntry(
      draw: (Canvas canvas, Offset center) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        if (backdrop) {
          // A stripe under the fill makes `cleanBeforeFill` visible.
          canvas.drawRect(
            const Rect.fromLTWH(-_cellSize / 2, -20, _cellSize, 40),
            Paint()..color = const Color(0xFF808080),
          );
        }
        painter.paint(canvas, const Size(_cellSize, _cellSize));
        canvas.restore();
      },
    );
  }

  THLinePainter linePainter({
    required THLineType lineType,
    String? subtype,
    bool hasID = false,
    bool ticks = false,
  }) {
    final MPVisualController visualController = controller.visualController;

    return THLinePainter(
      lineInfo: lineInfo(ticks: ticks),
      lineSegmentsMap: sampleSegments(),
      linePaint: visualController.getUnselectedLinePaint(
        lineType: lineType,
        subtype: subtype,
        lineHasID: hasID,
        isFromActiveScrap: true,
      ),
      lineDecorator: visualController.getLineDecorator(
        lineType,
        subtype: subtype,
      ),
      lineDecoratorColor: visualController.getLineDecoratorColor(
        lineType,
        subtype: subtype,
      ),
      th2FileEditController: controller,
    );
  }

  THLinePainter areaPainter({
    required THAreaType areaType,
    required THLineType borderLineType,
  }) {
    final MPVisualController visualController = controller.visualController;
    final THLinePaint areaPaint = visualController.getUnselectedAreaPaint(
      areaType: areaType,
      isFromActiveScrap: true,
    );
    final MPLineDecorator? decorator = visualController.getLineDecorator(
      borderLineType,
    );

    return THLinePainter(
      lineInfo: lineInfo(ticks: false),
      lineSegmentsMap: closedSegments(),
      linePaint: areaPaint,
      lineDecorator: decorator,
      lineDecoratorColor: visualController.getLineDecoratorColor(
        borderLineType,
      ),
      th2FileEditController: controller,
    );
  }

  Future<void> pumpAndCompare(
    WidgetTester tester,
    List<MPSymbolGoldenEntry> entries,
    String goldenName,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(_cellSize * entries.length, _cellSize);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: MPSymbolGoldenHarness(entries: entries, cellSize: _cellSize),
        ),
      ),
    );

    await expectLater(
      find.byType(MPSymbolGoldenHarness),
      matchesGoldenFile(goldenName),
    );
  }

  testWidgets('placeholder strokes, dashes, highlight borders and ticks', (
    WidgetTester tester,
  ) async {
    setMethod(MPTH2EditVisualizationMethod.mapiahPlaceholder);

    final List<MPSymbolGoldenEntry> entries = <MPSymbolGoldenEntry>[
      entryFor(linePainter(lineType: THLineType.wall)),
      entryFor(linePainter(lineType: THLineType.wall, ticks: true)),
      entryFor(linePainter(lineType: THLineType.pitChimney)),
      entryFor(linePainter(lineType: THLineType.pitch, ticks: true)),
      entryFor(linePainter(lineType: THLineType.wall, hasID: true)),
      entryFor(linePainter(lineType: THLineType.rockEdge, hasID: true)),
      entryFor(
        areaPainter(
          areaType: THAreaType.water,
          borderLineType: THLineType.border,
        ),
        backdrop: true,
      ),
    ];

    await pumpAndCompare(
      tester,
      entries,
      'goldens/th_line_painter_placeholder.png',
    );
  });

  testWidgets('Therion decoration, ticks over decoration and patterns', (
    WidgetTester tester,
  ) async {
    setMethod(MPTH2EditVisualizationMethod.therionUIS);

    final List<MPSymbolGoldenEntry> uisEntries = <MPSymbolGoldenEntry>[
      entryFor(linePainter(lineType: THLineType.pit)),
      entryFor(linePainter(lineType: THLineType.pit, ticks: true)),
      entryFor(linePainter(lineType: THLineType.gradient, ticks: true)),
      entryFor(linePainter(lineType: THLineType.wall, ticks: true)),
      entryFor(
        areaPainter(
          areaType: THAreaType.water,
          borderLineType: THLineType.border,
        ),
        backdrop: true,
      ),
    ];

    setMethod(MPTH2EditVisualizationMethod.therionSKBB);

    final List<MPSymbolGoldenEntry> skbbEntries = <MPSymbolGoldenEntry>[
      entryFor(linePainter(lineType: THLineType.pitch, ticks: true)),
      entryFor(
        areaPainter(
          areaType: THAreaType.water,
          borderLineType: THLineType.unknown,
        ),
        backdrop: true,
      ),
      entryFor(
        areaPainter(
          areaType: THAreaType.blocks,
          borderLineType: THLineType.unknown,
        ),
        backdrop: true,
      ),
      entryFor(
        areaPainter(areaType: THAreaType.clay, borderLineType: THLineType.wall),
      ),
    ];

    await pumpAndCompare(
      tester,
      <MPSymbolGoldenEntry>[...uisEntries, ...skbbEntries],
      'goldens/th_line_painter_therion.png',
    );
  });
}
