import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_undo_redo_controller.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_state_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
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
  late final TH2FileEditUserInteractionController userInteractionController;

  final List<ReactionDisposer> _disposers = [];

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

  @readonly
  Rect _canvasBoundingBox = Rect.zero;

  @readonly
  Rect _screenBoundingBox = Rect.zero;

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
      final THScrap scrap = _thFile.scrapByMPID(_activeScrapID);

      filename += ' | ${scrap.thID}';
    }

    return filename;
  }

  @readonly
  bool _isAddElementMode = false;

  @readonly
  bool _isEditLineMode = false;

  @readonly
  bool _enableNodeEditButton = false;

  @readonly
  bool _isOptionEditMode = false;

  @readonly
  bool _isSelectMode = false;

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

  @readonly
  double _lineThicknessOnCanvas = mpLocator.mpSettingsController.lineThickness;

  @readonly
  double _controlLineThicknessOnCanvas =
      mpLocator.mpSettingsController.lineThickness *
          thControlLineThicknessFactor;

  @readonly
  double _lineDirectionTickLengthOnCanvas = mpLineDirectionTickLength;

  @readonly
  double _pointRadiusOnCanvas = mpLocator.mpSettingsController.pointRadius;

  @readonly
  double _selectionToleranceOnCanvas =
      mpLocator.mpSettingsController.selectionTolerance;

  @readonly
  double _selectionToleranceSquaredOnCanvas =
      (mpLocator.mpSettingsController.selectionTolerance *
          mpLocator.mpSettingsController.selectionTolerance);

  @readonly
  bool _canvasScaleTranslationUndefined = true;

  @readonly
  Paint _selectionWindowFillPaint = thSelectionWindowFillPaint;

  @readonly
  Paint _selectionWindowBorderPaint = thSelectionWindowBorderPaint;

  @computed
  Paint get selectionWindowBorderPaintComplete => _selectionWindowBorderPaint
    ..strokeWidth = thSelectionWindowBorderPaintStrokeWidth / _canvasScale;

  @readonly
  double _selectionWindowBorderPaintDashInterval =
      thSelectionWindowBorderPaintDashInterval;

  @computed
  double get selectionWindowBorderPaintDashIntervalOnCanvas =>
      _selectionWindowBorderPaintDashInterval / _canvasScale;

  @readonly
  double _selectionHandleSizeOnCanvas = thSelectionHandleSize;

  @readonly
  double _selectionHandleDistanceOnCanvas = thSelectionHandleDistance;

  @readonly
  double _selectionHandleLineThicknessOnCanvas = thSelectionHandleLineThickness;

  @computed
  Paint get selectionHandlePaint => thSelectionHandleFillPaint
    ..strokeWidth = _selectionHandleLineThicknessOnCanvas;

  @computed
  bool get showAddLine =>
      (elementEditController.newLine != null) ||
      (elementEditController.lineStartScreenPosition != null);

  @computed
  bool get showEditLineSegment => _isEditLineMode;

  @computed
  bool get showMultipleElementsClickedHighlight =>
      selectionController.multipleElementsClickedHighlightedMPID != null;

  @computed
  bool get showMultipleEndControlPointsClickedHighlight =>
      selectionController
          .multipleEndControlPointsClickedHighlightedChoice.type !=
      MPMultipleEndControlPointsClickedType.none;

  @computed
  bool get showOptionsEdit =>
      stateController.state is MPTH2FileEditStateOptionEdit;

  @computed
  bool get showRemoveButton {
    final MPTH2FileEditState state = stateController.state;

    return ((state is MPTH2FileEditStateSelectEmptySelection) ||
        (state is MPTH2FileEditStateSelectNonEmptySelection));
  }

  @computed
  bool get showScrapScale {
    return !_isLoading && scrapHasScaleOption;
  }

  @computed
  bool get showSelectedElements =>
      selectionController.mpSelectedElementsLogical.isNotEmpty &&
      !_isEditLineMode;

  @computed
  bool get showSelectionHandles => showSelectedElements && _isSelectMode;

  @computed
  bool get showSelectionWindow =>
      selectionController.selectionWindowCanvasCoordinates.value != Rect.zero;

  @computed
  bool get showUndoRedoButtons =>
      _isAddElementMode || _isSelectMode || _isEditLineMode;

  @computed
  bool get enableRemoveButton =>
      selectionController.mpSelectedElementsLogical.isNotEmpty;

  @computed
  bool get enableSaveButton => _hasUndo;

  @readonly
  String _statusBarMessage = '';

  @computed
  bool get scrapHasScaleOption {
    final THScrap scrap = _thFile.scrapByMPID(_activeScrapID);

    return scrap.hasOption(THCommandOptionType.scrapScale);
  }

  @computed
  THLengthUnitType get scrapLengthUnitType {
    if (scrapHasScaleOption) {
      final THScrap scrap = _thFile.scrapByMPID(_activeScrapID);

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
      final THScrap scrap = _thFile.scrapByMPID(_activeScrapID);

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
  int _redrawTriggerOptionsList = 0;

  @readonly
  Offset _mousePosition = Offset.zero;

  @readonly
  double _canvasCenterX = 0.0;
  @readonly
  double _canvasCenterY = 0.0;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  final FocusNode thFileFocusNode = FocusNode();

  final List<String> errorMessages = <String>[];

  /// This is a factory constructor that creates a new instance of
  /// TH2FileEditController with an empty THFile.
  static TH2FileEditController create(
    String filename, {
    Uint8List? fileBytes,
  }) {
    final TH2FileEditController th2FileEditController =
        TH2FileEditController._create();
    final THFile thFile = THFile();

    thFile.filename = filename;
    thFile.fileBytes = fileBytes;
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
    userInteractionController =
        TH2FileEditUserInteractionController(this as TH2FileEditController);
    _thFileMPID = _thFile.mpID;
  }

  void _preParseInitialize() {
    _isLoading = true;
    errorMessages.clear();
  }

  Future<TH2FileEditControllerCreateResult> load() async {
    _preParseInitialize();

    final THFileParser parser = THFileParser();
    final (parsedFile, isSuccessful, errors) = await parser.parse(_thFile);

    _postParseInitialize(parsedFile, isSuccessful, errors);

    return TH2FileEditControllerCreateResult(isSuccessful, errors);
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

    _initializeReactions();

    selectionController.clearIsSelected();

    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine) {
        selectionController.setIsSelected(key, false);
      }
    });

    selectionController.resetSelectableElements();

    elementEditController.initializeMostUsedTypes();

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  void _initializeReactions() {
    _disposers.add(autorun((_) {
      final double magnitude = MPNumericAux.log10(_canvasScale);
      final int newDecimalPositions = magnitude.ceil() + 1;

      _currentDecimalPositions =
          newDecimalPositions < 0 ? 0 : newDecimalPositions;
    }));

    _disposers.add(autorun((_) {
      _screenBoundingBox = MPNumericAux.orderedRectFromLTWH(
        top: 0,
        left: 0,
        width: _screenSize.width,
        height: _screenSize.height,
      );
    }));

    _disposers.add(autorun((_) {
      final Offset topLeft = _canvasTranslation;
      final Offset bottomRight =
          topLeft + Offset(_canvasSize.width, _canvasSize.height);

      _canvasBoundingBox = MPNumericAux.orderedRectFromPoints(
        point1: topLeft,
        point2: bottomRight,
      );
    }));

    _disposers.add(autorun((_) {
      final MPTH2FileEditState state = stateController.state;

      _isAddElementMode = ((state is MPTH2FileEditStateAddArea) ||
          (state is MPTH2FileEditStateAddLine) ||
          (state is MPTH2FileEditStateAddPoint));
    }));

    _disposers.add(autorun((_) {
      final MPTH2FileEditState state = stateController.state;

      _isEditLineMode = ((state is MPTH2FileEditStateEditSingleLine) ||
          (state is MPTH2FileEditStateMovingEndControlPoints) ||
          (state is MPTH2FileEditStateMovingSingleControlPoint));
    }));

    _disposers.add(autorun((_) {
      _enableNodeEditButton =
          (selectionController.mpSelectedElementsLogical.length == 1) &&
              (selectionController.mpSelectedElementsLogical[selectionController
                  .mpSelectedElementsLogical.keys.first] is MPSelectedLine);
    }));

    _disposers.add(autorun((_) {
      _isOptionEditMode = stateController.state is MPTH2FileEditStateOptionEdit;
    }));

    _disposers.add(autorun((_) {
      final MPTH2FileEditState state = stateController.state;

      _isSelectMode = ((state is MPTH2FileEditStateSelectEmptySelection) ||
          (state is MPTH2FileEditStateSelectNonEmptySelection) ||
          (state is MPTH2FileEditStateMovingElements));
    }));

    _disposers.add(autorun((_) {
      _lineThicknessOnCanvas =
          mpLocator.mpSettingsController.lineThickness / _canvasScale;
      _lineDirectionTickLengthOnCanvas =
          mpLineDirectionTickLength / _canvasScale;
    }));

    _disposers.add(autorun((_) {
      _controlLineThicknessOnCanvas =
          _lineThicknessOnCanvas * thControlLineThicknessFactor;
    }));

    _disposers.add(autorun((_) {
      _pointRadiusOnCanvas =
          mpLocator.mpSettingsController.pointRadius / _canvasScale;
    }));

    _disposers.add(autorun((_) {
      _selectionToleranceOnCanvas =
          mpLocator.mpSettingsController.selectionTolerance / _canvasScale;
    }));

    _disposers.add(autorun((_) {
      _selectionToleranceSquaredOnCanvas =
          (_selectionToleranceOnCanvas * _selectionToleranceOnCanvas);
    }));

    _disposers.add(autorun((_) {
      _selectionHandleSizeOnCanvas = thSelectionHandleSize / _canvasScale;
    }));

    _disposers.add(autorun((_) {
      _selectionHandleDistanceOnCanvas =
          thSelectionHandleDistance / _canvasScale;
    }));

    _disposers.add(autorun((_) {
      _selectionHandleLineThicknessOnCanvas =
          thSelectionHandleLineThickness / _canvasScale;
    }));
  }

  void _disposeReactions() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
  }

  @action
  void performSetZoomButtonsHovered(bool isHovered) {
    _isZoomButtonsHovered = isHovered;
  }

  @action
  void performSetAddElementButtonsHovered(bool isHovered) {
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
    selectionController.resetSelectableElements();
    triggerAllElementsRedraw();
  }

  Map<int, String> availableScraps() {
    final Map<int, String> scraps = {};

    for (final int scrapMPID in _thFile.scrapMPIDs) {
      final THScrap scrap = _thFile.scrapByMPID(scrapMPID);

      scraps[scrapMPID] = scrap.thID;
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

    return ((dx * dx) + (dy * dy)) < _selectionToleranceSquaredOnCanvas;
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
    _changedCanvasTransform();
  }

  @action
  triggerAllElementsRedraw() {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerSelectedElements++;
    _redrawTriggerNonSelectedElements++;
    _redrawTriggerNewLine++;
    _redrawTriggerEditLine++;
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
  void triggerOptionsListRedraw() {
    _redrawTriggerOptionsList++;
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

    _changedCanvasTransform();
  }

  @action
  void zoomOut({bool fineZoom = false}) {
    _canvasScale = MPNumericAux.calculateNextZoomLevel(
      scale: _canvasScale,
      factor: fineZoom ? thFineZoomFactor : thRegularZoomFactor,
      isIncrease: false,
    );

    _changedCanvasTransform();
  }

  @action
  void zoomOneToOne() {
    _canvasScale = 1;

    _changedCanvasTransform();
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

    _changedCanvasTransform();
  }

  void _changedCanvasTransform() {
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    selectionController.warmSelectableElementsCanvasScaleChanged();
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    triggerAllElementsRedraw();
  }

  void close() {
    overlayWindowController.close();
    _disposeReactions();
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
    _changedCanvasTransform();
  }

  @action
  void moveCanvasHorizontally({required bool left}) {
    double delta = _canvasSize.width * thCanvasMovementFactor;
    if (!left) {
      delta = -delta;
    }
    _canvasCenterX += delta;
    _calculateCanvasOffset();
    _changedCanvasTransform();
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
        return (_thFile.scrapByMPID(_activeScrapID))
            .getBoundingBox(this as TH2FileEditController);
      case MPZoomToFitType.selection:
        return selectionController.getSelectedElementsBoundingBoxOnCanvas();
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
    /// Transformations are applied on the order they are defined.
    canvas.scale(_canvasScale);
    canvas.translate(_canvasTranslation.dx, _canvasTranslation.dy);
    canvas.scale(1, -1);
  }

  Uint8List _encodedFileContents() {
    final THFileWriter thFileWriter = THFileWriter();

    return thFileWriter.toBytes(
      _thFile,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );
  }

  void saveTH2File() {
    final File file = _localFile();

    _actualSave(file);
  }

  Future<void> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _thFile.filename,
      initialDirectory:
          mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
              ? null
              : mpLocator.mpGeneralController.lastAccessedDirectory,
    );

    if (filePath != null) {
      _thFile.filename = filePath;

      String directoryPath = p.dirname(filePath);

      mpLocator.mpGeneralController.lastAccessedDirectory = directoryPath;

      final File file = File(filePath);

      _actualSave(file);
    }
  }

  void _actualSave(File file) {
    final Uint8List encodedContent = _encodedFileContents();

    undoRedoController.clearUndoRedoStack();
    updateUndoRedoStatus();

    file.writeAsBytesSync(encodedContent, flush: true);
  }

  File _localFile() {
    final String filename = _thFile.filename;

    return File(filename);
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
    overlayWindowController.clearOverlayWindows();
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
  void performSetMousePosition(Offset position) {
    _mousePosition = position;
  }

  @action
  void applyMPCommandList(
    List<MPCommand> commandList,
    MPMultipleElementsCommandCompletionType completionType,
  ) {
    for (final MPCommand command in commandList) {
      command.execute(this as TH2FileEditController);
    }

    switch (completionType) {
      case MPMultipleElementsCommandCompletionType.elementsEdited:
      case MPMultipleElementsCommandCompletionType.elementsListChanged:
      case MPMultipleElementsCommandCompletionType.lineSegmentsAdded:
      case MPMultipleElementsCommandCompletionType.lineSegmentsRemoved:
      case MPMultipleElementsCommandCompletionType.optionsEdited:
        elementEditController.updateOptionEdited();
    }
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
