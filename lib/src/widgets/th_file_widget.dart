import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_endline.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/widgets/th_paint_action.dart';

class THFileWidget extends StatelessWidget {
  final THFile file;
  final List<THPaintAction> _paintActions = [];
  final THFileDisplayStore thFileDisplayStore;

  THFileWidget(this.file, this.thFileDisplayStore)
      : super(key: ObjectKey(file)) {
    thFileDisplayStore.updateDataBoundingBox(file.boundingBox());
    thFileDisplayStore.setCanvasScaleTranslationUndefined(true);
    for (final int childMapiahID in file.childrenMapiahID) {
      final THElement child = file.elementByMapiahID(childMapiahID);
      if (child is THScrap) {
        _addScrapPaintActions(child);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        thFileDisplayStore.updateScreenSize(
            Size(constraints.maxWidth, constraints.maxHeight));

        if (thFileDisplayStore.canvasScaleTranslationUndefined) {
          thFileDisplayStore.zoomShowAll();
        }

        return GestureDetector(
          onPanUpdate: thFileDisplayStore.onPanUpdate,
          child: Observer(
            builder: (context) {
              thFileDisplayStore.trigger;
              return CustomPaint(
                /// Creating another CustomPaint as child of this CustomPaint
                /// because CustomPaint creates 3 layers, from bottom to top:
                /// painter, child and foregroundPainter.
                /// The actual drawing is paint as the middle layer (child) so
                /// I can put grids below it (as the main CustomPaint painter)
                /// and a scale above it.
                child: CustomPaint(
                  painter: THFilePainter(_paintActions, thFileDisplayStore),
                  size: thFileDisplayStore.screenSize,
                ),
                size: thFileDisplayStore.screenSize,
              );
            },
          ),
        );
      },
    );
  }

  void _addScrapPaintActions(THScrap aScrap) {
    for (final int childMapiahID in aScrap.childrenMapiahID) {
      final THElement child = file.elementByMapiahID(childMapiahID);
      if (child is THPoint) {
        final THPointPaintAction newPointPaintAction =
            THPointPaintAction(child.x, child.y);
        _paintActions.add(newPointPaintAction);
      } else if (child is THLine) {
        bool isFirst = true;
        for (final int lineSegmentMapiahID in child.childrenMapiahID) {
          final THElement lineSegment =
              file.elementByMapiahID(lineSegmentMapiahID);
          if (lineSegment is THEndline) {
            continue;
          }

          if (isFirst) {
            final THLineSegment initialLineSegment =
                lineSegment as THLineSegment;
            final THMoveStartPathPaintAction newMovePaintAction =
                THMoveStartPathPaintAction(
                    initialLineSegment.endPointX, initialLineSegment.endPointY);
            _paintActions.add(newMovePaintAction);
            isFirst = false;
            continue;
          }

          if (lineSegment is THStraightLineSegment) {
            final THStraightLinePaintAction newStraightLinePaintAction =
                THStraightLinePaintAction(
                    lineSegment.endPointX, lineSegment.endPointY);
            _paintActions.add(newStraightLinePaintAction);
          } else if (lineSegment is THBezierCurveLineSegment) {
            final THBezierCurvePaintAction newBezierCurvePaintAction =
                THBezierCurvePaintAction(
                    lineSegment.endPointX,
                    lineSegment.endPointY,
                    lineSegment.controlPoint1X,
                    lineSegment.controlPoint1Y,
                    lineSegment.controlPoint2X,
                    lineSegment.controlPoint2Y);
            _paintActions.add(newBezierCurvePaintAction);
          }
        }
        if (!isFirst) {
          _paintActions.add(THEndPathPaintAction());
        }
      }
    }
  }
}

class THFilePainter extends CustomPainter {
  final List<THPaintAction> _paintActions;
  final THFileDisplayStore thFileStore;

  THFilePainter(this._paintActions, this.thFileStore);

  @override
  void paint(Canvas canvas, Size size) {
    // Transformations are applied on the order they are defined.
    canvas.scale(thFileStore.canvasScale);
    // // Drawing canvas border
    // canvas.drawRect(
    //     Rect.fromPoints(
    //         Offset(0, 0),
    //         Offset(
    //           thFileController.canvasSize.width,
    //           thFileController.canvasSize.height,
    //         )),
    //     THPaints.thPaint7);
    canvas.translate(
        thFileStore.canvasTranslation.dx, thFileStore.canvasTranslation.dy);
    canvas.scale(1, -1);

    Path newPath = Path();
    for (final THPaintAction paintAction in _paintActions) {
      switch (paintAction) {
        case THPointPaintAction _:
          canvas.drawCircle(paintAction.center, 5, paintAction.paint);
        case THBezierCurvePaintAction _:
          newPath.cubicTo(
              paintAction.controlPoint1X,
              paintAction.controlPoint1Y,
              paintAction.controlPoint2X,
              paintAction.controlPoint2Y,
              paintAction.endPointX,
              paintAction.endPointY);
        case THStraightLinePaintAction _:
          newPath.lineTo(paintAction.endPointX, paintAction.endPointY);
        case THMoveStartPathPaintAction _:
          newPath = Path()..moveTo(paintAction.x, paintAction.y);
        case THEndPathPaintAction _:
          canvas.drawPath(newPath, paintAction.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant oldDelegate) {
    if (thFileStore.shouldRepaint) {
      thFileStore.setShouldRepaint(false);
      return true;
    }
    return false;
  }
}
