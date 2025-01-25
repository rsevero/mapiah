import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/th2_file_edit_mode.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/selection/mp_selectable.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';
import 'package:mapiah/src/selection/mp_selected_line.dart';
import 'package:mapiah/src/selection/mp_selected_point.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_controller.dart';
import 'package:mobx/mobx.dart';

part 'th_file_edit_store.g.dart';

class THFileEditStore = THFileEditStoreBase with _$THFileEditStore;

abstract class THFileEditStoreBase with Store {
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
  bool _canvasScaleTranslationUndefined = true;

  @readonly
  TH2FileEditMode _mode = TH2FileEditMode.pan;

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
  MPSelectedElement? _selectedElement;

  final Map<int, MPSelectable> _selectableElements = {};

  Offset panStartCoordinates = Offset.zero;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  Rect _dataBoundingBox = Rect.zero;

  double _canvasCenterX = 0.0;
  double _canvasCenterY = 0.0;

  double lineThicknessOnCanvas = thDefaultLineThickness;

  double pointRadiusOnCanvas = thDefaultPointRadius;

  double selectionToleranceSquaredOnCanvas =
      thDefaultSelectionTolerance * thDefaultSelectionTolerance;

  final List<String> errorMessages = <String>[];

  late final MPUndoRedoController _undoRedoController;

  Future<THFileEditStoreCreateResult> load() async {
    _preParseInitialize();

    final THFileParser parser = THFileParser();

    final (parsedFile, isSuccessful, errors) =
        await parser.parse(_thFile.filename);

    _postParseInitialize(parsedFile, isSuccessful, errors);

    return THFileEditStoreCreateResult(isSuccessful, errors);
  }

  /// This is a factory constructor that creates a new instance of THFileEditStore
  /// with an empty THFile.
  static THFileEditStore create(String filename) {
    final THFileEditStore thFileEditStore = THFileEditStore._create();
    final THFile thFile = THFile();
    thFile.filename = filename;
    thFileEditStore._basicInitialization(thFile);
    return thFileEditStore;
  }

  THFileEditStoreBase._create();

  void _basicInitialization(THFile file) {
    _thFile = file;
    _thFileMapiahID = _thFile.mapiahID;
    _undoRedoController = MPUndoRedoController(this as THFileEditStore);
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

  void addSelectableElement(MPSelectableElement selectableElement) {
    _selectableElements[selectableElement.element.mapiahID] = selectableElement;
  }

  void clearSelectableElements() {
    _selectableElements.clear();
  }

  MPSelectableElement? selectableElementContains(Offset screenCoordinates) {
    final Offset canvasCoordinates = offsetScreenToCanvas(screenCoordinates);

    for (final MPSelectable selectable in _selectableElements.values) {
      if (offsetsInSelectionTolerance(selectable.position, canvasCoordinates)) {
        return selectable as MPSelectableElement;
      }
    }

    return null;
  }

  void onPanStart(DragStartDetails details) {
    if (_mode != TH2FileEditMode.select) {
      return;
    }

    MPSelectableElement? selectableElement =
        selectableElementContains(details.localPosition);

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
      element = element.parent(_thFile) as THLine;
    }

    panStartCoordinates = offsetScreenToCanvas(details.localPosition);

    switch (element) {
      case THLine _:
        _setSelectedElement(
            MPSelectedLine(thFile: _thFile, originalLine: element));
        break;
      case THPoint _:
        _setSelectedElement(MPSelectedPoint(originalPoint: element));
        break;
    }
  }

  @action
  void _setSelectedElement(MPSelectedElement selectedElement) {
    _selectedElement = selectedElement;
  }

  @action
  void clearSelectedElement() {
    _selectedElement = null;
  }

  void onPanUpdate(DragUpdateDetails details) {
    switch (_mode) {
      case TH2FileEditMode.select:
        _onPanUpdateSelectMode(details);
        break;
      case TH2FileEditMode.pan:
        onPanUpdatePanMode(details);
        triggerFileRedraw();
        break;
    }
  }

  void _onPanUpdateSelectMode(DragUpdateDetails details) {
    if ((_selectedElement == null) || (_mode != TH2FileEditMode.select)) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        offsetScreenToCanvas(details.localPosition) - panStartCoordinates;

    switch (_selectedElement!.originalElementClone) {
      case THPoint _:
        _updateTHPointPosition(
          _selectedElement! as MPSelectedPoint,
          localDeltaPositionOnCanvas,
        );
        break;
      case THLine _:
        _updateTHLinePosition(
          _selectedElement! as MPSelectedLine,
          localDeltaPositionOnCanvas,
        );
        break;
      default:
        break;
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
    if ((_selectedElement == null) || (_mode != TH2FileEditMode.select)) {
      return;
    }

    final Offset panEndOffset =
        offsetScreenToCanvas(details.localPosition) - panStartCoordinates;

    if (panEndOffset == Offset.zero) {
      // TODO - compare doubles with some epsilon
      _selectedElement = null;
      panStartCoordinates = Offset.zero;
      return;
    }

    switch (_selectedElement!) {
      case MPSelectedPoint _:
        updatePointPositionPerOffset(
          originalPoint:
              (_selectedElement! as MPSelectedPoint).originalPointClone,
          panOffset: panEndOffset,
        );
        break;
      case MPSelectedLine _:
        updateLinePositionPerOffset(
          originalLine: (_selectedElement! as MPSelectedLine).originalLineClone,
          originalLineSegmentsMap: (_selectedElement! as MPSelectedLine)
              .originalLineSegmentsMapClone,
          deltaOnCanvas: panEndOffset,
        );
        break;
      default:
        break;
    }

    _selectedElement = null;
    panStartCoordinates = Offset.zero;
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
  void setTH2FileEditMode(TH2FileEditMode newMode) {
    _mode = newMode;
  }

  void onPanUpdatePanMode(DragUpdateDetails details) {
    if (details.delta == Offset.zero) {
      return;
    }
    _onPanUpdatePanMode(details);
  }

  @action
  void _onPanUpdatePanMode(DragUpdateDetails details) {
    _canvasTranslation += (details.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
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
  void setCanvasScaleTranslationUndefined(bool isUndefined) {
    _canvasScaleTranslationUndefined = isUndefined;
  }

  @action
  void zoomIn() {
    _canvasScale *= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
  }

  @action
  void zoomOut() {
    _canvasScale /= thZoomFactor;
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
  }

  @action
  void _calculateCanvasOffset() {
    final double xOffset = (_canvasSize.width / 2.0) - _canvasCenterX;
    final double yOffset = (_canvasSize.height / 2.0) + _canvasCenterY;

    _canvasTranslation = Offset(xOffset, yOffset);
  }

  @action
  void updateDataWidth(double newWidth) {
    _dataWidth = newWidth;
  }

  @action
  void updateDataHeight(double newHeight) {
    _dataHeight = newHeight;
  }

  @action
  void updateDataBoundingBox(Rect newBoundingBox) {
    _dataBoundingBox = newBoundingBox;
  }

  void _getFileDrawingSize() {
    _dataWidth = (_dataBoundingBox.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : _dataBoundingBox.width;

    _dataHeight = (_dataBoundingBox.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : _dataBoundingBox.height;
  }

  void _setCanvasCenterToDrawingCenter() {
    getIt<MPLog>().finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX = (_dataBoundingBox.left + _dataBoundingBox.right) / 2.0;
    _canvasCenterY = (_dataBoundingBox.top + _dataBoundingBox.bottom) / 2.0;
    getIt<MPLog>().finer(
        "New center to center drawing in canvas: $_canvasCenterX, $_canvasCenterY");
  }

  @action
  void zoomShowAll() {
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
  }

  void undo() {
    _undoRedoController.undo();
  }

  void redo() {
    _undoRedoController.redo();
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
    _undoRedoController.execute(command);
  }

  void updateLinePosition({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required THLine newLine,
    required LinkedHashMap<int, THLineSegment> newLineSegmentsMap,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand(
      originalLine: originalLine,
      originalLineSegmentsMap: originalLineSegmentsMap,
      newLine: newLine,
      newLineSegmentsMap: newLineSegmentsMap,
      description: 'Move Line',
    );
    _undoRedoController.execute(command);
  }

  void updateLinePositionPerOffset({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required Offset deltaOnCanvas,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand.fromDelta(
      originalLine: originalLine,
      originalLineSegmentsMap: originalLineSegmentsMap,
      deltaOnCanvas: deltaOnCanvas,
    );
    _undoRedoController.execute(command);
  }

  @action
  void addElement(THElement element) {
    _thFile.addElement(element);
    _thFile.addElementToParent(element);
  }

  @action
  void addElementWithParent(THElement element, THParent parent) {
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

class THFileEditStoreCreateResult {
  final bool isSuccessful;
  final List<String> errors;

  THFileEditStoreCreateResult(
    this.isSuccessful,
    this.errors,
  );
}
