import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';

class THLineWidget extends StatelessWidget {
  final THLine line;
  final THFileEditStore thFileEditStore;
  final int thFileMapiahID;
  final int thScrapMapiahID;

  THLineWidget({
    required super.key,
    required this.line,
    required this.thFileEditStore,
    required this.thFileMapiahID,
    required this.thScrapMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        thFileEditStore.elementRedrawTrigger[thFileMapiahID]!.value;
        thFileEditStore.elementRedrawTrigger[thScrapMapiahID]!.value;
        thFileEditStore.elementRedrawTrigger[line.mapiahID]!.value;

        final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
            getLineSegmentsMap();

        final THLinePaint linePaint = thFileEditStore.getLinePaint(line);

        return RepaintBoundary(
          child: CustomPaint(
            painter: THLinePainter(
              lineSegmentsMap: lineSegmentsMap,
              linePaint: linePaint.paint,
              thFileEditStore: thFileEditStore,
            ),
            size: thFileEditStore.screenSize,
          ),
        );
      },
    );
  }

  LinkedHashMap<int, THLinePainterLineSegment> getLineSegmentsMap() {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final List<int> lineChildrenMapiahIDs = line.childrenMapiahID;
    bool isFirst = true;
    final THFile thFile = thFileEditStore.thFile;

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
        thFileEditStore.addSelectableElement(MPSelectableElement(
          element: lineChild,
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
      thFileEditStore.addSelectableElement(MPSelectableElement(
        element: lineChild,
        position: lineChild.endPoint.coordinates,
      ));
    }

    return lineSegmentsMap;
  }
}
