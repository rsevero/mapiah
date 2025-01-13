import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/painters/th_scrap_painter.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THFilePainter extends CustomPainter {
  final THFile thFile;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

  THFilePainter(this.thFile);

  @override
  void paint(Canvas canvas, Size size) {
    // Transformations are applied on the order they are defined.
    canvas.scale(thFileDisplayStore.canvasScale);
    // // Drawing canvas border
    // canvas.drawRect(
    //     Rect.fromPoints(
    //         Offset(0, 0),
    //         Offset(
    //           thFileController.canvasSize.width,
    //           thFileController.canvasSize.height,
    //         )),
    //     THPaints.thPaint7);
    canvas.translate(thFileDisplayStore.canvasTranslation.dx,
        thFileDisplayStore.canvasTranslation.dy);
    canvas.scale(1, -1);

    final List<int> fileChildrenMapiahIDs = thFile.childrenMapiahID;

    for (final int childMapiahID in fileChildrenMapiahIDs) {
      final THElement child = thFile.elementByMapiahID(childMapiahID);

      if (child is! THScrap) {
        continue;
      }

      final THScrapPainter scrapPainter = THScrapPainter(
        scrap: child,
        isSelected: false,
      );

      scrapPainter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant THFilePainter oldDelegate) {
    return false;
  }
}
