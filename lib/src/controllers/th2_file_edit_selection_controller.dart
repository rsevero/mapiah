import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_selection_controller.g.dart';

class TH2FileEditSelectionController = TH2FileEditSelectionControllerBase
    with _$TH2FileEditSelectionController;

abstract class TH2FileEditSelectionControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSelectionControllerBase(
      TH2FileEditController th2FileEditController)
      : _th2FileEditController = th2FileEditController,
        _thFile = th2FileEditController.thFile;

  @readonly
  Map<int, Observable<bool>> _isSelected = <int, Observable<bool>>{};

  @readonly
  ObservableMap<int, MPSelectedElement> _selectedElements =
      ObservableMap<int, MPSelectedElement>();

  @readonly
  MPSelectableControlPoint? _selectedControlPoint;

  Rect get selectedElementsBoundingBox {
    _selectedElementsBoundingBox ??= getSelectedElementsBoundingBox();

    return _selectedElementsBoundingBox!;
  }

  Rect? _selectedElementsBoundingBox;

  @readonly
  LinkedHashMap<int, THLineSegment> _selectedLineSegments =
      LinkedHashMap<int, THLineSegment>();

  @readonly
  Set<MPSelectableEndControlPoint> _selectableEndControlPoints = {};

  @readonly
  Observable<Rect> _selectionWindowCanvasCoordinates = Observable(Rect.zero);

  List<int>? _selectedLineLineSegmentsMapiahIDs;

  Map<MPSelectionHandleType, Offset>? _selectionHandleCenters;

  Map<MPSelectionHandleType, Offset> getSelectionHandleCenters() {
    _selectionHandleCenters ??= _calculateSelectionHandleCenters();

    return _selectionHandleCenters!;
  }

  /// Used to search for selected elements by list of selectable coordinates.
  final Map<int, MPSelectable> _selectableElements = {};

  Offset dragStartCanvasCoordinates = Offset.zero;

  @action
  Rect getSelectedElementsBoundingBox() {
    late Rect boundingBox;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    final selectedElements = _selectedElements.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      final THElement element =
          _thFile.elementByMapiahID(selectedElement.mapiahID);
      switch (element) {
        case THPoint _:
        case THLine _:
          boundingBox =
              (element as MPBoundingBox).getBoundingBox(_th2FileEditController);
        default:
          continue;
      }
      if (boundingBox.left < minX) {
        minX = boundingBox.left;
      }
      if (boundingBox.top < minY) {
        minY = boundingBox.top;
      }
      if (boundingBox.right > maxX) {
        maxX = boundingBox.right;
      }
      if (boundingBox.bottom > maxY) {
        maxY = boundingBox.bottom;
      }
    }

    return MPNumericAux.orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }

  @action
  void deleteSelected() {
    if (_selectedElements.isEmpty) {
      return;
    }

    late MPCommand mpCommand;

    if (_selectedElements.length == 1) {
      final THElement singleSelectedElement =
          _selectedElements.values.toList().first.originalElementClone;

      switch (singleSelectedElement) {
        case THPoint _:
          mpCommand = MPDeletePointCommand(
            pointMapiahID: singleSelectedElement.mapiahID,
          );
        case THLine _:
          mpCommand = MPDeleteLineCommand(
            lineMapiahID: singleSelectedElement.mapiahID,
            isInteractiveLineCreation:
                _th2FileEditController.lineStartScreenPosition != null,
          );
      }
    } else {}

    _th2FileEditController.execute(mpCommand);
    clearSelectedElements();
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void updateSelectedElementsClones() {
    for (final MPSelectedElement selectedElement in _selectedElements.values) {
      selectedElement.updateClone(_thFile);
    }
  }

  @action
  bool addSelectedElement(THElement element, {bool setState = false}) {
    switch (element) {
      case THLine _:
        _selectedElements[element.mapiahID] =
            MPSelectedLine(thFile: _thFile, originalLine: element);
      case THPoint _:
        _selectedElements[element.mapiahID] =
            MPSelectedPoint(originalPoint: element);
    }
    _isSelected[element.mapiahID]!.value = true;
    _th2FileEditController.triggerSelectedListChanged();

    if (setState) {
      return setSelectionState();
    }

    return false;
  }

  @action
  bool addSelectedElements(List<THElement> elements, {bool setState = false}) {
    for (THElement element in elements) {
      addSelectedElement(element);
    }

    if (setState) {
      return setSelectionState();
    }

    return false;
  }

  @action
  void deselectAllElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();
    _th2FileEditController.triggerSelectedListChanged();
  }

  @action
  void selectAllElements() {
    final THScrap scrap = _thFile
        .elementByMapiahID(_th2FileEditController.activeScrapID) as THScrap;
    final Set<int> elementMapiahIDs = scrap.childrenMapiahID;

    for (final int elementMapiahID in elementMapiahIDs) {
      final THElement element = _thFile.elementByMapiahID(elementMapiahID);

      if (element is THPoint || element is THLine) {
        addSelectedElement(element);
      }
    }
  }

  @action
  bool setSelectedElements(
    List<THElement> clickedElements, {
    bool setState = false,
  }) {
    _clearSelectedElementsWithoutResettingRedrawTriggers();

    for (THElement element in clickedElements) {
      if ((element is! THPoint) && (element is! THLine)) {
        continue;
      }

      addSelectedElement(element);
    }

    if (setState) {
      return setSelectionState();
    }

    return false;
  }

  @action
  bool removeSelectedElement(THElement element) {
    _selectedElements.remove(element.mapiahID);
    if (_isSelected.containsKey(element.mapiahID)) {
      _isSelected[element.mapiahID]!.value = false;
    }

    _th2FileEditController.triggerSelectedListChanged();

    return setSelectionState();
  }

  void setSelectedControlPoint(MPSelectableControlPoint controlPoint) {
    _selectedControlPoint = controlPoint;
  }

  void clearSelectedControlPoint() {
    _selectedControlPoint = null;
  }

  void setDragStartCoordinates(Offset screenCoordinates) {
    dragStartCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(screenCoordinates);
  }

  Map<MPSelectionHandleType, Offset> _calculateSelectionHandleCenters() {
    final Map<MPSelectionHandleType, Offset> handles =
        <MPSelectionHandleType, Offset>{};

    if (_selectedElements.isEmpty) {
      return ObservableMap<MPSelectionHandleType, Offset>.of(handles);
    }

    final double handleSize =
        _th2FileEditController.selectionHandleSizeOnCanvas.value;
    final double handleDistance =
        _th2FileEditController.selectionHandleDistanceOnCanvas.value;
    final Rect boundingBox = selectedElementsBoundingBox;
    final double halfSize = handleSize / 2.0;

    final double left = boundingBox.left - halfSize - handleDistance;
    final double right = boundingBox.right + halfSize + handleDistance;
    final double top = boundingBox.top - halfSize - handleDistance;
    final double bottom = boundingBox.bottom + halfSize + handleDistance;

    final double centerX = (boundingBox.left + boundingBox.right) / 2.0;
    final double centerY = (boundingBox.top + boundingBox.bottom) / 2.0;

    final Offset topLeft = Offset(left, top);
    final Offset topRight = Offset(right, top);
    final Offset bottomLeft = Offset(left, bottom);
    final Offset bottomRight = Offset(right, bottom);
    final Offset topCenter = Offset(centerX, top);
    final Offset bottomCenter = Offset(centerX, bottom);
    final Offset leftCenter = Offset(left, centerY);
    final Offset rightCenter = Offset(right, centerY);

    handles.addAll(<MPSelectionHandleType, Offset>{
      MPSelectionHandleType.topLeft: topLeft,
      MPSelectionHandleType.topRight: topRight,
      MPSelectionHandleType.bottomLeft: bottomLeft,
      MPSelectionHandleType.bottomRight: bottomRight,
      MPSelectionHandleType.topCenter: topCenter,
      MPSelectionHandleType.bottomCenter: bottomCenter,
      MPSelectionHandleType.leftCenter: leftCenter,
      MPSelectionHandleType.rightCenter: rightCenter,
    });

    return ObservableMap<MPSelectionHandleType, Offset>.of(handles);
  }

  void updateSelectableElements() {
    _selectableElements.clear();

    final THScrap scrap = _thFile
        .elementByMapiahID(_th2FileEditController.activeScrapID) as THScrap;

    for (final int elementMapiahID in scrap.childrenMapiahID) {
      final THElement element = _thFile.elementByMapiahID(elementMapiahID);

      if (element is THPoint || element is THLine) {
        addSelectableElement(element);
      }
    }
  }

  void addSelectableElement(THElement element) {
    if ((element is! THPoint) && (element is! THLine)) {
      return;
    }

    switch (element) {
      case THPoint _:
        _addPointSelectableElement(element);
      case THLine _:
        _addLineSelectableElement(element);
    }
  }

  void _addPointSelectableElement(THPoint point) {
    final MPSelectablePoint selectablePoint = MPSelectablePoint(
      point: point,
      th2fileEditController: _th2FileEditController,
    );

    final int pointMapiahID = point.mapiahID;

    _selectableElements[pointMapiahID] = selectablePoint;
    _isSelected[pointMapiahID] = Observable(false);
  }

  void _addLineSelectableElement(THLine line) {
    final MPSelectableLine selectableLine = MPSelectableLine(
      line: line,
      th2fileEditController: _th2FileEditController,
    );

    final int lineMapiahID = line.mapiahID;

    _selectableElements[lineMapiahID] = selectableLine;
    _isSelected[lineMapiahID] = Observable(false);
  }

  void removeSelectableElement(int mapiahID) {
    _selectableElements.remove(mapiahID);
    _isSelected.remove(mapiahID);
  }

  List<THElement> selectableElementsClicked(Offset screenCoordinates) {
    final Offset canvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(screenCoordinates);
    final List<THElement> clickedElements = [];
    final selectableElements = _selectableElements.values;

    for (final selectableElement in selectableElements) {
      if (selectableElement.contains(canvasCoordinates)) {
        if (selectableElement is MPSelectableElement) {
          switch (selectableElement.element) {
            case THPoint _:
            case THLine _:
              clickedElements.addAll(selectableElement.selectedElements);
          }
        }
      }
    }

    return clickedElements;
  }

  List<THElement> selectableElementsInsideWindow(Rect canvasSelectionWindow) {
    final Map<int, THElement> insideWindowElements = <int, THElement>{};

    for (final selectableElement in _selectableElements.values) {
      if (selectableElement is MPSelectableElement) {
        final THElement element = selectableElement.element;

        if (MPNumericAux.isRect1InsideRect2(
          rect1:
              (element as MPBoundingBox).getBoundingBox(_th2FileEditController),
          rect2: canvasSelectionWindow,
        )) {
          insideWindowElements[element.mapiahID] = element;
        }
      }
    }

    return insideWindowElements.values.toList();
  }

  List<MPSelectableEndControlPoint> selectableEndControlPointsClicked(
    Offset screenCoordinates,
    bool includeControlPoints,
  ) {
    final Offset canvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(screenCoordinates);
    final List<MPSelectableEndControlPoint> clickedEndControlPoints = [];

    for (final MPSelectableEndControlPoint endControlPoint
        in _selectableEndControlPoints) {
      if (endControlPoint.contains(canvasCoordinates)) {
        if (endControlPoint is MPSelectableEndPoint) {
          clickedEndControlPoints.add(endControlPoint);
        } else if (includeControlPoints &&
            (endControlPoint is MPSelectableControlPoint)) {
          clickedEndControlPoints.add(endControlPoint);
        }
      }
    }

    return clickedEndControlPoints;
  }

  List<THLineSegment> selectableEndPointsInsideWindow(
    Rect canvasSelectionWindow,
  ) {
    final Map<int, THLineSegment> insideWindowElements = <int, THLineSegment>{};

    for (final selectableEndControlPoint in _selectableEndControlPoints) {
      if (selectableEndControlPoint is MPSelectableEndPoint) {
        final THLineSegment element =
            selectableEndControlPoint.element as THLineSegment;

        if (canvasSelectionWindow.contains(element.endPoint.coordinates)) {
          insideWindowElements[element.mapiahID] = element;
        }
      }
    }

    return insideWindowElements.values.toList();
  }

  void updateSelectableEndAndControlPoints() {
    _selectableEndControlPoints.clear();

    if ((_selectedElements.length != 1) ||
        (_selectedElements.values.first is! MPSelectedLine)) {
      return;
    }

    final THLine line = _thFile.elementByMapiahID(
      _selectedElements.values.first.mapiahID,
    ) as THLine;
    final List<THLineSegment> lineSegments =
        _th2FileEditController.getLineSegmentsList(
      line: line,
      clone: false,
    );
    bool isFirst = true;
    bool previousLineSegmentSelected = false;

    for (final THLineSegment lineSegment in lineSegments) {
      if (isFirst) {
        _selectableEndControlPoints.add(
          MPSelectableEndPoint(
            lineSegment: lineSegment,
            position: lineSegment.endPoint.coordinates,
            th2fileEditController: _th2FileEditController,
          ),
        );
        isFirst = false;
        previousLineSegmentSelected =
            _selectedLineSegments.containsKey(lineSegment.mapiahID);
        continue;
      }

      final int lineSegmentMapiahID = lineSegment.mapiahID;
      final bool currentLineSegmentSelected =
          _selectedLineSegments.containsKey(lineSegmentMapiahID);
      final bool addControlPoints =
          (previousLineSegmentSelected || currentLineSegmentSelected) &&
              (lineSegment is THBezierCurveLineSegment);

      if (addControlPoints) {
        _selectableEndControlPoints.add(
          MPSelectableControlPoint(
            lineSegment: lineSegment,
            position: lineSegment.controlPoint1.coordinates,
            type: MPSelectableControlPointType.controlPoint1,
            th2fileEditController: _th2FileEditController,
          ),
        );
      }

      _selectableEndControlPoints.add(
        MPSelectableEndPoint(
          lineSegment: lineSegment,
          position: lineSegment.endPoint.coordinates,
          th2fileEditController: _th2FileEditController,
        ),
      );

      if (addControlPoints) {
        _selectableEndControlPoints.add(
          MPSelectableControlPoint(
            lineSegment: lineSegment,
            position: lineSegment.controlPoint2.coordinates,
            type: MPSelectableControlPointType.controlPoint2,
            th2fileEditController: _th2FileEditController,
          ),
        );
      }
      previousLineSegmentSelected = currentLineSegmentSelected;
    }
  }

  void setSelectedLineSegments(List<THLineSegment> lineSegments) {
    _selectedLineSegments.clear();
    addSelectedLineSegments(lineSegments);
  }

  void clearSelectedLineSegments() {
    _selectedLineSegments.clear();
  }

  void addSelectedLineSegments(List<THLineSegment> lineSegments) {
    for (final THLineSegment lineSegment in lineSegments) {
      _selectedLineSegments[lineSegment.mapiahID] = lineSegment;
    }
  }

  void removeSelectedLineSegments(List<THLineSegment> lineSegments) {
    for (final THLineSegment lineSegment in lineSegments) {
      _selectedLineSegments.remove(lineSegment.mapiahID);
    }
  }

  bool getIsLineSegmentSelected(THLineSegment lineSegment) {
    return _selectedLineSegments.containsKey(lineSegment.mapiahID);
  }

  void warmSelectableElementsCanvasScaleChanged() {
    for (final selectableElement in _selectableElements.values) {
      selectableElement.canvasScaleChanged();
    }
  }

  List<THLineSegment> getLineSegmentAndPrevious(THLineSegment lineSegment) {
    final THLine line =
        _thFile.elementByMapiahID(lineSegment.parentMapiahID) as THLine;
    final List<THLineSegment> lineSegments =
        _th2FileEditController.getLineSegmentsList(
      line: line,
      clone: false,
    );

    final int lineSegmentIndex = lineSegments.indexOf(lineSegment);

    if (lineSegmentIndex == 0) {
      return <THLineSegment>[lineSegment];
    } else {
      return <THLineSegment>[
        lineSegments[lineSegmentIndex - 1],
        lineSegment,
      ];
    }
  }

  void moveSelectedEndControlPointsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedEndControlPointsToCanvasCoordinates(
        canvasCoordinatesFinalPosition);
  }

  @action
  void moveSelectedEndControlPointsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if (_selectedLineSegments.isEmpty) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_selectedElements.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMapiahIDs =
        getSelectedLineLineSegmentsMapiahIDs();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final Iterable<THLineSegment> selectedLineSegments =
        _selectedLineSegments.values;
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    for (final THLineSegment selectedLineSegment in selectedLineSegments) {
      final int selectedLineSegmentMapiahID = selectedLineSegment.mapiahID;
      final THLineSegment originalLineSegment =
          originalLineSegments[selectedLineSegmentMapiahID]!;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegments[selectedLineSegmentMapiahID] =
              originalLineSegment.copyWith(
            endPoint: THPositionPart(
              coordinates: originalLineSegment.endPoint.coordinates +
                  localDeltaPositionOnCanvas,
              decimalPositions: currentDecimalPositions,
            ),
          );
        case THBezierCurveLineSegment _:
          final THBezierCurveLineSegment referenceLineSegment =
              modifiedLineSegments.containsKey(selectedLineSegmentMapiahID)
                  ? modifiedLineSegments[selectedLineSegmentMapiahID]
                      as THBezierCurveLineSegment
                  : originalLineSegment;

          modifiedLineSegments[selectedLineSegmentMapiahID] =
              referenceLineSegment.copyWith(
            endPoint: THPositionPart(
              coordinates: originalLineSegment.endPoint.coordinates +
                  localDeltaPositionOnCanvas,
              decimalPositions: currentDecimalPositions,
            ),
            controlPoint2: THPositionPart(
              coordinates: originalLineSegment.controlPoint2.coordinates +
                  localDeltaPositionOnCanvas,
              decimalPositions: currentDecimalPositions,
            ),
          );
      }

      final int? nextLineSegmentMapiahID = getNextLineSegmentMapiahID(
          selectedLineSegmentMapiahID, lineLineSegmentsMapiahIDs);

      if (nextLineSegmentMapiahID != null) {
        final THLineSegment nextLineSegment =
            _thFile.elementByMapiahID(nextLineSegmentMapiahID) as THLineSegment;

        if (nextLineSegment is THBezierCurveLineSegment) {
          final THBezierCurveLineSegment originalNextLineSegment =
              originalLineSegments[nextLineSegmentMapiahID]
                  as THBezierCurveLineSegment;
          final THBezierCurveLineSegment referenceNextLineSegment =
              (modifiedLineSegments.containsKey(nextLineSegmentMapiahID)
                  ? modifiedLineSegments[nextLineSegmentMapiahID]
                  : originalNextLineSegment) as THBezierCurveLineSegment;

          modifiedLineSegments[nextLineSegmentMapiahID] =
              referenceNextLineSegment.copyWith(
            controlPoint1: THPositionPart(
              coordinates: originalNextLineSegment.controlPoint1.coordinates +
                  localDeltaPositionOnCanvas,
              decimalPositions: currentDecimalPositions,
            ),
          );
        }
      }
    }

    _th2FileEditController.substituteLineSegments(modifiedLineSegments);
    updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  void moveSelectedControlPointToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedControlPointToCanvasCoordinates(canvasCoordinatesFinalPosition);
  }

  @action
  void moveSelectedControlPointToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if (_selectedControlPoint == null) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_selectedElements.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final THBezierCurveLineSegment controlPointLineSegment =
        _selectedControlPoint!.element as THBezierCurveLineSegment;
    final int controlPointLineSegmentMapiahID =
        controlPointLineSegment.mapiahID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMapiahID]
            as THBezierCurveLineSegment;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    switch (_selectedControlPoint!.type) {
      case MPSelectableControlPointType.controlPoint1:
        modifiedLineSegments[controlPointLineSegmentMapiahID] =
            originalControlPointLineSegment.copyWith(
          controlPoint1: THPositionPart(
            coordinates:
                originalControlPointLineSegment.controlPoint1.coordinates +
                    localDeltaPositionOnCanvas,
            decimalPositions: currentDecimalPositions,
          ),
        );
      case MPSelectableControlPointType.controlPoint2:
        modifiedLineSegments[controlPointLineSegmentMapiahID] =
            originalControlPointLineSegment.copyWith(
          controlPoint2: THPositionPart(
            coordinates:
                originalControlPointLineSegment.controlPoint2.coordinates +
                    localDeltaPositionOnCanvas,
            decimalPositions: currentDecimalPositions,
          ),
        );
    }

    _th2FileEditController.substituteLineSegments(modifiedLineSegments);
    updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  List<int> getSelectedLineLineSegmentsMapiahIDs() {
    _selectedLineLineSegmentsMapiahIDs ??=
        ((_selectedElements[_selectedElements.keys.first] as MPSelectedLine)
                .originalElementClone as THLine)
            .childrenMapiahID
            .where((childMapiahID) {
      return _thFile.elementByMapiahID(childMapiahID) is THLineSegment;
    }).toList();

    return _selectedLineLineSegmentsMapiahIDs!;
  }

  void resetSelectedLineLineSegmentsMapiahIDs() {
    _selectedLineLineSegmentsMapiahIDs = null;
  }

  int? getNextLineSegmentMapiahID(
      int lineSegmentMapiahID, List<int> lineLineSegmentsMapiahIDs) {
    final int lineSegmentIndex =
        lineLineSegmentsMapiahIDs.indexOf(lineSegmentMapiahID);

    if ((lineSegmentIndex == -1) ||
        (lineSegmentIndex == lineLineSegmentsMapiahIDs.length - 1)) {
      return null;
    }

    return lineLineSegmentsMapiahIDs[lineSegmentIndex + 1];
  }

  THLineSegment? nextLineSegment(
    THLineSegment lineSegment, {
    List<THLineSegment>? lineSegments,
  }) {
    if (lineSegments == null) {
      final THLine line =
          _thFile.elementByMapiahID(lineSegment.parentMapiahID) as THLine;

      lineSegments = _th2FileEditController.getLineSegmentsList(
        line: line,
        clone: false,
      );
    }

    final int lineSegmentIndex = lineSegments.indexOf(lineSegment);

    if (lineSegmentIndex == lineSegments.length - 1) {
      return null;
    } else {
      return lineSegments[lineSegmentIndex + 1];
    }
  }

  @action
  void setSelectionWindowCanvasCoordinates({
    required Offset point1,
    required Offset point2,
  }) {
    _selectionWindowCanvasCoordinates.value =
        MPNumericAux.orderedRectFromPoints(
      point1: point1,
      point2: point2,
    );
  }

  void setSelectionWindowScreenEndCoordinates(Offset screenEndCoordinates) {
    final Offset canvasEndCoordinates =
        _th2FileEditController.offsetScreenToCanvas(screenEndCoordinates);

    setSelectionWindowCanvasCoordinates(
      point1: dragStartCanvasCoordinates,
      point2: canvasEndCoordinates,
    );
  }

  @action
  void clearSelectionWindow() {
    _selectionWindowCanvasCoordinates.value = Rect.zero;
  }

  bool isElementSelected(THElement element) {
    return isElementSelectedByMapiahID(element.mapiahID);
  }

  bool isElementSelectedByMapiahID(int mapiahID) {
    return _selectedElements.containsKey(mapiahID);
  }

  bool isEndpointSelected(THLineSegment lineSegment) {
    return _selectedLineSegments.containsKey(lineSegment.mapiahID);
  }

  @action
  void clearSelectedElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();
  }

  void clearIsSelected() {
    _isSelected.clear();
  }

  void setIsSelected(int mapiahID, bool value) {
    _isSelected[mapiahID] = Observable(value);
  }

  void _clearSelectedElementsWithoutResettingRedrawTriggers() {
    _selectedElements.clear();
    _isSelected.forEach((key, value) => value.value = false);
    clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
  }

  void clearSelectedElementsBoundingBoxAndSelectionHandleCenters() {
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
  }

  void clearSelectedElementsAndSelectionHandleCenters() {
    _selectedElements.clear();
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
  }

  void clearSelectionHandleCenters() {
    _selectionHandleCenters = null;
  }

  bool setSelectionState() {
    if (_selectedElements.isEmpty) {
      return _th2FileEditController
          .setState(MPTH2FileEditStateType.selectEmptySelection);
    } else if ((_selectedElements.length == 1) &&
        (_selectedElements.values.first is MPSelectedLine)) {
      return _th2FileEditController
          .setState(MPTH2FileEditStateType.editSingleLine);
    } else {
      return _th2FileEditController
          .setState(MPTH2FileEditStateType.selectNonEmptySelection);
    }
  }
}
