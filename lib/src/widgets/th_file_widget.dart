import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/selection/th_selectable_element.dart';
import 'package:mapiah/src/selection/th_selected_element.dart';
import 'package:mapiah/src/selection/th_selected_line.dart';
import 'package:mapiah/src/selection/th_selected_point.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/widgets/th_scrap_widget.dart';

class THFileWidget extends StatefulWidget {
  final THFileStore thFileStore;

  THFileWidget(this.thFileStore);

  @override
  State<THFileWidget> createState() => _THFileWidgetState();
}

class _THFileWidgetState extends State<THFileWidget> {
  THSelectedElement? _selectedElement;
  Offset _panStartCoordinates = Offset.zero;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  late final THFileStore thFileStore = widget.thFileStore;
  late final THFile thFile = widget.thFileStore.thFile;
  bool _repaintTrigger = false;

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
        thFileDisplayStore.updateScreenSize(
            Size(constraints.maxWidth, constraints.maxHeight));

        if (thFileDisplayStore.canvasScaleTranslationUndefined) {
          thFileDisplayStore.zoomShowAll();
        }

        thFileDisplayStore.clearSelectableElements();

        final List<THScrapWidget> scrapWidgets = [];
        final List<int> fileChildrenMapiahIDs = thFile.childrenMapiahID;

        for (final int childMapiahID in fileChildrenMapiahIDs) {
          final THElement child = thFile.elementByMapiahID(childMapiahID);

          if (child is THScrap) {
            scrapWidgets.add(THScrapWidget(child, thFileStore));
          }
        }

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            children: scrapWidgets,
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (thFileDisplayStore.mode != TH2FileEditMode.select) {
      return;
    }

    THSelectableElement? selectableElement =
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
              THSelectedLine(thFile: thFile, modifiedLine: element);
          break;
        case THPoint _:
          _selectedElement = THSelectedPoint(modifiedPoint: element);
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
        setState(() {
          _repaintTrigger = !_repaintTrigger;
        });
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
          _updateTHLinePosition(_selectedElement!.modifiedElement as THLine,
              localDeltaPositionOnCanvas);
          break;
        default:
          break;
      }
    });
  }

  void _updateTHLinePosition(THLine line, Offset localDeltaPositionOnCanvas) {
    final List<int> lineChildrenMapiahIDs = line.childrenMapiahID;

    for (final int lineChildMapiahID in lineChildrenMapiahIDs) {
      final THElement lineChild = thFile.elementByMapiahID(lineChildMapiahID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      lineChild.endPoint.coordinates += localDeltaPositionOnCanvas;

      if (lineChild is THBezierCurveLineSegment) {
        lineChild.controlPoint1.coordinates += localDeltaPositionOnCanvas;
        lineChild.controlPoint2.coordinates += localDeltaPositionOnCanvas;
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
      case THSelectedPoint _:
        thFileStore.updatePointPosition(
          originalPoint: (_selectedElement! as THSelectedPoint).originalPoint,
          modifiedPoint: (_selectedElement! as THSelectedPoint).modifiedPoint,
        );
        break;
      case THSelectedLine _:
        thFileStore.updateLinePositionPerOffset(
          originalLine: (_selectedElement! as THSelectedLine).originalLine,
          originalLineSegmentsMap:
              (_selectedElement! as THSelectedLine).originalLineSegmentsMap,
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
