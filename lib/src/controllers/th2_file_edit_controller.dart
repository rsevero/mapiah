import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/th_point_paint.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_controller.dart';
import 'package:mapiah/src/widgets/interfaces/mp_actuator_interface.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th2_file_edit_controller.g.dart';

class TH2FileEditController = TH2FileEditControllerBase
    with _$TH2FileEditController;

abstract class TH2FileEditControllerBase
    with Store
    implements MPActuatorInterface {
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

  @computed
  String get canvasScaleAsPercentageText =>
      MPNumericAux.roundScaleAsTextPercentage(_canvasScale);

  @readonly
  Offset _canvasTranslation = Offset.zero;

  @readonly
  bool _isLoading = false;

  @readonly
  late THFile _thFile;

  @readonly
  late int _thFileMapiahID;

  @computed
  String get filenameAndScrap {
    String filename = p.basename(_thFile.filename);

    if (_hasMultipleScraps) {
      final THScrap scrap =
          _thFile.elementByMapiahID(_activeScrapID) as THScrap;

      filename += ' | ${scrap.thID}';
    }

    return filename;
  }

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
  bool get isSelectMode => (_state is MPTH2FileEditStateSelectEmptySelection ||
      (_state is MPTH2FileEditStateSelectNonEmptySelection));

  @computed
  bool get isAddElementMode => ((_state is MPTH2FileEditPageStateAddArea) ||
      (_state is MPTH2FileEditPageStateAddLine) ||
      (_state is MPTH2FileEditPageStateAddPoint));

  @readonly
  bool _isLineSegmentStraight = true;

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
  bool _isAddElementButtonsHovered = false;

  @computed
  MPButtonType get activeAddElementButton {
    switch (_state) {
      case MPTH2FileEditPageStateAddPoint _:
        return MPButtonType.addPoint;
      case MPTH2FileEditPageStateAddLine _:
        return MPButtonType.addLine;
      case MPTH2FileEditPageStateAddArea _:
        return MPButtonType.addArea;
      default:
        return MPButtonType.addElement;
    }
  }

  @readonly
  THPointType _lastAddedPointType = thDefaultPointType;

  @readonly
  THLineType _lastAddedLineType = thDefaultLineType;

  @readonly
  THAreaType _lastAddedAreaType = thDefaultAreaType;

  @readonly
  int _currentDecimalPositions = thDefaultDecimalPositions;

  @readonly
  late MPTH2FileEditState _state;

  @readonly
  int _activeScrapID = 0;

  @readonly
  bool _hasMultipleScraps = false;

  @computed
  double get lineThicknessOnCanvas =>
      mpLocator.mpSettingsController.lineThickness / _canvasScale;

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
  bool get showSelectedElements => _selectedElements.isNotEmpty;

  @computed
  bool get showSelectionHandles => showSelectedElements && isSelectMode;

  @computed
  bool get showSelectionWindow =>
      _selectionWindowCanvasCoordinates.value != Rect.zero;

  @computed
  bool get showAddLine => _newLine != null;

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
  bool get showUndoRedoButtons => isAddElementMode || isSelectMode;

  @computed
  bool get showDeleteButton =>
      ((_state is MPTH2FileEditStateSelectEmptySelection) ||
          (_state is MPTH2FileEditStateSelectNonEmptySelection));

  @computed
  bool get deleteButtonEnabled => _selectedElements.isNotEmpty;

  @readonly
  String _statusBarMessage = '';

  @computed
  bool get showScrapScale {
    return !_isLoading && scrapHasScaleOption;
  }

  @computed
  bool get scrapHasScaleOption {
    final THScrap scrap = _thFile.elementByMapiahID(_activeScrapID) as THScrap;

    return scrap.hasOption('scale');
  }

  @computed
  THLengthUnitType get scrapLengthUnitType {
    if (scrapHasScaleOption) {
      final THScrap scrap =
          _thFile.elementByMapiahID(_activeScrapID) as THScrap;

      return (scrap.optionByType('scale') as THScrapScaleCommandOption)
          .unitPart
          .unit;
    } else {
      return THLengthUnitType.meter;
    }
  }

  @computed
  double get scrapLengthUnitsPerPoint {
    if (scrapHasScaleOption) {
      final THScrap scrap =
          _thFile.elementByMapiahID(_activeScrapID) as THScrap;

      return (scrap.optionByType('scale') as THScrapScaleCommandOption)
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
  bool _redrawTriggerNewLine = false;

  @observable
  bool isChangeScrapsPopupVisible = false;

  @observable
  OverlayPortalController changeScrapsPopupOverlayPortalControllerController =
      OverlayPortalController();

  @observable
  GlobalKey changeScrapsFABKey = GlobalKey();

  @readonly
  double _canvasCenterX = 0.0;
  @readonly
  double _canvasCenterY = 0.0;

  @readonly
  THLine? _newLine;

  @action
  THLine getNewLine() {
    _newLine ??= _createNewLine();

    return _newLine!;
  }

  Map<MPSelectionHandleType, Offset>? _selectionHandleCenters;

  Map<MPSelectionHandleType, Offset> getSelectionHandleCenters() {
    _selectionHandleCenters ??= _calculateSelectionHandleCenters();

    return _selectionHandleCenters!;
  }

  /// Used to search for selected elements by list of selectable coordinates.
  final Map<int, MPSelectable> _selectables = {};

  Offset dragStartCanvasCoordinates = Offset.zero;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  final List<String> errorMessages = <String>[];

  late final MPUndoRedoController _undoRedoController;

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
    _thFileMapiahID = _thFile.mapiahID;
    _state = MPTH2FileEditState.getState(
      type: MPTH2FileEditStateType.selectEmptySelection,
      thFileEditController: this as TH2FileEditController,
    );
    _undoRedoController = MPUndoRedoController(this as TH2FileEditController);
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
    if (_thFile.scrapMapiahIDs.isNotEmpty) {
      _activeScrapID = _thFile.scrapMapiahIDs.first;
      _hasMultipleScraps = _thFile.scrapMapiahIDs.length > 1;
    }

    _isSelected.clear();

    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine) {
        _isSelected[key] = Observable(false);
      }
    });

    updateSelectableElements();

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  THLine _createNewLine() {
    final THLine newLine = THLine(
      parentMapiahID: _activeScrapID,
      lineType: _lastAddedLineType,
    );

    addElementWithParentMapiahIDWithoutSelectableElement(
      newElement: newLine,
      parentMapiahID: _activeScrapID,
    );

    return newLine;
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

  void updateSelectableElements() {
    _selectables.clear();

    final THScrap scrap = _thFile.elementByMapiahID(_activeScrapID) as THScrap;

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
        break;
      case THLine _:
        _addLineSelectableElement(element);
        break;
    }
  }

  void _addPointSelectableElement(THPoint point) {
    final MPSelectablePoint selectablePoint = MPSelectablePoint(
      point: point,
      th2fileEditController: this as TH2FileEditController,
    );

    _selectables[point.mapiahID] = selectablePoint;
  }

  void _addLineSelectableElement(THLine line) {
    final MPSelectableLine selectableLine = MPSelectableLine(
      line: line,
      th2fileEditController: this as TH2FileEditController,
    );

    _selectables[line.mapiahID] = selectableLine;
  }

  void _removeSelectableElement(int mapiahID) {
    _selectables.remove(mapiahID);
  }

  List<THElement> selectableElementsClicked(Offset screenCoordinates) {
    final Offset canvasCoordinates = offsetScreenToCanvas(screenCoordinates);
    final List<THElement> clickedElements = <THElement>[];
    final selectableElements = _selectables.values;

    for (final selectableElement in selectableElements) {
      if (selectableElement.contains(canvasCoordinates)) {
        switch (selectableElement.element) {
          case THPoint _:
          case THLine _:
            clickedElements.addAll(selectableElement.selectedElements);
            break;
        }
      }
    }

    return clickedElements;
  }

  List<THElement> selectableElementsInsideWindow(Rect canvasSelectionWindow) {
    final Map<int, THElement> insideWindowElements = <int, THElement>{};

    for (final selectableElement in _selectables.entries) {
      final THElement element = selectableElement.value.element;

      if (MPNumericAux.isRect1InsideRect2(
        rect1: (element as MPBoundingBox)
            .getBoundingBox(this as TH2FileEditController),
        rect2: canvasSelectionWindow,
      )) {
        insideWindowElements[element.mapiahID] = element;
      }
    }

    return insideWindowElements.values.toList();
  }

  void warmSelectableElementsCanvasScaleChanged() {
    for (final selectableElement in _selectables.values) {
      selectableElement.canvasScaleChanged();
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
  void setLastAddedPointType(THPointType pointType) {
    _lastAddedPointType = pointType;
  }

  @action
  void setLastAddedLineType(THLineType lineType) {
    _lastAddedLineType = lineType;
  }

  @action
  void setLastAddedAreaType(THAreaType areaType) {
    _lastAddedAreaType = areaType;
  }

  void convertLastLineSegmentFromStraightToBezier() {
    if ((_newLine == null) || (_newLine!.childrenMapiahID.length < 2)) {
      return;
    }

    final THLineSegment lastLineSegment = _thFile
        .elementByMapiahID(_newLine!.childrenMapiahID.last) as THLineSegment;

    if (lastLineSegment is! THStraightLineSegment) {
      return;
    }

    final THLineSegment secondToLastLineSegment = _thFile.elementByMapiahID(
      _newLine!.childrenMapiahID
          .elementAt(_newLine!.childrenMapiahID.length - 2),
    ) as THLineSegment;

    final Offset startPoint = secondToLastLineSegment.endPoint.coordinates;
    final Offset endPoint = lastLineSegment.endPoint.coordinates;

    final Offset third = (endPoint - startPoint) / 3;
    final Offset controlPoint1 = startPoint + third;
    final Offset controlPoint2 = controlPoint1 + third;

    final THBezierCurveLineSegment bezierCurveLineSegment =
        THBezierCurveLineSegment.forCWJM(
      mapiahID: lastLineSegment.mapiahID,
      parentMapiahID: _newLine!.mapiahID,
      endPoint: THPositionPart(
        coordinates: endPoint,
        decimalPositions: _currentDecimalPositions,
      ),
      controlPoint1: THPositionPart(
        coordinates: controlPoint1,
        decimalPositions: _currentDecimalPositions,
      ),
      controlPoint2: THPositionPart(
        coordinates: controlPoint2,
        decimalPositions: _currentDecimalPositions,
      ),
      optionsMap: LinkedHashMap<String, THCommandOption>(),
      originalLineInTH2File: '',
      sameLineComment: '',
    );

    _thFile.substituteElement(bezierCurveLineSegment);
    _redrawTriggerNewLine = !_redrawTriggerNewLine;
  }

  @action
  void addNewLineLineSegment(Offset enPointScreenCoordinates) {
    final Offset endPointCanvasCoordinates =
        offsetScreenToCanvas(enPointScreenCoordinates);
    late THLineSegment lineSegment;
    final int parentMapiahID = getNewLine().mapiahID;

    if (_isLineSegmentStraight) {
      lineSegment = THStraightLineSegment(
        parentMapiahID: parentMapiahID,
        endPoint: THPositionPart(
          coordinates: endPointCanvasCoordinates,
          decimalPositions: _currentDecimalPositions,
        ),
      );
    } else {
      // lineSegment = THBezierCurveLineSegment(
      //   endPoint: THPositionPart(
      //     coordinates: Offset(endPointCanvasCoordinates),
      //     decimalPositions: _currentDecimalPositions
      //   ),
      //   controlPoint1: THPoint(
      //     position: THPosition(
      //       coordinates: dragStartCanvasCoordinates,
      //     ),
      //   ),
      //   controlPoint2: THPoint(
      //     position: THPosition(
      //       coordinates: dragStartCanvasCoordinates,
      //     ),
      //   ),
      // );
    }
    addElementWithParentMapiahIDWithoutSelectableElement(
      parentMapiahID: parentMapiahID,
      newElement: lineSegment,
    );
    _redrawTriggerNewLine = !_redrawTriggerNewLine;
  }

  @action
  void clearNewLine() {
    _newLine = null;
  }

  @action
  void setIsLineSegmentStraight(bool isLineSegmentStraight) {
    _isLineSegmentStraight = isLineSegmentStraight;
  }

  @action
  void setStatusBarMessage(String message) {
    _statusBarMessage = message;
  }

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    _state.onPrimaryButtonDragStart(event);
  }

  @override
  void onSecondaryButtonDragStart(PointerDownEvent event) {
    _state.onSecondaryButtonDragStart(event);
  }

  @override
  void onTertiaryButtonDragStart(PointerDownEvent event) {
    _state.onTertiaryButtonDragStart(event);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onPrimaryButtonDragUpdate(event);
  }

  @override
  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onSecondaryButtonDragUpdate(event);
  }

  @override
  void onTertiaryButtonDragUpdate(PointerMoveEvent event) {
    _state.onTertiaryButtonDragUpdate(event);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    _state.onPrimaryButtonDragEnd(event);
  }

  @override
  void onSecondaryButtonDragEnd(PointerUpEvent event) {
    _state.onSecondaryButtonDragEnd(event);
  }

  @override
  void onTertiaryButtonDragEnd(PointerUpEvent event) {
    _state.onTertiaryButtonDragEnd(event);
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    _state.onPrimaryButtonClick(event);
  }

  @override
  void onSecondaryButtonClick(PointerUpEvent event) {
    _state.onSecondaryButtonClick(event);
  }

  @override
  void onTertiaryButtonClick(PointerUpEvent event) {
    _state.onTertiaryButtonClick(event);
  }

  @override
  void onTertiaryButtonScroll(PointerScrollEvent event) {
    _state.onTertiaryButtonScroll(event);
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    _state.onKeyDownEvent(event);
  }

  @override
  void onKeyRepeatEvent(KeyRepeatEvent event) {
    _state.onKeyRepeatEvent(event);
  }

  @override
  void onKeyUpEvent(KeyUpEvent event) {
    _state.onKeyUpEvent(event);
  }

  void onButtonPressed(MPButtonType buttonType) {
    _state.onButtonPressed(buttonType);
  }

  int getNextAvailableScrapID() {
    final List<int> scrapIDs = _thFile.scrapMapiahIDs;
    final int currentIndex = scrapIDs.indexOf(_activeScrapID);

    if (currentIndex == -1 || scrapIDs.isEmpty) {
      throw Exception('Current active scrap ID not found in scrapIDs');
    }
    final int nextIndex = (currentIndex + 1) % scrapIDs.length;
    return scrapIDs[nextIndex];
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
      point1: dragStartCanvasCoordinates,
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
  }

  void _clearSelectedElementsWithoutResettingRedrawTriggers() {
    _selectedElements.clear();
    _isSelected.forEach((key, value) => value.value = false);
    _selectedElementsBoundingBox = null;
    _selectionHandleCenters = null;
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
          );
      }
    } else {}

    execute(mpCommand);
    clearSelectedElements();
    triggerSelectedElementsRedraw();
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
        case THLine _:
          boundingBox = (element as MPBoundingBox)
              .getBoundingBox(this as TH2FileEditController);
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
  void deselectAllElements() {
    _clearSelectedElementsWithoutResettingRedrawTriggers();
    triggerSelectedListChanged();
  }

  @action
  void selectAllElements() {
    final THScrap scrap = _thFile.elementByMapiahID(_activeScrapID) as THScrap;
    final List<int> elementMapiahIDs = scrap.childrenMapiahID;

    for (final int elementMapiahID in elementMapiahIDs) {
      final THElement element = _thFile.elementByMapiahID(elementMapiahID);

      if (element is THPoint || element is THLine) {
        addSelectedElement(element);
      }
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

      addSelectedElement(element);
    }
  }

  @action
  void removeSelectedElement(THElement element) {
    _selectedElements.remove(element.mapiahID);
    if (_isSelected.containsKey(element.mapiahID)) {
      _isSelected[element.mapiahID]!.value = false;
    }
    triggerSelectedListChanged();
  }

  void setDragStartCoordinates(Offset screenCoordinates) {
    dragStartCanvasCoordinates = offsetScreenToCanvas(screenCoordinates);
  }

  @action
  void setState(MPTH2FileEditStateType type) {
    final MPTH2FileEditState previousState = _state;

    _state = MPTH2FileEditState.getState(
      type: type,
      thFileEditController: this as TH2FileEditController,
    );

    previousState.onStateExit(_state);

    _state.onStateEnter(previousState);
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

  List<THLineSegment> getLineSegments({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final List<int> lineSegmentMapiahIDs = line.childrenMapiahID;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is THLineSegment) {
        lineSegments.add(clone ? lineSegment.copyWith() : lineSegment);
      }
    }

    return lineSegments;
  }

  @action
  void moveSelectedElementsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if ((_selectedElements.isEmpty) || !isSelectMode) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition - dragStartCanvasCoordinates;

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
    substituteElementWithoutAddSelectableElement(modifiedPoint);
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

    substituteLineAndLineSegments(line.copyWith(), modifiedLineSegmentsMap);
  }

  THPointPaint getUnselectedPointPaint(THPoint point) {
    final Paint paint =
        isFromActiveScrap(point) ? THPaints.thPaint1 : THPaints.thPaint4;
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: paint..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getUnselectedLinePaint(THLine line) {
    final Paint paint =
        isFromActiveScrap(line) ? THPaints.thPaint3 : THPaints.thPaint4;
    return THLinePaint(
      paint: paint..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THPointPaint getSelectedPointPaint() {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaint2..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THPointPaint getNewLinePointPaint() {
    return THPointPaint(
      radius: pointRadiusOnCanvas,
      paint: THPaints.thPaintBlackBorder..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getSelectedLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint2..strokeWidth = lineThicknessOnCanvas,
    );
  }

  THLinePaint getNewLinePaint() {
    return THLinePaint(
      paint: THPaints.thPaint19..strokeWidth = lineThicknessOnCanvas,
    );
  }

  bool isFromActiveScrap(THElement element) {
    return element.parentMapiahID == _activeScrapID;
  }

  @action
  void setActiveScrap(int scrapMapiahID) {
    _activeScrapID = scrapMapiahID;
  }

  List<(int, String, bool)> availableScraps() {
    final List<(int, String, bool)> scraps = <(int, String, bool)>[];

    for (final int scrapMapiahID in _thFile.scrapMapiahIDs) {
      final THScrap scrap = _thFile.elementByMapiahID(scrapMapiahID) as THScrap;
      final bool isActive = scrapMapiahID == _activeScrapID;
      scraps.add((scrapMapiahID, scrap.thID, isActive));
    }

    return scraps;
  }

  @action
  void toggleToNextAvailableScrap() {
    final int nextAvailableScrapID = getNextAvailableScrapID();

    setActiveScrap(nextAvailableScrapID);
    clearSelectedElements();
    updateSelectableElements();
    triggerAllElementsRedraw();
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
    _selectionHandleCenters = null;
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
  void updateCanvasOffsetDrawing(Offset newOffset) {
    _canvasTranslation = newOffset;
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
    warmSelectableElementsCanvasScaleChanged();
    _selectionHandleCenters = null;
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
        return (_thFile.elementByMapiahID(_activeScrapID) as THScrap)
            .getBoundingBox(this as TH2FileEditController);
      case MPZoomToFitType.selection:
        return _getSelectedElementsBoundingBox();
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

  void substituteElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    addSelectableElement(modifiedElement);
    mpLocator.mpLog.finer('Substituted element ${modifiedElement.mapiahID}');
  }

  void substituteElements(List<THElement> modifiedElements) {
    for (final modifiedElement in modifiedElements) {
      _thFile.substituteElement(modifiedElement);
      addSelectableElement(modifiedElement);
      mpLocator.mpLog
          .finer('Substituted element ${modifiedElement.mapiahID} from list');
    }
  }

  void substituteElementWithoutAddSelectableElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    mpLocator.mpLog.finer(
        'Substituted element without add selectable element ${modifiedElement.mapiahID}');
  }

  void substituteLineAndLineSegments(
    THLine line,
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }
    _thFile.substituteElement(line);
  }

  @action
  void execute(MPCommand command) {
    _undoRedoController.execute(command);
    _updateUndoRedoStatus();
  }

  @action
  void _updateUndoRedoStatus() {
    _hasUndo = _undoRedoController.hasUndo;
    _hasRedo = _undoRedoController.hasRedo;
    _undoDescription = mpLocator.appLocalizations
        .th2FileEditPageUndo(_undoRedoController.undoDescription);
    _redoDescription = mpLocator.appLocalizations
        .th2FileEditPageRedo(_undoRedoController.redoDescription);
  }

  @action
  void _undoRedoDone() {
    _updateUndoRedoStatus();
    _selectedElements.clear();
    _selectionHandleCenters = null;
  }

  void undo() {
    _undoRedoController.undo();
    _undoRedoDone();
  }

  void redo() {
    _undoRedoController.redo();
    _undoRedoDone();
  }

  MPUndoRedoController get undoRedoController => _undoRedoController;

  @action
  void addElement({required THElement newElement}) {
    _thFile.addElement(newElement);

    final int parentMapiahID = newElement.parentMapiahID;

    if (parentMapiahID < 0) {
      _thFile.addElementToParent(newElement);
    } else {
      final THIsParentMixin parent =
          _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin;

      parent.addElementToParent(newElement);
    }

    addSelectableElement(newElement);
  }

  void addElementWithParentMapiahIDWithoutSelectableElement({
    required THElement newElement,
    required int parentMapiahID,
  }) {
    addElementWithParentWithoutSelectableElement(
      newElement: newElement,
      parent: _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin,
    );
  }

  @action
  void addElementWithParentWithoutSelectableElement({
    required THElement newElement,
    required THIsParentMixin parent,
  }) {
    _thFile.addElement(newElement);
    parent.addElementToParent(newElement);
  }

  @action
  void deleteElement(THElement element) {
    _thFile.deleteElement(element);
    _removeSelectableElement(element.mapiahID);
    removeSelectedElement(element);
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

  @action
  void registerNewLineInFile() {
    if (_newLine != null) {
      final THLine newLine = _newLine!.copyWith(childrenMapiahID: <int>[]);
      final List<THLineSegment> newLineSegments =
          getLineSegments(line: _newLine!, clone: true);

      deleteElement(_newLine!);
      final MPAddLineCommand command = MPAddLineCommand(
        newLine: newLine,
        lineChildren: newLineSegments,
      );

      execute(command);
      clearNewLine();
      triggerNonSelectedElementsRedraw();
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
