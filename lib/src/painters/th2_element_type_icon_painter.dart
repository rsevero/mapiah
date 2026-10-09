// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' as ui;

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/types/mp_th2_edit_visualization_method.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_line_path_painter.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/helpers/th2_element_type_preview_cache.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_fixed_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_steps_skbb_line_decorator.dart';
import 'package:material_ui/material_ui.dart';

/// Everything an element-type preview's picture depends on. Two elements
/// share a preview exactly when their keys are equal: geometry, MPID,
/// file, selection and every option other than the subtype stay out.
@immutable
class TH2ElementTypePreviewKey {
  /// [THElementType.point], [THElementType.line] or [THElementType.area].
  final THElementType kind;

  /// The element's [THPointType], [THLineType] or [THAreaType].
  final Enum type;

  /// The subtype, or [mpNoSubtypeID]. Always [mpNoSubtypeID] for areas,
  /// whose rendering ignores subtypes.
  final String subtype;

  /// Also fixes the Therion symbol set.
  final MPTH2EditVisualizationMethod visualizationMethod;

  final double devicePixelRatio;

  /// The frame color (`colorScheme.outline`).
  final Color outlineColor;

  /// The icon interior, the canvas interior color.
  final Color interiorColor;

  const TH2ElementTypePreviewKey({
    required this.kind,
    required this.type,
    required this.subtype,
    required this.visualizationMethod,
    required this.devicePixelRatio,
    required this.outlineColor,
    required this.interiorColor,
  }) : assert(
         (kind == THElementType.point) ||
             (kind == THElementType.line) ||
             (kind == THElementType.area),
       );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return (other is TH2ElementTypePreviewKey) &&
        (other.kind == kind) &&
        (other.type == type) &&
        (other.subtype == subtype) &&
        (other.visualizationMethod == visualizationMethod) &&
        (other.devicePixelRatio == devicePixelRatio) &&
        (other.outlineColor == outlineColor) &&
        (other.interiorColor == interiorColor);
  }

  @override
  int get hashCode => Object.hash(
    kind,
    type,
    subtype,
    visualizationMethod,
    devicePixelRatio,
    outlineColor,
    interiorColor,
  );

  @override
  String toString() =>
      'TH2ElementTypePreviewKey($kind, $type, $subtype, '
      '$visualizationMethod, $devicePixelRatio, $outlineColor, '
      '$interiorColor)';
}

/// The fixed synthetic geometry a line preview is drawn and decorated
/// along, in the icon's Y-up coordinates centered on the icon.
class TH2ElementTypeLineSample {
  final Path path;
  final List<Offset> vertices;
  final List<THLinePainterLineSegment> segments;

  const TH2ElementTypeLineSample({
    required this.path,
    required this.vertices,
    required this.segments,
  });

  /// The sample for [decorator]: the SKBB `steps` decorator gets its rails
  /// sample, the SKBB `fixed-ladder` decorator the subdivided S-curve and
  /// every other decorator, or none, the single cubic S-curve.
  static TH2ElementTypeLineSample forDecorator(MPLineDecorator? decorator) {
    return switch (decorator) {
      MPStepsSKBBLineDecorator _ => steps(),
      MPFixedLadderSKBBLineDecorator _ => subdividedSCurve(),
      _ => sCurve(),
    };
  }

  /// The four control points of the fixed cubic S-curve.
  static List<Offset> sCurveControlPoints() {
    const double halfWidth = mpTH2ElementTypeIconLineHalfWidth;
    const double halfHeight = mpTH2ElementTypeIconLineHalfHeight;

    return const <Offset>[
      Offset(-halfWidth, 0),
      Offset(-halfWidth / 3, halfHeight * 2),
      Offset(halfWidth / 3, -halfHeight * 2),
      Offset(halfWidth, 0),
    ];
  }

  /// One cubic segment from the start to the end of the S-curve.
  static TH2ElementTypeLineSample sCurve() {
    final List<Offset> controls = sCurveControlPoints();

    return _fromCubics(start: controls.first, cubics: <List<Offset>>[
      controls.sublist(1),
    ]);
  }

  /// The S-curve split into [mpTH2ElementTypeIconLineSubdivisions] cubic
  /// segments at evenly spaced parameters. Each piece reproduces its part
  /// of the curve exactly, so the path is unchanged while its knots are
  /// spread along it.
  static TH2ElementTypeLineSample subdividedSCurve() {
    final List<Offset> controls = sCurveControlPoints();
    const int count = mpTH2ElementTypeIconLineSubdivisions;
    final List<List<Offset>> cubics = <List<Offset>>[];

    for (int i = 0; i < count; i++) {
      final double from = i / count;
      final double to = (i + 1) / count;
      final double third = (to - from) / 3;

      cubics.add(<Offset>[
        _cubicPoint(controls, from) + (_cubicDerivative(controls, from) * third),
        _cubicPoint(controls, to) - (_cubicDerivative(controls, to) * third),
        _cubicPoint(controls, to),
      ]);
    }

    return _fromCubics(start: controls.first, cubics: cubics);
  }

  /// Five straight-line points for the SKBB `steps` decorator: a discarded
  /// first point, then the upper rail left to right and the lower rail
  /// right to left, giving two rails and two end rungs.
  static TH2ElementTypeLineSample steps() {
    const double halfWidth = mpTH2ElementTypeIconLineHalfWidth;
    const double halfGap = mpTH2ElementTypeIconStepsRailHalfGap;
    const List<Offset> points = <Offset>[
      Offset(-halfWidth, 0),
      Offset(-halfWidth, halfGap),
      Offset(halfWidth, halfGap),
      Offset(halfWidth, -halfGap),
      Offset(-halfWidth, -halfGap),
    ];
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    return TH2ElementTypeLineSample(
      path: path,
      vertices: points,
      segments: <THLinePainterLineSegment>[
        for (final Offset point in points)
          THLinePainterStraightLineSegment(
            x: point.dx,
            y: point.dy,
            lSize: mpTH2ElementTypeIconSlopeLSize,
          ),
      ],
    );
  }

  static TH2ElementTypeLineSample _fromCubics({
    required Offset start,
    required List<List<Offset>> cubics,
  }) {
    final Path path = Path()..moveTo(start.dx, start.dy);
    final List<Offset> vertices = <Offset>[start];
    final List<THLinePainterLineSegment> segments = <THLinePainterLineSegment>[
      THLinePainterStraightLineSegment(
        x: start.dx,
        y: start.dy,
        lSize: mpTH2ElementTypeIconSlopeLSize,
      ),
    ];

    for (final List<Offset> cubic in cubics) {
      final Offset control1 = cubic[0];
      final Offset control2 = cubic[1];
      final Offset end = cubic[2];

      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );
      vertices.add(end);
      segments.add(
        THLinePainterBezierCurveLineSegment(
          x: end.dx,
          y: end.dy,
          controlPoint1X: control1.dx,
          controlPoint1Y: control1.dy,
          controlPoint2X: control2.dx,
          controlPoint2Y: control2.dy,
          lSize: mpTH2ElementTypeIconSlopeLSize,
        ),
      );
    }

    return TH2ElementTypeLineSample(
      path: path,
      vertices: vertices,
      segments: segments,
    );
  }

  static Offset _cubicPoint(List<Offset> controls, double t) {
    final double u = 1 - t;

    return (controls[0] * (u * u * u)) +
        (controls[1] * (3 * u * u * t)) +
        (controls[2] * (3 * u * t * t)) +
        (controls[3] * (t * t * t));
  }

  static Offset _cubicDerivative(List<Offset> controls, double t) {
    final double u = 1 - t;

    return ((controls[1] - controls[0]) * (3 * u * u)) +
        ((controls[2] - controls[1]) * (6 * u * t)) +
        ((controls[3] - controls[2]) * (3 * t * t));
  }
}

/// Records element-type previews: a point symbol, or a line or area sample
/// in a small frame, resolved from the type and subtype only and drawn at
/// a fixed scale.
class TH2ElementTypePreviewRecorder {
  /// The fixed symbol unit of every preview.
  static const MPSymbolUnit symbolUnit = MPSymbolUnit.preview(
    canvasValue: mpTH2ElementTypeIconSymbolUnit,
    oneMeterInLocalUnits: mpTH2ElementTypeIconOneMeter,
  );

  static const Size iconSize = Size(
    mpTH2ElementTypeIconSize,
    mpTH2ElementTypeIconSize,
  );

  /// Records the preview of [key], resolving paints through
  /// [visualController], whose active visualization method must be
  /// [TH2ElementTypePreviewKey.visualizationMethod].
  static ui.Picture record({
    required TH2ElementTypePreviewKey key,
    required MPVisualController visualController,
  }) {
    assert(
      mpLocator.mpSettingsController.tH2EditVisualizationMethod ==
          key.visualizationMethod,
    );

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    paintPreview(
      canvas: canvas,
      key: key,
      visualController: visualController,
    );

    return recorder.endRecording();
  }

  /// Paints the preview of [key] into the [iconSize] box at the origin.
  static void paintPreview({
    required Canvas canvas,
    required TH2ElementTypePreviewKey key,
    required MPVisualController visualController,
  }) {
    final bool hasFrame = key.kind != THElementType.point;
    final RRect box = RRect.fromRectAndRadius(
      Offset.zero & iconSize,
      const Radius.circular(mpTH2ElementTypeIconFrameCornerRadius),
    );

    canvas.drawRRect(box, Paint()..color = key.interiorColor);
    canvas.save();
    canvas.clipRRect(
      hasFrame ? box.deflate(mpTH2ElementTypeIconFrameThickness) : box,
    );
    // Same reflection as `TH2FileEditController.transformCanvas`: element
    // content is drawn on a Y-up canvas, as on the editor canvas.
    canvas.translate(iconSize.width / 2, iconSize.height / 2);
    canvas.scale(1, -1);
    _paintContent(
      canvas: canvas,
      key: key,
      visualController: visualController,
    );
    canvas.restore();

    if (hasFrame) {
      canvas.drawRRect(
        box.deflate(mpTH2ElementTypeIconFrameThickness / 2),
        Paint()
          ..color = key.outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = mpTH2ElementTypeIconFrameThickness,
      );
    }
  }

  static void _paintContent({
    required Canvas canvas,
    required TH2ElementTypePreviewKey key,
    required MPVisualController visualController,
  }) {
    switch (key.type) {
      case THPointType pointType:
        _paintPoint(
          canvas: canvas,
          pointType: pointType,
          subtype: key.subtype,
          visualController: visualController,
        );
      case THLineType lineType:
        _paintLine(
          canvas: canvas,
          lineType: lineType,
          subtype: key.subtype,
          visualController: visualController,
        );
      case THAreaType areaType:
        _paintArea(
          canvas: canvas,
          areaType: areaType,
          visualController: visualController,
        );
      default:
        throw ArgumentError.value(key.type, 'key.type');
    }
  }

  static void _paintPoint({
    required Canvas canvas,
    required THPointType pointType,
    required String subtype,
    required MPVisualController visualController,
  }) {
    final THPointPaint pointPaint = visualController.getPreviewPointPaint(
      pointType: pointType,
      pointSubtype: subtype,
      radius: mpTH2ElementTypeIconPointRadius,
      lineThickness: mpTH2ElementTypeIconLineThickness,
    );

    assert(pointPaint.labelPaint == null);
    MPInteractionAux.drawPoint(
      canvas: canvas,
      position: Offset.zero,
      pointPaint: pointPaint,
      symbolUnit: symbolUnit,
    );
  }

  static void _paintLine({
    required Canvas canvas,
    required THLineType lineType,
    required String subtype,
    required MPVisualController visualController,
  }) {
    final String? lineSubtype = (subtype == mpNoSubtypeID) ? null : subtype;
    final MPLineDecorator? decorator = visualController.getLineDecorator(
      lineType,
      subtype: lineSubtype,
    );
    final Paint? decoratorColor = visualController.getLineDecoratorColor(
      lineType,
      subtype: lineSubtype,
    );
    final TH2ElementTypeLineSample sample =
        TH2ElementTypeLineSample.forDecorator(decorator);

    _paintPath(
      canvas: canvas,
      path: sample.path,
      vertices: sample.vertices,
      segments: sample.segments,
      linePaint: visualController.getPreviewLinePaint(
        lineType: lineType,
        subtype: lineSubtype,
        lineThickness: mpTH2ElementTypeIconLineThickness,
      ),
      decorator: decorator,
      decoratorColor: (decoratorColor == null)
          ? null
          : Paint.from(decoratorColor),
    );
  }

  /// Draws the area's own fill and outline along a fixed oval. A real
  /// area's border lines can carry decorators of their own types; they are
  /// not part of the area type, so the preview passes none.
  static void _paintArea({
    required Canvas canvas,
    required THAreaType areaType,
    required MPVisualController visualController,
  }) {
    final Path path = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: mpTH2ElementTypeIconAreaHalfWidth * 2,
          height: mpTH2ElementTypeIconAreaHalfHeight * 2,
        ),
      );

    _paintPath(
      canvas: canvas,
      path: path,
      vertices: const <Offset>[],
      segments: const <THLinePainterLineSegment>[],
      linePaint: visualController.getPreviewAreaPaint(
        areaType: areaType,
        symbolUnit: symbolUnit,
        lineThickness: mpTH2ElementTypeIconLineThickness,
      ),
      decorator: null,
      decoratorColor: null,
    );
  }

  static void _paintPath({
    required Canvas canvas,
    required Path path,
    required List<Offset> vertices,
    required List<THLinePainterLineSegment> segments,
    required THLinePaint linePaint,
    required MPLineDecorator? decorator,
    required Paint? decoratorColor,
  }) {
    final MPLinePathPainter pathPainter = MPLinePathPainter(
      path: path,
      vertices: vertices,
      lineSegments: segments,
      linePaint: linePaint,
      lineDecorator: decorator,
      lineDecoratorColor: decoratorColor,
      symbolUnit: symbolUnit,
      dashScale: mpTH2ElementTypeIconDashScale,
      isReversed: false,
      mpID: mpTH2ElementTypeIconSyntheticMPID,
      showBorder: false,
      arrowHead: THOptionChoicesArrowPositionType.end,
    );
    final Path basePath = pathPainter.buildBasePath();

    pathPainter.paintBase(canvas, basePath);
    pathPainter.paintDecoration(canvas, basePath);
  }
}

/// Draws one element-type preview through the app-wide preview cache.
///
/// It keeps only the key and the controller that resolves paints: each
/// paint looks the key up again, recording the picture when the cache no
/// longer holds it.
class TH2ElementTypeIconPainter extends CustomPainter {
  final TH2ElementTypePreviewKey previewKey;
  final MPVisualController visualController;
  final TH2ElementTypePreviewCache<TH2ElementTypePreviewKey> cache;

  TH2ElementTypeIconPainter({
    required this.previewKey,
    required this.visualController,
    required this.cache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    cache.draw(
      canvas: canvas,
      key: previewKey,
      record: () => TH2ElementTypePreviewRecorder.record(
        key: previewKey,
        visualController: visualController,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant TH2ElementTypeIconPainter oldDelegate) {
    return (previewKey != oldDelegate.previewKey) ||
        !identical(visualController, oldDelegate.visualController) ||
        !identical(cache, oldDelegate.cache);
  }
}
