import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_widgets/th_file_widget.dart';

class THPointWidget extends StatelessWidget {
  final THPoint point;

  final THFileController sizeController = Get.find<THFileController>();

  THPointWidget(this.point) : super(key: ObjectKey(point));

  @override
  Widget build(BuildContext context) {
    // Ensure the CanvasSizeController is available for the entire app
    final THFileController sizeController = Get.put(THFileController());

    // Use Obx to reactively build the widget when canvas size changes
    return Obx(() {
      // Now you can use the size in your CustomPaint
      final Size size = sizeController.canvasSize.value;
      return CustomPaint(
        painter: THPointPainter(point),
        size: size,
      );
    });
  }
}

class THPointPainter extends CustomPainter {
  final THPoint point;

  THPointPainter(this.point);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = Offset(point.x, point.y);
    canvas.drawCircle(center, 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final oldPoint = (oldDelegate as THPointPainter).point;
    return (point.x != oldPoint.x) ||
        (point.y != oldPoint.y) ||
        (point.plaType != oldPoint.plaType);
  }
}
