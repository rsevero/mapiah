import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
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
    TH2FileEditController th2FileEditController,
  ) : _th2FileEditController = th2FileEditController,
      _thFile = th2FileEditController.thFile;

  @readonly
  Set<int> _isSelected = {};

  @readonly
  ObservableMap<int, MPSelectedElement> _mpSelectedElementsLogical =
      ObservableMap<int, MPSelectedElement>();

  @readonly
  ObservableMap<int, THElement> _selectedElementsDrawable =
      ObservableMap<int, THElement>();

  @readonly
  Iterable<THElement> _clickedElementsAtPointerDown = {};

  List<MPSelectableEndControlPoint> clickedEndControlPoints = [];

  @readonly
  MPMultipleEndControlPointsClickedChoice
  _multipleEndControlPointsClickedChoice =
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.all,
      );

  @readonly
  MPMultipleEndControlPointsClickedChoice
  _multipleEndControlPointsClickedHighlightedChoice =
      MPMultipleEndControlPointsClickedChoice(
        type: MPMultipleEndControlPointsClickedType.none,
      );

  Map<int, THElement> clickedElements = {};

  @readonly
  int _multipleElementsClickedChoice = mpMultipleElementsClickedAllChoiceID;

  @readonly
  int? _multipleElementsClickedHighlightedMPID;

  Completer<void> multipleClickedSemaphore = Completer<void>();

  bool selectionCanBeMultiple = false;

  Rect? _selectedElementsBoundingBox;

  @readonly
  Map<int, MPSelectedEndControlPoint> _selectedEndControlPoints = {};

  @readonly
  Set<MPSelectableEndControlPoint> _selectableEndControlPoints = {};

  @readonly
  Observable<Rect> _selectionWindowCanvasCoordinates = Observable(Rect.zero);

  List<int>? _selectedLineLineSegmentsMPIDs;

  Map<MPSelectionHandleType, Offset>? _selectionHandleCenters;

  Rect? _selectionHandlesBoundingBox;

  /// Used to search for selected elements by list of selectable coordinates.
  Map<int, MPSelectable>? _mpSelectableElements;

  Offset dragStartCanvasCoordinates = Offset.zero;

  Rect get selectedElementsBoundingBox {
    _selectedElementsBoundingBox ??= getSelectedElementsBoundingBoxOnCanvas();

    return _selectedElementsBoundingBox!;
  }

  MPSelectedEndControlPointPointType
  getCurrentSelectedEndControlPointPointType() {
    if (_selectedEndControlPoints.length > 1) {
      return MPSelectedEndControlPointPointType.endPoint;
    } else if (_selectedEndControlPoints.length == 1) {
      return MPEditElementAux.isEndPoint(
            _selectedEndControlPoints.values.first.type,
          )
          ? MPSelectedEndControlPointPointType.endPoint
          : MPSelectedEndControlPointPointType.controlPoint;
    } else {
      return MPSelectedEndControlPointPointType.none;
    }
  }

  Map<MPSelectionHandleType, Offset> getSelectionHandleCenters() {
    if (_selectionHandleCenters == null) {
      _calculateSelectionHandleCentersAndBoundingBox();
    }

    return _selectionHandleCenters!;
  }

  Rect getSelectionHandlesBoundingBox() {
    if (_selectionHandlesBoundingBox == null) {
      _calculateSelectionHandleCentersAndBoundingBox();
    }

    return _selectionHandlesBoundingBox!;
  }

  Map<int, MPSelectable> getMPSelectableElements() {
    if (_mpSelectableElements == null) {
      _updateMPSelectableElements();
    }

    return _mpSelectableElements!;
  }

  void _updateMPSelectableElements() {
    _mpSelectableElements = {};

    if (_th2FileEditController.activeScrapID <= 0) {
      return;
    }

    final THScrap scrap = _thFile.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );

    for (final int elementMPID in scrap.childrenMPIDs) {
      final THElement element = _thFile.elementByMPID(elementMPID);

      addSelectableElement(element);
    }
  }

  Rect _getElementsListBoundingBoxOnCanvas(Iterable<THElement> elements) {
    Rect? boundingBox;

    for (final THElement element in elements) {
      switch (element) {
        case THPoint _:
        case THLine _:
        case THArea _:
          final Rect newElementBoundingBox = (element as MPBoundingBox)
              .getBoundingBox(_th2FileEditController);

          boundingBox =
              boundingBox?.expandToInclude(newElementBoundingBox) ??
              newElementBoundingBox;
        default:
          continue;
      }
    }

    return boundingBox ?? Rect.zero;
  }

  void setClickedElementsAtPointerDown(Iterable<THElement> clickedElements) {
    _clickedElementsAtPointerDown = clickedElements;
  }

  void clearClickedElementsAtPointerDown() {
    _clickedElementsAtPointerDown = <THElement>[];
  }

  @action
  void substituteSelectedElementsByClickedElements() {
    _mpSelectedElementsLogical.clear();
    _selectedElementsDrawable.clear();
    for (final THElement clickedElement in _clickedElementsAtPointerDown) {
      addSelectedElement(clickedElement);
    }
    clearClickedElementsAtPointerDown();
  }

  @action
  Rect getSelectedElementsBoundingBoxOnCanvas() {
    final Iterable<THElement> selectedElements = _mpSelectedElementsLogical
        .values
        .map(
          (MPSelectedElement selectedElement) =>
              _thFile.elementByMPID(selectedElement.mpID),
        );

    return _getElementsListBoundingBoxOnCanvas(selectedElements);
  }

  Rect getClickedElementsBoundingBoxOnCanvas() {
    return _getElementsListBoundingBoxOnCanvas(clickedElements.values);
  }

  @action
  void removeSelected() {
    if (_mpSelectedElementsLogical.isEmpty) {
      return;
    }

    late MPCommand mpCommand;

    if (_mpSelectedElementsLogical.length == 1) {
      final THElement singleSelectedElement = _mpSelectedElementsLogical.values
          .toList()
          .first
          .originalElementClone;

      switch (singleSelectedElement) {
        case THPoint _:
          mpCommand = MPRemovePointCommand(
            pointMPID: singleSelectedElement.mpID,
          );
        case THLine _:
          mpCommand = MPRemoveLineCommand(
            lineMPID: singleSelectedElement.mpID,
            isInteractiveLineCreation:
                _th2FileEditController
                    .elementEditController
                    .lineStartScreenPosition !=
                null,
          );
      }
    } else {
      final List<int> selectedMPIDs = _mpSelectedElementsLogical.keys.toList();

      mpCommand = MPCommandFactory.removeElements(
        mpIDs: selectedMPIDs,
        thFile: _thFile,
      );
    }

    _th2FileEditController.execute(mpCommand);
    clearSelectedElements();
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void updateSelectedElementClone(int mpID) {
    if (_mpSelectedElementsLogical.containsKey(mpID)) {
      _mpSelectedElementsLogical[mpID]!.updateClone(_th2FileEditController);
    }
  }

  void updateSelectedLineSegment(THLineSegment lineSegment) {
    if (_selectedEndControlPoints.containsKey(lineSegment.mpID)) {
      _selectedEndControlPoints[lineSegment.mpID] = MPSelectedEndControlPoint(
        originalLineSegment: lineSegment,
        type: (lineSegment is THStraightLineSegment)
            ? MPEndControlPointType.endPointStraight
            : MPEndControlPointType.endPointBezierCurve,
      );
    }
  }

  void updateSelectedElementsClones() {
    for (final MPSelectedElement selectedElement
        in _mpSelectedElementsLogical.values) {
      selectedElement.updateClone(_th2FileEditController);
    }
  }

  void updateAfterAddElement(THElement element) {
    addSelectableElement(element);
    updateSelectedElementClone(element.parentMPID);
  }

  @action
  bool addSelectedElement(THElement element, {bool setState = false}) {
    switch (element) {
      case THPoint _:
        _mpSelectedElementsLogical[element.mpID] = MPSelectedPoint(
          originalPoint: element,
        );
        _selectedElementsDrawable[element.mpID] = element;
      case THLine _:
        _mpSelectedElementsLogical[element.mpID] = MPSelectedLine(
          originalLine: element,
          th2FileEditController: _th2FileEditController,
        );
        _selectedElementsDrawable[element.mpID] = element;
      case THArea _:
        _mpSelectedElementsLogical[element.mpID] = MPSelectedArea(
          originalArea: element,
          th2FileEditController: _th2FileEditController,
        );

        final List<int> lineMPIDs = element.getLineMPIDs(_thFile);

        for (final int lineMPID in lineMPIDs) {
          final THLine line = _thFile.lineByMPID(lineMPID);

          _selectedElementsDrawable[lineMPID] = line;
        }
    }

    _isSelected.add(element.mpID);
    _th2FileEditController.optionEditController.setOptionElementsType(
      MPOptionElementType.pla,
    );
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
    if (_th2FileEditController.activeScrapID <= 0) {
      return;
    }

    final THScrap scrap = _thFile.scrapByMPID(
      _th2FileEditController.activeScrapID,
    );
    final List<int> elementMPIDs = scrap.childrenMPIDs;

    for (final int elementMPID in elementMPIDs) {
      final THElement element = _thFile.elementByMPID(elementMPID);

      if (element is THPoint || element is THLine) {
        addSelectedElement(element);
      }
    }

    _th2FileEditController.snapController.updateSnapTargets();
  }

  @action
  bool setSelectedElements(
    Iterable<THElement> selectedElements, {
    bool setState = false,
  }) {
    _clearSelectedElementsWithoutResettingRedrawTriggers();

    for (THElement element in selectedElements) {
      switch (element) {
        case THPoint _:
        case THLine _:
        case THArea _:
          addSelectedElement(element);
      }
    }

    _th2FileEditController.snapController.updateSnapTargets();

    if (setState) {
      return setSelectionState();
    }

    return false;
  }

  @action
  bool removeElementFromSelected(
    THElement element, {
    bool setState = false,
    bool updateSnapTargets = true,
  }) {
    final int elementMPID = element.mpID;

    _mpSelectedElementsLogical.remove(elementMPID);

    if (element is THArea) {
      final List<int> lineMPIDs = element.getLineMPIDs(_thFile);

      for (final int lineMPID in lineMPIDs) {
        _selectedElementsDrawable.remove(lineMPID);
      }
    } else {
      _selectedElementsDrawable.remove(elementMPID);
    }

    _isSelected.remove(elementMPID);
    if (updateSnapTargets) {
      _th2FileEditController.snapController.updateSnapTargets();
    }
    _th2FileEditController.triggerSelectedListChanged();

    if (setState) {
      return setSelectionState();
    }

    return false;
  }

  @action
  void removeSelectedElements(List<THElement> elements) {
    for (THElement element in elements) {
      removeElementFromSelected(element, updateSnapTargets: false);
    }
    _th2FileEditController.snapController.updateSnapTargets();
  }

  void setSelectedEndControlPoint(MPSelectableEndControlPoint endControlPoint) {
    _selectedEndControlPoints.clear();
    _selectedEndControlPoints[endControlPoint.element.mpID] =
        MPSelectedEndControlPoint(
          originalLineSegment: endControlPoint.lineSegment,
          type: endControlPoint.type,
        );
    _th2FileEditController.optionEditController.setOptionElementsType(
      MPOptionElementType.lineSegment,
    );
  }

  void clearSelectedEndControlPoints() {
    _selectedEndControlPoints.clear;
  }

  void setDragStartCoordinatesFromScreenCoordinates(Offset screenCoordinates) {
    dragStartCanvasCoordinates = _th2FileEditController.offsetScreenToCanvas(
      screenCoordinates,
    );
  }

  void setDragStartCoordinatesFromCanvasCoordinates(Offset canvasCoordinates) {
    dragStartCanvasCoordinates = canvasCoordinates;
  }

  void _calculateSelectionHandleCentersAndBoundingBox() {
    final Map<MPSelectionHandleType, Offset> handles =
        <MPSelectionHandleType, Offset>{};

    if (_mpSelectedElementsLogical.isEmpty) {
      _selectionHandleCenters = ObservableMap<MPSelectionHandleType, Offset>.of(
        handles,
      );
      _selectionHandlesBoundingBox = Rect.zero;

      return;
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

    _selectionHandlesBoundingBox = MPNumericAux.orderedRectFromLTRB(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );

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

    _selectionHandleCenters = handles;
  }

  void resetSelectableElements() {
    _mpSelectableElements = null;
  }

  void addSelectableElement(THElement element) {
    if (_mpSelectableElements == null) {
      _updateMPSelectableElements();
      return;
    }

    switch (element) {
      case THPoint _:
        _addPointSelectableElement(element);
      case THLine _:
        _addLineSelectableElement(element);
      case THArea _:
        _addAreaSelectableElement(element);
    }
  }

  void _addAreaSelectableElement(THArea area) {
    final int areaMPID = area.mpID;

    _isSelected.remove(areaMPID);
  }

  void _addPointSelectableElement(THPoint point) {
    if (_mpSelectableElements == null) {
      throw Exception(
        'At TH2FileEditSelectionController._addPointSelectableElement: selectable elements map is not initialized',
      );
    }

    final MPSelectablePoint selectablePoint = MPSelectablePoint(
      point: point,
      th2fileEditController: _th2FileEditController,
    );

    final int pointMPID = point.mpID;

    _mpSelectableElements![pointMPID] = selectablePoint;

    _isSelected.remove(pointMPID);
  }

  void _addLineSelectableElement(THLine line) {
    if (_mpSelectableElements == null) {
      throw Exception(
        'At TH2FileEditSelectionController._addLineSelectableElement: selectable elements map is not initialized',
      );
    }

    final MPSelectableLine selectableLine = MPSelectableLine(
      line: line,
      th2fileEditController: _th2FileEditController,
    );
    final int lineMPID = line.mpID;

    _mpSelectableElements![lineMPID] = selectableLine;
    _isSelected.remove(lineMPID);

    /// Adding line segments as selectable elements so on 'single line edit
    /// mode' its possible to select end point clicking on line segments.
    final List<THLineSegment> lineSegments = line.getLineSegments(_thFile);

    Offset? startPoint;

    for (final THLineSegment lineSegment in lineSegments) {
      if (startPoint == null) {
        startPoint = lineSegment.endPoint.coordinates;
        continue;
      }

      final MPSelectableLineSegment selectableLineSegment;

      switch (lineSegment) {
        case THStraightLineSegment _:
          selectableLineSegment = MPSelectableStraightLineSegment(
            straightLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditController: _th2FileEditController,
          );
        case THBezierCurveLineSegment _:
          selectableLineSegment = MPSelectableBezierCurveLineSegment(
            bezierCurveLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditController: _th2FileEditController,
          );
        default:
          throw Exception(
            'THLineSegment type not supported: ${lineSegment.elementType}',
          );
      }

      _mpSelectableElements![lineSegment.mpID] = selectableLineSegment;
      startPoint = lineSegment.endPoint.coordinates;
    }
  }

  void removeElementFromSelectable(int mpID) {
    _mpSelectableElements?.remove(mpID);
    _isSelected.remove(mpID);
  }

  Map<int, THElement> getSelectableElementsClickedWithoutDialog({
    required Offset screenCoordinates,
    required THSelectionType selectionType,
  }) {
    final Map<int, THElement> clicked = _getSelectableElementsClicked(
      screenCoordinates: screenCoordinates,
      selectionType: selectionType,
    );

    clickedElements.clear();
    clickedElements.addAll(clicked);

    return clickedElements;
  }

  Map<int, THElement> _getSelectableElementsClicked({
    required Offset screenCoordinates,
    required THSelectionType selectionType,
  }) {
    final Offset canvasCoordinates = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinates);
    final Iterable<MPSelectable> selectableElements =
        getMPSelectableElements().values;
    final Map<int, THElement> clickedElementsMap = {};

    for (final MPSelectable selectableElement in selectableElements) {
      if (selectableElement.contains(canvasCoordinates)) {
        if (selectableElement is MPSelectableElement) {
          final THElement element = selectableElement.element;

          switch (selectionType) {
            case THSelectionType.line:
              if (selectableElement is! MPSelectableLine) {
                continue;
              }
              clickedElementsMap[element.mpID] = element;
            case THSelectionType.lineSegment:
              if (selectableElement is! MPSelectableLineSegment) {
                continue;
              }
              clickedElementsMap[element.mpID] = element;
            case THSelectionType.pla:
              switch (element) {
                case THPoint _:
                  clickedElementsMap[element.mpID] = element;
                case THLine _:
                  final int? areaMPID = _thFile.getAreaMPIDByLineMPID(
                    element.mpID,
                  );

                  if (areaMPID != null) {
                    clickedElementsMap[areaMPID] = _thFile.elementByMPID(
                      areaMPID,
                    );
                  }
                  clickedElementsMap[element.mpID] = element;
                case THLineSegment _:
                  clickedElementsMap[element.parentMPID] = _thFile
                      .elementByMPID(element.parentMPID);
              }
          }
        }
      }
    }

    return clickedElementsMap;
  }

  Future<Map<int, THElement>> getSelectableElementsClickedWithDialog({
    required Offset screenCoordinates,
    required THSelectionType selectionType,
    required bool canBeMultiple,
    required bool presentMultipleElementsClickedWidget,
  }) async {
    final Map<int, THElement> clicked = _getSelectableElementsClicked(
      screenCoordinates: screenCoordinates,
      selectionType: selectionType,
    );

    clickedElements.clear();
    clickedElements.addAll(clicked);

    if (presentMultipleElementsClickedWidget && (clickedElements.length > 1)) {
      selectionCanBeMultiple = canBeMultiple;
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPWindowType.multipleElementsClicked,
        true,
      );

      multipleClickedSemaphore = Completer<void>();
      await multipleClickedSemaphore.future;

      if (_multipleElementsClickedChoice > 0) {
        clickedElements.clear();
        clickedElements[_multipleElementsClickedChoice] = _thFile.elementByMPID(
          _multipleElementsClickedChoice,
        );
      } else if (_multipleElementsClickedChoice < 0) {
        clickedElements.clear();
      }
    }

    return clickedElements;
  }

  List<THElement> selectableElementsInsideWindow(Rect canvasSelectionWindow) {
    final Map<int, THElement> insideWindowElements = <int, THElement>{};
    final Iterable<MPSelectable> selectableElements =
        getMPSelectableElements().values;

    for (final MPSelectable selectableElement in selectableElements) {
      if (selectableElement is MPSelectableElement) {
        if ((selectableElement is! MPSelectablePoint) &&
            (selectableElement is! MPSelectableLine)) {
          continue;
        }

        final THElement element = selectableElement.element;

        if (MPNumericAux.isRect1InsideRect2(
          rect1: (element as MPBoundingBox).getBoundingBox(
            _th2FileEditController,
          ),
          rect2: canvasSelectionWindow,
        )) {
          insideWindowElements[element.mpID] = element;
        }
      }
    }

    return insideWindowElements.values.toList();
  }

  Future<List<MPSelectableEndControlPoint>> selectableEndControlPointsClicked({
    required Offset screenCoordinates,
    required bool includeControlPoints,
    required bool canBeMultiple,
    required bool presentMultipleEndControlPointsClickedWidget,
  }) async {
    final Offset canvasCoordinates = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinates);
    clickedEndControlPoints.clear();
    final List<MPSelectableEndControlPoint> clickedControlPoints = [];

    for (final MPSelectableEndControlPoint endControlPoint
        in _selectableEndControlPoints) {
      if (endControlPoint.contains(canvasCoordinates)) {
        if (MPEditElementAux.isEndPoint(endControlPoint.type)) {
          clickedEndControlPoints.add(endControlPoint);
        } else if (includeControlPoints &&
            MPEditElementAux.isControlPoint(endControlPoint.type)) {
          clickedControlPoints.add(endControlPoint);
        }
      }
    }

    if (clickedControlPoints.isNotEmpty) {
      clickedEndControlPoints.addAll(clickedControlPoints);
    }

    if ((clickedEndControlPoints.length > 1) &&
        presentMultipleEndControlPointsClickedWidget) {
      selectionCanBeMultiple = canBeMultiple;
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPWindowType.multipleEndControlPointsClicked,
        true,
      );

      multipleClickedSemaphore = Completer<void>();
      await multipleClickedSemaphore.future;

      if (_multipleEndControlPointsClickedChoice.type ==
          MPMultipleEndControlPointsClickedType.single) {
        clickedEndControlPoints.clear();
        clickedEndControlPoints.add(
          _multipleEndControlPointsClickedChoice.endControlPoint!,
        );
      } else if (_multipleEndControlPointsClickedChoice.type ==
          MPMultipleEndControlPointsClickedType.none) {
        clickedEndControlPoints.clear();
      }
    }

    return clickedEndControlPoints;
  }

  List<THLineSegment> selectableEndPointsInsideWindow(
    Rect canvasSelectionWindow,
  ) {
    final Map<int, THLineSegment> insideWindowElements = <int, THLineSegment>{};

    for (final MPSelectableEndControlPoint selectableEndControlPoint
        in _selectableEndControlPoints) {
      if (MPEditElementAux.isEndPoint(selectableEndControlPoint.type)) {
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

    if ((_mpSelectedElementsLogical.length != 1) ||
        (_mpSelectedElementsLogical.values.first is! MPSelectedLine)) {
      return;
    }

    final THLine line = _thFile.lineByMPID(
      _mpSelectedElementsLogical.values.first.mpID,
    );
    final List<THLineSegment> lineSegments = _th2FileEditController
        .elementEditController
        .getLineSegmentsList(line: line, clone: false);
    bool isFirst = true;
    bool previousLineSegmentSelected = false;

    for (final THLineSegment lineSegment in lineSegments) {
      if (isFirst) {
        _selectableEndControlPoints.add(
          MPSelectableEndControlPoint(
            lineSegment: lineSegment,
            position: lineSegment.endPoint.coordinates,
            th2fileEditController: _th2FileEditController,
            type: (lineSegment is THStraightLineSegment)
                ? MPEndControlPointType.endPointStraight
                : MPEndControlPointType.endPointBezierCurve,
          ),
        );
        isFirst = false;

        final int lineSegmentMPID = lineSegment.mpID;

        previousLineSegmentSelected =
            _selectedEndControlPoints.containsKey(lineSegmentMPID) &&
            (_selectedEndControlPoints[lineSegmentMPID]!.type !=
                MPEndControlPointType.controlPoint1);
        continue;
      }

      final int lineSegmentMPID = lineSegment.mpID;
      final bool currentLineSegmentSelected = _selectedEndControlPoints
          .containsKey(lineSegmentMPID);

      bool nextLineSegmentSelected = false;

      if (lineSegments.length > lineSegments.indexOf(lineSegment) + 1) {
        final int nextLineSegmentMPID =
            lineSegments[lineSegments.indexOf(lineSegment) + 1].mpID;

        if (_selectedEndControlPoints.containsKey(nextLineSegmentMPID) &&
            _selectedEndControlPoints[nextLineSegmentMPID]!.type ==
                MPEndControlPointType.controlPoint1) {
          nextLineSegmentSelected = true;
        }
      }

      final bool addControlPoints =
          (previousLineSegmentSelected ||
              currentLineSegmentSelected ||
              nextLineSegmentSelected) &&
          (lineSegment is THBezierCurveLineSegment);

      if (addControlPoints) {
        _selectableEndControlPoints.add(
          MPSelectableEndControlPoint(
            lineSegment: lineSegment,
            position: lineSegment.controlPoint1.coordinates,
            type: MPEndControlPointType.controlPoint1,
            th2fileEditController: _th2FileEditController,
          ),
        );
      }

      _selectableEndControlPoints.add(
        MPSelectableEndControlPoint(
          lineSegment: lineSegment,
          position: lineSegment.endPoint.coordinates,
          th2fileEditController: _th2FileEditController,
          type: (lineSegment is THStraightLineSegment)
              ? MPEndControlPointType.endPointStraight
              : MPEndControlPointType.endPointBezierCurve,
        ),
      );

      if (addControlPoints) {
        _selectableEndControlPoints.add(
          MPSelectableEndControlPoint(
            lineSegment: lineSegment,
            position: lineSegment.controlPoint2.coordinates,
            type: MPEndControlPointType.controlPoint2,
            th2fileEditController: _th2FileEditController,
          ),
        );
      }
      previousLineSegmentSelected =
          currentLineSegmentSelected &&
          (_selectedEndControlPoints[lineSegment.mpID]!.type !=
              MPEndControlPointType.controlPoint1);
    }
  }

  void setSelectedEndPoints(List<THLineSegment> lineSegments) {
    _selectedEndControlPoints.clear();
    addSelectedEndPoints(lineSegments);
  }

  void clearSelectedLineSegments() {
    _selectedEndControlPoints.clear();
  }

  void addSelectedEndPoint(THLineSegment lineSegment) {
    _selectedEndControlPoints[lineSegment.mpID] =
        getNewMPSelectedEndControlPoint(lineSegment);
    _th2FileEditController.optionEditController.setOptionElementsType(
      MPOptionElementType.lineSegment,
    );
  }

  void addSelectedEndControlPoint(MPSelectableEndControlPoint endControlPoint) {
    _selectedEndControlPoints[endControlPoint.element.mpID] =
        MPSelectedEndControlPoint(
          originalLineSegment: endControlPoint.lineSegment,
          type: endControlPoint.type,
        );
  }

  MPSelectedEndControlPoint getNewMPSelectedEndControlPoint(
    THLineSegment lineSegment,
  ) {
    return MPSelectedEndControlPoint(
      originalLineSegment: lineSegment,
      type: lineSegment is THStraightLineSegment
          ? MPEndControlPointType.endPointStraight
          : MPEndControlPointType.endPointBezierCurve,
    );
  }

  void addSelectedEndPoints(List<THLineSegment> lineSegments) {
    for (final THLineSegment lineSegment in lineSegments) {
      _selectedEndControlPoints[lineSegment.mpID] =
          getNewMPSelectedEndControlPoint(lineSegment);
    }
    _th2FileEditController.optionEditController.setOptionElementsType(
      MPOptionElementType.lineSegment,
    );
  }

  void removeSelectedLineSegment(THLineSegment lineSegment) {
    _selectedEndControlPoints.remove(lineSegment.mpID);
  }

  void removeSelectedEndControlPoints(List<THLineSegment> lineSegments) {
    for (final THLineSegment lineSegment in lineSegments) {
      _selectedEndControlPoints.remove(lineSegment.mpID);
    }
  }

  bool getIsLineSegmentSelected(THLineSegment lineSegment) {
    return _selectedEndControlPoints.containsKey(lineSegment.mpID);
  }

  void warmSelectableElementsCanvasScaleChanged() {
    final Iterable<MPSelectable> selectableElements =
        getMPSelectableElements().values;

    for (final MPSelectable selectableElement in selectableElements) {
      selectableElement.canvasTransformChanged();
    }
  }

  List<THLineSegment> getLineSegmentAndPrevious(THLineSegment lineSegment) {
    final THLine line = _thFile.lineByMPID(lineSegment.parentMPID);
    final List<THLineSegment> lineSegments = _th2FileEditController
        .elementEditController
        .getLineSegmentsList(line: line, clone: false);

    final int lineSegmentIndex = lineSegments.indexOf(lineSegment);

    if (lineSegmentIndex == 0) {
      return <THLineSegment>[lineSegment];
    } else {
      return <THLineSegment>[lineSegments[lineSegmentIndex - 1], lineSegment];
    }
  }

  MPSelectedLineSegmentType getSelectedLineSegmentsType() {
    if (getCurrentSelectedEndControlPointPointType() ==
        MPSelectedEndControlPointPointType.controlPoint) {
      throw Exception(
        'TH2FileEditSelectionController.getSelectedLineSegmentsType() called when control control point is selected',
      );
    }

    final Iterable<MPSelectedEndControlPoint> endPoints =
        _selectedEndControlPoints.values;

    if (endPoints.isEmpty) {
      return MPSelectedLineSegmentType.none;
    }

    THElementType? elementType =
        endPoints.first.originalLineSegmentClone.elementType;

    if (endPoints.length == 1) {
      return elementType == THElementType.straightLineSegment
          ? MPSelectedLineSegmentType.straightLineSegment
          : MPSelectedLineSegmentType.bezierCurveLineSegment;
    }

    final Iterable<MPSelectedEndControlPoint> otherEndPoints = endPoints.skip(
      1,
    );

    for (final MPSelectedEndControlPoint endPoint in otherEndPoints) {
      if (endPoint.originalLineSegmentClone.elementType != elementType) {
        elementType = null;
        break;
      }
    }

    if (elementType == null) {
      return MPSelectedLineSegmentType.mixed;
    } else {
      return elementType == THElementType.straightLineSegment
          ? MPSelectedLineSegmentType.straightLineSegment
          : MPSelectedLineSegmentType.bezierCurveLineSegment;
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
    if ((_mpSelectedElementsLogical.isEmpty) ||
        !_th2FileEditController.isSelectMode) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;
    final Iterable<MPSelectedElement> mpSelectedElements =
        _mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in mpSelectedElements) {
      switch (selectedElement) {
        case MPSelectedPoint _:
          _updateTHPointPosition(selectedElement, localDeltaPositionOnCanvas);
        case MPSelectedLine _:
          _updateTHLinePosition(selectedElement, localDeltaPositionOnCanvas);
        case MPSelectedArea _:
          _updateTHAreaPosition(selectedElement, localDeltaPositionOnCanvas);
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
        coordinates:
            originalPoint.position.coordinates + localDeltaPositionOnCanvas,
      ),
      originalLineInTH2File: '',
      makeSameLineCommentNull: true,
    );
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
              coordinates:
                  lineChild.endPoint.coordinates + localDeltaPositionOnCanvas,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
        case THBezierCurveLineSegment _:
          modifiedLineSegment = lineChild.copyWith(
            endPoint: lineChild.endPoint.copyWith(
              coordinates:
                  lineChild.endPoint.coordinates + localDeltaPositionOnCanvas,
            ),
            controlPoint1: lineChild.controlPoint1.copyWith(
              coordinates:
                  lineChild.controlPoint1.coordinates +
                  localDeltaPositionOnCanvas,
            ),
            controlPoint2: lineChild.controlPoint2.copyWith(
              coordinates:
                  lineChild.controlPoint2.coordinates +
                  localDeltaPositionOnCanvas,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
        default:
          throw Exception('Unknown line segment type');
      }

      modifiedLineSegmentsMap[lineChild.mpID] = modifiedLineSegment;
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegmentsMap,
    );
  }

  void _updateTHAreaPosition(
    MPSelectedArea selectedArea,
    Offset localDeltaPositionOnCanvas,
  ) {
    final mpAreaLines = selectedArea.originalLines;

    for (final mpAreaLine in mpAreaLines) {
      _updateTHLinePosition(mpAreaLine, localDeltaPositionOnCanvas);
    }

    _thFile.areaByMPID(selectedArea.mpID).clearBoundingBox();
  }

  void moveSelectedEndControlPointsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedEndControlPointsToCanvasCoordinates(
      canvasCoordinatesFinalPosition,
    );
  }

  @action
  void moveSelectedEndControlPointsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if (getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.endPoint) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_mpSelectedElementsLogical.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMPIDs = getSelectedLineLineSegmentsMPIDs();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;
    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        _selectedEndControlPoints.values;

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      final THLineSegment selectedLineSegment =
          selectedEndControlPoint.originalLineSegmentClone;
      final int selectedLineSegmentMPID = selectedLineSegment.mpID;
      final THLineSegment originalLineSegment =
          originalLineSegments[selectedLineSegmentMPID]!;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegments[selectedLineSegmentMPID] = originalLineSegment
              .copyWith(
                endPoint: THPositionPart(
                  coordinates:
                      originalLineSegment.endPoint.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
        case THBezierCurveLineSegment _:
          final THBezierCurveLineSegment referenceLineSegment =
              modifiedLineSegments.containsKey(selectedLineSegmentMPID)
              ? modifiedLineSegments[selectedLineSegmentMPID]
                    as THBezierCurveLineSegment
              : originalLineSegment;

          modifiedLineSegments[selectedLineSegmentMPID] = referenceLineSegment
              .copyWith(
                endPoint: THPositionPart(
                  coordinates:
                      originalLineSegment.endPoint.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                controlPoint2: THPositionPart(
                  coordinates:
                      originalLineSegment.controlPoint2.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
      }

      final int? nextLineSegmentMPID = getNextLineSegmentMPID(
        selectedLineSegmentMPID,
        lineLineSegmentsMPIDs,
      );

      if (nextLineSegmentMPID != null) {
        final THLineSegment nextLineSegment = _thFile.lineSegmentByMPID(
          nextLineSegmentMPID,
        );

        if (nextLineSegment is THBezierCurveLineSegment) {
          final THBezierCurveLineSegment originalNextLineSegment =
              originalLineSegments[nextLineSegmentMPID]
                  as THBezierCurveLineSegment;
          final THBezierCurveLineSegment referenceNextLineSegment =
              (modifiedLineSegments.containsKey(nextLineSegmentMPID)
                      ? modifiedLineSegments[nextLineSegmentMPID]
                      : originalNextLineSegment)
                  as THBezierCurveLineSegment;

          modifiedLineSegments[nextLineSegmentMPID] = referenceNextLineSegment
              .copyWith(
                controlPoint1: THPositionPart(
                  coordinates:
                      originalNextLineSegment.controlPoint1.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
        }
      }
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegments,
    );
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
    if (getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.controlPoint) {
      return;
    }

    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_mpSelectedElementsLogical.values.first as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final MPSelectedEndControlPoint selectedControlPoint =
        _selectedEndControlPoints.values.first;
    final THBezierCurveLineSegment controlPointLineSegment =
        selectedControlPoint.originalElementClone as THBezierCurveLineSegment;
    final int controlPointLineSegmentMPID = controlPointLineSegment.mpID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMPID]
            as THBezierCurveLineSegment;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;
    final MPMoveControlPointSmoothInfo moveControlPointSmoothInfo =
        _th2FileEditController.elementEditController.moveControlPointSmoothInfo;

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        THBezierCurveLineSegment modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset newPosition = MPEditElementAux.moveControlPointInLine(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint1: THPositionPart(
              coordinates: newPosition,
              decimalPositions: mpCalculatedDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
        } else {
          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint1: THPositionPart(
              coordinates: canvasCoordinatesFinalPosition,
              decimalPositions: currentDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
        }

        modifiedLineSegments[controlPointLineSegmentMPID] = modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            !moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset? newPosition = MPEditElementAux.moveMirrorControlPoint(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          if (newPosition != null) {
            final THBezierCurveLineSegment newMirrorLineSegment =
                moveControlPointSmoothInfo.adjacentLineSegment!.copyWith(
                  controlPoint2: THPositionPart(
                    coordinates: newPosition,
                    decimalPositions: mpCalculatedDecimalPositions,
                  ),
                  originalLineInTH2File: '',
                );

            modifiedLineSegments[newMirrorLineSegment.mpID] =
                newMirrorLineSegment;
          }
        }
      case MPEndControlPointType.controlPoint2:
        THBezierCurveLineSegment modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset newPosition = MPEditElementAux.moveControlPointInLine(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint2: THPositionPart(
              coordinates: newPosition,
              decimalPositions: mpCalculatedDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
        } else {
          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint2: THPositionPart(
              coordinates: canvasCoordinatesFinalPosition,
              decimalPositions: currentDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
        }

        modifiedLineSegments[controlPointLineSegmentMPID] = modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            !moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset? newPosition = MPEditElementAux.moveMirrorControlPoint(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          if (newPosition != null) {
            final THBezierCurveLineSegment newMirrorLineSegment =
                moveControlPointSmoothInfo.adjacentLineSegment!.copyWith(
                  controlPoint1: THPositionPart(
                    coordinates: newPosition,
                    decimalPositions: mpCalculatedDecimalPositions,
                  ),
                  originalLineInTH2File: '',
                );

            modifiedLineSegments[newMirrorLineSegment.mpID] =
                newMirrorLineSegment;
          }
        }
      default:
        throw Exception(
          'TH2FileEditSelectionController.moveSelectedControlPointToCanvasCoordinates() called with invalid end/control point type: ${selectedControlPoint.type}',
        );
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegments,
    );
    updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  List<int> getSelectedLineLineSegmentsMPIDs() {
    _selectedLineLineSegmentsMPIDs ??=
        ((_mpSelectedElementsLogical[_mpSelectedElementsLogical.keys.first]
                        as MPSelectedLine)
                    .originalElementClone
                as THLine)
            .childrenMPIDs
            .where((childMPID) {
              return _thFile.elementByMPID(childMPID) is THLineSegment;
            })
            .toList();

    return _selectedLineLineSegmentsMPIDs!;
  }

  void resetSelectedLineLineSegmentsMPIDs() {
    _selectedLineLineSegmentsMPIDs = null;
  }

  int? getNextLineSegmentMPID(
    int lineSegmentMPID,
    List<int> lineLineSegmentsMPIDs,
  ) {
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

      lineSegments = _th2FileEditController.elementEditController
          .getLineSegmentsList(line: line, clone: false);
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
        MPNumericAux.orderedRectFromPoints(point1: point1, point2: point2);
  }

  void setSelectionWindowScreenEndCoordinates(Offset screenEndCoordinates) {
    final Offset canvasEndCoordinates = _th2FileEditController
        .offsetScreenToCanvas(screenEndCoordinates);

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
    return _mpSelectedElementsLogical.containsKey(mpID);
  }

  bool isEndControlPointSelected(int mpID) {
    return _selectedEndControlPoints.containsKey(mpID);
  }

  @action
  void clearSelectedElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();

    _th2FileEditController.snapController.updateSnapTargets();
  }

  void clearIsSelected() {
    _isSelected.clear();
  }

  void setIsSelected(int mpID, bool isSelected) {
    if (isSelected) {
      _isSelected.add(mpID);
    } else {
      _isSelected.remove(mpID);
    }
  }

  void _clearSelectedElementsWithoutResettingRedrawTriggers() {
    _mpSelectedElementsLogical.clear();
    _selectedElementsDrawable.clear();
    _isSelected.clear();
    clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
  }

  void clearSelectedElementsBoundingBoxAndSelectionHandleCenters() {
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
    _selectionHandlesBoundingBox = null;
  }

  void clearSelectedElementsAndSelectionHandleCenters() {
    _mpSelectedElementsLogical.clear();
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
    _selectionHandlesBoundingBox = null;
  }

  bool setSelectionState() {
    if (_mpSelectedElementsLogical.isEmpty) {
      return _th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );
    } else {
      return _th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectNonEmptySelection,
      );
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
  void setMultipleElementsClickedHighlightedMPIDs(int? mpID) {
    _multipleElementsClickedHighlightedMPID = mpID;
  }

  void setMultipleEndControlPointsClickedChoice(
    MPMultipleEndControlPointsClickedChoice choice,
  ) {
    _multipleEndControlPointsClickedChoice = choice;
  }

  void performMultipleEndControlPointsClickedChoosen(
    MPMultipleEndControlPointsClickedChoice choice,
  ) {
    _multipleEndControlPointsClickedChoice = choice;

    _th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.multipleEndControlPointsClicked,
      false,
    );
  }

  @action
  void setMultipleEndControlPointsClickedHighlightedChoice(
    MPMultipleEndControlPointsClickedChoice choice,
  ) {
    _multipleEndControlPointsClickedHighlightedChoice = choice;
  }

  Rect getClickedEndControlPointsBoundingBoxOnCanvas() {
    if (_selectedEndControlPoints.isEmpty) {
      return Rect.zero;
    }

    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        _selectedEndControlPoints.values;

    Rect boundingBox = MPNumericAux.orderedRectSmallestAroundPoint(
      center: selectedEndControlPoints
          .first
          .originalLineSegmentClone
          .endPoint
          .coordinates,
    );

    for (final MPSelectedEndControlPoint selectedLineSegment
        in selectedEndControlPoints.skip(1)) {
      boundingBox = MPNumericAux.orderedRectExpandedToIncludeOffset(
        rect: boundingBox,
        offset:
            selectedLineSegment.originalLineSegmentClone.endPoint.coordinates,
      );
    }

    return boundingBox;
  }

  @action
  void setImageVisibility(int imageMPID, bool isVisible) {
    _th2FileEditController.thFile
            .xtherionImageInsertConfigByMPID(imageMPID)
            .isVisible =
        isVisible;
    _th2FileEditController.triggerImagesRedraw();
  }

  @action
  void setSelectedScrapByMPID(int scrapID) {
    final THScrap scrap = _thFile.scrapByMPID(scrapID);

    _clearSelectedElementsWithoutResettingRedrawTriggers();
    _mpSelectedElementsLogical[scrapID] = MPSelectedScrap(originalScrap: scrap);
    _th2FileEditController.optionEditController.setOptionElementsType(
      MPOptionElementType.scrap,
    );
  }
}

enum THSelectionType { line, lineSegment, pla }

enum MPMultipleEndControlPointsClickedType { all, none, single }

enum MPSelectedLineSegmentType {
  bezierCurveLineSegment,
  mixed,
  none,
  straightLineSegment,
}

/// Informs if currently dealing with a control point or with 1 or more
/// endpoints.
enum MPSelectedEndControlPointPointType { none, controlPoint, endPoint }

class MPMultipleEndControlPointsClickedChoice {
  final MPSelectableEndControlPoint? endControlPoint;
  final MPMultipleEndControlPointsClickedType type;

  MPMultipleEndControlPointsClickedChoice({
    this.endControlPoint,
    required this.type,
  });
}
