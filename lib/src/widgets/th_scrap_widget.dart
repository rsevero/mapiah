import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/th_paints.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';

class THScrapWidget extends StatelessWidget {
  final THScrap thScrap;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

  THScrapWidget(this.thScrap);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final List<Widget> drawableElements = [];
        final List<int> scrapChildrenMapiahIDs = thScrap.childrenMapiahID;
        final THFile thFile = thScrap.thFile;
        final double pointRadius = thFileDisplayStore.pointRadiusOnCanvas;
        final double lineThickness = thFileDisplayStore.lineThicknessOnCanvas;
        final Paint pointPaint = THPaints.thPaint1..strokeWidth = lineThickness;
        final Paint linePaint = THPaints.thPaint2..strokeWidth = lineThickness;
        final Size screenSize = thFileDisplayStore.screenSize;

        for (final int childMapiahID in scrapChildrenMapiahIDs) {
          final THElement child = thFile.elementByMapiahID(childMapiahID);

          switch (child) {
            case THPoint _:
              drawableElements.add(THPointWidget(
                point: child,
                pointRadius: pointRadius,
                pointPaint: pointPaint,
                thFileDisplayStore: thFileDisplayStore,
                screenSize: screenSize,
              ));
              break;
            case THLine _:
              drawableElements.add(THLineWidget(
                line: child,
                linePaint: linePaint,
                thFileDisplayStore: thFileDisplayStore,
                screenSize: screenSize,
              ));
              break;
          }
        }

        return Stack(
          children: drawableElements,
        );
      },
    );
  }
}
