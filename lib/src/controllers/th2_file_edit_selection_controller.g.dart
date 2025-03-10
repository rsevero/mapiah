// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_edit_selection_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FileEditSelectionController
    on TH2FileEditSelectionControllerBase, Store {
  late final _$_thFileAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._thFile', context: context);

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom.reportWrite(value, super._thFile, () {
      super._thFile = value;
    });
  }

  late final _$_th2FileEditControllerAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._th2FileEditController',
      context: context);

  TH2FileEditController get th2FileEditController {
    _$_th2FileEditControllerAtom.reportRead();
    return super._th2FileEditController;
  }

  @override
  TH2FileEditController get _th2FileEditController => th2FileEditController;

  @override
  set _th2FileEditController(TH2FileEditController value) {
    _$_th2FileEditControllerAtom
        .reportWrite(value, super._th2FileEditController, () {
      super._th2FileEditController = value;
    });
  }

  late final _$_isSelectedAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._isSelected', context: context);

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

  late final _$_selectedElementsAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._selectedElements',
      context: context);

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

  late final _$_selectedControlPointAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._selectedControlPoint',
      context: context);

  MPSelectableControlPoint? get selectedControlPoint {
    _$_selectedControlPointAtom.reportRead();
    return super._selectedControlPoint;
  }

  @override
  MPSelectableControlPoint? get _selectedControlPoint => selectedControlPoint;

  @override
  set _selectedControlPoint(MPSelectableControlPoint? value) {
    _$_selectedControlPointAtom.reportWrite(value, super._selectedControlPoint,
        () {
      super._selectedControlPoint = value;
    });
  }

  late final _$_selectedLineSegmentsAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._selectedLineSegments',
      context: context);

  LinkedHashMap<int, THLineSegment> get selectedLineSegments {
    _$_selectedLineSegmentsAtom.reportRead();
    return super._selectedLineSegments;
  }

  @override
  LinkedHashMap<int, THLineSegment> get _selectedLineSegments =>
      selectedLineSegments;

  @override
  set _selectedLineSegments(LinkedHashMap<int, THLineSegment> value) {
    _$_selectedLineSegmentsAtom.reportWrite(value, super._selectedLineSegments,
        () {
      super._selectedLineSegments = value;
    });
  }

  late final _$_selectableEndControlPointsAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._selectableEndControlPoints',
      context: context);

  Set<MPSelectableEndControlPoint> get selectableEndControlPoints {
    _$_selectableEndControlPointsAtom.reportRead();
    return super._selectableEndControlPoints;
  }

  @override
  Set<MPSelectableEndControlPoint> get _selectableEndControlPoints =>
      selectableEndControlPoints;

  @override
  set _selectableEndControlPoints(Set<MPSelectableEndControlPoint> value) {
    _$_selectableEndControlPointsAtom
        .reportWrite(value, super._selectableEndControlPoints, () {
      super._selectableEndControlPoints = value;
    });
  }

  late final _$_selectionWindowCanvasCoordinatesAtom = Atom(
      name:
          'TH2FileEditSelectionControllerBase._selectionWindowCanvasCoordinates',
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

  late final _$_selectableElementsAtom = Atom(
      name: 'TH2FileEditSelectionControllerBase._selectableElements',
      context: context);

  ObservableMap<int, MPSelectable> get selectableElements {
    _$_selectableElementsAtom.reportRead();
    return super._selectableElements;
  }

  @override
  ObservableMap<int, MPSelectable> get _selectableElements =>
      selectableElements;

  @override
  set _selectableElements(ObservableMap<int, MPSelectable> value) {
    _$_selectableElementsAtom.reportWrite(value, super._selectableElements, () {
      super._selectableElements = value;
    });
  }

  late final _$TH2FileEditSelectionControllerBaseActionController =
      ActionController(
          name: 'TH2FileEditSelectionControllerBase', context: context);

  @override
  Rect getSelectedElementsBoundingBox() {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name:
                'TH2FileEditSelectionControllerBase.getSelectedElementsBoundingBox');
    try {
      return super.getSelectedElementsBoundingBox();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deleteSelected() {
    final _$actionInfo = _$TH2FileEditSelectionControllerBaseActionController
        .startAction(name: 'TH2FileEditSelectionControllerBase.deleteSelected');
    try {
      return super.deleteSelected();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  bool addSelectedElement(THElement element, {bool setState = false}) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.addSelectedElement');
    try {
      return super.addSelectedElement(element, setState: setState);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  bool addSelectedElements(List<THElement> elements, {bool setState = false}) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.addSelectedElements');
    try {
      return super.addSelectedElements(elements, setState: setState);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void deselectAllElements() {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.deselectAllElements');
    try {
      return super.deselectAllElements();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void selectAllElements() {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.selectAllElements');
    try {
      return super.selectAllElements();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  bool setSelectedElements(List<THElement> clickedElements,
      {bool setState = false}) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.setSelectedElements');
    try {
      return super.setSelectedElements(clickedElements, setState: setState);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  bool removeSelectedElement(THElement element) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.removeSelectedElement');
    try {
      return super.removeSelectedElement(element);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void moveSelectedElementsToCanvasCoordinates(
      Offset canvasCoordinatesFinalPosition) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name:
                'TH2FileEditSelectionControllerBase.moveSelectedElementsToCanvasCoordinates');
    try {
      return super.moveSelectedElementsToCanvasCoordinates(
          canvasCoordinatesFinalPosition);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void moveSelectedEndControlPointsToCanvasCoordinates(
      Offset canvasCoordinatesFinalPosition) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name:
                'TH2FileEditSelectionControllerBase.moveSelectedEndControlPointsToCanvasCoordinates');
    try {
      return super.moveSelectedEndControlPointsToCanvasCoordinates(
          canvasCoordinatesFinalPosition);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void moveSelectedControlPointToCanvasCoordinates(
      Offset canvasCoordinatesFinalPosition) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name:
                'TH2FileEditSelectionControllerBase.moveSelectedControlPointToCanvasCoordinates');
    try {
      return super.moveSelectedControlPointToCanvasCoordinates(
          canvasCoordinatesFinalPosition);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void setSelectionWindowCanvasCoordinates(
      {required Offset point1, required Offset point2}) {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name:
                'TH2FileEditSelectionControllerBase.setSelectionWindowCanvasCoordinates');
    try {
      return super
          .setSelectionWindowCanvasCoordinates(point1: point1, point2: point2);
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectionWindow() {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.clearSelectionWindow');
    try {
      return super.clearSelectionWindow();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  void clearSelectedElements() {
    final _$actionInfo =
        _$TH2FileEditSelectionControllerBaseActionController.startAction(
            name: 'TH2FileEditSelectionControllerBase.clearSelectedElements');
    try {
      return super.clearSelectedElements();
    } finally {
      _$TH2FileEditSelectionControllerBaseActionController
          .endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
