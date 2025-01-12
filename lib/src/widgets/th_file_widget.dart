import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/definitions/th_paints.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_endline.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/widgets/th_paint_action.dart';

class THFileWidget extends StatefulWidget {
  final THFileStore thFileStore;

  THFileWidget(this.thFileStore);

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  final LinkedHashMap<int, THPaintAction> _paintActions =
      LinkedHashMap<int, THPaintAction>();
  THElement? _selectedElement;
  THElement? _originalSelectedElement;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  late final THFileStore thFileStore = widget.thFileStore;
  late final THFile file = widget.thFileStore.thFile;

  @override
  void initState() {
    super.initState();
    thFileDisplayStore.updateDataBoundingBox(file.boundingBox());
    thFileDisplayStore.setCanvasScaleTranslationUndefined(true);

    final List<int> fileChildrenMapiahIDs = file.childrenMapiahID;
    for (final int childMapiahID in fileChildrenMapiahIDs) {
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
          // onPanUpdate: thFileDisplayStore.onPanUpdate,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            /// Creating another CustomPaint as child of this CustomPaint
            /// because CustomPaint creates 3 layers, from bottom to top:
            /// painter, child and foregroundPainter.
            /// The actual drawing is paint as the middle layer (child) so
            /// I can put grids below it (as the main CustomPaint painter)
            /// and a scale above it.
            child: CustomPaint(
              painter: THFilePainter(_paintActions.values),
              size: thFileDisplayStore.screenSize,
            ),
            size: thFileDisplayStore.screenSize,
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    final Offset localPositionOnCanvas =
        thFileDisplayStore.offsetScreenToCanvas(details.localPosition);
    final Iterable<THPaintAction> paintActions = _paintActions.values;

    for (final THPaintAction action in paintActions) {
      if (action is THPointPaintAction &&
          action.contains(localPositionOnCanvas)) {
        setState(() {
          _selectedElement = action.element;
          _originalSelectedElement = (_selectedElement! as THPoint).clone();
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedElement == null) {
      return;
    }

    final Offset localPositionOnCanvas =
        thFileDisplayStore.offsetScreenToCanvas(details.localPosition);

    setState(() {
      (_selectedElement! as THPointInterface).x = localPositionOnCanvas.dx;
      (_selectedElement! as THPointInterface).y = localPositionOnCanvas.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedElement == null) {
      return;
    }
    thFileStore.updatePointPosition(
        _originalSelectedElement! as THPoint, _selectedElement! as THPoint);
    setState(() {
      _selectedElement = null;
      _originalSelectedElement = null;
    });
  }

  void _addScrapPaintActions(THScrap scrap) {
    final List<int> scrapChildrenMapiahIDs = scrap.childrenMapiahID;
    _paintActions.clear();

    for (final int childMapiahID in scrapChildrenMapiahIDs) {
      final THElement child = file.elementByMapiahID(childMapiahID);

      if (child is THPoint) {
        final THPointPaintAction newPointPaintAction =
            THPointPaintAction(child);

        _paintActions[childMapiahID] = newPointPaintAction;
      } else if (child is THLine) {
        final List<int> lineChildrenMapiahIDs = child.childrenMapiahID;
        bool isFirst = true;

        for (final int lineSegmentMapiahID in lineChildrenMapiahIDs) {
          final THElement lineSegment =
              file.elementByMapiahID(lineSegmentMapiahID);

          if (lineSegment is THEndline) {
            continue;
          }

          if (isFirst) {
            final THLineSegment initialLineSegment =
                lineSegment as THLineSegment;
            final THMoveStartPathPaintAction newMovePaintAction =
                THMoveStartPathPaintAction(initialLineSegment);

            _paintActions[lineSegmentMapiahID] = newMovePaintAction;
            isFirst = false;
            continue;
          }

          if (lineSegment is THStraightLineSegment) {
            final THStraightLinePaintAction newStraightLinePaintAction =
                THStraightLinePaintAction(lineSegment);

            _paintActions[lineSegmentMapiahID] = newStraightLinePaintAction;
          } else if (lineSegment is THBezierCurveLineSegment) {
            final THBezierCurvePaintAction newBezierCurvePaintAction =
                THBezierCurvePaintAction(lineSegment);

            _paintActions[lineSegmentMapiahID] = newBezierCurvePaintAction;
          }
        }
        if (!isFirst) {
          _paintActions[-childMapiahID] = THEndPathPaintAction();
        }
      }
    }
  }
}

class THFilePainter extends CustomPainter {
  final Iterable<THPaintAction> _paintActions;
  late final THFileDisplayStore thFileDisplayStore;

  THFilePainter(this._paintActions) {
    thFileDisplayStore = getIt<THFileDisplayStore>();
  }

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

    Path newPath = Path();
    final double pointRadiusOnCanvas = thFileDisplayStore.pointRadiusOnCanvas;
    final double lineThicknessOnCanvas =
        thFileDisplayStore.lineThicknessOnCanvas;
    for (final THPaintAction paintAction in _paintActions) {
      switch (paintAction) {
        case THPointPaintAction _:
          final Paint pointPaint =
              (paintAction.element as THPoint).plaType == 'continuation'
                  ? THPaints.thPaint8
                  : paintAction.paint;
          // canvas.drawCircle(
          //     paintAction.position, pointRadius, paintAction.paint);
          canvas.drawCircle(paintAction.position, pointRadiusOnCanvas,
              pointPaint..strokeWidth = lineThicknessOnCanvas);
        case THBezierCurvePaintAction _:
          newPath.cubicTo(
              paintAction.controlPoint1X,
              paintAction.controlPoint1Y,
              paintAction.controlPoint2X,
              paintAction.controlPoint2Y,
              paintAction.x,
              paintAction.y);
        case THStraightLinePaintAction _:
          newPath.lineTo(paintAction.x, paintAction.y);
        case THMoveStartPathPaintAction _:
          newPath = Path()..moveTo(paintAction.x, paintAction.y);
        case THEndPathPaintAction _:
          canvas.drawPath(
              newPath, paintAction.paint..strokeWidth = lineThicknessOnCanvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant oldDelegate) {
    if (thFileDisplayStore.shouldRepaint) {
      thFileDisplayStore.setShouldRepaint(false);
      return true;
    }
    return false;
  }
}
