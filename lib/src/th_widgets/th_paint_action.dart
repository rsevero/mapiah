import 'package:flutter/material.dart';
import 'package:mapiah/src/th_definitions/th_paints.dart';

sealed class THPaintAction {
  final Paint _paint;

  THPaintAction(Paint aPaint) : _paint = aPaint;

  Paint get paint => _paint;
}

class THPointPaintAction extends THPaintAction {
  final Offset center;

  THPointPaintAction(double x, double y, [Paint? aPaint])
      : center = Offset(x, y),
        super(aPaint ?? genericPointPaint);

  static Paint get genericPointPaint => THPaints.thPaint1;
}

class THStraightLinePaintAction extends THPaintAction {
  final double endPointX;
  final double endPointY;

  THStraightLinePaintAction(this.endPointX, this.endPointY, [Paint? aPaint])
      : super(aPaint ?? genericLinePaint);

  static Paint get genericLinePaint => THPaints.thPaint2;
}

class THBezierCurvePaintAction extends THStraightLinePaintAction {
  final double controlPoint1X;
  final double controlPoint1Y;
  final double controlPoint2X;
  final double controlPoint2Y;

  THBezierCurvePaintAction(
      double endPointX,
      double endPointY,
      this.controlPoint1X,
      this.controlPoint1Y,
      this.controlPoint2X,
      this.controlPoint2Y,
      [Paint? aPaint])
      : super(endPointX, endPointY,
            aPaint ?? THStraightLinePaintAction.genericLinePaint);
}

class THMoveStartPathPaintAction extends THPaintAction {
  final double x;
  final double y;

  THMoveStartPathPaintAction(this.x, this.y) : super(genericMovePaint);

  static Paint get genericMovePaint => THPaints.thPaint3;
}

class THEndPathPaintAction extends THPaintAction {
  THEndPathPaintAction() : super(genericEndPaint);

  static Paint get genericEndPaint => THPaints.thPaint4;
}
