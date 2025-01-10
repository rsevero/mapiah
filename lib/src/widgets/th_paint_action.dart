import 'package:flutter/material.dart';
import 'package:mapiah/src/definitions/th_paints.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';

sealed class THPaintAction {
  final Paint _paint;

  THPaintAction(Paint paint) : _paint = paint;

  Paint get paint => _paint;

  bool contains(Offset localPosition);
}

class THPointPaintAction extends THPaintAction with THPaintActionElement {
  final Offset center;

  THPointPaintAction(THPoint point, [Paint? paint])
      : center = Offset(point.x, point.y),
        super(paint ?? genericPointPaint) {
    element = point;
  }

  static Paint get genericPointPaint => THPaints.thPaint1;

  @override
  bool contains(Offset localPosition) {
    return (center - localPosition).distanceSquared <
        100; // TODO - substitute with THSettingsStore.selectionToleranceSquared
  }
}

class THStraightLinePaintAction extends THPaintAction
    with THPaintActionElement {
  final double endPointX;
  final double endPointY;

  THStraightLinePaintAction(THStraightLineSegment lineSegment, [Paint? aPaint])
      : endPointX = lineSegment.endPointPosition.xDoublePart.value,
        endPointY = lineSegment.endPointPosition.yDoublePart.value,
        super(aPaint ?? genericLinePaint) {
    element = lineSegment;
  }

  static Paint get genericLinePaint => THPaints.thPaint2;

  @override
  bool contains(Offset localPosition) {
    return false; // TODO - implement
  }
}

class THBezierCurvePaintAction extends THStraightLinePaintAction
    with THPaintActionElement {
  final double controlPoint1X;
  final double controlPoint1Y;
  final double controlPoint2X;
  final double controlPoint2Y;

  THBezierCurvePaintAction(THBezierCurveLineSegment lineSegment,
      [Paint? aPaint])
      : controlPoint1X = lineSegment.controlPoint1.xDoublePart.value,
        controlPoint1Y = lineSegment.controlPoint1.yDoublePart.value,
        controlPoint2X = lineSegment.controlPoint2.xDoublePart.value,
        controlPoint2Y = lineSegment.controlPoint2.yDoublePart.value,
        super(lineSegment as THStraightLineSegment,
            aPaint ?? THStraightLinePaintAction.genericLinePaint);
}

class THMoveStartPathPaintAction extends THPaintAction
    with THPaintActionElement {
  final double x;
  final double y;

  THMoveStartPathPaintAction(THPointInterface element)
      : x = element.x,
        y = element.y,
        super(genericMovePaint) {
    this.element = element as THElement;
  }

  static Paint get genericMovePaint => THPaints.thPaint3;

  @override
  bool contains(Offset localPosition) {
    return false; // TODO - implement
  }
}

class THEndPathPaintAction extends THPaintAction {
  THEndPathPaintAction() : super(genericEndPaint);

  static Paint get genericEndPaint => THPaints.thPaint4;

  @override
  bool contains(Offset localPosition) {
    return false; // TODO - implement
  }
}

mixin THPaintActionElement {
  late final THElement _element;

  THElement get element => _element;

  set element(THElement element) {
    _element = element;
  }
}
