import 'dart:collection';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
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
  ObservableMap<int, MPSelectedElement> _mpSelectedElements =
      ObservableMap<int, MPSelectedElement>();

  @readonly
  Iterable<THElement> _clickedElementsAtPointerDown = {};

  @readonly
  MPSelectableControlPoint? _selectedControlPoint;

  @readonly
  int _multipleElementsClickedChoice = mpMultipleElementsClickedAllChoiceID;

  Map<int, THElement> clickedElements = {};

  @readonly
  int? _multipleElementsClickedHighlightedMPID;

  Completer<void> multipleElementsClickedSemaphore = Completer<void>();

  bool selectionCanBeMultiple = false;

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

  List<int>? _selectedLineLineSegmentsMPIDs;

  Map<MPSelectionHandleType, Offset>? _selectionHandleCenters;

  Map<MPSelectionHandleType, Offset> getSelectionHandleCenters() {
    _selectionHandleCenters ??= _calculateSelectionHandleCenters();

    return _selectionHandleCenters!;
  }

  /// Used to search for selected elements by list of selectable coordinates.
  @readonly
  ObservableMap<int, MPSelectable> _selectableElements =
      ObservableMap<int, MPSelectable>();

  Offset dragStartCanvasCoordinates = Offset.zero;

  Rect _getElementsListBoundingBox(Iterable<THElement> elements) {
    late Rect boundingBox;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final THElement element in elements) {
      switch (element) {
        case THPoint _:
        case THLine _:
        case THArea _:
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

  void setClickedElementsAtPointerDown(Iterable<THElement> clickedElements) {
    _clickedElementsAtPointerDown = clickedElements;
  }

  void clearClickedElementsAtPointerDown() {
    _clickedElementsAtPointerDown = <THElement>[];
  }

  @action
  void substituteSelectedElementsByClickedElements() {
    _mpSelectedElements.clear();
    for (final THElement clickedElement in _clickedElementsAtPointerDown) {
      addSelectedElement(clickedElement);
    }
    clearClickedElementsAtPointerDown();
  }

  @action
  Rect getSelectedElementsBoundingBox() {
    final Iterable<THElement> selectedElements = _mpSelectedElements.values.map(
      (MPSelectedElement selectedElement) =>
          _thFile.elementByMPID(selectedElement.mpID),
    );

    return _getElementsListBoundingBox(selectedElements);
  }

  Rect getClickedElementsBoundingBox() {
    return _getElementsListBoundingBox(clickedElements.values);
  }

  @action
  void removeSelected() {
    if (_mpSelectedElements.isEmpty) {
      return;
    }

    late MPCommand mpCommand;

    if (_mpSelectedElements.length == 1) {
      final THElement singleSelectedElement =
          _mpSelectedElements.values.toList().first.originalElementClone;

      switch (singleSelectedElement) {
        case THPoint _:
          mpCommand = MPRemovePointCommand(
            pointMPID: singleSelectedElement.mpID,
          );
        case THLine _:
          mpCommand = MPRemoveLineCommand(
            lineMPID: singleSelectedElement.mpID,
            isInteractiveLineCreation: _th2FileEditController
                    .elementEditController.lineStartScreenPosition !=
                null,
          );
      }
    } else {
      final List<int> selectedMPIDs = _mpSelectedElements.keys.toList();

      mpCommand = MPMultipleElementsCommand.removeElements(
        mpIDs: selectedMPIDs,
        thFile: _thFile,
      );
    }

    _th2FileEditController.execute(mpCommand);
    clearSelectedElements();
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void updateSelectedElementClone(int mpID) {
    if (_mpSelectedElements.containsKey(mpID)) {
      _mpSelectedElements[mpID]!.updateClone(_thFile);
    }
  }

  void updateSelectedElementsClones() {
    for (final MPSelectedElement selectedElement
        in _mpSelectedElements.values) {
      selectedElement.updateClone(_thFile);
    }
  }

  @action
  bool addSelectedElement(THElement element, {bool setState = false}) {
    switch (element) {
      case THLine _:
        _mpSelectedElements[element.mpID] =
            MPSelectedLine(thFile: _thFile, originalLine: element);
      case THPoint _:
        _mpSelectedElements[element.mpID] =
            MPSelectedPoint(originalPoint: element);
    }
    _isSelected[element.mpID]!.value = true;
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
    final THScrap scrap =
        _thFile.scrapByMPID(_th2FileEditController.activeScrapID);
    final Set<int> elementMPIDs = scrap.childrenMPID;

    for (final int elementMPID in elementMPIDs) {
      final THElement element = _thFile.elementByMPID(elementMPID);

      if (element is THPoint || element is THLine) {
        addSelectedElement(element);
      }
    }
  }

  @action
  bool setSelectedElements(
    Iterable<THElement> clickedElements, {
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
    _mpSelectedElements.remove(element.mpID);
    if (_isSelected.containsKey(element.mpID)) {
      _isSelected[element.mpID]!.value = false;
    }

    _th2FileEditController.triggerSelectedListChanged();

    return setSelectionState();
  }

  @action
  void removeSelectedElements(List<THElement> elements) {
    for (THElement element in elements) {
      removeSelectedElement(element);
    }
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

    if (_mpSelectedElements.isEmpty) {
      return ObservableMap<MPSelectionHandleType, Offset>.of(handles);
    }

    final double handleSize =
        _th2FileEditController.selectionHandleSizeOnCanvas;
    final double handleDistance =
        _th2FileEditController.selectionHandleDistanceOnCanvas;
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

    final THScrap scrap =
        _thFile.scrapByMPID(_th2FileEditController.activeScrapID);

    for (final int elementMPID in scrap.childrenMPID) {
      final THElement element = _thFile.elementByMPID(elementMPID);

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

    final int pointMPID = point.mpID;

    _selectableElements[pointMPID] = selectablePoint;

    if (!_isSelected.containsKey(pointMPID)) {
      _isSelected[pointMPID] = Observable(false);
    }
  }

  void _addLineSelectableElement(THLine line) {
    final MPSelectableLine selectableLine = MPSelectableLine(
      line: line,
      th2fileEditController: _th2FileEditController,
    );

    final int lineMPID = line.mpID;

    _selectableElements[lineMPID] = selectableLine;
    if (!_isSelected.containsKey(lineMPID)) {
      _isSelected[lineMPID] = Observable(false);
    }
  }

  void removeSelectableElement(int mpID) {
    _selectableElements.remove(mpID);
    _isSelected.remove(mpID);
  }

  Future<Map<int, THElement>> getSelectableElementsClicked({
    required Offset screenCoordinates,
    required THSelectionType selectionType,
    required bool canBeMultiple,
    required bool presentMultipleElementsClickedWidget,
  }) async {
    final Offset canvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(screenCoordinates);
    final selectableElements = _selectableElements.values;

    clickedElements.clear();

    for (final MPSelectable selectableElement in selectableElements) {
      if (selectableElement.contains(canvasCoordinates)) {
        if (selectableElement is MPSelectableElement) {
          final THElement element = selectableElement.element;

          switch (selectionType) {
            case THSelectionType.pla:
              switch (element) {
                case THPoint _:
                case THLine _:
                  clickedElements[element.mpID] = element;
                case THLineSegment _:
                  clickedElements[element.parentMPID] =
                      _thFile.elementByMPID(element.parentMPID);
              }
            case THSelectionType.lineSegment:
              if (selectableElement is! MPSelectableLineSegment) {
                continue;
              }
              clickedElements[element.mpID] = element;
          }
        }
      }
    }

    if ((clickedElements.length > 1) && presentMultipleElementsClickedWidget) {
      selectionCanBeMultiple = canBeMultiple;
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPWindowType.multipleElementsClicked,
        true,
      );

      multipleElementsClickedSemaphore = Completer<void>();
      await multipleElementsClickedSemaphore.future;

      if (_multipleElementsClickedChoice > 0) {
        clickedElements.clear();
        clickedElements[_multipleElementsClickedChoice] =
            _thFile.elementByMPID(_multipleElementsClickedChoice);
      } else if (_multipleElementsClickedChoice < 0) {
        clickedElements.clear();
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
          insideWindowElements[element.mpID] = element;
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
          insideWindowElements[element.mpID] = element;
        }
      }
    }

    return insideWindowElements.values.toList();
  }

  void updateSelectableEndAndControlPoints() {
    _selectableEndControlPoints.clear();

    if ((_mpSelectedElements.length != 1) ||
        (_mpSelectedElements.values.first is! MPSelectedLine)) {
      return;
    }

    final THLine line =
        _thFile.lineByMPID(_mpSelectedElements.values.first.mpID);
    final List<THLineSegment> lineSegments =
        _th2FileEditController.elementEditController.getLineSegmentsList(
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
            _selectedLineSegments.containsKey(lineSegment.mpID);
        continue;
      }

      final int lineSegmentMPID = lineSegment.mpID;
      final bool currentLineSegmentSelected =
          _selectedLineSegments.containsKey(lineSegmentMPID);
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
      _selectedLineSegments[lineSegment.mpID] = lineSegment;
    }
  }

  void removeSelectedLineSegments(List<THLineSegment> lineSegments) {
    for (final THLineSegment lineSegment in lineSegments) {
      _selectedLineSegments.remove(lineSegment.mpID);
    }
  }

  bool getIsLineSegmentSelected(THLineSegment lineSegment) {
    return _selectedLineSegments.containsKey(lineSegment.mpID);
  }

  void warmSelectableElementsCanvasScaleChanged() {
    for (final selectableElement in _selectableElements.values) {
      selectableElement.canvasScaleChanged();
    }
  }

  List<THLineSegment> getLineSegmentAndPrevious(THLineSegment lineSegment) {
    final THLine line = _thFile.lineByMPID(lineSegment.parentMPID);
    final List<THLineSegment> lineSegments =
        _th2FileEditController.elementEditController.getLineSegmentsList(
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

  void moveSelectedElementsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedElementsToCanvasCoordinates(canvasCoordinatesFinalPosition);
  }

  @action
  void moveSelectedElementsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if ((_mpSelectedElements.isEmpty) || !_th2FileEditController.isSelectMode) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;
    final selectedElements = _mpSelectedElements.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement.originalElementClone) {
        case THPoint _:
          _updateTHPointPosition(
            selectedElement as MPSelectedPoint,
            localDeltaPositionOnCanvas,
          );
        case THLine _:
          _updateTHLinePosition(
            selectedElement as MPSelectedLine,
            localDeltaPositionOnCanvas,
          );
      }
    }

    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void _updateTHPointPosition(
    MPSelectedPoint selectedPoint,
    Offset localDeltaPositionOnCanvas,
  ) {
    final THPoint originalPoint = selectedPoint.originalPointClone;
    final THPoint modifiedPoint = originalPoint.copyWith(
        position: originalPoint.position.copyWith(
            coordinates: originalPoint.position.coordinates +
                localDeltaPositionOnCanvas));
    _th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(modifiedPoint);
  }

  void _updateTHLinePosition(
    MPSelectedLine selectedLine,
    Offset localDeltaPositionOnCanvas,
  ) {
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final lineSegmentEntry
        in selectedLine.originalLineSegmentsMapClone.entries) {
      final THElement lineChild = lineSegmentEntry.value;

      if (lineChild is! THLineSegment) {
        continue;
      }

      late THLineSegment modifiedLineSegment;

      switch (lineChild) {
        case THStraightLineSegment _:
          modifiedLineSegment = lineChild.copyWith(
              endPoint: lineChild.endPoint.copyWith(
                  coordinates: lineChild.endPoint.coordinates +
                      localDeltaPositionOnCanvas));
        case THBezierCurveLineSegment _:
          modifiedLineSegment = lineChild.copyWith(
              endPoint: lineChild.endPoint.copyWith(
                  coordinates: lineChild.endPoint.coordinates +
                      localDeltaPositionOnCanvas),
              controlPoint1: lineChild.controlPoint1.copyWith(
                  coordinates: lineChild.controlPoint1.coordinates +
                      localDeltaPositionOnCanvas),
              controlPoint2: lineChild.controlPoint2.copyWith(
                  coordinates: lineChild.controlPoint2.coordinates +
                      localDeltaPositionOnCanvas));
        default:
          throw Exception('Unknown line segment type');
      }

      modifiedLineSegmentsMap[lineChild.mpID] = modifiedLineSegment;
    }

    _th2FileEditController.elementEditController
        .substituteLineSegments(modifiedLineSegmentsMap);
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
        (_mpSelectedElements.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMPIDs = getSelectedLineLineSegmentsMPIDs();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final Iterable<THLineSegment> selectedLineSegments =
        _selectedLineSegments.values;
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    for (final THLineSegment selectedLineSegment in selectedLineSegments) {
      final int selectedLineSegmentMPID = selectedLineSegment.mpID;
      final THLineSegment originalLineSegment =
          originalLineSegments[selectedLineSegmentMPID]!;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegments[selectedLineSegmentMPID] =
              originalLineSegment.copyWith(
            endPoint: THPositionPart(
              coordinates: originalLineSegment.endPoint.coordinates +
                  localDeltaPositionOnCanvas,
              decimalPositions: currentDecimalPositions,
            ),
          );
        case THBezierCurveLineSegment _:
          final THBezierCurveLineSegment referenceLineSegment =
              modifiedLineSegments.containsKey(selectedLineSegmentMPID)
                  ? modifiedLineSegments[selectedLineSegmentMPID]
                      as THBezierCurveLineSegment
                  : originalLineSegment;

          modifiedLineSegments[selectedLineSegmentMPID] =
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

      final int? nextLineSegmentMPID = getNextLineSegmentMPID(
          selectedLineSegmentMPID, lineLineSegmentsMPIDs);

      if (nextLineSegmentMPID != null) {
        final THLineSegment nextLineSegment =
            _thFile.lineSegmentByMPID(nextLineSegmentMPID);

        if (nextLineSegment is THBezierCurveLineSegment) {
          final THBezierCurveLineSegment originalNextLineSegment =
              originalLineSegments[nextLineSegmentMPID]
                  as THBezierCurveLineSegment;
          final THBezierCurveLineSegment referenceNextLineSegment =
              (modifiedLineSegments.containsKey(nextLineSegmentMPID)
                  ? modifiedLineSegments[nextLineSegmentMPID]
                  : originalNextLineSegment) as THBezierCurveLineSegment;

          modifiedLineSegments[nextLineSegmentMPID] =
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

    _th2FileEditController.elementEditController
        .substituteLineSegments(modifiedLineSegments);
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
        (_mpSelectedElements.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final THBezierCurveLineSegment controlPointLineSegment =
        _selectedControlPoint!.element as THBezierCurveLineSegment;
    final int controlPointLineSegmentMPID = controlPointLineSegment.mpID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMPID]
            as THBezierCurveLineSegment;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    switch (_selectedControlPoint!.type) {
      case MPSelectableControlPointType.controlPoint1:
        modifiedLineSegments[controlPointLineSegmentMPID] =
            originalControlPointLineSegment.copyWith(
          controlPoint1: THPositionPart(
            coordinates:
                originalControlPointLineSegment.controlPoint1.coordinates +
                    localDeltaPositionOnCanvas,
            decimalPositions: currentDecimalPositions,
          ),
        );
      case MPSelectableControlPointType.controlPoint2:
        modifiedLineSegments[controlPointLineSegmentMPID] =
            originalControlPointLineSegment.copyWith(
          controlPoint2: THPositionPart(
            coordinates:
                originalControlPointLineSegment.controlPoint2.coordinates +
                    localDeltaPositionOnCanvas,
            decimalPositions: currentDecimalPositions,
          ),
        );
    }

    _th2FileEditController.elementEditController
        .substituteLineSegments(modifiedLineSegments);
    updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  List<int> getSelectedLineLineSegmentsMPIDs() {
    _selectedLineLineSegmentsMPIDs ??=
        ((_mpSelectedElements[_mpSelectedElements.keys.first] as MPSelectedLine)
                .originalElementClone as THLine)
            .childrenMPID
            .where((childMPID) {
      return _thFile.elementByMPID(childMPID) is THLineSegment;
    }).toList();

    return _selectedLineLineSegmentsMPIDs!;
  }

  void resetSelectedLineLineSegmentsMPIDs() {
    _selectedLineLineSegmentsMPIDs = null;
  }

  int? getNextLineSegmentMPID(
      int lineSegmentMPID, List<int> lineLineSegmentsMPIDs) {
    final int lineSegmentIndex = lineLineSegmentsMPIDs.indexOf(lineSegmentMPID);

    if ((lineSegmentIndex == -1) ||
        (lineSegmentIndex == lineLineSegmentsMPIDs.length - 1)) {
      return null;
    }

    return lineLineSegmentsMPIDs[lineSegmentIndex + 1];
  }

  THLineSegment? nextLineSegment(
    THLineSegment lineSegment, {
    List<THLineSegment>? lineSegments,
  }) {
    if (lineSegments == null) {
      final THLine line = _thFile.lineByMPID(lineSegment.parentMPID);

      lineSegments =
          _th2FileEditController.elementEditController.getLineSegmentsList(
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
    return isElementSelectedByMPID(element.mpID);
  }

  bool isElementSelectedByMPID(int mpID) {
    return _mpSelectedElements.containsKey(mpID);
  }

  bool isEndpointSelected(THLineSegment lineSegment) {
    return _selectedLineSegments.containsKey(lineSegment.mpID);
  }

  @action
  void clearSelectedElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();
  }

  void clearIsSelected() {
    _isSelected.clear();
  }

  void setIsSelected(int mpID, bool value) {
    _isSelected[mpID] = Observable(value);
  }

  void _clearSelectedElementsWithoutResettingRedrawTriggers() {
    _mpSelectedElements.clear();
    _isSelected.forEach((key, value) => value.value = false);
    clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
  }

  void clearSelectedElementsBoundingBoxAndSelectionHandleCenters() {
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
  }

  void clearSelectedElementsAndSelectionHandleCenters() {
    _mpSelectedElements.clear();
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
  }

  bool setSelectionState() {
    if (_mpSelectedElements.isEmpty) {
      return _th2FileEditController.stateController
          .setState(MPTH2FileEditStateType.selectEmptySelection);
    } else {
      return _th2FileEditController.stateController
          .setState(MPTH2FileEditStateType.selectNonEmptySelection);
    }
  }

  void setMultipleElementsClickedChoice(int choiceID) {
    _multipleElementsClickedChoice = choiceID;
  }

  void performMultipleElementsClickedChoosen(int choiceID) {
    _multipleElementsClickedChoice = choiceID;

    _th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.multipleElementsClicked,
      false,
    );
  }

  @action
  setMultipleElementsClickedHighlightedMPIDs(int? mpID) {
    _multipleElementsClickedHighlightedMPID = mpID;
  }
}

enum THSelectionType {
  lineSegment,
  pla;
}
