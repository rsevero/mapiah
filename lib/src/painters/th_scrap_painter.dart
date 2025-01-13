import 'package:flutter/widgets.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/th_paints.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THScrapPainter extends CustomPainter {
  final THScrap scrap;
  final bool isSelected;
  final THFile thFile;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

  THScrapPainter({
    required this.scrap,
    required this.isSelected,
  }) : thFile = scrap.thFile;

  @override
  void paint(Canvas canvas, Size size) {
    final List<int> scrapChildrenMapiahIDs = scrap.childrenMapiahID;
    final double pointRadiusOnCanvas = thFileDisplayStore.pointRadiusOnCanvas;
    final double lineThicknessOnCanvas =
        thFileDisplayStore.lineThicknessOnCanvas;
    final Paint pointPaint = THPaints.thPaint1
      ..strokeWidth = lineThicknessOnCanvas;
    final Paint linePaint = THPaints.thPaint2
      ..strokeWidth = lineThicknessOnCanvas;

    for (int childMapiahID in scrapChildrenMapiahIDs) {
      final THElement child = thFile.elementByMapiahID(childMapiahID);

      switch (child) {
        case THPoint _:
          final THPointPainter pointPainter = THPointPainter(
            point: child,
            pointRadius: pointRadiusOnCanvas,
            pointPaint: pointPaint,
          );
          pointPainter.paint(canvas, size);
          break;
        case THLine _:
          final THLinePainter linePainter = THLinePainter(
            line: child,
            linePaint: linePaint,
          );
          linePainter.paint(canvas, size);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant THScrapPainter oldDelegate) {
    return (isSelected != oldDelegate.isSelected);
  }
}
