import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';
import 'package:mapiah/src/selection/mp_selected_line.dart';
import 'package:mapiah/src/selection/mp_selected_point.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';
import 'package:mapiah/src/widgets/th_scrap_widget.dart';

class THFileWidget extends StatefulWidget {
  final THFileEditStore thFileEditStore;

  THFileWidget({required super.key, required this.thFileEditStore});

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  MPSelectedElement? _selectedElement;
  Offset _panStartCoordinates = Offset.zero;
  late final THFileEditStore thFileEditStore = widget.thFileEditStore;
  late final THFile thFile = widget.thFileEditStore.thFile;
  late final int thFileMapiahID = thFileEditStore.thFileMapiahID;

  @override
  void initState() {
    super.initState();
    thFileEditStore.updateDataBoundingBox(thFile.boundingBox());
    thFileEditStore.setCanvasScaleTranslationUndefined(true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (context) {
            thFileEditStore.updateScreenSize(
                Size(constraints.maxWidth, constraints.maxHeight));

            if (thFileEditStore.canvasScaleTranslationUndefined) {
              thFileEditStore.zoomShowAll();
            }

            thFileEditStore.clearSelectableElements();

            thFileEditStore
                .childrenListLengthChangeTrigger[thFileMapiahID]!.value;

            final List<Widget> childWidgets = [];
            final List<int> fileChildrenMapiahIDs = thFile.childrenMapiahID;

            for (final int childMapiahID in fileChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THScrap _:
                  childWidgets.add(THScrapWidget(
                    key: ValueKey(childMapiahID),
                    thScrap: child,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                  ));
                  break;
                case THPoint _:
                  childWidgets.add(THPointWidget(
                    key: ValueKey(childMapiahID),
                    point: child,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                case THLine _:
                  childWidgets.add(THLineWidget(
                    key: ValueKey(childMapiahID),
                    line: child,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                default:
                  break;
              }
            }

            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                children: childWidgets,
              ),
            );
          },
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (thFileEditStore.mode != TH2FileEditMode.select) {
      return;
    }

    MPSelectableElement? selectableElement =
        thFileEditStore.selectableElementContains(details.localPosition);

    if (selectableElement == null) {
      return;
    }

    THElement element = selectableElement.element;

    if ((element is! THPoint) &&
        (element is! THLine) &&
        (element is! THLineSegment)) {
      return;
    }

    // bool isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed
    //         .contains(LogicalKeyboardKey.shiftLeft) ||
    //     HardwareKeyboard.instance.logicalKeysPressed
    //         .contains(LogicalKeyboardKey.shiftRight);

    if (element is THLineSegment) {
      element = element.parent(thFile) as THLine;
    }

    switch (element) {
      case THLine _:
        _selectedElement =
            MPSelectedLine(thFile: thFile, modifiedLine: element);
        break;
      case THPoint _:
        _selectedElement = MPSelectedPoint(modifiedPoint: element);
        break;
    }

    _panStartCoordinates =
        thFileEditStore.offsetScreenToCanvas(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    switch (thFileEditStore.mode) {
      case TH2FileEditMode.select:
        _onPanUpdateSelectMode(details);
        break;
      case TH2FileEditMode.pan:
        thFileEditStore.onPanUpdate(details);
        thFileEditStore.triggerFileRedraw();
        break;
    }
  }

  void _onPanUpdateSelectMode(DragUpdateDetails details) {
    if ((_selectedElement == null) ||
        (thFileEditStore.mode != TH2FileEditMode.select)) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        thFileEditStore.offsetScreenToCanvas(details.localPosition) -
            _panStartCoordinates;

    switch (_selectedElement!.originalElement) {
      case THPoint _:
        final THPoint currentPoint =
            _selectedElement!.originalElement as THPoint;
        final THPoint modifiedPoint = currentPoint.copyWith(
            position: currentPoint.position.copyWith(
                coordinates: currentPoint.position.coordinates +
                    localDeltaPositionOnCanvas));
        thFileEditStore.substituteElement(modifiedPoint);
        break;
      case THLine _:
        _updateTHLinePosition(
            _selectedElement! as MPSelectedLine, localDeltaPositionOnCanvas);
        break;
      default:
        break;
    }
  }

  void _updateTHLinePosition(
      MPSelectedLine selectedLine, Offset localDeltaPositionOnCanvas) {
    final THLine line = selectedLine.modifiedLine;
    final List<int> lineChildrenMapiahIDs = line.childrenMapiahID;

    for (final int lineChildMapiahID in lineChildrenMapiahIDs) {
      final THElement lineChild = thFile.elementByMapiahID(lineChildMapiahID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      late THLineSegment newLineSegment;

      switch (lineChild) {
        case THStraightLineSegment _:
          newLineSegment = lineChild.copyWith(
              endPoint: lineChild.endPoint.copyWith(
                  coordinates: lineChild.endPoint.coordinates +
                      localDeltaPositionOnCanvas));
          break;
        case THBezierCurveLineSegment _:
          newLineSegment = lineChild.copyWith(
              endPoint: lineChild.endPoint.copyWith(
                  coordinates: lineChild.endPoint.coordinates +
                      localDeltaPositionOnCanvas),
              controlPoint1: lineChild.controlPoint1.copyWith(
                  coordinates: lineChild.controlPoint1.coordinates +
                      localDeltaPositionOnCanvas),
              controlPoint2: lineChild.controlPoint2.copyWith(
                  coordinates: lineChild.controlPoint2.coordinates +
                      localDeltaPositionOnCanvas));
          break;
        default:
          throw Exception('Unknown line segment type');
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedElement == null) {
      return;
    }

    final Offset panEndOffset =
        thFileEditStore.offsetScreenToCanvas(details.localPosition) -
            _panStartCoordinates;

    if (panEndOffset == Offset.zero) {
      // TODO - compare doubles with some epsilon
      setState(() {
        _selectedElement = null;
        _panStartCoordinates = Offset.zero;
      });
      return;
    }

    switch (_selectedElement!) {
      case MPSelectedPoint _:
        thFileEditStore.updatePointPosition(
          originalPoint: (_selectedElement! as MPSelectedPoint).originalPoint,
          modifiedPoint: (_selectedElement! as MPSelectedPoint).modifiedPoint,
        );
        break;
      case MPSelectedLine _:
        thFileEditStore.updateLinePositionPerOffset(
          originalLine: (_selectedElement! as MPSelectedLine).originalLine,
          originalLineSegmentsMap:
              (_selectedElement! as MPSelectedLine).originalLineSegmentsMap,
          deltaOnCanvas: panEndOffset,
        );
        break;
      default:
        break;
    }

    setState(() {
      _selectedElement = null;
      _panStartCoordinates = Offset.zero;
    });
  }
}
