import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class THLineWidget extends StatelessWidget {
  final int lineMapiahID;
  final TH2FileEditStore th2FileEditStore;
  final int thFileMapiahID;
  final int thScrapMapiahID;

  THLineWidget({
    required super.key,
    required this.lineMapiahID,
    required this.th2FileEditStore,
    required this.thFileMapiahID,
    required this.thScrapMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final THLine line =
            th2FileEditStore.thFile.elementByMapiahID(lineMapiahID) as THLine;

        th2FileEditStore.elementRedrawTrigger[thFileMapiahID]!.value;
        th2FileEditStore.elementRedrawTrigger[thScrapMapiahID]!.value;
        th2FileEditStore.elementRedrawTrigger[lineMapiahID]!.value;
        th2FileEditStore.isSelected[lineMapiahID]!.value;

        final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
            getLineSegmentsMap(line);

        final THLinePaint linePaint = th2FileEditStore.getLinePaint(line);

        return RepaintBoundary(
          child: CustomPaint(
            painter: THLinePainter(
              lineSegmentsMap: lineSegmentsMap,
              linePaint: linePaint.paint,
              th2FileEditStore: th2FileEditStore,
            ),
            size: th2FileEditStore.screenSize,
          ),
        );
      },
    );
  }

  LinkedHashMap<int, THLinePainterLineSegment> getLineSegmentsMap(THLine line) {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final List<int> lineChildrenMapiahIDs = line.childrenMapiahID;
    bool isFirst = true;
    final THFile thFile = th2FileEditStore.thFile;

    for (int lineChildMapiahID in lineChildrenMapiahIDs) {
      final THElement lineChild = thFile.elementByMapiahID(lineChildMapiahID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        lineSegmentsMap[lineChildMapiahID] = THLinePainterStraightLineSegment(
          x: lineChild.x,
          y: lineChild.y,
        );
        isFirst = false;
        th2FileEditStore.addSelectableElement(MPSelectableElement(
          element: line,
          position: lineChild.endPoint.coordinates,
        ));
        continue;
      }

      switch (lineChild) {
        case THBezierCurveLineSegment _:
          lineSegmentsMap[lineChildMapiahID] =
              THLinePainterBezierCurveLineSegment(
            x: lineChild.x,
            y: lineChild.y,
            controlPoint1X: lineChild.controlPoint1X,
            controlPoint1Y: lineChild.controlPoint1Y,
            controlPoint2X: lineChild.controlPoint2X,
            controlPoint2Y: lineChild.controlPoint2Y,
          );
          break;
        case THStraightLineSegment _:
          lineSegmentsMap[lineChildMapiahID] = THLinePainterStraightLineSegment(
            x: lineChild.x,
            y: lineChild.y,
          );
          break;
        default:
          continue;
      }
      th2FileEditStore.addSelectableElement(MPSelectableElement(
        element: line,
        position: lineChild.endPoint.coordinates,
      ));
    }

    return lineSegmentsMap;
  }
}
