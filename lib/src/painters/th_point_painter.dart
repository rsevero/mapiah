import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_point.dart';

class THPointPainter extends CustomPainter {
  final THPoint point;
  final double pointRadius;
  final Paint pointPaint;
  final Offset position;

  THPointPainter({
    super.repaint,
    required this.point,
    required this.pointRadius,
    required this.pointPaint,
  }) : position = Offset(point.position.x, point.position.y);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      position,
      pointRadius,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant THPointPainter oldDelegate) {
    return (pointRadius != oldDelegate.pointRadius) ||
        (pointPaint != oldDelegate.pointPaint) ||
        (point.position.x != oldDelegate.point.position.x) ||
        (point.position.y != oldDelegate.point.position.y) ||
        (point.plaType != oldDelegate.point.plaType);
  }
}
