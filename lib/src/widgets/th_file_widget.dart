import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
import 'package:mapiah/src/stores/th_settings_store.dart';
import 'package:mapiah/src/widgets/th_paint_action.dart';

class THFileWidget extends StatefulWidget {
  final THFile file;

  THFileWidget(this.file) : super(key: ObjectKey(file));

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  final LinkedHashMap<int, THPaintAction> _paintActions =
      LinkedHashMap<int, THPaintAction>();
  THPointInterface? _selectedPointElement;
  THPointInterface? _originalSelectedPointElement;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  final THFileStore thFileStore = getIt<THFileStore>();
  late final THFile file = widget.file;

  @override
  void initState() {
    super.initState();
    thFileDisplayStore.updateDataBoundingBox(file.boundingBox());
    thFileDisplayStore.setCanvasScaleTranslationUndefined(true);
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

        final List<int> fileChildrenMapiahIDs = file.childrenMapiahID;
        for (final int childMapiahID in fileChildrenMapiahIDs) {
          final THElement child = file.elementByMapiahID(childMapiahID);
          if (child is THScrap) {
            _addScrapPaintActions(child);
          }
        }

        return GestureDetector(
          // onPanUpdate: thFileDisplayStore.onPanUpdate,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
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
                  painter: THFilePainter(_paintActions.values),
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

  void _onPanStart(DragStartDetails details) {
    final Offset localPosition = details.localPosition;
    final Iterable<THPaintAction> paintActions = _paintActions.values;

    for (final THPaintAction action in paintActions) {
      if (action is THPointPaintAction && action.contains(localPosition)) {
        setState(() {
          _selectedPointElement = action.element as THPointInterface;
          _originalSelectedPointElement = _selectedPointElement;
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedPointElement == null) {
      return;
    }

    final Offset localPositionOnCanvas =
        thFileDisplayStore.offsetScreenToCanvas(details.localPosition);

    setState(() {
      _selectedPointElement!.x = localPositionOnCanvas.dx;
      _selectedPointElement!.y = localPositionOnCanvas.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    thFileStore.updatePointPosition(_originalSelectedPointElement! as THPoint,
        (_originalSelectedPointElement! as THPoint).position);
    setState(() {
      _selectedPointElement = null;
      _originalSelectedPointElement = null;
    });
  }

  void _addScrapPaintActions(THScrap scrap) {
    final THFile file = widget.file;
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
  late final THFileStore thFileStore;
  late final THSettingsStore thSettingsStore;

  THFilePainter(this._paintActions) {
    thFileDisplayStore = getIt<THFileDisplayStore>();
    thFileStore = getIt<THFileStore>();
    thSettingsStore = getIt<THSettingsStore>();
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
    final double pointRadius =
        thFileDisplayStore.scaleScreenToCanvas(thSettingsStore.pointRadius);
    final double lineThickness =
        thFileDisplayStore.scaleScreenToCanvas(thSettingsStore.lineThickness);
    for (final THPaintAction paintAction in _paintActions) {
      switch (paintAction) {
        case THPointPaintAction _:
          final Paint pointPaint =
              (paintAction.element as THPoint).plaType == 'continuation'
                  ? THPaints.thPaint8
                  : paintAction.paint;
          // canvas.drawCircle(
          //     paintAction.position, pointRadius, paintAction.paint);
          canvas.drawCircle(paintAction.position, pointRadius,
              pointPaint..strokeWidth = lineThickness);
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
              newPath, paintAction.paint..strokeWidth = lineThickness);
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
