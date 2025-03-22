import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_state_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/controllers/mp_undo_redo_controller.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th2_file_edit_controller.g.dart';

class TH2FileEditController = TH2FileEditControllerBase
    with _$TH2FileEditController;

abstract class TH2FileEditControllerBase with Store {
  late final MPUndoRedoController undoRedoController;
  late final MPVisualController visualController;
  late final TH2FileEditElementEditController elementEditController;
  late final TH2FileEditOptionEditController optionEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final TH2FileEditSelectionController selectionController;
  late final TH2FileEditStateController stateController;

  /// 'screen' is related to actual pixels on the screen.
  /// 'canvas' is the virtual canvas used to draw.
  /// 'data' is the actual data to be drawn.
  /// 'canvas' and 'data' are on the same scale. They are both scaled and
  /// translated to be shown on the screen.

  @readonly
  Size _screenSize = Size.zero;

  @readonly
  Size _canvasSize = Size.zero;

  @readonly
  double _canvasScale = 1.0;

  @computed
  String get canvasScaleAsPercentageText =>
      MPNumericAux.roundScaleAsTextPercentage(_canvasScale);

  @readonly
  Offset _canvasTranslation = Offset.zero;

  @computed
  Rect get canvasBoundingBox {
    final Offset topLeft = _canvasTranslation;
    final Offset bottomRight =
        topLeft + Offset(_canvasSize.width, _canvasSize.height);
    final Rect canvasBoundingBox = MPNumericAux.orderedRectFromPoints(
      point1: topLeft,
      point2: bottomRight,
    );

    return canvasBoundingBox;
  }

  @computed
  Rect get screenBoundingBox {
    final Rect screenBoundingBox = MPNumericAux.orderedRectFromLTWH(
      top: 0,
      left: 0,
      width: _screenSize.width,
      height: _screenSize.height,
    );

    return screenBoundingBox;
  }

  @readonly
  bool _isLoading = false;

  @readonly
  late THFile _thFile;

  @readonly
  late int _thFileMPID;

  @readonly
  bool _hasUndo = false;

  @readonly
  bool _hasRedo = false;

  @readonly
  String _undoDescription = '';

  @readonly
  String _redoDescription = '';

  final GlobalKey thFileWidgetKey = GlobalKey();

  @computed
  String get filenameAndScrap {
    String filename = p.basename(_thFile.filename);

    if (_hasMultipleScraps) {
      final THScrap scrap = _thFile.elementByMPID(_activeScrapID) as THScrap;

      filename += ' | ${scrap.thID}';
    }

    return filename;
  }

  @computed
  bool get isAddElementMode {
    final MPTH2FileEditState state = stateController.state;

    return ((state is MPTH2FileEditStateAddArea) ||
        (state is MPTH2FileEditStateAddLine) ||
        (state is MPTH2FileEditStateAddPoint));
  }

  @computed
  bool get isEditLineMode {
    final MPTH2FileEditState state = stateController.state;

    return (state is MPTH2FileEditStateEditSingleLine) ||
        (state is MPTH2FileEditStateMovingEndControlPoints) ||
        (state is MPTH2FileEditStateMovingSingleControlPoint);
  }

  @computed
  bool get isNodeEditButtonEnabled =>
      (selectionController.selectedElements.length == 1) &&
      (selectionController
              .selectedElements[selectionController.selectedElements.keys.first]
          is MPSelectedLine);

  @computed
  bool get isOptionEditMode =>
      stateController.state is MPTH2FileEditStateOptionEdit;

  @computed
  bool get isSelectMode {
    final MPTH2FileEditState state = stateController.state;

    return (state is MPTH2FileEditStateSelectEmptySelection ||
        (state is MPTH2FileEditStateSelectNonEmptySelection) ||
        state is MPTH2FileEditStateMovingElements);
  }

  @readonly
  bool _isZoomButtonsHovered = false;

  @readonly
  bool _isAddElementButtonsHovered = false;

  @computed
  MPButtonType get activeAddElementButton {
    switch (stateController.state) {
      case MPTH2FileEditStateAddPoint _:
        return MPButtonType.addPoint;
      case MPTH2FileEditStateAddLine _:
        return MPButtonType.addLine;
      case MPTH2FileEditStateAddArea _:
        return MPButtonType.addArea;
      default:
        return MPButtonType.addElement;
    }
  }

  @readonly
  int _currentDecimalPositions = thDefaultDecimalPositions;

  @readonly
  int _activeScrapID = 0;

  @readonly
  bool _hasMultipleScraps = false;

  @computed
  double get lineThicknessOnCanvas =>
      mpLocator.mpSettingsController.lineThickness / _canvasScale;

  @computed
  double get controlLineThicknessOnCanvas =>
      lineThicknessOnCanvas * thControlLineThicknessFactor;

  @computed
  double get pointRadiusOnCanvas =>
      mpLocator.mpSettingsController.pointRadius / _canvasScale;

  @computed
  double get selectionToleranceOnCanvas =>
      mpLocator.mpSettingsController.selectionTolerance / _canvasScale;

  @computed
  double get selectionToleranceSquaredOnCanvas =>
      (selectionToleranceOnCanvas * selectionToleranceOnCanvas);

  @computed
  bool get showSelectedElements =>
      selectionController.selectedElements.isNotEmpty && !isEditLineMode;

  @computed
  bool get showSelectionHandles => showSelectedElements && isSelectMode;

  @computed
  bool get showSelectionWindow =>
      selectionController.selectionWindowCanvasCoordinates.value != Rect.zero;

  @computed
  bool get showAddLine =>
      (elementEditController.newLine != null) ||
      (elementEditController.lineStartScreenPosition != null);

  @computed
  bool get showOverlayWindows =>
      overlayWindowController.overlayWindows.isNotEmpty;

  @readonly
  bool _canvasScaleTranslationUndefined = true;

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
  bool get showRemoveButton {
    final MPTH2FileEditState state = stateController.state;

    return ((state is MPTH2FileEditStateSelectEmptySelection) ||
        (state is MPTH2FileEditStateSelectNonEmptySelection));
  }

  @computed
  bool get showEditLineSegment => isEditLineMode;

  @computed
  bool get showOptionsEdit =>
      stateController.state is MPTH2FileEditStateOptionEdit;

  @computed
  bool get showUndoRedoButtons =>
      isAddElementMode || isSelectMode || isEditLineMode;

  @computed
  bool get removeButtonEnabled =>
      selectionController.selectedElements.isNotEmpty;

  @readonly
  String _statusBarMessage = '';

  @computed
  bool get showScrapScale {
    return !_isLoading && scrapHasScaleOption;
  }

  @computed
  bool get scrapHasScaleOption {
    final THScrap scrap = _thFile.elementByMPID(_activeScrapID) as THScrap;

    return scrap.hasOption(THCommandOptionType.scrapScale);
  }

  @computed
  THLengthUnitType get scrapLengthUnitType {
    if (scrapHasScaleOption) {
      final THScrap scrap = _thFile.elementByMPID(_activeScrapID) as THScrap;

      return (scrap.optionByType(THCommandOptionType.scrapScale)
              as THScrapScaleCommandOption)
          .unitPart
          .unit;
    } else {
      return THLengthUnitType.meter;
    }
  }

  @computed
  double get scrapLengthUnitsPerPoint {
    if (scrapHasScaleOption) {
      final THScrap scrap = _thFile.elementByMPID(_activeScrapID) as THScrap;

      return (scrap.optionByType(THCommandOptionType.scrapScale)
              as THScrapScaleCommandOption)
          .lengthUnitsPerPoint;
    } else {
      return 1.0;
    }
  }

  @computed
  double get scrapLengthUnitsOnGraphicalScale {
    double scrapLengthUnitsOnScreen = scrapLengthUnitsPerPointOnScreen *
        thDesiredGraphicalScaleScreenPointLength;

    scrapLengthUnitsOnScreen =
        MPNumericAux.roundNumber(scrapLengthUnitsOnScreen);
    if (scrapLengthUnitsOnScreen < 1) {
      scrapLengthUnitsOnScreen = 1;
    }

    return scrapLengthUnitsOnScreen;
  }

  @computed
  double get scrapLengthUnitsPerPointOnScreen {
    return scrapLengthUnitsPerPoint / _canvasScale;
  }

  @readonly
  int _redrawTriggerSelectedElementsListChanged = 0;

  @readonly
  int _redrawTriggerSelectedElements = 0;

  @readonly
  int _redrawTriggerNonSelectedElements = 0;

  @readonly
  int _redrawTriggerNewLine = 0;

  @readonly
  int _redrawTriggerEditLine = 0;

  @readonly
  int _redrawTriggerOverlayWindows = 0;

  bool _isMouseOverChangeScrapButton = false;

  bool _isMouseOverChangeScrapOverlayWindow = false;

  @readonly
  Offset _mousePosition = Offset.zero;

  @readonly
  double _canvasCenterX = 0.0;
  @readonly
  double _canvasCenterY = 0.0;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  final List<String> errorMessages = <String>[];

  Future<TH2FileEditControllerCreateResult> load() async {
    _preParseInitialize();

    final THFileParser parser = THFileParser();

    final (parsedFile, isSuccessful, errors) =
        await parser.parse(_thFile.filename);

    _postParseInitialize(parsedFile, isSuccessful, errors);

    return TH2FileEditControllerCreateResult(isSuccessful, errors);
  }

  /// This is a factory constructor that creates a new instance of
  /// TH2FileEditController with an empty THFile.
  static TH2FileEditController create(String filename) {
    final TH2FileEditController th2FileEditController =
        TH2FileEditController._create();
    final THFile thFile = THFile();
    thFile.filename = filename;
    th2FileEditController._basicInitialization(thFile);
    return th2FileEditController;
  }

  TH2FileEditControllerBase._create();

  void _basicInitialization(THFile file) {
    _thFile = file;
    elementEditController =
        TH2FileEditElementEditController(this as TH2FileEditController);
    optionEditController =
        TH2FileEditOptionEditController(this as TH2FileEditController);
    overlayWindowController =
        TH2FileEditOverlayWindowController(this as TH2FileEditController);
    selectionController =
        TH2FileEditSelectionController(this as TH2FileEditController);
    stateController = TH2FileEditStateController(this as TH2FileEditController);
    undoRedoController = MPUndoRedoController(this as TH2FileEditController);
    visualController = MPVisualController(this as TH2FileEditController);
    _thFileMPID = _thFile.mpID;
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
    if (_thFile.scrapMPIDs.isNotEmpty) {
      _activeScrapID = _thFile.scrapMPIDs.first;
      updateHasMultipleScraps();
    }

    selectionController.clearIsSelected();

    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine) {
        selectionController.setIsSelected(key, false);
      }
    });

    selectionController.updateSelectableElements();

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  @action
  void setZoomButtonsHovered(bool isHovered) {
    _isZoomButtonsHovered = isHovered;
  }

  @action
  void setAddElementButtonsHovered(bool isHovered) {
    _isAddElementButtonsHovered = isHovered;
  }

  @action
  void setStatusBarMessage(String message) {
    _statusBarMessage = message;
  }

  int getNextAvailableScrapID() {
    final List<int> scrapIDs = _thFile.scrapMPIDs.toList();
    final int currentIndex = scrapIDs.indexOf(_activeScrapID);

    if (currentIndex == -1 || scrapIDs.isEmpty) {
      throw Exception('Current active scrap ID not found in scrapIDs');
    }

    final int nextIndex = (currentIndex + 1) % scrapIDs.length;

    return scrapIDs[nextIndex];
  }

  bool isFromActiveScrap(THElement element) {
    return element.parentMPID == _activeScrapID;
  }

  @action
  void setActiveScrap(int scrapMPID) {
    _activeScrapID = scrapMPID;
    selectionController.clearSelectedElements();
    selectionController.updateSelectableElements();
    triggerAllElementsRedraw();
  }

  List<(int, String, bool)> availableScraps() {
    final List<(int, String, bool)> scraps = <(int, String, bool)>[];

    for (final int scrapMPID in _thFile.scrapMPIDs) {
      final THScrap scrap = _thFile.elementByMPID(scrapMPID) as THScrap;
      final bool isActive = scrapMPID == _activeScrapID;
      scraps.add((scrapMPID, scrap.thID, isActive));
    }

    return scraps;
  }

  @action
  void toggleToNextAvailableScrap() {
    final int nextAvailableScrapID = getNextAvailableScrapID();

    setActiveScrap(nextAvailableScrapID);
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
  void onPointerMoveUpdateMoveCanvasMode(PointerMoveEvent event) {
    _canvasTranslation += (event.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
  }

  @action
  triggerAllElementsRedraw() {
    _redrawTriggerSelectedElements++;
    _redrawTriggerNonSelectedElements++;
    _redrawTriggerNewLine++;
    _redrawTriggerEditLine++;
    selectionController.clearSelectionHandleCenters();
  }

  @action
  triggerSelectedElementsRedraw({bool setState = false}) {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerSelectedElements++;

    if (setState) {
      selectionController.setSelectionState();
    }
  }

  @action
  triggerNonSelectedElementsRedraw() {
    _redrawTriggerNonSelectedElements++;
  }

  @action
  triggerSelectedListChanged() {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerSelectedElementsListChanged++;
  }

  @action
  void triggerNewLineRedraw() {
    _redrawTriggerNewLine++;
  }

  @action
  void triggerEditLineRedraw() {
    _redrawTriggerEditLine++;
  }

  @action
  void triggerOverlayWindowsRedraw() {
    _redrawTriggerOverlayWindows++;
  }

  void _setCanvasCenterFromCurrent() {
    mpLocator.mpLog.finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX =
        -(_canvasTranslation.dx - (_screenSize.width / 2.0 / _canvasScale));
    _canvasCenterY =
        _canvasTranslation.dy - (_screenSize.height / 2.0 / _canvasScale);
    mpLocator.mpLog.finer("New center: $_canvasCenterX, $_canvasCenterY");
  }

  @action
  void updateCanvasScale(double newScale) {
    _canvasScale = MPNumericAux.roundScale(newScale);
    _canvasSize = _screenSize / _canvasScale;
  }

  @action
  void zoomIn({bool fineZoom = false}) {
    _canvasScale = MPNumericAux.calculateNextZoomLevel(
      scale: _canvasScale,
      factor: fineZoom ? thFineZoomFactor : thRegularZoomFactor,
      isIncrease: true,
    );

    _changedCanvasScale();
  }

  @action
  void zoomOut({bool fineZoom = false}) {
    _canvasScale = MPNumericAux.calculateNextZoomLevel(
      scale: _canvasScale,
      factor: fineZoom ? thFineZoomFactor : thRegularZoomFactor,
      isIncrease: false,
    );

    _changedCanvasScale();
  }

  @action
  void zoomOneToOne() {
    _canvasScale = 1;

    _changedCanvasScale();
  }

  @action
  void zoomToFit({required MPZoomToFitType zoomFitToType}) {
    final double screenWidth = _screenSize.width;
    final double screenHeight = _screenSize.height;

    _getFileDrawingSize(zoomToFitType: zoomFitToType);

    final double widthScale =
        (screenWidth * (1.0 - thCanvasVisibleMargin)) / _dataWidth;
    final double heightScale =
        (screenHeight * (1.0 - thCanvasVisibleMargin)) / _dataHeight;

    _setCanvasCenterToDrawingCenter(zoomToFitType: zoomFitToType);

    _canvasScale = MPNumericAux.roundScale(
        (widthScale < heightScale) ? widthScale : heightScale);

    _changedCanvasScale();
  }

  void _changedCanvasScale() {
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    selectionController.warmSelectableElementsCanvasScaleChanged();
    selectionController.clearSelectionHandleCenters();
    triggerAllElementsRedraw();
  }

  void close() {
    mpLocator.mpGeneralController
        .removeFileController(filename: _thFile.filename);
  }

  @action
  void _calculateCanvasOffset() {
    final double xOffset = (_canvasSize.width / 2.0) - _canvasCenterX;
    final double yOffset = (_canvasSize.height / 2.0) + _canvasCenterY;

    _canvasTranslation = Offset(xOffset, yOffset);
  }

  @action
  void moveCanvasVertically({required bool up}) {
    double delta = _canvasSize.height * thCanvasMovementFactor;
    if (up) {
      delta = -delta;
    }
    _canvasCenterY += delta;
    _calculateCanvasOffset();
    triggerAllElementsRedraw();
  }

  @action
  void moveCanvasHorizontally({required bool left}) {
    double delta = _canvasSize.width * thCanvasMovementFactor;
    if (!left) {
      delta = -delta;
    }
    _canvasCenterX += delta;
    _calculateCanvasOffset();
    triggerAllElementsRedraw();
  }

  void updateDataWidth(double newWidth) {
    _dataWidth = newWidth;
  }

  void updateDataHeight(double newHeight) {
    _dataHeight = newHeight;
  }

  void _getFileDrawingSize({required MPZoomToFitType zoomToFitType}) {
    final Rect dataBoundingBox = _getZoomToFitBoundingBox(
      zoomFitToType: zoomToFitType,
    );

    _dataWidth = (dataBoundingBox.width < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.width;

    _dataHeight = (dataBoundingBox.height < thMinimumSizeForDrawing)
        ? thMinimumSizeForDrawing
        : dataBoundingBox.height;
  }

  Rect _getZoomToFitBoundingBox({required MPZoomToFitType zoomFitToType}) {
    switch (zoomFitToType) {
      case MPZoomToFitType.file:
        return _thFile.getBoundingBox(this as TH2FileEditController);
      case MPZoomToFitType.scrap:
        return (_thFile.elementByMPID(_activeScrapID) as THScrap)
            .getBoundingBox(this as TH2FileEditController);
      case MPZoomToFitType.selection:
        return selectionController.getSelectedElementsBoundingBox();
    }
  }

  void _setCanvasCenterToDrawingCenter(
      {required MPZoomToFitType zoomToFitType}) {
    final Rect dataBoundingBox = _getZoomToFitBoundingBox(
      zoomFitToType: zoomToFitType,
    );

    mpLocator.mpLog.finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX = (dataBoundingBox.left + dataBoundingBox.right) / 2.0;
    _canvasCenterY = (dataBoundingBox.top + dataBoundingBox.bottom) / 2.0;
    mpLocator.mpLog.finer(
        "New center to center drawing in canvas: $_canvasCenterX, $_canvasCenterY");
  }

  void transformCanvas(Canvas canvas) {
    // Transformations are applied on the order they are defined.
    canvas.scale(_canvasScale);
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
    return await thFileWriter.toBytes(
      _thFile,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );
  }

  Future<File?> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _thFile.filename,
      initialDirectory:
          mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
              ? null
              : mpLocator.mpGeneralController.lastAccessedDirectory,
    );

    if (filePath != null) {
      String directoryPath = p.dirname(filePath);
      mpLocator.mpGeneralController.lastAccessedDirectory = directoryPath;
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
  void setIsMouseOverChangeScrapsButton(bool isMouseOver) {
    _isMouseOverChangeScrapButton = isMouseOver;
    _setShowChangeScrapOverlayWindow();
  }

  @action
  void setIsMouseOverChangeScrapsOverlayWindow(bool isMouseOver) {
    _isMouseOverChangeScrapOverlayWindow = isMouseOver;
    _setShowChangeScrapOverlayWindow();
  }

  @action
  void _setShowChangeScrapOverlayWindow() {
    overlayWindowController.setShowOverlayWindow(
      MPOverlayWindowType.availableScraps,
      (_isMouseOverChangeScrapButton || _isMouseOverChangeScrapOverlayWindow),
    );
  }

  @action
  void updateHasMultipleScraps() {
    _hasMultipleScraps = _thFile.scrapMPIDs.length > 1;
  }

  @action
  void execute(MPCommand command) {
    undoRedoController.execute(command);
    updateUndoRedoStatus();
  }

  @action
  void executeAndSubstituteLastUndo(MPCommand command) {
    undoRedoController.executeAndSubstituteLastUndo(command);
    updateUndoRedoStatus();
  }

  @action
  void updateUndoRedoStatus() {
    _hasUndo = undoRedoController.hasUndo;
    _hasRedo = undoRedoController.hasRedo;
    _undoDescription = mpLocator.appLocalizations
        .th2FileEditPageUndo(undoRedoController.undoDescription);
    _redoDescription = mpLocator.appLocalizations
        .th2FileEditPageRedo(undoRedoController.redoDescription);
  }

  @action
  void _undoRedoDone() {
    updateUndoRedoStatus();
    selectionController.clearSelectedElementsAndSelectionHandleCenters();
  }

  void undo() {
    undoRedoController.undo();
    _undoRedoDone();
  }

  void redo() {
    undoRedoController.redo();
    _undoRedoDone();
  }

  @action
  void setMousePosition(Offset position) {
    _mousePosition = position;
  }
}

class TH2FileEditControllerCreateResult {
  final bool isSuccessful;
  final List<String> errors;

  TH2FileEditControllerCreateResult(
    this.isSuccessful,
    this.errors,
  );
}
