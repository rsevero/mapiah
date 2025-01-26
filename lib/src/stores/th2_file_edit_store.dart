import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_parent_mixin.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/selection/mp_selectable.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';
import 'package:mapiah/src/selection/mp_selected_line.dart';
import 'package:mapiah/src/selection/mp_selected_point.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
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

  /// These triggers are used to notify the drawable widgets that they should
  /// redraw. There area triggers specific to each point and line (the actual
  /// drawable elements), to each scrap and the THFile itself:
  ///
  /// 1. THFile: triggers the whole file to redraw when some setting that
  ///  affects the whole file changes like zoom or pan.
  /// 2. THScrap: triggers the scrap to redraw when some setting that affects
  /// the scrap changes like changing the isSelected property of the scrap.
  /// 3. THPoint and THLine: triggers the point or line to redraw when this
  /// particular element has been edit: moved, changed type etc.
  @readonly
  Map<int, Observable<bool>> _elementRedrawTrigger = <int, Observable<bool>>{};

  /// These triggers are used to notify the widgets that have drawable children,
  /// i.e., THFile and THScraps, that they should redraw themselves because a
  /// child widget has been added or removed.
  @readonly
  Map<int, Observable<bool>> _childrenListLengthChangeTrigger =
      <int, Observable<bool>>{};

  @readonly
  Map<int, MPSelectedElement> _selectedElements = <int, MPSelectedElement>{};

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

  @readonly
  bool _canvasScaleTranslationUndefined = true;

  final Map<int, MPSelectable> _selectableElements = {};

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

  /// This is a factory constructor that creates a new instance of TH2FileEditStore
  /// with an empty THFile.
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
    _elementRedrawTrigger.clear();
    _childrenListLengthChangeTrigger.clear();

    _elementRedrawTrigger[_thFileMapiahID] = Observable(false);
    _childrenListLengthChangeTrigger[_thFileMapiahID] = Observable(false);
    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine || value is THScrap) {
        _elementRedrawTrigger[key] = Observable(false);
        if (value is THScrap) {
          _childrenListLengthChangeTrigger[key] = Observable(false);
        }
      }
    });

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  @action
  void setZoomButtonsHovered(bool isHovered) {
    _isZoomButtonsHovered = isHovered;
  }

  void addSelectableElement(MPSelectableElement selectableElement) {
    _selectableElements[selectableElement.element.mapiahID] = selectableElement;
  }

  void clearSelectableElements() {
    _selectableElements.clear();
  }

  List<THElement> selectableElementsClicked(Offset screenCoordinates) {
    final Offset canvasCoordinates = offsetScreenToCanvas(screenCoordinates);
    final List<THElement> clickedElements = <THElement>[];

    for (final MPSelectable selectable in _selectableElements.values) {
      if (offsetsInSelectionTolerance(selectable.position, canvasCoordinates)) {
        switch (selectable.selected) {
          case THPoint _:
          case THLine _:
            clickedElements.add(selectable.selected as THElement);
            break;
        }
      }
    }

    return clickedElements;
  }

  List<THElement> selectableElementsInsideWindow(Rect canvasSelectionWindow) {
    final List<THElement> insideWindowElements = <THElement>[];

    for (final MPSelectable selectable in _selectableElements.values) {
      final THElement selected = selectable.selected as THElement;
      switch (selected) {
        case THPoint _:
          if (MPNumericAux.isRect1InsideRect2(
            rect1: selected.getBoundingBox(),
            rect2: canvasSelectionWindow,
          )) {
            insideWindowElements.add(selected);
          }
          break;
        case THLine _:
          if (MPNumericAux.isRect1InsideRect2(
            rect1: selected.getBoundingBox(_thFile),
            rect2: canvasSelectionWindow,
          )) {
            insideWindowElements.add(selected);
          }
          break;
      }
    }

    return insideWindowElements;
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

  void onPanToolPressed() {
    _state.onPanToolPressed();
  }

  void onSelectToolPressed() {
    _state.onSelectToolPressed();
  }

  @action
  void setSelectedElements(List<THElement> clickedElements) {
    _selectedElements.clear();

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

  bool isSelected(THElement element) {
    return _selectedElements.containsKey(element.mapiahID);
  }

  void removeSelectedElement(THElement element) {
    _selectedElements.remove(element.mapiahID);
  }

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
  }

  void addSelectedElements(List<THElement> elements) {
    for (THElement element in elements) {
      addSelectedElement(element);
    }
  }

  void setPanStartCoordinates(Offset screenCoordinates) {
    panStartCanvasCoordinates = offsetScreenToCanvas(screenCoordinates);
  }

  @action
  void _addSelectedElement(MPSelectedElement selectedElement) {
    _selectedElements[selectedElement.mapiahID] = selectedElement;
  }

  @action
  void clearSelectedElements() {
    _selectedElements.clear();
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
    substituteElement(modifiedPoint);
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

  void onPanEnd(DragEndDetails details) {
    _state.onPanEnd(details);
  }

  THPointPaint getPointPaint(THPoint point) {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaint1..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getLinePaint(THLine line) {
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
    triggerElementActuallyDrawableRedraw(_thFileMapiahID);
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
    triggerElementActuallyDrawableRedraw(_thFileMapiahID);
  }

  @action
  void zoomOut() {
    _canvasScale /= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    triggerElementActuallyDrawableRedraw(_thFileMapiahID);
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
    triggerElementActuallyDrawableRedraw(_thFileMapiahID);
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

  /// Should be used only when a drawable element (scrap, line or point) is
  /// added or removed directly as child of the THFile. Usually there should
  /// only be one drawable element as child of the THFile: a scrap.
  ///
  /// The THFileWidget itself will redraw.
  @action
  void triggerTHFileLengthChildrenList() {
    _childrenListLengthChangeTrigger[_thFileMapiahID]!.value =
        !_childrenListLengthChangeTrigger[_thFileMapiahID]!.value;
  }

  /// Should be used when some change that potentially affects the whole file
  /// happens. For example a pan or zoom operation.
  ///
  /// All drawable items in the THFile will be triggered.
  void triggerFileRedraw() {
    triggerElementActuallyDrawableRedraw(_thFileMapiahID);
  }

  /// Should be used when a element with children (file or scrap) has a child
  /// added or deleted. The actual element (file or scrap) will redraw itself to
  /// recreate it's children list.
  @action
  void triggerElementWithChildrenRedraw(int mapiahID) {
    _childrenListLengthChangeTrigger[mapiahID]!.value =
        !_childrenListLengthChangeTrigger[mapiahID]!.value;
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

  @action
  void triggerElementActuallyDrawableRedraw(int mapiahID) {
    _elementRedrawTrigger[mapiahID]!.value =
        !_elementRedrawTrigger[mapiahID]!.value;
  }

  void substituteElement(THElement newElement) {
    _thFile.substituteElement(newElement);
    triggerElementActuallyDrawableRedraw(newElement.mapiahID);
    getIt<MPLog>().finer('Substituted element ${newElement.mapiahID}');
  }

  void substituteElementWithoutRedrawTrigger(THElement newElement) {
    _thFile.substituteElement(newElement);
    getIt<MPLog>().finer(
        'Substituted element without redraw trigger ${newElement.mapiahID}');
  }

  void substituteLineSegmentsOfLine(
    int lineMapiahID,
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }
    triggerElementActuallyDrawableRedraw(lineMapiahID);
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
      description: 'Move Line',
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
  }

  @action
  void addElementWithParent(THElement element, THIsParentMixin parent) {
    _thFile.addElement(element);
    parent.addElementToParent(element);
  }

  @action
  void deleteElement(THElement element) {
    _thFile.deleteElement(element);
  }

  @action
  void deleteElementByMapiahID(int mapiahID) {
    final THElement element = _thFile.elementByMapiahID(mapiahID);
    _thFile.deleteElement(element);
  }

  @action
  void deleteElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);
    _thFile.deleteElement(element);
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
