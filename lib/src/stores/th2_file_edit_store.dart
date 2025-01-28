import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_selection_handle_type.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_parent_mixin.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/stores/mp_general_store.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';
import 'package:mapiah/src/stores/th2_file_edit_mode.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_controller.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_store.g.dart';

class TH2FileEditStore = TH2FileEditStoreBase with _$TH2FileEditStore;

abstract class TH2FileEditStoreBase with Store {
  // 'screen' is related to actual pixels on the screen.
  // 'canvas' is the virtual canvas used to draw.
  // 'data' is the actual data to be drawn.
  // 'canvas' and 'data' are on the same scale. They are both scaled and
  // translated to be shown on the screen.

  @readonly
  Size _screenSize = Size.zero;

  Size _canvasSize = Size.zero;

  @readonly
  double _canvasScale = 1.0;

  @readonly
  Offset _canvasTranslation = Offset.zero;

  @readonly
  TH2FileEditMode _visualMode = TH2FileEditMode.pan;

  @readonly
  bool _isLoading = false;

  @readonly
  late THFile _thFile;

  @readonly
  late int _thFileMapiahID;

  @readonly
  Map<int, Observable<bool>> _isSelected = <int, Observable<bool>>{};

  @readonly
  ObservableMap<int, MPSelectedElement> _selectedElements =
      ObservableMap<int, MPSelectedElement>();

  Rect get selectedElementsBoundingBox {
    _selectedElementsBoundingBox ??= _getSelectedElementsBoundingBox();

    return _selectedElementsBoundingBox!;
  }

  Rect? _selectedElementsBoundingBox;

  @computed
  bool get isEditMode => _visualMode == TH2FileEditMode.edit;

  @computed
  bool get isPanMode => _visualMode == TH2FileEditMode.pan;

  @computed
  bool get isSelectMode => _visualMode == TH2FileEditMode.select;

  @readonly
  bool _hasUndo = false;

  @readonly
  bool _hasRedo = false;

  @readonly
  String _undoDescription = '';

  @readonly
  String _redoDescription = '';

  @readonly
  bool _isZoomButtonsHovered = false;

  @readonly
  late MPTH2FileEditState _state;

  @computed
  double get lineThicknessOnCanvas =>
      getIt<MPSettingsStore>().lineThickness / _canvasScale;

  @computed
  double get pointRadiusOnCanvas =>
      getIt<MPSettingsStore>().pointRadius / _canvasScale;

  @computed
  double get selectionToleranceSquaredOnCanvas {
    final double selectionTolerance =
        getIt<MPSettingsStore>().selectionTolerance;

    return (selectionTolerance * selectionTolerance) / _canvasScale;
  }

  @computed
  bool get showSelectedElements => _selectedElements.isNotEmpty;

  @computed
  bool get showSelectionHandles =>
      showSelectedElements &&
      isSelectMode &&
      _state is! MPTH2FileEditStateMoving;

  @computed
  bool get showSelectionWindow =>
      _selectionWindowCanvasCoordinates.value != Rect.zero;

  @readonly
  bool _canvasScaleTranslationUndefined = true;

  @readonly
  Observable<Rect> _selectionWindowCanvasCoordinates = Observable(Rect.zero);

  @readonly
  Observable<Paint> _selectionWindowFillPaint =
      Observable(thSelectionWindowFillPaint);

  @readonly
  Observable<Paint> _selectionWindowBorderPaint =
      Observable(thSelectionWindowBorderPaint);

  @computed
  Observable<Paint> get selectionWindowBorderPaintComplete =>
      Observable(_selectionWindowBorderPaint.value
        ..strokeWidth = thSelectionWindowBorderPaintStrokeWidth / _canvasScale);

  @readonly
  Observable<double> _selectionWindowBorderPaintDashInterval =
      Observable(thSelectionWindowBorderPaintDashInterval);

  @computed
  Observable<double> get selectionWindowBorderPaintDashIntervalOnCanvas =>
      Observable(_selectionWindowBorderPaintDashInterval.value / _canvasScale);

  @computed
  Observable<double> get selectionHandleSizeOnCanvas =>
      Observable(thSelectionHandleSize / _canvasScale);

  @computed
  Observable<double> get selectionHandleDistanceOnCanvas =>
      Observable(thSelectionHandleDistance / _canvasScale);

  @computed
  Observable<double> get selectionHandleLineThicknessOnCanvas =>
      Observable(thSelectionHandleLineThickness / _canvasScale);

  @computed
  Observable<Paint> get selectionHandlePaint =>
      Observable(thSelectionHandleFillPaint
        ..strokeWidth = selectionHandleLineThicknessOnCanvas.value);

  @computed
  bool get showUndoRedoButtons => isSelectMode;

  Map<MPSelectionHandleType, Offset>? _selectionHandleCenters;

  Map<MPSelectionHandleType, Offset> getSelectionHandleCenters() {
    _selectionHandleCenters ??= _calculateSelectionHandleCenters();

    return _selectionHandleCenters!;
  }

  Map<MPSelectionHandleType, Offset> _calculateSelectionHandleCenters() {
    final Map<MPSelectionHandleType, Offset> handles =
        <MPSelectionHandleType, Offset>{};

    if (_selectedElements.isEmpty) {
      return ObservableMap<MPSelectionHandleType, Offset>.of(handles);
    }

    final double handleSize = selectionHandleSizeOnCanvas.value;
    final double handleDistance = selectionHandleDistanceOnCanvas.value;
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

  @readonly
  int _redrawTriggerSelectedElementsListChanged = 0;

  @readonly
  int _redrawTriggerSelectedElements = 0;

  @readonly
  int _redrawTriggerNonSelectedElements = 0;

  /// Used to serach for selected elements by list of selectable coordinates.
  final Map<int, List<Offset>> _selectableCoordinates = {};

  /// Used to search for selected elements by others characteristcs of the
  /// element: boundingBox() for example.
  final Map<int, Rect> _selectableBoundingBoxes = {};

  Offset panStartCanvasCoordinates = Offset.zero;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  double _canvasCenterX = 0.0;
  double _canvasCenterY = 0.0;

  final List<String> errorMessages = <String>[];

  late final MPUndoRedoController _undoRedoController;

  Future<TH2FileEditStoreCreateResult> load() async {
    _preParseInitialize();

    final THFileParser parser = THFileParser();

    final (parsedFile, isSuccessful, errors) =
        await parser.parse(_thFile.filename);

    _postParseInitialize(parsedFile, isSuccessful, errors);

    return TH2FileEditStoreCreateResult(isSuccessful, errors);
  }

  /// This is a factory constructor that creates a new instance of
  /// TH2FileEditStore with an empty THFile.
  static TH2FileEditStore create(String filename) {
    final TH2FileEditStore th2FileEditStore = TH2FileEditStore._create();
    final THFile thFile = THFile();
    thFile.filename = filename;
    th2FileEditStore._basicInitialization(thFile);
    return th2FileEditStore;
  }

  TH2FileEditStoreBase._create();

  void _basicInitialization(THFile file) {
    _thFile = file;
    _thFileMapiahID = _thFile.mapiahID;
    _state = MPTH2FileEditState.getState(
      type: MPTH2FileEditStateType.pan,
      thFileEditStore: this as TH2FileEditStore,
    );
    _undoRedoController = MPUndoRedoController(this as TH2FileEditStore);
  }

  void _preParseInitialize() {
    _isLoading = true;
    errorMessages.clear();
  }

  void _postParseInitialize(
    THFile parsedFile,
    bool isSuccessful,
    List<String> errors,
  ) {
    _isSelected.clear();
    _selectableCoordinates.clear();
    _selectableBoundingBoxes.clear();

    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine) {
        _isSelected[key] = Observable(false);
        _addSelectableElement(value);
      }
    });

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  /// We are sure that _selectableCoordinates[mapiahID] is already set to a list
  /// because _addSelectableElement adds/resets it.
  void _addSelectableElementCoordinates(
    int mapiahID,
    Offset selectableCanvasCoordinate,
  ) {
    _selectableCoordinates[mapiahID]!.add(selectableCanvasCoordinate);
  }

  void _addSelectableElement(THElement element) {
    if ((element is! THPoint) && (element is! THLine)) {
      return;
    }

    _selectableCoordinates[element.mapiahID] = <Offset>[];
    switch (element) {
      case THPoint _:
        _addPointSelectableElement(element);
        break;
      case THLine _:
        _addLineSelectableElement(element);
        break;
    }
  }

  void _addPointSelectableElement(THPoint point) {
    _selectableBoundingBoxes[point.mapiahID] = point.getBoundingBox();
    _addSelectableElementCoordinates(
        point.mapiahID, point.position.coordinates);
  }

  void _addLineSelectableElement(THLine line) {
    final int lineMapiahID = line.mapiahID;
    final lineSegmentMapiahIDs = line.childrenMapiahID;

    _selectableBoundingBoxes[lineMapiahID] = line.getBoundingBox(_thFile);

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is! THLineSegment) {
        continue;
      }

      _addSelectableElementCoordinates(
          lineMapiahID, lineSegment.endPoint.coordinates);
    }
  }

  void _removeSelectableElement(int mapiahID) {
    _selectableCoordinates.remove(mapiahID);
    _selectableBoundingBoxes.remove(mapiahID);
  }

  @action
  void setZoomButtonsHovered(bool isHovered) {
    _isZoomButtonsHovered = isHovered;
  }

  List<THElement> selectableElementsClicked(Offset screenCoordinates) {
    final Offset canvasCoordinates = offsetScreenToCanvas(screenCoordinates);
    final List<THElement> clickedElements = <THElement>[];
    final selectableElements = _selectableCoordinates.entries;

    for (final selectableElement in selectableElements) {
      final int mapiahID = selectableElement.key;
      final List<Offset> selectableCanvasCoordinatesList =
          selectableElement.value;

      for (final selectableCoordinates in selectableCanvasCoordinatesList) {
        if (offsetsInSelectionTolerance(
            selectableCoordinates, canvasCoordinates)) {
          final THElement selectedElement = _thFile.elementByMapiahID(mapiahID);
          switch (selectedElement) {
            case THPoint _:
            case THLine _:
              clickedElements.add(selectedElement);
              break;
          }
        }
      }
    }

    return clickedElements;
  }

  List<THElement> selectableElementsInsideWindow(Rect canvasSelectionWindow) {
    final Map<int, THElement> insideWindowElements = <int, THElement>{};
    final selectableElements = _selectableBoundingBoxes.entries;

    for (final selectableElement in selectableElements) {
      if (MPNumericAux.isRect1InsideRect2(
        rect1: selectableElement.value,
        rect2: canvasSelectionWindow,
      )) {
        final int mapiahID = selectableElement.key;
        final THElement selectedElement = _thFile.elementByMapiahID(mapiahID);

        insideWindowElements[mapiahID] = selectedElement;
      }
    }

    return insideWindowElements.values.toList();
  }

  void onTapUp(TapUpDetails details) {
    _state.onTapUp(details);
  }

  void onPanStart(DragStartDetails details) {
    _state.onPanStart(details);
  }

  void onPanUpdate(DragUpdateDetails details) {
    _state.onPanUpdate(details);
  }

  void onPanEnd(DragEndDetails details) {
    _state.onPanEnd(details);
  }

  void onPanToolPressed() {
    _state.onPanToolPressed();
  }

  void onSelectToolPressed() {
    _state.onSelectToolPressed();
  }

  void onUndoPressed() {
    _state.onUndoPressed();
  }

  void onRedoPressed() {
    _state.onRedoPressed();
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
        offsetScreenToCanvas(screenEndCoordinates);

    setSelectionWindowCanvasCoordinates(
      point1: panStartCanvasCoordinates,
      point2: canvasEndCoordinates,
    );
  }

  @action
  void clearSelectionWindow() {
    _selectionWindowCanvasCoordinates.value = Rect.zero;
  }

  bool getIsSelected(THElement element) {
    return _selectedElements.containsKey(element.mapiahID);
  }

  @action
  void clearSelectedElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();
    _redrawTriggerNonSelectedElements = 0;
    _redrawTriggerSelectedElements = 0;
    _redrawTriggerSelectedElementsListChanged = 0;
  }

  void _clearSelectedElementsWithoutResettingRedrawTriggers() {
    _selectedElements.clear();
    _isSelected.forEach((key, value) => value.value = false);
  }

  void updateSelectedElementsClones() {
    for (final MPSelectedElement selectedElement in _selectedElements.values) {
      selectedElement.updateClone(_thFile);
    }
  }

  @action
  void addSelectedElement(THElement element) {
    switch (element) {
      case THLine _:
        _selectedElements[element.mapiahID] =
            MPSelectedLine(thFile: _thFile, originalLine: element);
        break;
      case THPoint _:
        _selectedElements[element.mapiahID] =
            MPSelectedPoint(originalPoint: element);
        break;
    }
    _isSelected[element.mapiahID]!.value = true;
    triggerSelectedListChanged();
  }

  @action
  Rect _getSelectedElementsBoundingBox() {
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
          boundingBox = element.getBoundingBox();
          break;
        case THLine _:
          boundingBox = element.getBoundingBox(_thFile);
          break;
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
  void addSelectedElements(List<THElement> elements) {
    for (THElement element in elements) {
      addSelectedElement(element);
    }
  }

  @action
  void setSelectedElements(List<THElement> clickedElements) {
    _clearSelectedElementsWithoutResettingRedrawTriggers();

    for (THElement element in clickedElements) {
      if ((element is! THPoint) &&
          (element is! THLine) &&
          (element is! THLineSegment)) {
        return;
      }

      if (element is THLineSegment) {
        element = element.parent(_thFile) as THLine;
      }

      addSelectedElement(element);
    }
  }

  @action
  void removeSelectedElement(THElement element) {
    _selectedElements.remove(element.mapiahID);
    _isSelected[element.mapiahID]!.value = false;
    triggerSelectedListChanged();
  }

  void setPanStartCoordinates(Offset screenCoordinates) {
    panStartCanvasCoordinates = offsetScreenToCanvas(screenCoordinates);
  }

  @action
  void setState(MPTH2FileEditStateType type) {
    _state = MPTH2FileEditState.getState(
      type: type,
      thFileEditStore: this as TH2FileEditStore,
    );
    _state.setVisualMode();
    _state.setCursor();
    _state.setStatusBarMessage();
  }

  void moveSelectedElementsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition =
        offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedElementsToCanvasCoordinates(canvasCoordinatesFinalPosition);
  }

  void moveSelectedElementsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if ((_selectedElements.isEmpty) || !isSelectMode) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - panStartCanvasCoordinates;

    for (final MPSelectedElement selectedElement in _selectedElements.values) {
      switch (selectedElement.originalElementClone) {
        case THPoint _:
          _updateTHPointPosition(
            selectedElement as MPSelectedPoint,
            localDeltaPositionOnCanvas,
          );
          break;
        case THLine _:
          _updateTHLinePosition(
            selectedElement as MPSelectedLine,
            localDeltaPositionOnCanvas,
          );
          break;
        default:
          break;
      }
    }
    triggerSelectedElementsRedraw();
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
    substituteElementWithoutRedrawTriggerAddSelectableElement(modifiedPoint);
  }

  void _updateTHLinePosition(
    MPSelectedLine selectedLine,
    Offset localDeltaPositionOnCanvas,
  ) {
    final THLine line = selectedLine.originalLineClone;
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
          break;
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
          break;
        default:
          throw Exception('Unknown line segment type');
      }

      modifiedLineSegmentsMap[lineChild.mapiahID] = modifiedLineSegment;
    }

    substituteLineSegmentsOfLine(line.mapiahID, modifiedLineSegmentsMap);
  }

  THPointPaint getUnselectedPointPaint(THPoint point) {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaint1..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedPointPaint() {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaint2..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getUnselectedLinePaint(THLine line) {
    return THLinePaint(
      paint: THPaints.thPaint3..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint2..strokeWidth = lineThicknessOnCanvas,
    );
  }

  bool offsetsInSelectionTolerance(Offset offset1, Offset offset2) {
    final double dx = offset1.dx - offset2.dx;
    final double dy = offset1.dy - offset2.dy;

    return ((dx * dx) + (dy * dy)) < selectionToleranceSquaredOnCanvas;
  }

  void updateScreenSize(Size newSize) {
    if (_screenSize == newSize) {
      return;
    }
    _updateScreenSize(newSize);
  }

  @action
  void _updateScreenSize(Size newSize) {
    _screenSize = newSize;
    _canvasSize = newSize / _canvasScale;
    _calculateCanvasOffset();
  }

  Offset offsetScaleScreenToCanvas(Offset screenCoordinate) {
    return Offset(screenCoordinate.dx / _canvasScale,
        screenCoordinate.dy / (-_canvasScale));
  }

  Offset offsetScaleCanvasToScreen(Offset canvasCoordinate) {
    return Offset(canvasCoordinate.dx * _canvasScale,
        canvasCoordinate.dy * (-_canvasScale));
  }

  Offset offsetScreenToCanvas(Offset screenCoordinate) {
    // Apply the inverse of the translation
    final double canvasX =
        (screenCoordinate.dx / _canvasScale) - _canvasTranslation.dx;
    final double canvasY =
        _canvasTranslation.dy - (screenCoordinate.dy / _canvasScale);

    return Offset(canvasX, canvasY);
  }

  Offset offsetCanvasToScreen(Offset canvasCoordinate) {
    // Apply the translation and scaling
    final double screenX =
        (_canvasTranslation.dx + canvasCoordinate.dx) * _canvasScale;
    final double screenY =
        (_canvasTranslation.dy - canvasCoordinate.dy) * _canvasScale;

    return Offset(screenX, screenY);
  }

  double scaleScreenToCanvas(double screenValue) {
    return screenValue / _canvasScale;
  }

  double scaleCanvasToScreen(double canvasValue) {
    return canvasValue * _canvasScale;
  }

  @action
  void setVisualMode(TH2FileEditMode visualMode) {
    _visualMode = visualMode;
  }

  @action
  void onPanUpdatePanMode(DragUpdateDetails details) {
    _canvasTranslation += (details.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
    triggerAllElementsRedraw();
  }

  @action
  triggerAllElementsRedraw() {
    _redrawTriggerSelectedElements++;
    _redrawTriggerNonSelectedElements++;
  }

  @action
  triggerSelectedElementsRedraw() {
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
    _redrawTriggerSelectedElements++;
  }

  @action
  triggerNonSelectedElementsRedraw() {
    _redrawTriggerNonSelectedElements++;
  }

  @action
  triggerSelectedListChanged() {
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
    _redrawTriggerSelectedElementsListChanged++;
  }

  void _setCanvasCenterFromCurrent() {
    getIt<MPLog>().finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX =
        -(_canvasTranslation.dx - (_screenSize.width / 2.0 / _canvasScale));
    _canvasCenterY =
        _canvasTranslation.dy - (_screenSize.height / 2.0 / _canvasScale);
    getIt<MPLog>().finer("New center: $_canvasCenterX, $_canvasCenterY");
  }

  void updateCanvasScale(double newScale) {
    if (_canvasScale == newScale) {
      return;
    }
    _updateCanvasScale(newScale);
  }

  @action
  void _updateCanvasScale(double newScale) {
    _canvasScale = newScale;
    _canvasSize = _screenSize / _canvasScale;
  }

  @action
  void updateCanvasOffsetDrawing(Offset newOffset) {
    _canvasTranslation = newOffset;
  }

  @action
  void zoomIn() {
    _canvasScale *= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    triggerAllElementsRedraw();
  }

  @action
  void zoomOut() {
    _canvasScale /= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    triggerAllElementsRedraw();
  }

  @action
  void zoomAll() {
    final double screenWidth = _screenSize.width;
    final double screenHeight = _screenSize.height;

    _getFileDrawingSize();

    final double widthScale =
        (screenWidth * (1.0 - thCanvasVisibleMargin)) / _dataWidth;
    final double heightScale =
        (screenHeight * (1.0 - thCanvasVisibleMargin)) / _dataHeight;

    _canvasScale = (widthScale < heightScale) ? widthScale : heightScale;
    _canvasSize = _screenSize / _canvasScale;

    _setCanvasCenterToDrawingCenter();
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    triggerAllElementsRedraw();
  }

  void close() {
    getIt<MPGeneralStore>().removeFileStore(filename: _thFile.filename);
  }

  void _calculateCanvasOffset() {
    final double xOffset = (_canvasSize.width / 2.0) - _canvasCenterX;
    final double yOffset = (_canvasSize.height / 2.0) + _canvasCenterY;

    _canvasTranslation = Offset(xOffset, yOffset);
  }

  void updateDataWidth(double newWidth) {
    _dataWidth = newWidth;
  }

  void updateDataHeight(double newHeight) {
    _dataHeight = newHeight;
  }

  void _getFileDrawingSize() {
    final Rect dataBoundingBox = _thFile.getBoundingBox();

    _dataWidth = (dataBoundingBox.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.width;

    _dataHeight = (dataBoundingBox.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.height;
  }

  void _setCanvasCenterToDrawingCenter() {
    final Rect dataBoundingBox = _thFile.getBoundingBox();

    getIt<MPLog>().finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX = (dataBoundingBox.left + dataBoundingBox.right) / 2.0;
    _canvasCenterY = (dataBoundingBox.top + dataBoundingBox.bottom) / 2.0;
    getIt<MPLog>().finer(
        "New center to center drawing in canvas: $_canvasCenterX, $_canvasCenterY");
  }

  void transformCanvas(Canvas canvas) {
    // Transformations are applied on the order they are defined.
    canvas.scale(_canvasScale);
    // // Drawing canvas border
    // canvas.drawRect(
    //     Rect.fromPoints(
    //         Offset(0, 0),
    //         Offset(
    //           thFileController.canvasSize.width,
    //           thFileController.canvasSize.height,
    //         )),
    //     THPaints.thPaint7);
    canvas.translate(_canvasTranslation.dx, _canvasTranslation.dy);
    canvas.scale(1, -1);
  }

  Future<File?> saveTH2File() async {
    final File file = await _localFile();
    final List<int> encodedContent = await _encodedFileContents();
    return await file.writeAsBytes(encodedContent, flush: true);
  }

  Future<List<int>> _encodedFileContents() async {
    final THFileWriter thFileWriter = THFileWriter();
    return await thFileWriter.toBytes(_thFile);
  }

  Future<File?> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _thFile.filename,
    );

    if (filePath != null) {
      final File file = File(filePath);
      final List<int> encodedContent = await _encodedFileContents();
      return await file.writeAsBytes(encodedContent, flush: true);
    }

    return null;
  }

  Future<File> _localFile() async {
    final String filename = _thFile.filename;

    return File(filename);
  }

  void substituteElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    _addSelectableElement(modifiedElement);
    triggerSelectedElementsRedraw();
    getIt<MPLog>().finer('Substituted element ${modifiedElement.mapiahID}');
  }

  void substituteElements(List<THElement> modifiedElements) {
    for (final modifiedElement in modifiedElements) {
      _thFile.substituteElement(modifiedElement);
      _addSelectableElement(modifiedElement);
      getIt<MPLog>()
          .finer('Substituted element ${modifiedElement.mapiahID} from list');
    }
    triggerSelectedElementsRedraw();
  }

  void substituteElementWithoutRedrawTriggerAddSelectableElement(
      THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    getIt<MPLog>().finer(
        'Substituted element without redraw trigger ${modifiedElement.mapiahID}');
  }

  void substituteLineSegmentsOfLine(
    int lineMapiahID,
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }
  }

  void execute(MPCommand command) {
    _undoRedoController.execute(command);
    _updateUndoRedoStatus();
  }

  @action
  void _updateUndoRedoStatus() {
    _hasUndo = _undoRedoController.hasUndo;
    _hasRedo = _undoRedoController.hasRedo;
    _undoDescription = _undoRedoController.undoDescription;
    _redoDescription = _undoRedoController.redoDescription;
  }

  void undo() {
    _undoRedoController.undo();
    _updateUndoRedoStatus();
  }

  void redo() {
    _undoRedoController.redo();
    _updateUndoRedoStatus();
  }

  MPUndoRedoController get undoRedoController => _undoRedoController;

  void updatePointPositionPerOffset({
    required THPoint originalPoint,
    required Offset panOffset,
  }) {
    final MPMovePointCommand command = MPMovePointCommand(
      pointMapiahID: originalPoint.mapiahID,
      originalCoordinates: originalPoint.position.coordinates,
      modifiedCoordinates: originalPoint.position.coordinates + panOffset,
    );
    execute(command);
  }

  void updateLinePosition({
    required int lineMapiahID,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required LinkedHashMap<int, THLineSegment> newLineSegmentsMap,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand(
      lineMapiahID: lineMapiahID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      modifiedLineSegmentsMap: newLineSegmentsMap,
    );
    execute(command);
  }

  void updateLinePositionPerOffset({
    required int lineMapiahID,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required Offset deltaOnCanvas,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand.fromDelta(
      lineMapiahID: lineMapiahID,
      originalLineSegmentsMap: originalLineSegmentsMap,
      deltaOnCanvas: deltaOnCanvas,
    );
    execute(command);
  }

  @action
  void addElement(THElement element) {
    _thFile.addElement(element);
    _thFile.addElementToParent(element);
    _addSelectableElement(element);
  }

  @action
  void addElementWithParentWithoutSelectableElement(
    THElement element,
    THIsParentMixin parent,
  ) {
    _thFile.addElement(element);
    parent.addElementToParent(element);
  }

  @action
  void deleteElement(THElement element) {
    _thFile.deleteElement(element);
    _removeSelectableElement(element.mapiahID);
  }

  @action
  void deleteElementByMapiahID(int mapiahID) {
    final THElement element = _thFile.elementByMapiahID(mapiahID);
    _thFile.deleteElement(element);
    _removeSelectableElement(mapiahID);
  }

  @action
  void deleteElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);
    _thFile.deleteElement(element);
    _removeSelectableElement(element.mapiahID);
  }

  @action
  void registerElementWithTHID(THElement element, String thID) {
    _thFile.registerElementWithTHID(element, thID);
  }
}

class TH2FileEditStoreCreateResult {
  final bool isSuccessful;
  final List<String> errors;

  TH2FileEditStoreCreateResult(
    this.isSuccessful,
    this.errors,
  );
}
