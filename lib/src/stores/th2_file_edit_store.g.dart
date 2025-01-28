// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditStore on TH2FileEditStoreBase, Store {
  Computed<bool>? _$isEditModeComputed;

  @override
  bool get isEditMode =>
      (_$isEditModeComputed ??= Computed<bool>(() => super.isEditMode,
              name: 'TH2FileEditStoreBase.isEditMode'))
          .value;
  Computed<bool>? _$isPanModeComputed;

  @override
  bool get isPanMode =>
      (_$isPanModeComputed ??= Computed<bool>(() => super.isPanMode,
              name: 'TH2FileEditStoreBase.isPanMode'))
          .value;
  Computed<bool>? _$isSelectModeComputed;

  @override
  bool get isSelectMode =>
      (_$isSelectModeComputed ??= Computed<bool>(() => super.isSelectMode,
              name: 'TH2FileEditStoreBase.isSelectMode'))
          .value;
  Computed<double>? _$lineThicknessOnCanvasComputed;

  @override
  double get lineThicknessOnCanvas => (_$lineThicknessOnCanvasComputed ??=
          Computed<double>(() => super.lineThicknessOnCanvas,
              name: 'TH2FileEditStoreBase.lineThicknessOnCanvas'))
      .value;
  Computed<double>? _$pointRadiusOnCanvasComputed;

  @override
  double get pointRadiusOnCanvas => (_$pointRadiusOnCanvasComputed ??=
          Computed<double>(() => super.pointRadiusOnCanvas,
              name: 'TH2FileEditStoreBase.pointRadiusOnCanvas'))
      .value;
  Computed<double>? _$selectionToleranceSquaredOnCanvasComputed;

  @override
  double get selectionToleranceSquaredOnCanvas =>
      (_$selectionToleranceSquaredOnCanvasComputed ??= Computed<double>(
              () => super.selectionToleranceSquaredOnCanvas,
              name: 'TH2FileEditStoreBase.selectionToleranceSquaredOnCanvas'))
          .value;
  Computed<bool>? _$showSelectedElementsComputed;

  @override
  bool get showSelectedElements => (_$showSelectedElementsComputed ??=
          Computed<bool>(() => super.showSelectedElements,
              name: 'TH2FileEditStoreBase.showSelectedElements'))
      .value;
  Computed<bool>? _$showSelectionHandlesComputed;

  @override
  bool get showSelectionHandles => (_$showSelectionHandlesComputed ??=
          Computed<bool>(() => super.showSelectionHandles,
              name: 'TH2FileEditStoreBase.showSelectionHandles'))
      .value;
  Computed<bool>? _$showSelectionWindowComputed;

  @override
  bool get showSelectionWindow => (_$showSelectionWindowComputed ??=
          Computed<bool>(() => super.showSelectionWindow,
              name: 'TH2FileEditStoreBase.showSelectionWindow'))
      .value;
  Computed<Observable<Paint>>? _$selectionWindowBorderPaintCompleteComputed;

  @override
  Observable<Paint> get selectionWindowBorderPaintComplete =>
      (_$selectionWindowBorderPaintCompleteComputed ??= Computed<
                  Observable<Paint>>(
              () => super.selectionWindowBorderPaintComplete,
              name: 'TH2FileEditStoreBase.selectionWindowBorderPaintComplete'))
          .value;
  Computed<Observable<double>>?
      _$selectionWindowBorderPaintDashIntervalOnCanvasComputed;

  @override
  Observable<double> get selectionWindowBorderPaintDashIntervalOnCanvas =>
      (_$selectionWindowBorderPaintDashIntervalOnCanvasComputed ??= Computed<
                  Observable<double>>(
              () => super.selectionWindowBorderPaintDashIntervalOnCanvas,
              name:
                  'TH2FileEditStoreBase.selectionWindowBorderPaintDashIntervalOnCanvas'))
          .value;
  Computed<Observable<double>>? _$selectionHandleSizeOnCanvasComputed;

  @override
  Observable<double> get selectionHandleSizeOnCanvas =>
      (_$selectionHandleSizeOnCanvasComputed ??= Computed<Observable<double>>(
              () => super.selectionHandleSizeOnCanvas,
              name: 'TH2FileEditStoreBase.selectionHandleSizeOnCanvas'))
          .value;
  Computed<Observable<double>>? _$selectionHandleDistanceOnCanvasComputed;

  @override
  Observable<double> get selectionHandleDistanceOnCanvas =>
      (_$selectionHandleDistanceOnCanvasComputed ??=
              Computed<Observable<double>>(
                  () => super.selectionHandleDistanceOnCanvas,
                  name: 'TH2FileEditStoreBase.selectionHandleDistanceOnCanvas'))
          .value;
  Computed<Observable<double>>? _$selectionHandleLineThicknessOnCanvasComputed;

  @override
  Observable<double> get selectionHandleLineThicknessOnCanvas =>
      (_$selectionHandleLineThicknessOnCanvasComputed ??= Computed<
                  Observable<double>>(
              () => super.selectionHandleLineThicknessOnCanvas,
              name:
                  'TH2FileEditStoreBase.selectionHandleLineThicknessOnCanvas'))
          .value;
  Computed<Observable<Paint>>? _$selectionHandlePaintComputed;

  @override
  Observable<Paint> get selectionHandlePaint =>
      (_$selectionHandlePaintComputed ??= Computed<Observable<Paint>>(
              () => super.selectionHandlePaint,
              name: 'TH2FileEditStoreBase.selectionHandlePaint'))
          .value;

  late final _$_screenSizeAtom =
      Atom(name: 'TH2FileEditStoreBase._screenSize', context: context);

  Size get screenSize {
    _$_screenSizeAtom.reportRead();
    return super._screenSize;
  }

  @override
  Size get _screenSize => screenSize;

  @override
  set _screenSize(Size value) {
    _$_screenSizeAtom.reportWrite(value, super._screenSize, () {
      super._screenSize = value;
    });
  }

  late final _$_canvasScaleAtom =
      Atom(name: 'TH2FileEditStoreBase._canvasScale', context: context);

  double get canvasScale {
    _$_canvasScaleAtom.reportRead();
    return super._canvasScale;
  }

  @override
  double get _canvasScale => canvasScale;

  @override
  set _canvasScale(double value) {
    _$_canvasScaleAtom.reportWrite(value, super._canvasScale, () {
      super._canvasScale = value;
    });
  }

  late final _$_canvasTranslationAtom =
      Atom(name: 'TH2FileEditStoreBase._canvasTranslation', context: context);

  Offset get canvasTranslation {
    _$_canvasTranslationAtom.reportRead();
    return super._canvasTranslation;
  }

  @override
  Offset get _canvasTranslation => canvasTranslation;

  @override
  set _canvasTranslation(Offset value) {
    _$_canvasTranslationAtom.reportWrite(value, super._canvasTranslation, () {
      super._canvasTranslation = value;
    });
  }

  late final _$_visualModeAtom =
      Atom(name: 'TH2FileEditStoreBase._visualMode', context: context);

  TH2FileEditMode get visualMode {
    _$_visualModeAtom.reportRead();
    return super._visualMode;
  }

  @override
  TH2FileEditMode get _visualMode => visualMode;

  @override
  set _visualMode(TH2FileEditMode value) {
    _$_visualModeAtom.reportWrite(value, super._visualMode, () {
      super._visualMode = value;
    });
  }

  late final _$_isLoadingAtom =
      Atom(name: 'TH2FileEditStoreBase._isLoading', context: context);

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_thFileAtom =
      Atom(name: 'TH2FileEditStoreBase._thFile', context: context);

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  bool __thFileIsInitialized = false;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom
        .reportWrite(value, __thFileIsInitialized ? super._thFile : null, () {
      super._thFile = value;
      __thFileIsInitialized = true;
    });
  }

  late final _$_thFileMapiahIDAtom =
      Atom(name: 'TH2FileEditStoreBase._thFileMapiahID', context: context);

  int get thFileMapiahID {
    _$_thFileMapiahIDAtom.reportRead();
    return super._thFileMapiahID;
  }

  @override
  int get _thFileMapiahID => thFileMapiahID;

  bool __thFileMapiahIDIsInitialized = false;

  @override
  set _thFileMapiahID(int value) {
    _$_thFileMapiahIDAtom.reportWrite(
        value, __thFileMapiahIDIsInitialized ? super._thFileMapiahID : null,
        () {
      super._thFileMapiahID = value;
      __thFileMapiahIDIsInitialized = true;
    });
  }

  late final _$_isSelectedAtom =
      Atom(name: 'TH2FileEditStoreBase._isSelected', context: context);

  Map<int, Observable<bool>> get isSelected {
    _$_isSelectedAtom.reportRead();
    return super._isSelected;
  }

  @override
  Map<int, Observable<bool>> get _isSelected => isSelected;

  @override
  set _isSelected(Map<int, Observable<bool>> value) {
    _$_isSelectedAtom.reportWrite(value, super._isSelected, () {
      super._isSelected = value;
    });
  }

  late final _$_selectedElementsAtom =
      Atom(name: 'TH2FileEditStoreBase._selectedElements', context: context);

  ObservableMap<int, MPSelectedElement> get selectedElements {
    _$_selectedElementsAtom.reportRead();
    return super._selectedElements;
  }

  @override
  ObservableMap<int, MPSelectedElement> get _selectedElements =>
      selectedElements;

  @override
  set _selectedElements(ObservableMap<int, MPSelectedElement> value) {
    _$_selectedElementsAtom.reportWrite(value, super._selectedElements, () {
      super._selectedElements = value;
    });
  }

  late final _$_hasUndoAtom =
      Atom(name: 'TH2FileEditStoreBase._hasUndo', context: context);

  bool get hasUndo {
    _$_hasUndoAtom.reportRead();
    return super._hasUndo;
  }

  @override
  bool get _hasUndo => hasUndo;

  @override
  set _hasUndo(bool value) {
    _$_hasUndoAtom.reportWrite(value, super._hasUndo, () {
      super._hasUndo = value;
    });
  }

  late final _$_hasRedoAtom =
      Atom(name: 'TH2FileEditStoreBase._hasRedo', context: context);

  bool get hasRedo {
    _$_hasRedoAtom.reportRead();
    return super._hasRedo;
  }

  @override
  bool get _hasRedo => hasRedo;

  @override
  set _hasRedo(bool value) {
    _$_hasRedoAtom.reportWrite(value, super._hasRedo, () {
      super._hasRedo = value;
    });
  }

  late final _$_undoDescriptionAtom =
      Atom(name: 'TH2FileEditStoreBase._undoDescription', context: context);

  String get undoDescription {
    _$_undoDescriptionAtom.reportRead();
    return super._undoDescription;
  }

  @override
  String get _undoDescription => undoDescription;

  @override
  set _undoDescription(String value) {
    _$_undoDescriptionAtom.reportWrite(value, super._undoDescription, () {
      super._undoDescription = value;
    });
  }

  late final _$_redoDescriptionAtom =
      Atom(name: 'TH2FileEditStoreBase._redoDescription', context: context);

  String get redoDescription {
    _$_redoDescriptionAtom.reportRead();
    return super._redoDescription;
  }

  @override
  String get _redoDescription => redoDescription;

  @override
  set _redoDescription(String value) {
    _$_redoDescriptionAtom.reportWrite(value, super._redoDescription, () {
      super._redoDescription = value;
    });
  }

  late final _$_isZoomButtonsHoveredAtom = Atom(
      name: 'TH2FileEditStoreBase._isZoomButtonsHovered', context: context);

  bool get isZoomButtonsHovered {
    _$_isZoomButtonsHoveredAtom.reportRead();
    return super._isZoomButtonsHovered;
  }

  @override
  bool get _isZoomButtonsHovered => isZoomButtonsHovered;

  @override
  set _isZoomButtonsHovered(bool value) {
    _$_isZoomButtonsHoveredAtom.reportWrite(value, super._isZoomButtonsHovered,
        () {
      super._isZoomButtonsHovered = value;
    });
  }

  late final _$_stateAtom =
      Atom(name: 'TH2FileEditStoreBase._state', context: context);

  MPTH2FileEditState get state {
    _$_stateAtom.reportRead();
    return super._state;
  }

  @override
  MPTH2FileEditState get _state => state;

  bool __stateIsInitialized = false;

  @override
  set _state(MPTH2FileEditState value) {
    _$_stateAtom.reportWrite(value, __stateIsInitialized ? super._state : null,
        () {
      super._state = value;
      __stateIsInitialized = true;
    });
  }

  late final _$_canvasScaleTranslationUndefinedAtom = Atom(
      name: 'TH2FileEditStoreBase._canvasScaleTranslationUndefined',
      context: context);

  bool get canvasScaleTranslationUndefined {
    _$_canvasScaleTranslationUndefinedAtom.reportRead();
    return super._canvasScaleTranslationUndefined;
  }

  @override
  bool get _canvasScaleTranslationUndefined => canvasScaleTranslationUndefined;

  @override
  set _canvasScaleTranslationUndefined(bool value) {
    _$_canvasScaleTranslationUndefinedAtom
        .reportWrite(value, super._canvasScaleTranslationUndefined, () {
      super._canvasScaleTranslationUndefined = value;
    });
  }

  late final _$_selectionWindowCanvasCoordinatesAtom = Atom(
      name: 'TH2FileEditStoreBase._selectionWindowCanvasCoordinates',
      context: context);

  Observable<Rect> get selectionWindowCanvasCoordinates {
    _$_selectionWindowCanvasCoordinatesAtom.reportRead();
    return super._selectionWindowCanvasCoordinates;
  }

  @override
  Observable<Rect> get _selectionWindowCanvasCoordinates =>
      selectionWindowCanvasCoordinates;

  @override
  set _selectionWindowCanvasCoordinates(Observable<Rect> value) {
    _$_selectionWindowCanvasCoordinatesAtom
        .reportWrite(value, super._selectionWindowCanvasCoordinates, () {
      super._selectionWindowCanvasCoordinates = value;
    });
  }

  late final _$_selectionWindowFillPaintAtom = Atom(
      name: 'TH2FileEditStoreBase._selectionWindowFillPaint', context: context);

  Observable<Paint> get selectionWindowFillPaint {
    _$_selectionWindowFillPaintAtom.reportRead();
    return super._selectionWindowFillPaint;
  }

  @override
  Observable<Paint> get _selectionWindowFillPaint => selectionWindowFillPaint;

  @override
  set _selectionWindowFillPaint(Observable<Paint> value) {
    _$_selectionWindowFillPaintAtom
        .reportWrite(value, super._selectionWindowFillPaint, () {
      super._selectionWindowFillPaint = value;
    });
  }

  late final _$_selectionWindowBorderPaintAtom = Atom(
      name: 'TH2FileEditStoreBase._selectionWindowBorderPaint',
      context: context);

  Observable<Paint> get selectionWindowBorderPaint {
    _$_selectionWindowBorderPaintAtom.reportRead();
    return super._selectionWindowBorderPaint;
  }

  @override
  Observable<Paint> get _selectionWindowBorderPaint =>
      selectionWindowBorderPaint;

  @override
  set _selectionWindowBorderPaint(Observable<Paint> value) {
    _$_selectionWindowBorderPaintAtom
        .reportWrite(value, super._selectionWindowBorderPaint, () {
      super._selectionWindowBorderPaint = value;
    });
  }

  late final _$_selectionWindowBorderPaintDashIntervalAtom = Atom(
      name: 'TH2FileEditStoreBase._selectionWindowBorderPaintDashInterval',
      context: context);

  Observable<double> get selectionWindowBorderPaintDashInterval {
    _$_selectionWindowBorderPaintDashIntervalAtom.reportRead();
    return super._selectionWindowBorderPaintDashInterval;
  }

  @override
  Observable<double> get _selectionWindowBorderPaintDashInterval =>
      selectionWindowBorderPaintDashInterval;

  @override
  set _selectionWindowBorderPaintDashInterval(Observable<double> value) {
    _$_selectionWindowBorderPaintDashIntervalAtom
        .reportWrite(value, super._selectionWindowBorderPaintDashInterval, () {
      super._selectionWindowBorderPaintDashInterval = value;
    });
  }

  late final _$_redrawTriggerSelectedElementsListChangedAtom = Atom(
      name: 'TH2FileEditStoreBase._redrawTriggerSelectedElementsListChanged',
      context: context);

  int get redrawTriggerSelectedElementsListChanged {
    _$_redrawTriggerSelectedElementsListChangedAtom.reportRead();
    return super._redrawTriggerSelectedElementsListChanged;
  }

  @override
  int get _redrawTriggerSelectedElementsListChanged =>
      redrawTriggerSelectedElementsListChanged;

  @override
  set _redrawTriggerSelectedElementsListChanged(int value) {
    _$_redrawTriggerSelectedElementsListChangedAtom.reportWrite(
        value, super._redrawTriggerSelectedElementsListChanged, () {
      super._redrawTriggerSelectedElementsListChanged = value;
    });
  }

  late final _$_redrawTriggerSelectedElementsAtom = Atom(
      name: 'TH2FileEditStoreBase._redrawTriggerSelectedElements',
      context: context);

  int get redrawTriggerSelectedElements {
    _$_redrawTriggerSelectedElementsAtom.reportRead();
    return super._redrawTriggerSelectedElements;
  }

  @override
  int get _redrawTriggerSelectedElements => redrawTriggerSelectedElements;

  @override
  set _redrawTriggerSelectedElements(int value) {
    _$_redrawTriggerSelectedElementsAtom
        .reportWrite(value, super._redrawTriggerSelectedElements, () {
      super._redrawTriggerSelectedElements = value;
    });
  }

  late final _$_redrawTriggerNonSelectedElementsAtom = Atom(
      name: 'TH2FileEditStoreBase._redrawTriggerNonSelectedElements',
      context: context);

  int get redrawTriggerNonSelectedElements {
    _$_redrawTriggerNonSelectedElementsAtom.reportRead();
    return super._redrawTriggerNonSelectedElements;
  }

  @override
  int get _redrawTriggerNonSelectedElements => redrawTriggerNonSelectedElements;

  @override
  set _redrawTriggerNonSelectedElements(int value) {
    _$_redrawTriggerNonSelectedElementsAtom
        .reportWrite(value, super._redrawTriggerNonSelectedElements, () {
      super._redrawTriggerNonSelectedElements = value;
    });
  }

  late final _$TH2FileEditStoreBaseActionController =
      ActionController(name: 'TH2FileEditStoreBase', context: context);

  @override
  void setZoomButtonsHovered(bool isHovered) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.setZoomButtonsHovered');
    try {
      return super.setZoomButtonsHovered(isHovered);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectionWindowCanvasCoordinates(
      {required Offset point1, required Offset point2}) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.setSelectionWindowCanvasCoordinates');
    try {
      return super
          .setSelectionWindowCanvasCoordinates(point1: point1, point2: point2);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectionWindow() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.clearSelectionWindow');
    try {
      return super.clearSelectionWindow();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedElements() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.clearSelectedElements');
    try {
      return super.clearSelectedElements();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSelectedElement(THElement element) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.addSelectedElement');
    try {
      return super.addSelectedElement(element);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Rect _getSelectedElementsBoundingBox() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase._getSelectedElementsBoundingBox');
    try {
      return super._getSelectedElementsBoundingBox();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSelectedElements(List<THElement> elements) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.addSelectedElements');
    try {
      return super.addSelectedElements(elements);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedElements(List<THElement> clickedElements) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.setSelectedElements');
    try {
      return super.setSelectedElements(clickedElements);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeSelectedElement(THElement element) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.removeSelectedElement');
    try {
      return super.removeSelectedElement(element);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setState(MPTH2FileEditStateType type) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.setState');
    try {
      return super.setState(type);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateScreenSize(Size newSize) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase._updateScreenSize');
    try {
      return super._updateScreenSize(newSize);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVisualMode(TH2FileEditMode visualMode) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.setVisualMode');
    try {
      return super.setVisualMode(visualMode);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onPanUpdatePanMode(DragUpdateDetails details) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.onPanUpdatePanMode');
    try {
      return super.onPanUpdatePanMode(details);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic triggerAllElementsRedraw() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.triggerAllElementsRedraw');
    try {
      return super.triggerAllElementsRedraw();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic triggerSelectedElementsRedraw() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.triggerSelectedElementsRedraw');
    try {
      return super.triggerSelectedElementsRedraw();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic triggerNonSelectedElementsRedraw() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.triggerNonSelectedElementsRedraw');
    try {
      return super.triggerNonSelectedElementsRedraw();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic triggerSelectedListChanged() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.triggerSelectedListChanged');
    try {
      return super.triggerSelectedListChanged();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateCanvasScale(double newScale) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase._updateCanvasScale');
    try {
      return super._updateCanvasScale(newScale);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCanvasOffsetDrawing(Offset newOffset) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.updateCanvasOffsetDrawing');
    try {
      return super.updateCanvasOffsetDrawing(newOffset);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomIn() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.zoomIn');
    try {
      return super.zoomIn();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomOut() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.zoomOut');
    try {
      return super.zoomOut();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void zoomAll() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.zoomAll');
    try {
      return super.zoomAll();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateUndoRedoStatus() {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase._updateUndoRedoStatus');
    try {
      return super._updateUndoRedoStatus();
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElement(THElement element) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.addElement');
    try {
      return super.addElement(element);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addElementWithParentWithoutSelectableElement(
      THElement element, THIsParentMixin parent) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name:
            'TH2FileEditStoreBase.addElementWithParentWithoutSelectableElement');
    try {
      return super
          .addElementWithParentWithoutSelectableElement(element, parent);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElement(THElement element) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.deleteElement');
    try {
      return super.deleteElement(element);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByMapiahID(int mapiahID) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.deleteElementByMapiahID');
    try {
      return super.deleteElementByMapiahID(mapiahID);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteElementByTHID(String thID) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.deleteElementByTHID');
    try {
      return super.deleteElementByTHID(thID);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void registerElementWithTHID(THElement element, String thID) {
    final _$actionInfo = _$TH2FileEditStoreBaseActionController.startAction(
        name: 'TH2FileEditStoreBase.registerElementWithTHID');
    try {
      return super.registerElementWithTHID(element, thID);
    } finally {
      _$TH2FileEditStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isEditMode: ${isEditMode},
isPanMode: ${isPanMode},
isSelectMode: ${isSelectMode},
lineThicknessOnCanvas: ${lineThicknessOnCanvas},
pointRadiusOnCanvas: ${pointRadiusOnCanvas},
selectionToleranceSquaredOnCanvas: ${selectionToleranceSquaredOnCanvas},
showSelectedElements: ${showSelectedElements},
showSelectionHandles: ${showSelectionHandles},
showSelectionWindow: ${showSelectionWindow},
selectionWindowBorderPaintComplete: ${selectionWindowBorderPaintComplete},
selectionWindowBorderPaintDashIntervalOnCanvas: ${selectionWindowBorderPaintDashIntervalOnCanvas},
selectionHandleSizeOnCanvas: ${selectionHandleSizeOnCanvas},
selectionHandleDistanceOnCanvas: ${selectionHandleDistanceOnCanvas},
selectionHandleLineThicknessOnCanvas: ${selectionHandleLineThicknessOnCanvas},
selectionHandlePaint: ${selectionHandlePaint}
    ''';
  }
}
