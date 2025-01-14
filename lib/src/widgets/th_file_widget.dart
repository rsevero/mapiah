import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/selection/th_element_selectable.dart';
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
  THElement? _selectedElement;
  THElement? _originalSelectedElement;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  late final THFileStore thFileStore = widget.thFileStore;
  late final THFile file = widget.thFileStore.thFile;
  bool _repaintTrigger = false;

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

        thFileDisplayStore.clearSelectableElements();

        final List<THScrapWidget> scrapWidgets = [];
        final List<int> fileChildrenMapiahIDs = file.childrenMapiahID;

        for (final int childMapiahID in fileChildrenMapiahIDs) {
          final THElement child = file.elementByMapiahID(childMapiahID);

          if (child is THScrap) {
            scrapWidgets.add(THScrapWidget(child));
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

    THElementSelectable? selectableElement =
        thFileDisplayStore.selectableElementContains(details.localPosition);

    if (selectableElement == null) {
      return;
    }

    if (selectableElement.element is! THPoint) {
      return;
    }

    setState(() {
      _selectedElement = selectableElement.element;
      _originalSelectedElement = (_selectedElement! as THPoint).clone();
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

    final Offset localPositionOnCanvas =
        thFileDisplayStore.offsetScreenToCanvas(details.localPosition);

    setState(() {
      (_selectedElement! as THPoint).position.coordinates =
          localPositionOnCanvas;
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
}
