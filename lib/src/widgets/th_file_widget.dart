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
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';
import 'package:mapiah/src/widgets/th_scrap_widget.dart';

class THFileWidget extends StatefulWidget {
  final THFileStore thFileStore;

  THFileWidget({required this.thFileStore});

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  MPSelectedElement? _selectedElement;
  Offset _panStartCoordinates = Offset.zero;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  late final THFileStore thFileStore = widget.thFileStore;
  late final THFile thFile = widget.thFileStore.thFile;
  late final int thFileMapiahID = thFile.mapiahID;

  @override
  void initState() {
    super.initState();
    thFileDisplayStore.updateDataBoundingBox(thFile.boundingBox());
    thFileDisplayStore.setCanvasScaleTranslationUndefined(true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (context) {
            thFileStore.redrawTrigger[thFileMapiahID];
            thFileDisplayStore.updateScreenSize(
                Size(constraints.maxWidth, constraints.maxHeight));

            if (thFileDisplayStore.canvasScaleTranslationUndefined) {
              thFileDisplayStore.zoomShowAll();
            }

            thFileDisplayStore.clearSelectableElements();

            final List<Widget> childWidgets = [];
            final List<int> fileChildrenMapiahIDs = thFile.childrenMapiahID;

            for (final int childMapiahID in fileChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THScrap _:
                  childWidgets.add(THScrapWidget(
                    thScrap: child,
                    thFileStore: thFileStore,
                    thFileMapiahID: thFileMapiahID,
                  ));
                  break;
                case THPoint _:
                  childWidgets.add(THPointWidget(
                    point: child,
                    thFileDisplayStore: thFileDisplayStore,
                    thFileStore: thFileStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                case THLine _:
                  childWidgets.add(THLineWidget(
                    line: child,
                    thFileDisplayStore: thFileDisplayStore,
                    thFileStore: thFileStore,
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
    if (thFileDisplayStore.mode != TH2FileEditMode.select) {
      return;
    }

    MPSelectableElement? selectableElement =
        thFileDisplayStore.selectableElementContains(details.localPosition);

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

    setState(() {
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
          thFileDisplayStore.offsetScreenToCanvas(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    switch (thFileDisplayStore.mode) {
      case TH2FileEditMode.select:
        _onPanUpdateSelectMode(details);
        break;
      case TH2FileEditMode.pan:
        thFileDisplayStore.onPanUpdate(details);
        thFileStore.triggerFileRedraw();
        break;
    }
  }

  void _onPanUpdateSelectMode(DragUpdateDetails details) {
    if ((_selectedElement == null) ||
        (thFileDisplayStore.mode != TH2FileEditMode.select)) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        thFileDisplayStore.offsetScaleScreenToCanvas(details.delta);

    setState(() {
      switch (_selectedElement!.modifiedElement) {
        case THPoint _:
          final THPoint currentPoint =
              _selectedElement!.modifiedElement as THPoint;
          _selectedElement!.modifiedElement = currentPoint.copyWith(
              position: currentPoint.position.copyWith(
                  coordinates: currentPoint.position.coordinates +
                      localDeltaPositionOnCanvas));
          break;
        case THLine _:
          _updateTHLinePosition(
              _selectedElement! as MPSelectedLine, localDeltaPositionOnCanvas);
          break;
        default:
          break;
      }
    });
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
        thFileDisplayStore.offsetScreenToCanvas(details.localPosition) -
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
        thFileStore.updatePointPosition(
          originalPoint: (_selectedElement! as MPSelectedPoint).originalPoint,
          modifiedPoint: (_selectedElement! as MPSelectedPoint).modifiedPoint,
        );
        break;
      case MPSelectedLine _:
        thFileStore.updateLinePositionPerOffset(
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
