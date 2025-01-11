import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/th_paints.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_settings_store.dart';

sealed class THPaintAction {
  final Paint _paint;

  THPaintAction(Paint paint) : _paint = paint;

  Paint get paint => _paint;

  bool contains(Offset localPosition);
}

class THPointPaintAction extends THPaintAction
    with THPaintActionPositionElement {
  THPointPaintAction(THPoint point, [Paint? paint])
      : super(paint ?? genericPointPaint) {
    position = Offset(point.x, point.y);
    element = point;
  }

  static Paint get genericPointPaint => THPaints.thPaint1;

  @override
  bool contains(Offset localPosition) {
    return (positionOnScreen - localPosition).distanceSquared <
        getIt<THSettingsStore>().selectionToleranceSquared;
  }
}

class THStraightLinePaintAction extends THPaintAction
    with THPaintActionPositionElement {
  THStraightLinePaintAction(THStraightLineSegment lineSegment, [Paint? aPaint])
      : super(aPaint ?? genericLinePaint) {
    position = Offset(lineSegment.x, lineSegment.y);
    element = lineSegment as THElement;
  }

  static Paint get genericLinePaint => THPaints.thPaint2;

  @override
  bool contains(Offset localPosition) {
    return (positionOnScreen - localPosition).distanceSquared <
        getIt<THSettingsStore>().selectionToleranceSquared;
  }
}

class THBezierCurvePaintAction extends THPaintAction
    with THPaintActionPositionElement {
  final double controlPoint1X;
  final double controlPoint1Y;
  final double controlPoint2X;
  final double controlPoint2Y;

  THBezierCurvePaintAction(THBezierCurveLineSegment lineSegment,
      [Paint? aPaint])
      : controlPoint1X = lineSegment.controlPoint1.x,
        controlPoint1Y = lineSegment.controlPoint1.y,
        controlPoint2X = lineSegment.controlPoint2.x,
        controlPoint2Y = lineSegment.controlPoint2.y,
        super(aPaint ?? THStraightLinePaintAction.genericLinePaint) {
    position = Offset(lineSegment.x, lineSegment.y);
    element = lineSegment as THElement;
  }

  @override
  bool contains(Offset localPosition) {
    return (positionOnScreen - localPosition).distanceSquared <
        getIt<THSettingsStore>().selectionToleranceSquared;
  }
}

class THMoveStartPathPaintAction extends THPaintAction
    with THPaintActionPositionElement {
  THMoveStartPathPaintAction(THPointInterface pointPositionElement)
      : super(genericMovePaint) {
    position = Offset(pointPositionElement.x, pointPositionElement.y);
    element = pointPositionElement as THElement;
  }

  static Paint get genericMovePaint => THPaints.thPaint3;

  @override
  bool contains(Offset localPosition) {
    return (positionOnScreen - localPosition).distanceSquared <
        getIt<THSettingsStore>().selectionToleranceSquared;
  }
}

class THEndPathPaintAction extends THPaintAction {
  THEndPathPaintAction() : super(genericEndPaint);

  static Paint get genericEndPaint => THPaints.thPaint4;

  @override
  bool contains(Offset localPosition) {
    return false;
  }
}

mixin THPaintActionPositionElement {
  late final THElement _element;
  late final Offset _position;
  late final Offset _positionOnScreen;

  THElement get element => _element;

  Offset get position => _position;

  Offset get positionOnScreen => _positionOnScreen;

  set element(THElement element) {
    _element = element;
  }

  set position(Offset position) {
    _position = position;
    _positionOnScreen = getIt<THFileDisplayStore>().canvasToScreen(position);
  }

  double get x => _position.dx;

  double get y => _position.dy;
}
