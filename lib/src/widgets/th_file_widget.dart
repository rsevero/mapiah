import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
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
import 'package:mapiah/src/stores/th_settings_store.dart';
import 'package:mapiah/src/widgets/th_paint_action.dart';

class THFileWidget extends StatefulWidget {
  final THFile file;

  THFileWidget(this.file) : super(key: ObjectKey(file));

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  final List<THPaintAction> _paintActions = [];
  THPointInterface? _selectedPointElement;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();

  @override
  void initState() {
    super.initState();
    final THFile file = widget.file;
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

  void _onPanStart(DragStartDetails details) {
    final Offset localPosition = details.localPosition;
    for (final THPaintAction action in _paintActions) {
      if (action is THPointPaintAction && action.contains(localPosition)) {
        setState(() {
          _selectedPointElement = action.element as THPointInterface;
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedPointElement != null) {
      setState(() {
        _selectedPointElement!.x += details.delta.dx;
        _selectedPointElement!.y += details.delta.dy;
      });
      // widget.thFileDisplayStore.updatePointPosition(_selectedPointElement!);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _selectedPointElement = null;
    });
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

  void _addScrapPaintActions(THScrap scrap) {
    final THFile file = widget.file;
    final List<int> scrapChildrenMapiahIDs = scrap.childrenMapiahID;
    for (final int childMapiahID in scrapChildrenMapiahIDs) {
      final THElement child = file.elementByMapiahID(childMapiahID);
      if (child is THPoint) {
        final THPointPaintAction newPointPaintAction =
            THPointPaintAction(child);
        _paintActions.add(newPointPaintAction);
      } else if (child is THLine) {
        bool isFirst = true;
        final List<int> lineChildrenMapiahIDs = child.childrenMapiahID;
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
            _paintActions.add(newMovePaintAction);
            isFirst = false;
            continue;
          }

          if (lineSegment is THStraightLineSegment) {
            final THStraightLinePaintAction newStraightLinePaintAction =
                THStraightLinePaintAction(lineSegment);
            _paintActions.add(newStraightLinePaintAction);
          } else if (lineSegment is THBezierCurveLineSegment) {
            final THBezierCurvePaintAction newBezierCurvePaintAction =
                THBezierCurvePaintAction(lineSegment);
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
    final double pointRadius = getIt<THSettingsStore>().pointRadius;
    for (final THPaintAction paintAction in _paintActions) {
      switch (paintAction) {
        case THPointPaintAction _:
          canvas.drawCircle(
              paintAction.position, pointRadius, paintAction.paint);
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
