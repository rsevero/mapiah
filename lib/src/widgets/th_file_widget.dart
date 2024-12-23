import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
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
  final THFileStore thFileStore;

  THFileWidget(this.file, this.thFileStore) : super(key: ObjectKey(file)) {
    thFileStore.updateDataBoundingBox(file.boundingBox());
    thFileStore.setCanvasScaleTranslationUndefined(true);
    for (final child in file.children) {
      if (child is THScrap) {
        _addScrapPaintActions(child);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        thFileStore.updateScreenSize(
            Size(constraints.maxWidth, constraints.maxHeight));

        if (thFileStore.canvasScaleTranslationUndefined) {
          thFileStore.zoomShowAll();
        }

        return GestureDetector(
          onPanUpdate: thFileStore.onPanUpdate,
          child: Observer(
            builder: (context) {
              thFileStore.trigger;
              return CustomPaint(
                /// Creating another CustomPaint as child of this CustomPaint
                /// because CustomPaint creates 3 layers, from bottom to top:
                /// painter, child and foregroundPainter.
                /// The actual drawing is paint as the middle layer (child) so
                /// I can put grids below it (as the main CustomPaint painter)
                /// and a scale above it.
                child: CustomPaint(
                  painter: THFilePainter(_paintActions, thFileStore),
                  size: thFileStore.screenSize,
                ),
                size: thFileStore.screenSize,
              );
            },
          ),
        );
      },
    );
  }

  void _addScrapPaintActions(THScrap aScrap) {
    for (final child in aScrap.children) {
      if (child is THPoint) {
        final newPointPaintAction = THPointPaintAction(child.x, child.y);
        _paintActions.add(newPointPaintAction);
      } else if (child is THLine) {
        var isFirst = true;
        for (final lineSegment in child.children) {
          if (lineSegment is THEndline) {
            continue;
          }
          if (isFirst) {
            final initialLineSegment = lineSegment as THLineSegment;
            final newMovePaintAction = THMoveStartPathPaintAction(
                initialLineSegment.endPointX, initialLineSegment.endPointY);
            _paintActions.add(newMovePaintAction);
            isFirst = false;
            continue;
          }

          if (lineSegment is THStraightLineSegment) {
            final newStraightLinePaintAction = THStraightLinePaintAction(
                lineSegment.endPointX, lineSegment.endPointY);
            _paintActions.add(newStraightLinePaintAction);
          } else if (lineSegment is THBezierCurveLineSegment) {
            final newBezierCurvePaintAction = THBezierCurvePaintAction(
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
  final THFileStore thFileStore;

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

    var newPath = Path();
    for (final paintAction in _paintActions) {
      switch (paintAction.runtimeType) {
        case THPointPaintAction:
          final pointPaintAction = paintAction as THPointPaintAction;
          canvas.drawCircle(pointPaintAction.center, 5, paintAction.paint);
        case THBezierCurvePaintAction:
          final bezierCurvePaintAction =
              paintAction as THBezierCurvePaintAction;
          newPath.cubicTo(
              bezierCurvePaintAction.controlPoint1X,
              bezierCurvePaintAction.controlPoint1Y,
              bezierCurvePaintAction.controlPoint2X,
              bezierCurvePaintAction.controlPoint2Y,
              bezierCurvePaintAction.endPointX,
              bezierCurvePaintAction.endPointY);
        case THStraightLinePaintAction:
          final straightLinePaintAction =
              paintAction as THStraightLinePaintAction;
          newPath.lineTo(straightLinePaintAction.endPointX,
              straightLinePaintAction.endPointY);
        case THMoveStartPathPaintAction:
          final moveStartPathPaintAction =
              paintAction as THMoveStartPathPaintAction;
          newPath = Path()
            ..moveTo(moveStartPathPaintAction.x, moveStartPathPaintAction.y);
        case THEndPathPaintAction:
          canvas.drawPath(newPath, paintAction.paint);
      }
    }

    // Rect.fromLTWH(
    //   thFileController.canvasOffsetDrawing.dx,
    //   thFileController.canvasOffsetDrawing.dy,
    //   thFileController.canvasSize.value.width,
    //   thFileController.canvasSize.value.height,
    // ),
    // THPaints.thPaint7);

    // // Drawing canvas border
    // canvas.drawRect(
    //     Rect.fromPoints(
    //         thFileController.screenToCanvas(Offset(0, 0)),
    //         thFileController.screenToCanvas(Offset(
    //           thFileController.screenSize.value.width,
    //           thFileController.screenSize.value.height,
    //         ))),
    //     THPaints.thPaint9);

    // // Canvas center after transformation
    // canvas.drawCircle(
    //     Offset(thFileController.canvasCenterX, thFileController.canvasCenterY),
    //     3,
    //     THPaints.thPaint5);

    // // Drawing center
    // canvas.drawCircle(
    //     Offset(thFileController.dataBoundingBox.center.dx,
    //         thFileController.dataBoundingBox.center.dy),
    //     2,
    //     THPaints.thPaint2);

    // // Drawing bounding box
    // canvas.drawRect(thFileController.dataBoundingBox, THPaints.thPaint2);

    // print("screenSize: ${thFileController.screenSize}");
    // print("dataWidth: ${thFileController.dataWidth}");
    // print("dataHeight: ${thFileController.dataHeight}");
    // print("dataBoundingBox: ${thFileController.dataBoundingBox}");
    // print("canvasTranslation: ${thFileController.canvasTranslation}");
    // print("canvasSize: ${thFileController.canvasSize}");
    // print("canvasScale: ${thFileController.canvasScale}");
    // print(
    //     "canvasCenter: ${thFileController.canvasCenterX}, ${thFileController.canvasCenterY}");
  }

  @override
  bool shouldRepaint(covariant oldDelegate) {
    // print(
    //     "shouldRepaint with ${thFileController.shouldRepaint}: ${DateTime.now()}\n");
    if (thFileStore.shouldRepaint) {
      thFileStore.setShouldRepaint(false);
      return true;
    }
    return false;
  }
}
